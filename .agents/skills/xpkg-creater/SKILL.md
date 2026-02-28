---
name: xpkg-creater
description: 在 xim-pkgindex 中创建/更新 xpkg 包（V1），遵守 xlings subos 隔离规范，补齐 tests，并在本地与测试集验证通过后再提交 PR。
---

# xpkg-creater

用于在 `xim-pkgindex` 仓库中新增或维护 xpkg 包文件，确保满足：
- XPackage Spec V1（`spec = "1"`）
- hooks 约束（尤其 `install` / `config`）
- subos 环境隔离规范
- 本地验证 + 测试集验证 + CI 要求

> 详细安装命令、测试命令清单、相关链接见：
> - `references/xlings-setup-and-links.md`
> - `references/testing-and-acceptance.md`

## 0) xlings 工具入口（必须具备）

开发/验证 xpkg 之前，先确保环境可用：
- 已安装 `xlings`（用于 `xim/xlings/xvm` 命令）
- `xlings` 命令在 shell 中可执行

安装方式与快速命令见 `references/xlings-setup-and-links.md`。

## 1) 包格式规范（基于本仓库 V1）

一个 xpkg 文件由两部分组成：
1. `package = { ... }` 元数据域
2. hooks 函数域（`installed/build/install/config/uninstall`，按需实现）

### 1.1 必填与推荐字段

至少保证：
- `spec = "1"`
- `name`
- `description`
- `type`（常见：`package/script/config/template`）
- `xpm`（平台、版本、资源映射）

常见推荐字段：
- `archs`, `status`, `categories`, `keywords`
- `authors/maintainers/licenses/repo/docs/homepage`
- `xvm_enable = true`（需要 xvm 管理时）

### 1.2 xpm 写法要点

- 按平台配置：`windows/linux/macosx/ubuntu/debian/...`
- 版本常用：
  - `{"latest" = { ref = "x.y.z" }}`
  - `{"x.y.z" = { url = "...", sha256 = "..." }}`
  - `"XLINGS_RES"`
- 平台继承：`ubuntu = { ref = "linux" }`
- script/config 类型可使用空资源：`["0.0.1"] = {}`

## 2) hooks 实现规范（核心）

### 2.1 import 规范
优先使用新版 API：
- `import("xim.libxpkg.pkginfo")`
- `import("xim.libxpkg.xvm")`
- `import("xim.libxpkg.system")`（可选）
- `import("xim.libxpkg.log")`（可选）

避免旧 API：
- `import("xim.base.runtime")`
- `import("common")`
- `import("platform")`

### 2.2 install() 约束

`install()` 只负责安装动作本身：
- 使用 `pkginfo.install_file()` 获取下载/解压后的输入路径
- 使用 `pkginfo.install_dir()` 作为目标安装目录
- 可先 `os.tryrm(pkginfo.install_dir())` 再 `os.mv(...)`
- 若是 Linux 预构建 ELF，必要时做可重定位修复（如 patchelf）

### 2.3 config() 约束

`config()` 负责将该版本注册到 xvm（subos 隔离路由）：
- 使用 `xvm.add("tool")`
- 或 `xvm.add("tool", { bindir = ..., alias = ... })`
- 可执行文件不在安装根目录时，必须明确 `bindir`

### 2.4 禁止事项（隔离合规）

- 不要 `os.exec("xvm add ...")` / `os.exec("xvm remove ...")`
- 不要修改 `.bashrc` / shell profile
- 不要直接 `os.addenv("PATH")` 或 `os.setenv("PATH")`
- 不要直接 `apt install` / `brew install` / `pacman -S`

依赖请通过 `xpm.<platform>.deps` 声明；命令路由请通过 xvm shim 完成。

## 3) 新增/修改包的标准流程

1. 在 `pkgs/<首字母>/<name>.lua` 新增或修改包。
2. 若新增包，创建镜像测试文件：
   - `tests/<首字母>/test_<name_with_underscore>.py`
3. 先跑本地直接命令验证（索引/安装/搜索/卸载）。
4. 再跑测试集验证（L0~L4，至少 L0/L1/L2）。
5. 准备 PR：写清楚包用途、安装/卸载行为、系统影响、测试结果。

详细步骤与命令见 `references/testing-and-acceptance.md`。

## 4) PR 提交硬性要求

- 本地通过直接命令验证 + pytest 测试验证。
- 新增包必须带对应 `tests/` 测试文件。
- 不破坏 subos 隔离。
- PR 描述中必须包含：
  1) 包的作用
  2) 安装时做了什么
  3) 卸载时做了什么
  4) 是否修改系统配置/环境变量
  5) 本地测试与 CI 测试结果

## 5) 最小骨架（V1）

```lua
package = {
  spec = "1",
  name = "demo",
  description = "demo package",
  type = "package",
  archs = {"x86_64"},
  status = "stable",
  categories = {"tools"},
  keywords = {"demo"},
  xvm_enable = true,
  xpm = {
    linux = {
      ["latest"] = { ref = "1.0.0" },
      ["1.0.0"] = "XLINGS_RES",
    },
  },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")

function install()
  os.tryrm(pkginfo.install_dir())
  os.mv("demo", pkginfo.install_dir())
  return true
end

function config()
  xvm.add("demo")
  return true
end

function uninstall()
  xvm.remove("demo")
  return true
end
```
