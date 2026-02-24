# XPackage Spec V1

> `spec = "1"`

## Package 域

### 基础字段

```lua
package = {
    spec = "1",  -- 规范版本号 (必填)

    -- 基础信息
    name = "package-name",          -- 包名 (必填)
    description = "描述信息",        -- 包描述 (必填)
    type = "package",               -- 包类型 (必填): "package" | "script" | "template" | "config"

    homepage = "https://example.com",
    repo = "https://example.com/repo",
    docs = "https://example.com/docs",
    forum = "https://forum.example.com",

    authors = {"Author1", "Author2"},
    maintainers = {"Maintainer1"},
    contributors = "https://github.com/xxx/graphs/contributors",
    licenses = {"MIT"},

    -- xim 包信息
    archs = {"x86_64", "arm64"},           -- 支持的架构
    status = "stable",                      -- 状态: "dev" | "stable" | "deprecated"
    categories = {"category1", "category2"},
    keywords = {"keyword1", "keyword2"},

    -- 可执行程序列表
    programs = {"program1", "program2"},

    -- xvm (xlings版本管理) 集成
    xvm_enable = true,

    -- 平台资源配置
    xpm = { ... },
}
```

### 引用包 (Ref Package)

可以通过 `ref` 字段创建包别名, 指向另一个已有的包:

```lua
package = { spec = "1", type = "package", ref = "nodejs" }
```

### xpm 字段详解

`xpm` 描述包在各平台下的依赖和资源。**没有描述的平台/系统和版本不会添加到本地索引数据库中, 即不可查询和安装。**

```lua
xpm = {
    -- 平台key: windows, linux, macosx, ubuntu, archlinux, manjaro, ...
    linux = {
        deps = {"dep1", "dep2@1.0.0"},    -- 可选: 平台依赖
        ["latest"] = { ref = "1.0.0" },   -- 版本引用: latest -> 1.0.0
        ["1.0.0"] = {                      -- 完整URL格式
            url = "https://example.com/pkg-1.0.0.tar.gz",
            sha256 = "abc123..."           -- 可选: sha256 校验
        },
        ["0.9.0"] = "XLINGS_RES",         -- 自动生成URL (从xlings镜像)
    },
    macosx = {
        ["latest"] = { ref = "1.0.0" },
        ["1.0.0"] = "XLINGS_RES",
    },
    ubuntu = { ref = "linux" },            -- 平台引用: 继承linux的配置
}
```

**版本值的三种格式:**

| 格式 | 说明 | 示例 |
|------|------|------|
| `{ url = "...", sha256 = "..." }` | 完整URL + 可选校验 | `["1.0.0"] = { url = "https://...", sha256 = nil }` |
| `"XLINGS_RES"` | 自动从xlings镜像生成URL | `["1.0.0"] = "XLINGS_RES"` |
| `{ ref = "x.x.x" }` | 引用另一个版本 | `["latest"] = { ref = "1.0.0" }` |
| `{ }` | 空资源 (用于script/config等无需下载的包) | `["0.0.1"] = { }` |

## Hooks 域

Hooks 是安装/卸载时实际执行的 Lua 函数。通过 `import` 导入辅助模块:

```lua
import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.system")
import("xim.libxpkg.log")
import("xim.libxpkg.utils")
```

### Hook 执行流程

1. `installed()` - 检测是否已安装
2. download - 自动下载资源 (框架处理)
3. deps - 处理依赖 (框架处理)
4. `build()` - 构建 (可选)
5. `install()` - 安装
6. `config()` - 配置
7. `uninstall()` - 卸载

### Hook 函数说明

**installed()** - 检测包是否已安装

```lua
function installed()
    -- 返回 boolean 或 包含版本号的字符串
    return os.iorun("program --version")
end
```

**install()** - 安装包

```lua
function install()
    -- pkginfo.install_file() 下载的文件路径 (压缩包已自动解压)
    -- pkginfo.install_dir()  安装目标目录
    os.mv("program", pkginfo.install_dir())
    return true
end
```

**config()** - 配置包 (通常注册到xvm)

```lua
function config()
    xvm.add("program-name")
    -- 或指定 bindir:
    -- xvm.add("program-name", { bindir = path.join(pkginfo.install_dir(), "bin") })
    return true
end
```

**uninstall()** - 卸载包

```lua
function uninstall()
    xvm.remove("program-name")
    return true
end
```

**build()** - 构建包 (可选)

```lua
function build()
    os.exec("make -j$(nproc)")
    return true
end
```

### 辅助模块 API

**pkginfo** (`xim.libxpkg.pkginfo`)

| 方法 | 说明 |
|------|------|
| `pkginfo.name()` | 包名 |
| `pkginfo.version()` | 当前安装的版本 |
| `pkginfo.install_file()` | 下载的文件路径 |
| `pkginfo.install_dir()` | 安装目录 |
| `pkginfo.dep_install_dir(dep_name, dep_version)` | 依赖的安装目录 |

**xvm** (`xim.libxpkg.xvm`)

| 方法 | 说明 |
|------|------|
| `xvm.add(name)` | 注册到xvm (自动检测bindir) |
| `xvm.add(name, { bindir = "..." })` | 注册到xvm (指定bindir) |
| `xvm.remove(name)` | 从xvm移除当前版本 |
| `xvm.remove(name, version)` | 从xvm移除指定版本 |

**system** (`xim.libxpkg.system`)

