# xpkg 生态系统修复与完善 — 执行报告

## 1. 概述

本次工作对 xpkg 生态系统进行了全面修复，涉及三个仓库：

| 仓库 | 工作内容 | 提交 |
|------|---------|------|
| **xim-pkgindex** | 包级 bug 修复 + 深度迁移 + V1 spec 更新 | `8d1df08`, `654f987`, `c4b0d35` |
| **libxpkg** | 运行时模块增强（pkgmanager/elfpatch/json/base64） | `610d037`, `65e24d0` |
| **xlings** | xvm libdir 版本切换 | `1fe7081` |

共修改 **14 个包文件** + **4 个新 libxpkg 模块** + **V1 spec 文档**，合计约 **180 行改动**（xim-pkgindex）。

---

## 2. 分阶段执行记录

### Phase A: xim-pkgindex 包级修复（commit `8d1df08`）

#### A1: P0 运行时 Bug 修复

| 文件 | 问题 | 修复 |
|------|------|------|
| `pkgs/n/nodejs.lua:90` | `not os.host() == "windows"` 运算符优先级错误 | → `os.host() ~= "windows"` |
| `pkgs/n/nodejs.lua:79,110` | `print("fmt %s", arg)` 格式化无效 | → `print("fmt " .. arg)` |
| `pkgs/c/code.lua:184,192` | 同上 | 同上 |
| `pkgs/p/project-graph.lua:153` | 同上 | → `print(string.format(...))` |

#### A2: P1 风格统一 + P2 清理

| 文件 | 修复 |
|------|------|
| `pkgs/o/openclaw.lua:72` | `is_host("windows")` → `os.host() == "windows"` |
| `pkgs/c/codex.lua:72` | 同上 |
| `pkgs/r/rust.lua` | 删除无用 `import("xim.xinstall")` |

#### A3: xvm API 规范化

| 文件 | 修复 |
|------|------|
| `pkgs/p/python.lua` | 删除 `import("common")`, `import("xim.base.utils")`；`os.execute("xvm add/remove ...")` → `xvm.add()/xvm.remove()`；`utils.prompt()` → `print()+io.read()` |
| `pkgs/n/nvm.lua` | 删除 `import("xim.base.utils")`；`utils.append_bashrc()` → 标准 `io.open/write` 实现；新增 `config()` 函数注册 xvm |

---

### Phase B: libxpkg 运行时增强（commits `610d037`, `65e24d0`）

在 `/home/speak/workspace/github/mcpplibs/libxpkg` 中完成。

| 模块 | 文件 | API | 行数 |
|------|------|-----|------|
| **pkgmanager** | `xim/libxpkg/pkgmanager.lua` | `install(target)`, `remove(target)`, `uninstall(target)` | ~20 |
| **elfpatch** | `xim/libxpkg/elfpatch.lua` | `auto()`, `is_auto()`, `apply_auto()`, `patch_elf_loader_rpath()`, `closure_lib_paths()` | ~220 |
| **json** | `xim/libxpkg/json.lua` | `decode()`, `encode()`, `loadfile()`, `savefile()` | ~260 |
| **base64** | `xim/libxpkg/base64.lua` | `encode()`, `decode()` | ~60 |

其他改动：
- `prelude.lua`：未知模块 import 打印 WARNING（原先静默返回 stub）
- `xpkg-executor.cppm`：注册 4 个新模块到 `load_stdlib()`
- `xmake.lua`：添加 4 个 `embed()` 调用

---

### Phase C: xim-pkgindex 深度迁移（commit `654f987`）

| 文件 | 迁移内容 |
|------|---------|
| `pkgs/m/msvc.lua` | `import("common")` + `import("core.tool.toolchain")` → `os.execute()` + `os.isdir()` |
| `pkgs/c/cpp.lua` | `import("core.tool.toolchain")` → `os.isdir()` |
| `pkgs/s/sing-box-helper.lua` | `core.base.{json,base64,bytes}` → `xim.libxpkg.{json,base64}`；`base64.decode(x):str()` → `base64.decode(x)` |
| `pkgs/g/github-notifications-clear.lua` | `core.base.json` → `xim.libxpkg.json`；删除 `lib.detect.find_tool` |
| `pkgs/g/git-autosync.lua` | `core.base.json` → `xim.libxpkg.json` |

---

### Phase D: xlings 集成完善（commits `1fe7081`, `c4b0d35`）

