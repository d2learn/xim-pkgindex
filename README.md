# XIM Package Index Repository | [xlings](https://github.com/d2learn/xlings)

software, library, environment install/config ...

---

## 最近动态

- 增加Project-Graph图/节点绘制工具 - [文章1](http://forum.d2learn.org/post/209) / [文章2](http://forum.d2learn.org/post/210) - 2024/12/30
- xpkg增加自动匹配github上release的url功能 - [文章](http://forum.d2learn.org/post/208) - 2024/12/30
- 从xlings中分离包文件, 形成[xim-pkgindex](https://github.com/d2learn/xim-pkgindex)索引仓库 - 2024/12/16
- 更多动态和讨论 -> [More](https://forum.d2learn.org/category/9/xlings)

[![Star History Chart](https://api.star-history.com/svg?repos=d2learn/xlings,d2learn/xim-pkgindex&type=Date)](https://star-history.com/#d2learn/xlings&d2learn/xim-pkgindex&Date)

## 如何添加一个XPackage包文件到索引仓库?

- 第一步: 创建个[Add XPackage](https://github.com/d2learn/xim-pkgindex/issues/new/choose) & 填写基础信息
- 第二步: 复制一份[包模板文件](docs/xpackage-template.lua)
- 第三步: 修改文件名和包内容 (可以参考仓库中的包或[xpackage规范示例](docs/xpackage-spec.md))
- 第四步: 对包内容进行测试
  - 添加包到索引数据库: `xim --add-xpkg yourLocalPath/filename.lua`
  - 搜索测试: `xim -s filename`
  - 安装测试: `xim -i filename`
  - 已经安装测试: `xim -i filename` (会显示包已安装)
  - 安装列表测试: `xim -l filename`
  - 卸载测试: `xim -r filename`
  - 已卸载测试: `xim -r filename` (会显示包没有安装)
- 第五步: 当第四步通过后, 把测试信息补充到第一步中创建的问题里
- 第六步: [fork项目](https://github.com/d2learn/xim-pkgindex), 并把包文件放到`pkgs`目录下的对应位置
- 第七步: 发起合入Pull-Request, 把PR地址补充到问题里并在评论区@项目维护人员
- 第八步: TODO (reviewer本地验证&approval)

[详细文档](docs/add-xpackage.md)

## 参与项目贡献

- 1.包的多平台适配和验证
- 2.添加工具/软件/配置的包文件到仓库
- 3.编写文档或制作视频教程等方式,帮助新手用户快速上手
- 4.帮助社区中遇到问题的用户及相关issues的处理
- 5.以及其他关于项目提升优化和社区中的相关活动...

## 社区&交流

- [论坛](https://forum.d2learn.org/category/9/xlings)
- 交流群(Q): 1006282943