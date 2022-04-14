---
title: Spotify的docker-maven-plugin无法推送image到需认证的镜像注册中心
date: 2022-02-26 18:17:04
tags:
	- Docker
	- Maven
categories:
	- 编程开发

---

我使用的maven插件是[Spotify的docker-maven-plugin](https://github.com/spotify/docker-maven-plugin)
即：
```java
<plugin>
 <groupId>com.spotify</groupId>
 <artifactId>docker-maven-plugin</artifactId>
 <version>1.2.2</version>
</plugin>
```

<!-- more -->

找了找资料，看看如何配置认证信息。
- [docker-maven-plugin插件官方仓库](https://github.com/spotify/docker-maven-plugin) README文档中
- [使用docker-maven-plugin插件实现Docker构建并提交到私有仓库](https://www.jianshu.com/p/c435ea4c0cc0)

按步骤配置后，发现依然不能将构建的镜像推送到注册中心。

继续搜索，后来找到解决办法是在‪Docker配置文件（`C:\Users\Bennie\.docker\config.json`）提供该镜像注册中心的认证信息。
```json
{
	"auths": {
	    "registry.cn-beijing.aliyuncs.com": {
            "username": "xxxx@gmail.com",
            "password": "123456"
        }
	},
	"credsStore": "desktop"
}
```

再次执行发现已经可以推送镜像到远程仓库了。

如果你有遇到其他错误，可以通过`mvn clean package docker:build -X`打开maven的调试参数查看详细输出。


相关资料：
- [使用docker-maven-plugin插件实现Docker构建并提交到私有仓库](https://www.jianshu.com/p/c435ea4c0cc0)
- [使用Docker部署SpringBoot](https://www.jianshu.com/p/2909593e30ed)
- [Docker部署SpringBoot项目](https://www.jianshu.com/p/397929dbc27d)
- [阿里云Docker镜像注册中心的申请与使用](https://help.aliyun.com/document_detail/51810.html)

