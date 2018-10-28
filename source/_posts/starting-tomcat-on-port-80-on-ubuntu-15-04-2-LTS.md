title: Ubuntu15.04绑定tomcat到80端口
date: 2016-07-08 21:07:54
tags: 
	- Tomcat
categories:
	- Tomcat

---


## 端口占用分析
想将tomcat6绑定到80端口上. 但是提示我绑定失败,想起来自带的Apache Server占用了这个端口.
首先用
`ps -ef | grep apache2`查看Apache进程pid值.
然后用`netstat -anp | grep pid`查看他所占用的端口号. 确定它占用的是80端口.

## 更换Apache Server端口
于是我将Apache Server的端口修改为8081.
用: `vi /etc/apache2/ports.conf`打开这个文件,将Listen 后的端口号改成8081. 然后根据文件上面的提示说还需要修改000-default的文件中的端口号.
> \# If you just change the port or add more ports here, you will likely also
\# have to change the VirtualHost statement in
\# /etc/apache2/sites-enabled/000-default.conf

于是用`vi /etc/apache2/sites-enabled/000-default.conf`打开这个文件将`<VirtualHost *:80>`也改成`<VirtualHost *:8081>`
<!-- more -->
### 重启Apache Server
端口换好后重启一下Apache Server. 用`apachectl -k restart`重启之后, 再按照上面的方法找到他的进程再查看端口号,确定端口改过来之后用浏览器访问一下这个端口. 成功访问,并访问原来的80端口已经无法访问了.到此端口成功更换.

## 绑定Tomcat到80端口
上面把端口换好了, 这时候想着再将tomcat绑到80端口应该就可以解决了吧.
`vi /var/lib/tomcat6/conf/server.xml` 打开这个文件,输入数字71然后按下shift+g定位到71行(大概就是在71行的位置). 可以看到`<Connector port="8080" protocol="HTTP/1.1" `这样的标签, 将port后面的8080改成80就可以了.

改好了就重启tomcat, 输入命令: `service tomcat6 restart`,

但重启时依然报错说`java.net.BindException: Permission denied <null>:80`. 于是网上找解决方法, 国内大部分人都说是非root用户登录无法绑定1024以下的端口号. 但我这里确实是以root用户登录的.

于是就上谷歌看看在国外能不能找到答案. 后来在: http://stackoverflow.com/questions/5544713/starting-tomcat-on-port-80-on-centos-release-5-5-final
这里有个回答是这样子的:

> You can change AUTHBIND property of "/etc/default/tomcat6" to "yes" as follows
> `AUTHBIND=yes`
> Restart your tomcat and that will enable you to use available privileged port (1-1023).

说是可以在`/etc/default/tomcat6`(我用的版本6)这个文件中改变AUTHBIND这个属性为yes然后重启服务器就可以允许绑定到1024以下的端口了.

按照他的说法用`vi /etc/default/tomcat6`打开这个文件, 然后用/进入指令模式后输入AUTHBIND查找这个property, 找到之后看到下面的一段内容
> \# If you run Tomcat on port numbers that are all higher than 1023, then you
\# do not need authbind.  It is used for binding Tomcat to lower port numbers.
\# NOTE: authbind works only with IPv4.  Do not enable it when using IPv6.
 \# (yes/no, default: no)

意思就是说如果你让tomcat运行的端口号高于1023那么不需要authbind这个东西, authbind是被用于绑定到低的端口号上去的. 注意: authbind仅在ipv4上工作, 当使用ipv6时不要开启它.

看完之后就好了, 我将authbind后面的no改为yes. 然后再次'service tomcat6 restart'重启tomcat发现已经不报错了...

我遇到的情况在这里已经得到解决了.
如果按照这个方法没有解决的朋友, 请参考下stackover flow上那个问题的其他回答. 链接是: http://stackoverflow.com/questions/5544713/starting-tomcat-on-port-80-on-centos-release-5-5-final