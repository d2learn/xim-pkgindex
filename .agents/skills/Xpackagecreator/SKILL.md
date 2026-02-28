---
name: xpackagecreator
description: 根据 xim-pkgindex 的 V1 文档与现有 pkgs 模式，创建/更新符合 subos 隔离规范的 XPackage（xpkg）并补充 tests，完成本地验证后再提交 PR。
---

# XPackageCreator

用于在 `xim-pkgindex` 仓库中新增或维护 xpkg 包文件，确保满足：
- XPackage Spec V1（`spec = "1"`）
- hooks 约束（尤其 `install` / `config`）
- subos（你可能也会称作 subways）环境隔离规范
- 测试与 CI 要求

## 0) XLens / xlings 工具入口（简版）

- 官方仓库：<https://github.com/d2learn/xlings>
- 本仓库 README 也直接指向 xlings 文档与社区入口。
- 使用细节（含更多 skills / 文档）优先参考 xlings 仓库 docs 与本仓库 `docs/`。

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

## 2.1 import 规范
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
3. 套用测试分层：
   - L0: static（字段/拼写/spec/type）
   - L1: index（`xim --add-xpkg`）
   - L2: isolation（subos 合规）
   - L3: lifecycle（install/remove）
   - L4: verify（命令可用、xvm 注册）
4. 本地先过 static + isolation，再跑 index；条件允许时补跑 lifecycle + verify。
5. 准备 PR：写清楚包用途、安装/卸载具体行为、潜在系统影响。

## 4) 本地测试与验收清单（提交前必须）

最低要求（必须）：
- `pytest tests/<...>.py -m "static or isolation" -v`
- `pytest tests/<...>.py -m index -v`

建议补充（强烈推荐）：
- 安装：`xim -i <pkg>` 或对应 lifecycle 测试
- 可用性：命令 `--version` / `which` / 功能 smoke test
- 检索：`xim -s <pkg>` 可检索到
- 卸载：`xim -r <pkg>` 或 lifecycle uninstall 测试
- CI 视角：确保与 GitHub Actions 的 static/isolation/index 期望一致

## 5) 贡献与 PR 说明模板

提交 PR 前必须满足：
- 本地测试通过（至少 L0/L1/L2）
- 新增包必须有对应 `tests/` 用例
- 不破坏 subos 隔离

PR 描述建议包含：
1. 这是哪个包、解决什么问题
2. 安装行为（下载/解压/拷贝/注册）
3. 卸载行为（移除 xvm 注册、清理文件）
4. 对系统的影响说明：
   - 是否仅安装到 xlings/xpkg 目录并通过 xvm shim 暴露命令
   - 是否会修改系统配置文件（通常不允许）
   - 是否包含额外后台服务/端口/权限需求
5. 本地与 CI 测试结果

## 6) 最小骨架（V1）

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
