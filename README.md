# XIM Package Index Repository | [xlings](https://github.com/d2learn/xlings)

software, library, environment install/config ...


| [Package Index](https://d2learn.github.io/xim-pkgindex) |
| --- |
| [![pkgindex test](https://github.com/d2learn/xim-pkgindex/actions/workflows/ci-test.yml/badge.svg?branch=main)](https://github.com/d2learn/xim-pkgindex/actions/workflows/ci-test.yml) - [![Deploy Static Site - xpkgindex](https://github.com/d2learn/xim-pkgindex/actions/workflows/pkgindex-deloy.yml/badge.svg)](https://github.com/d2learn/xim-pkgindex/actions/workflows/pkgindex-deloy.yml) - [![gitee-sync](https://github.com/d2learn/xim-pkgindex/actions/workflows/gitee-sync.yml/badge.svg)](https://github.com/d2learn/xim-pkgindex/actions/workflows/gitee-sync.yml) |
| **type:** package - app - config - courses - lib - plugin - script |

---

## 最近动态

- xpkgindex: 增加包索引静态网站自动生成及部署 - 2025/5/14
- xim+: 增加gcc15.1支持 - [文章](https://forum.d2learn.org/topic/84) - 2025/5/1
- 增加Project-Graph图/节点绘制工具 - [文章1](http://forum.d2learn.org/post/209) / [文章2](http://forum.d2learn.org/post/210) - 2024/12/30
- xpkg增加自动匹配github上release的url功能 - [文章](http://forum.d2learn.org/post/208) - 2024/12/30
- 从xlings中分离包文件, 形成[xim-pkgindex](https://github.com/d2learn/xim-pkgindex)索引仓库 - 2024/12/16
- 更多动态和讨论 -> [More](https://forum.d2learn.org/category/9/xlings)

[![Star History Chart](https://api.star-history.com/svg?repos=d2learn/xlings,d2learn/xim-pkgindex&type=Date)](https://star-history.com/#d2learn/xlings&d2learn/xim-pkgindex&Date)

## 基本用法

**同步最新索引**

```bash
xim --update index
```

**添加本地包文件**

> 把本地包文件添加到索引数据库, 即可通过xim进行安装管理

```bash
xim --add-xpkg yourPath/xxx.lua
```

## 如何添加一个XPackage包文件到索引仓库?

- 第0步: 复制一份[包模板文件](docs/xpackage-template.lua)
- 第1步: 修改文件名和包内容 (可以参考仓库中的包或[xpackage规范示例](docs/xpackage-spec.md))
- 第2步: 对包内容进行测试
  - 添加包到索引数据库: `xim --add-xpkg yourLocalPath/filename.lua`
  - 搜索测试: `xim -s filename`
  - 安装测试: `xim -i filename`
  - 已经安装测试: `xim -i filename` (会显示包已安装)
  - 安装列表测试: `xim -l filename`
  - 卸载测试: `xim -r filename`
  - 已卸载测试: `xim -r filename` (会显示包没有安装)
- 第3步: 创建个[Add XPackage](https://github.com/d2learn/xim-pkgindex/issues/new/choose) & 填写基础信息、测试log/截图
- 第4步: [fork项目](https://github.com/d2learn/xim-pkgindex), 并把包文件放到`pkgs`目录下的对应位置
- 第5步: 发起合入Pull-Request, 把PR地址补充到问题里并在评论区@项目维护人员
- 第6步: TODO (reviewer本地验证&approval)

[详细文档](docs/add-xpackage.md)

## 包索引仓库

| 仓库 | 命名空间 | 简介 |
| -- | -- | -- |
| [xim-pkgindex-template](https://github.com/d2learn/xim-pkgindex-template) | xim | 自建/镜像/私有包索引模板仓库 |
| [xim-pkgindex-d2x](https://github.com/d2learn/xim-pkgindex-d2x) | d2x | d2x公开课系列项目 |


## 参与项目贡献

- 1.包的多平台适配和验证
- 2.添加工具/软件/配置的包文件到仓库
- 3.编写文档或制作视频教程等方式,帮助新手用户快速上手
- 4.帮助社区中遇到问题的用户及相关issues的处理
- 5.以及其他关于项目提升优化和社区中的相关活动...

## 社区&交流

- [论坛](https://forum.d2learn.org/category/9/xlings)
- 交流群(Q): 1006282943