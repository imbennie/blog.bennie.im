title: Linux创建指定文件，文件夹，网页url地址快捷方式
date: 2016-01-07 00:19:23
tags:
	- Linux
categories:
	- Linux
---

### 创建指定文件快捷方式
命令：`ln -s 目标文件路径 link_name`
可以通过man ln详细看一下
例如：`ln -s /opt/eclipse/eclipse /home/123fs/desktop`

### 创建指定文件夹快捷方式
命令：`ln -s 目标文件夹路径 link_name`
同上。

### 创建指定网页URL地址快捷方式

1. 进入到你想创建快捷方式的目录执行`vim xxxx.url`
2. 按i进入编辑模式输入以下内容
    
    ```
    [InternetShortcut]
    URL=Http://Google.CoM
    ```
3. 按ESC退到命令模式`:wq！`保存退出。
4. 右键创建的文件，打开方式选择浏览器即可。