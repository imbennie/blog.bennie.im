---
title: Eclipse配置所有工作空间默认文件编码
date: 2017-08-18 23:57:30
tags:
	- Eclipse
	- 工具
categories:
	- 工具
---

一般Eclipse创建新的工作空间时都需要手动指定一下编码，也就是File Encoding，这里分享的就是以配置文件的方式来指定所有的工作空间默认的编码。
包括新建的工作空间也会生效。

方法很简单，在Eclipse安装目录，找到`eclipse.ini`使用文本编辑器打开（建议不要使用记事本）
在最后一行加上 `-Dfile.encoding=utf-8` 即可，建议再加一个回车。