| 方法 | 说明 |
|------|------|
| `system.exec(cmd, opt)` | 执行命令 (支持重试) |
| `system.subos_sysrootdir()` | 获取sysroot目录 |
| `system.unix_api().append_to_shell_profile(config)` | 配置shell profile |
| `system.rundir()` | 获取运行目录 |

**log** (`xim.libxpkg.log`)

| 方法 | 说明 |
|------|------|
| `log.info(msg, ...)` | 信息日志 |
| `log.warn(msg, ...)` | 警告日志 |
| `log.error(msg, ...)` | 错误日志 |

## 包类型说明

### package 类型

标准包, 用于安装可执行程序或库。通常需要 `install`, `config`, `uninstall` 函数。

### script 类型

脚本包, 通过 `xscript` 命令调用。入口函数为 `xpkg_main(...)`:

```lua
package = {
    spec = "1",
    name = "my-script",
    type = "script",
    -- ...
    xpm = {
        linux = { ["0.0.1"] = { } },
    },
}

import("xim.libxpkg.utils")

local __xscript_input = {
    ["--option1"] = false,
    ["--option2"] = false,
}

function xpkg_main(action, ...)
    local _, cmds = utils.input_args_process(__xscript_input, { ... })
    -- 脚本逻辑...
end
```

### config 类型

配置包, 用于系统配置操作, 无需下载资源文件。

## 完整示例

### 示例1: 标准包 (mdbook)

```lua
package = {
    spec = "1",
    -- base info
    name = "mdbook",
    description = "Create book from markdown files. Like Gitbook but implemented in Rust",

    authors = {"Mathieu David", "Michael-F-Bryan", "Matt Ickstadt"},
    contributors = "https://github.com/rust-lang/mdBook/graphs/contributors",
    licenses = {"MPL-2.0"},
    repo = "https://github.com/rust-lang/mdBook",
    docs = "https://rust-lang.github.io/mdBook",

    -- xim pkg info
    type = "package",
    archs = {"x86_64"},
    status = "stable",
    categories = {"book", "markdown"},
    keywords = {"book", "gitbook", "rustbook", "markdown"},

    xvm_enable = true,

    xpm = {
        windows = {
            ["latest"] = { ref = "0.4.40" },
            ["0.4.43"] = {
                url = "https://github.com/rust-lang/mdBook/releases/download/v0.4.43/mdbook-v0.4.43-x86_64-pc-windows-msvc.zip",
                sha256 = nil
            },
            ["0.4.40"] = {
                url = "https://gitee.com/sunrisepeak/xlings-pkg/releases/download/mdbook/mdbook-v0.4.40-x86_64-pc-windows-msvc.zip",
                sha256 = nil
            },
        },
        linux = {
            ["latest"] = { ref = "0.4.43" },
            ["0.4.43"] = "XLINGS_RES",
            ["0.4.40"] = {
                url = "https://github.com/rust-lang/mdBook/releases/download/v0.4.40/mdbook-v0.4.40-x86_64-unknown-linux-gnu.tar.gz",
                sha256 = "9ef07fd288ba58ff3b99d1c94e6d414d431c9a61fdb20348e5beb74b823d546b"
            },
        },
        macosx = {
            ["latest"] = { ref = "0.4.43" },
            ["0.4.43"] = "XLINGS_RES",
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

local mdbook_file = {
    windows = "mdbook.exe",
    linux = "mdbook",
    macosx = "mdbook"
}

function install()
    return os.trymv(mdbook_file[os.host()], pkginfo.install_dir())
end

function config()
    xvm.add("mdbook")
    return true
end

function uninstall()
    xvm.remove("mdbook")
    return true
end
```

### 示例2: 带依赖的包 (gcc)

```lua
package = {
    spec = "1",
    name = "gcc",
    description = "GCC, the GNU Compiler Collection",
    type = "package",

    authors = {"GNU"},
    licenses = {"GPL"},
    repo = "https://github.com/gcc-mirror/gcc",

    archs = { "x86_64" },
    status = "stable",
    categories = { "compiler", "gnu", "language" },
    keywords = { "compiler", "gnu", "gcc", "language", "c", "c++" },

    programs = {
        "gcc", "g++", "c++", "cpp",
        "gcc-ar", "gcc-nm", "gcc-ranlib",
    },

    xvm_enable = true,

    xpm = {
        linux = {
            deps = { "glibc@2.39", "binutils@2.42", "linux-headers@5.11.1" },
            ["latest"] = { ref = "15.1.0" },
            ["15.1.0"] = "XLINGS_RES",
            ["13.3.0"] = "XLINGS_RES",
        },
    },
}
```

### 示例3: 引用包 (node -> nodejs)

```lua
package = { spec = "1", type = "package", ref = "nodejs" }
```

### 示例4: 脚本包 (script)

```lua
package = {
    spec = "1",
    name = "my-tool",
    description = "XScript: My Tool",
    type = "script",

    authors = {"author"},
    licenses = {"Apache-2.0"},

    status = "stable",
    categories = {"tools"},

    xpm = {
        linux = { ["0.0.1"] = { } },
    },
}

import("xim.libxpkg.log")
import("xim.libxpkg.utils")

local __xscript_input = {
    ["--flag1"] = false,
    ["--flag2"] = false,
}

function xpkg_main(action, ...)
    local _, cmds = utils.input_args_process(__xscript_input, { ... })
    -- 脚本逻辑
    log.info("Running my-tool with action: %s", action)
end

function uninstall()
    log.info("Uninstalling my-tool...")
    return true
end
```
