---
title: 使用SSH配置文件进行SSH连接
date: 2017-06-14 01:30:16
tags:
    - SSH
categories:
    - IT Notes

---

SSH配置文件可以方便我们进行一个SSH连接。而不用每次连接的时候都输入账号和密码。

## 不使用配置文件进行连接(使用命令行方式)

那么我们在不使用配置文件的时候(使用命令行的方式)是如何建立连接的呢？

### 用密码登录
输入命令：`ssh root@66.111.222.23 -p 27275`
### 用密钥登录
输入命令：`ssh root@66.111.222.23 -p 27275 -i ~/VPS_SSH_KEY/66.111.222.23.pri`
通过-p参数指定端口(默认为22)，-i参数手动指定私钥的路径。

<!-- more -->

> 
~代表用户家目录，如果你电脑用户名为flix
对Windows系统来说，用户家目录的路径就是`C:\User\flix\`
对Linux系统来说就是`/home/flix/`


## 使用配置文件方式登录(基于密钥)
上面通过命令行的方式登录，麻烦的地方在于每次都要输入password或者私钥的passphrase，所以这里说一下SSH的配置文件方式来登录。

### 建立目录并创建文件
首先在**用户家目录里**建立.ssh文件夹(如果没有创建该文件夹)，然后在.ssh文件夹里建立一个**config**文件。

1. Windows系统在新建.ssh文件夹时需要通过cmd命令来新建，在cmd窗口输入`mkdir .ssh`，然后再在.ssh文件夹中新建config文件。
2. Linux系统按照顺序输入下面3个命令：
最后chmod为什么要输入，最下面的注意事项会说。

    ```
    mkdir ~/.ssh
    touch ~/.ssh/config
    chmod 600 ~/.ssh/config
    ```


### 编辑文件内容
编辑config文件的内容，输入相关的配置：
```
Host 66.vps
    HostName 66.111.222.23
    Port 27275
    User root
    PreferredAuthentications publickey
    IdentityFile ~/VPS_SSH_KEY/66.111.222.23.pri
```
Windows系统用记事本编辑config文件。
Linux系统输入命令`vi ~/.ssh/config`来进行编辑。
上面的内容做一下说明，**具体的配置你按照自己的配置进行替换**，config文件中是用Host配置项来进行多个配置的分割。并用缩进符来进行一些子项配置。

- Host后面的文本内容可以随意命名，起一个标识作用，用于区分多个Host
- HostName用于指定主机地址，可以是域名或者ip地址
- Port用于指定主机端口，如果不写这一项默认端口为22
- User指定主机的用户名，就是命令`ssh root@66.111.222.23`@前面的用户名
- PreferredAuthentications 指定优先身份认证方式，由于我们是通过公私钥来与服务器进行验证交互，所以这里写publickey就行(默认是按照gssapi-with-mic,hostbased,publickey,keyboard-interactive,password这样的顺序来进行身份验证)
- IdentityFile就是指定私钥的路径

### 建立连接

经过这样的配置之后我们就可以使用`ssh 66.vps`如此简单的命令来连接了。

```
flix@flix-PC:~$ ssh 66.vps
Enter passphrase for key '~/VPS_SSH_KEY/66.111.222.23.pri': 
Welcome to Ubuntu 16.04.2 LTS (GNU/Linux 4.4.0-79-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 packages can be updated.
0 updates are security updates.


*** System restart required ***
root@ubuntu:~# 
```

这样子是不是简单多了。

## 配置多个Host
我们也可以利用配置文件的方式来配置多个不同提供了SSH连接的主机。
下面是2个Github配置以及一个Coding.net的配置。

```
Host github1 
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/Git_SSH_KEY/github1.pri

Host github2 
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/Git_SSH_KEY/github2.pri
    
Host coding
    HostName git.coding.net
    User git
    PreferredAuthentications publickey
    IdentityFile ~/Git_SSH_KEY/coding.pri
    
```

输入`ssh -T github1`测试连接是否成功。
```
flix@flix-PC:~$ ssh -T github1
Hi flix! You've successfully authenticated, but GitHub does not provide shell access.
```

## 注意事项

在Linux中，你的私钥文件，以及.ssh文件夹下的config文件，权限如果过于开放，那么在进行连接的时候会提示你**Bad owner or permissions on ~/.ssh/config**，目的是提醒你这些重要的文件你不应该对其他人开放较高的权限。解决这一问题的办法很简单。
只需要降低文件权限即可。
输入`chmod 600 ~/.ssh/config`只给予当前读写权限。
私钥文件的权限也要这样设置。

```
flix@flix-PC:~$ ls -l .ssh/config ~/Git_SSH_KEY/github.pri
-rw------- 1 flix flix  462 6月  14 00:22 .ssh/config
-rw------- 1 flix flix 1794 6月  11 14:50 ~/Git_SSH_KEY/github.pri
```

## 相关配置
也许有的人会好奇config文件里都可以配置哪些东西，这里就不描述那么多了，你可以看一下命令手册：[《ssh_cofig》](http://man.openbsd.org/ssh_config)，Linux系统直接`man ssh_config`。

## 其他SSH相关
Git SSH Key 生成步骤：http://blog.csdn.net/hustpzb/article/details/8230454
SSH密钥登录让Linux VPS/服务器更安全：https://www.vpser.net/security/linux-ssh-authorized-keys-login.html
使用 SSH config 文件：http://daemon369.github.io/ssh/2015/03/21/using-ssh-config-file