| 子任务 | 内容 |
|--------|------|
| D1: installer 增强 | 确认 `create_executor()` 自动加载新模块（无需额外改动） |
| D2: libdir 版本切换 | `core/xvm/commands.cppm` 新增 `install_libdir()`/`remove_libdir()`，`cmd_use()` 处理 libdir |
| D3: V1 Spec 更新 | `xpackage-spec.md` 添加 pkgmanager/elfpatch/json/base64 模块文档 |

---

## 3. 本地端到端验证

### 3.1 测试环境

- 二进制：`xlings/build/linux/x86_64/release/xlings`（v0.4.0，含全部改动）
- 索引：项目级 `.xlings.json` + symlink 指向本地 `xim-pkgindex`

### 3.2 包安装/卸载测试

| 包 | 类型 | 安装 | 卸载 | 备注 |
|----|------|------|------|------|
| git-autosync | script | OK | FAIL | 卸载需 sudo 删 cron 文件，非代码问题 |
| github-notifications-clear | script | OK | OK | |
| sing-box-helper | script | OK | OK | |
| nvm | config | OK | OK | install.sh 输出噪音为预存在行为 |
| node@22.14.0 | package | OK(注册) | OK | install dir 为空是 `os.tryrm` 预存在 bug |
| project-graph | package | N/A | N/A | 依赖 webkit2gtk 不在索引中 |
| code/openclaw/codex | package | N/A | N/A | 需 GUI 或 npm 依赖，无法无头测试 |
| rust/cpp | package | N/A | N/A | 需依赖链（rustup/gcc） |
| msvc | package | N/A | N/A | Windows 专用 |

### 3.3 自动化测试

```
pytest tests/ -m static   → 241 passed
pytest tests/ -m isolation → 230 passed
─────────────────────────────────────────
总计                         471 passed, 0 failed
```

### 3.4 全局扫描

```
grep 'import.*"core\.' pkgs/        → 0 matches (清零)
grep 'import.*"lib\.'  pkgs/        → 0 matches (清零)
grep 'import.*"common"' pkgs/       → 0 matches (清零)
grep 'import.*"xim\.base\.' pkgs/   → 0 matches (清零)
grep 'import.*"xim\.xinstall"' pkgs/→ 0 matches (清零)
grep 'is_host(' pkgs/               → 0 matches (清零)
```

---

## 4. 发现的预存在问题

以下问题在本次工作中被发现，但属于预先存在的 bug，不在本次修复范围内：

| 问题 | 位置 | 说明 |
|------|------|------|
| node install dir 为空 | `nodejs.lua:78` | `os.tryrm(pkginfo.install_dir())` 删除了下载解压目录，随后 `os.mv()` 无源可移 |
| npm/npx 卸载残留 | `nodejs.lua:113-114` | `pkginfo.version()` 在 uninstall 上下文返回空，导致 `xvm.remove("npm", "node-")` 不匹配 |
| git-autosync 卸载需 sudo | `git-autosync.lua:32` | `sudo rm -f /etc/cron.d/...` 在非交互环境失败 |

---

## 5. 改动文件清单

### xim-pkgindex（本仓库）

```
 docs/V1/xpackage-spec.md               | +48 -1
 pkgs/c/code.lua                        | +2 -2
 pkgs/c/codex.lua                       | +1 -1
 pkgs/c/cpp.lua                         | +3 -2
 pkgs/g/git-autosync.lua                | +1 -1
 pkgs/g/github-notifications-clear.lua  | +5 -10
 pkgs/m/msvc.lua                        | +5 -8
 pkgs/n/nodejs.lua                      | +3 -3
 pkgs/n/nvm.lua                         | +41 -5
 pkgs/o/openclaw.lua                    | +1 -1
 pkgs/p/project-graph.lua               | +1 -1
 pkgs/p/python.lua                      | +14 -14
 pkgs/r/rust.lua                        | -1
 pkgs/s/sing-box-helper.lua             | +4 -4
 14 files changed, +121 -61
```

### libxpkg

```
 src/lua-stdlib/prelude.lua                    | +1 (import warning)
 src/lua-stdlib/xim/libxpkg/pkgmanager.lua     | +20 (新文件)
 src/lua-stdlib/xim/libxpkg/elfpatch.lua       | +220 (新文件)
 src/lua-stdlib/xim/libxpkg/json.lua           | +260 (新文件)
 src/lua-stdlib/xim/libxpkg/base64.lua         | +60 (新文件)
 src/xpkg-executor.cppm                        | +4 (注册新模块)
 xmake.lua                                     | +4 (embed 调用)
```

### xlings

```
 core/xvm/commands.cppm                        | +40 (libdir 切换)
```
