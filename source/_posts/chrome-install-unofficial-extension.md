---
title: Chrome安装非官方市场插件
date: 2016-12-24 21:24:14
tags:
	- Chrome
categories:
	- Chrome
---


本文转载自: https://www.zhihu.com/question/24027794


### 方式1(Windows系统)

1. 下载 Chrome组策略管理模板【**[chrome.adm](http://p7ivlhq87.bkt.clouddn.com/chrome.adm)**】
2. Win+R 打开运行，输入 **gpedit.msc** 回车；
3. 依次展开 **本地计算机策略 > 计算机配置 > 管理模板**，在管理模板上右击，选择添加/删除模板；
4. 点击添加，找到第1步下载的chrome.adm，打开，关闭添加/删除模板窗口；
5. 依次展开 **本地计算机策略 > 计算机配置 > 管理模板 > 经典管理模板(ADM) > Google > Google Chrome > 扩展程序**，双击右侧的配置扩展程序安装白名单；
6. 点选左边第二项已启用，点击下面的显示，
7. 打开 Chrome，将下载的 .crx 文件拖放至 Chrome 扩展程序页面安装；
8. 找到右上角的**开发者模式**，勾选，复制刚安装的扩展的 ID；
9. 粘贴到第6步弹出的窗口中，确定；

<!-- more -->


### 方式2
首先，需要在管理拓展的地方勾选开发者模式（Developer mode）。
![1.jpg](/images/2018-05-29-173616.png)

接着将 testExtention.crx 改名为 testExtention.zip
然后用解压缩工具解压为文件夹 testExtention
![2.jpg](/images/2018-05-29-173617.png)

接着在 Chrome 设置拓展的地方，点击加载未打包的拓展（Load unpacked extension...）
![3.jpg](/images/2018-05-29-173618.png)
即可：
![4.jpg](/images/2018-05-29-173620.png)
