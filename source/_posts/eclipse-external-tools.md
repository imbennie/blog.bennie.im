title: Eclipse使用外部编辑器打开当前编辑文件
date: 2016-08-03 20:43
tags:
	- Eclipse
categories:
	- 工具

---


有时候我们需要找到正在编写的java文件,包,配置文件等在哪个目录.
一般是通过`选中文件/文件夹/包名->右击->Properties->Location->复制路径->按Win键->粘贴地址->回车`这种方式来打开那个文件夹.这种方式很繁琐效率也低下.

但Eclipse已经给我们提供了一种方式来解决这个问题, 提供了一个`External Tools`这个东东.
在菜单栏上的`Run->External Tools->External Tools Configurations`这个地方
或者工具栏如果有图标的话,直接点击也可以.
![](/images/2018-05-29-173830.png)

<!-- more -->

打开后就可以进行配置了. 
![](/images/2018-05-29-173830.jpg)
先选中`Program`, 接着点击左上角那个新建图标, 创建一个配置.
`Location`输入`C:\Windows\explorer.exe`,表示文件浏览器.
`Araguments`输入`${selected_resource_loc}`这个参数会返回已经当前选中资源的绝对路径.
`Name`那里写一个你可以记住的名字就好了.

> `Location`那里输入`C:\Windows\explorer.exe`是表示让资源管理器打开这个文件, 在windows里这个文件就是文件夹窗口. 所以我们可以让文件在文件夹中

这个命令运行之后就会调用你系统上默认的文本编辑器来打开你选中的这个文件.

接下来配置在文件夹中显示当前编辑的资源文件.
配置方式如上所述, 只要把`Araguments`换成`${container_loc}`就可以了.

至于其他的一些扩展工具, 可以点`Variables`来选择更多的实用功能.
