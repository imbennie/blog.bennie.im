---
title: 记一下 Invalid bound statement (not found) 的问题
date: 2018-06-02 18:15:47
tags: 
	- Java
	- MyBatis

categories: 
	- Programming


---

记一下在开发时出现的一个问题, 弄了很久才得到解决.
网上查询到的回答大概都是如这篇文章回答的一样来解决 https://www.jianshu.com/p/800fe918cc7a
但进行操作后依旧未能解决我的问题.



<!-- more -->


我的问题如下:
我和同事共同负责系统模块的开发, 我的模块需要依赖他开发的模块. 我们的项目都是基于Spring Boot开发的项目, 我在Application的启动类中使用`@MapperScan`注解扫描我们两个人工程中的Mapper接口文件. 
这里需要说明的是, 由于我们是开发两个模块, 所以在配置Mapper扫描包的路径需要是我们包路径的公共部分, 例如我的Mapper接口存放在了包`com.xxx.system.user.mapper` , 他的存放在`com.xxx.system.blog.dao`中. 
所以这时候我配置的Mapper接口包扫描路径为`@MapperScan(basePackages = {"com.xxx.system"})`, 以便扫描到我们两个工程的Mapper接口包.
但是这样设置后我遇到一个问题, 由于我们在开发中大多数也会在Service层提供一个抽象接口, 例如`com.xxx.system.usser.service.IUserService`, 然后还为该接口提供一个实现类UserServiceImpl. 
这时候`@MapperScan`注解会发生一个错误, 会奇怪的将IUserService这个接口当做是Mybatis的Mapper接口, 然后还尝试拿去跟Mapper.xml中去做映射关联.
这时候就会发生Invalid bound statement (not found)的问题. 

解决方法是可以选择在`@MapperScan`注解中分两次配置两个工程的Mapper接口包路径, 或者将两个人的包命名为同一个路径下, 
例如最后不要一个人是mapper中, 一个人是放在dao中, 统一一下, 这样就可以写成`com.xxx.system.*.mapper`用*通配符来代替中间的部分.


这里还说另一个问题, 是`classpath*`与`classpath`的问题.

由于是基于SpringBoot整合的Mybatis, 所以可以在application.properties用`mybatis.mapper-locations`来配置Mybatis的mapper.xml文件路径. 

我在一开始配置的值是`mybatis.mapper-locations=classpath:mapper/*Mapper.xml`, 这个配置值存在的问题是, 如果在classpath的mapper文件夹中检查到了任意的Mapper.xml文件时, 都会返回结果停止往下继续匹配. 

这里的问题是, 我依赖我同事的工程中, 也需要扫描classpath下他的Mapper.xml文件, 而此时无法找到他工程里的Maper.xml文件, 
原因就是因为匹配到我工程里classpath中的Mapper.xml文件就停止了对他工程的匹配搜索. 解决的办法是将`classpath:mapper/*Mapper.xml`改为`classpath*:mapper/*Mapper.xml`. 
`classpath*`的作用是找到包括你依赖的jar文件在内的classpath中的资源文件.


本来想仔细探究一下这其中的究竟, 但因工作繁忙无暇深入去探索, 暂且记录一下留作以后参考. 
上网看了一下别人的博客, 介绍的classpath和classpath*的大概区别如下: 
https://blog.csdn.net/kkdelta/article/details/5507799
http://kyfxbl.iteye.com/blog/1675362
