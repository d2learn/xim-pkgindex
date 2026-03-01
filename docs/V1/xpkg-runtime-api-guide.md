# xpkg 运行时 API 指南

> 本文档记录 xpkg V1 包脚本从 xmake 兼容 API 迁移到标准 Lua + libxpkg API 的指南，以及未来运行时扩展建议。

## 1. 迁移背景

xpkg 包脚本最初在 xmake 环境下开发，使用了大量 xmake 特有的 `os.*` 扩展 API。随着 libxpkg 作为独立运行时的推进，包脚本需要仅依赖**标准 Lua 5.4 + libxpkg prelude + libxpkg 模块**。

## 2. API 迁移对照表

### 2.1 直接替换

| xmake API | 替代方案 | 说明 |
|-----------|---------|------|
| `os.exec(cmd)` | `os.execute(cmd)` | 标准 Lua |
| `os.exec(fmt, ...)` | `os.execute(string.format(fmt, ...))` | xmake 的 os.exec 支持 format 参数 |
| `os.rm(path)` | `os.tryrm(path)` | libxpkg prelude |
| `os.rmdir(path)` | `os.tryrm(path)` | libxpkg prelude |
| `os.raise(msg)` | `error(msg)` | 标准 Lua |
| `os.exists(path)` | `os.isfile(path) or os.isdir(path)` | libxpkg prelude |
| `os.tmpdir()` | `os.getenv("TMPDIR") or os.getenv("TMP") or "/tmp"` | 标准 Lua |
| `format(...)` | `string.format(...)` | 标准 Lua |
| `is_host("linux")` | `os.host() == "linux"` | libxpkg prelude |

### 2.2 需要辅助函数

#### os.iorun(cmd) — 执行命令并捕获输出

**使用频率：** 高（41 处调用，23 个包）

```lua
-- 在包文件顶部定义（import 之后）
local function iorun(cmd)
    local f = io.popen(cmd)
    if not f then return "" end
    local output = f:read("*a")
    f:close()
    return output or ""
end

-- 使用
local version = iorun("gcc --version")
```

#### os.files(pattern) — 列出匹配文件

**使用频率：** 低（4 处调用，3 个包）

```lua
local function list_files(pattern)
    local result = {}
    local f = io.popen('ls -d ' .. pattern .. ' 2>/dev/null')
    if f then
        for line in f:lines() do
            local clean = line:gsub("[\r\n]+$", "")
            if clean ~= "" and os.isfile(clean) then
                table.insert(result, clean)
            end
        end
        f:close()
    end
    return result
end
```

#### string:trim() — 去除首尾空白

```lua
-- xmake 的 :trim() 替代
local trimmed = str:match("^%s*(.-)%s*$")
```

### 2.3 需要重写逻辑

#### os.cd(dir) — 切换工作目录

**使用频率：** 中（13 处调用，7 个包）

标准 Lua 没有 chdir。根据上下文选择替代方案：

**场景 A：cd 后执行 shell 命令**
```lua
-- 旧写法
os.cd(build_dir)
os.exec("make -j$(nproc)")

-- 新写法：合并为单条命令
os.execute('cd "' .. build_dir .. '" && make -j$(nproc)')
```

**场景 B：cd 后进行文件 I/O**
```lua
-- 旧写法
os.cd(pkginfo.install_dir())
local content = io.readfile("lib/libc.so")

-- 新写法：使用绝对路径
local base = pkginfo.install_dir()
local content = io.readfile(path.join(base, "lib/libc.so"))
```

#### os.cp(src, dst, opts) — 目录复制（带选项）

**使用频率：** 中（~20 处调用）

libxpkg prelude 的 `os.cp` 仅支持单文件复制（2 参数）。目录复制需要用 shell：

```lua
-- 旧写法
os.cp(srcdir, dstdir, { force = true, symlink = true })

-- 新写法
os.execute('cp -r "' .. srcdir .. '" "' .. dstdir .. '"')
```

#### os.setenv / os.addenv — 环境变量

**使用频率：** 低（5 处调用，3 个包）

标准 Lua 无法修改当前进程的环境变量。替代方案：

```lua
-- Windows: 使用 setx 持久设置
os.execute('setx NVM_HOME "' .. nvm_home .. '"')

-- 或标记为 TODO，由 xvm/config 系统处理
-- TODO: os.setenv not available, configure via xvm
```

## 3. 运行时扩展建议

以下 API 建议未来纳入 libxpkg prelude（按优先级排序）：

### 高优先级（使用频率高，实现简单）

| API | 使用频率 | 建议原型 | 理由 |
|-----|---------|---------|------|
| `os.exec(cmd)` | 64 次 | `os.exec = os.execute` | 几乎所有包都使用，一行 alias |
| `os.iorun(cmd)` | 41 次 | 返回 stdout 字符串 | 核心模式：检测已安装版本 |
| `os.rm(path)` | 2 次 | `os.rm = os.tryrm` | 语义一致，减少迁移成本 |
| `os.exists(path)` | 1 次 | `isfile or isdir` | 常用检查，一行实现 |

### 中优先级（有一定需求，实现可行）

| API | 使用频率 | 建议原型 | 理由 |
|-----|---------|---------|------|
| `os.files(pattern)` | 4 次 | 返回文件路径数组 | 与 `os.dirs` 对称 |
| `os.cd(dir)` | 13 次 | 需 C binding (chdir) | 无法用纯 Lua 实现，但使用频率不低 |
| `string:trim()` | 5 次 | 去除首尾空白 | 配合 iorun 常用 |

### 低优先级（使用少或难以安全实现）

| API | 使用频率 | 说明 |
|-----|---------|------|
| `os.setenv(k,v)` | 3 次 | 需 C binding (setenv)，仅 Windows 包使用 |
| `os.addenv(k,v)` | 2 次 | 同上 |
| `os.tmpdir()` | 1 次 | 内联替代已足够 |
| `os.raise(msg)` | 1 次 | `error()` 完全替代 |

## 4. 迁移统计

| 指标 | 数据 |
|------|------|
| 总包数 | 61 |
| 受影响包数 | 31 (51%) |
| 不兼容 API 调用总数 | ~184 |
| 最常用不兼容 API | `os.exec` (64), `os.iorun` (41), `os.cp+opts` (20) |

## 5. 后续优化方向

1. **扩展 prelude**：将高优先级 API（`os.exec`、`os.iorun`、`os.rm`、`os.exists`）纳入 libxpkg prelude，减少每个包文件的 boilerplate
2. **os.cd 支持**：通过 C binding 在 libxpkg executor 中暴露 `chdir()`，避免包脚本需要复杂的路径重写
3. **规范化 xpkg V2**：在下一版规范中明确列出运行时 API 的完整清单，区分"核心 API"（prelude 提供）和"扩展 API"（模块提供）
4. **包脚本 lint 工具**：开发静态检查工具，检测包脚本中使用了未定义的 API
