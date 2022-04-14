---
title: 多个SSH连接配置之HEXO部署
date: 2017-08-20 21:18:05
tags:
	- Hexo
	- SSH
categories:
	- 笔记本

---


**本文是给自己留个笔记，是建立在本人自己的思路上，所以有些地方不会说的那么详细**
如果只是来找直接的解决方案，可以参考《[本地有多个github账号如何使用hexo部署到特定账号](https://knightdevelop.github.io/2017/04/03/%E6%9C%AC%E5%9C%B0%E6%9C%89%E5%A4%9A%E4%B8%AAgithub%E8%B4%A6%E5%8F%B7%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8hexo%E9%83%A8%E7%BD%B2%E5%88%B0%E7%89%B9%E5%AE%9A%E8%B4%A6%E5%8F%B7/)》这篇文章。

`这里只针对Hexo部署时在多个SSH配置时一些处理，关于多个Github账号的搭配多个SSH配置的问题请自行谷歌了解。`

<!-- more -->

----------------

多个SSH配置是指的是在用户家目录下.ssh\config文件中(`C:\Users\good_boy\.ssh\config`)文件中配置了多个SSH的连接。
之前在《[如何使用SSH配置文件进行SSH连接](/2017/06/14/how-to-use-ssh-config-file-for-a-ssh-connection/)》已经介绍了多个SSH配置的配置方法。

但当我们这样子配置之后，会发现在Hexo部署的时候会出现错误。因为Hexo在提交到仓库的时候不知道使用哪个SSH配置。
我们要解决的问题让仓库地址跟我们的SSH配置中的Host主机对应上，这样子他就会去找对应的SSH配置了。
听起来可能不太明白，其实很简单。

例如现在我的电脑上有两个Github账号，然后SSH配置文件的连接配置为：

```yml
Host github_1
    User git
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile C:/Users/good_boy/.ssh/keys/github_1

Host github_2
    User git
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile C:/Users/good_boy/.ssh/keys/github_2
```



配置了多个SSH链接，这时候我们如果还是以git作为github.com这个主机的User去连接那么就会失败。

> $ ssh -T git@github.com
> Permission denied (publickey).

这是因为不能确定具体要去使用哪个配置文件。这时候我们就需要指定具体的Host了，也就是你得通过`ssh github_1`这样子的方式来连接。

> $ ssh -T github_1
> Hi good_boy! You've successfully authenticated, but GitHub does not provide shell access.



一般情况下，我们的Hexo配置文件_config.yml中Deploy部分配置如下：

```yml
deploy:
- type: git
  repo: 
    github: git@github.com:good_boy/good_boy.github.io.git
```

---



部署仓库的地址中有 git@github.com 这么一段，这就是SSH连接的用户名和主机。
这样部署，当进行ssh通讯的时候就相当于 `ssh -T git@github.com` ，所以是会导致连接失败的。



解决方法就是把仓库SSH地址：`git@github.com:good_boy/good_boy.github.io.git` 中的 `git@github.com` 替换成对应的SSH配置的主机，冒号后面的就是Github的用户名，这个不需要改。
例如这里HEXO部署到的Github账号需要使用github_1这个SSH配置来进行SSH连接验证。
那么部署的仓库地址就需要写成：`repo: github_1:good_boy/good_boy.github.io.git`
这样子Hexo在部署进行SSH连接的时候就会知道使用哪个SSH配置了。

这样的做法也适用于部署到多个Git仓库，例如同时部署到了Github和Coding上，那么SSH连接配置和Hexo的配置就是下面这样子：

**SSH连接配置**

```yml
Host coding_good_boy
    User git
    HostName git.coding.net
    PreferredAuthentications publickey
    IdentityFile C:/Users/good_boy/.ssh/keys/coding_good_boy

Host github_good_boy
    User git
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile C:/Users/good_boy/.ssh/keys/github_good_boy
```

**Hexo部署配置**

```yml
deploy:
- type: git
  repo: 
    coding: coding_good_boy:good_boy/good_boy.coding.me.git
    github: github_good_boy:good_boy/good_boy.github.io.git
```


