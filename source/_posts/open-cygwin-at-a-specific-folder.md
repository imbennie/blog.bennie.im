---
title:  Windows上Cygwin安装文件夹右键菜单实现任意目录打开 
date: 2021-11-25 10:12:56
tags:
	- Windows
	- Cygwin 
categories:
    - Tools 
---
实现效果：任意菜单右键后，弹出菜单项，点击后shell自动进入当前目录路径。

参考链接：https://stackoverflow.com/questions/9637601/open-cygwin-at-a-specific-folder#

高赞回答大意：安装Cygwin时，选择安装`chere`包，然后以管理员身份运行Cygwin终端，输入命令`chere -i -t mintty -s bash`，然后便可在右键菜单中看到"Bash Prompt Here"选项。
如果之前没有安装chere包，那么重新运行Cygwin的安装文件`setup-x86_64.exe`，搜索`chere`包安装即可。

<!-- more -->

备注：
- 再次安装时原有的包可以选择keep，这样便不会更新已安装包。
- 若安装zsh，执行`chere -i -t mintty -s zsh`可令zsh作为默认shell。
- 使用`-u`参数卸载：`chere -u -t mintty -s bash`。

chere包的安装帮助：https://stackoverflow.com/questions/18473600/i-need-help-to-install-the-chere-package

效果图：
![](/images/1223378-20211125100250094-68857032.png)

通过Windows Terminal集成cygwin的zsh配置
![](/images/20211129103841.png)

其他方案（未做测试）
https://github.com/olegcherr/Cygwin-Bash-Here

