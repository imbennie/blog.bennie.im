---
title: Spring Cloud Netflix多语言/非java语言支持Sidecar
date: 2017-09-12 12:09:27
tags:
	- Spring Cloud
	- Sidecar
	- 微服务
categories:
	- 微服务	
---



### 前言
公司有一个调研要做，调研如何将Python语言提供的服务纳入到Spring Cloud管理中来，找到了这个Sidecar组件，发现官方提供一篇文档如下，对其进行相关翻译。

### Sidecar简介

根据我的理解，Sidecar是作为一个代理的服务来间接性的让其他语言可以使用Eureka等相关组件。通过与Zuul的来进行路由的映射，从而可以做到服务的获取，然后可以使用Ribbon，Feign对服务进行消费，以及对Config Server的间接性调用。(此段内容仅个人理解，只作为参考，欢迎讨论，同时有误请及时指正。)

<!-- more -->

### 正文翻译

以下是原文翻译，原文地址：https://cloud.spring.io/spring-cloud-netflix/multi/multi__polyglot_support_with_sidecar.html


你是否想要在非jvm的语言中利用（间接性使用）Eureka，Ribbon以及Config Server？Spring Cloud Netflix Sidecar的设计灵感来自[Netflix Prana](https://github.com/Netflix/Prana)。它包含一个简单的http api去获取一个已知服务的所有实例(例如主机和端口)。你也可以通过嵌入的Zuul代理(Zuul中有一个代理功能)对代理的服务进行调用，Zuul从Eureka服务注册中心获取所有的路由记录(route entries)。通过host发现(host lookup)或者Zuul代理可以直接访问Spring Cloud Config。非jvm应用应该实现一个健康检查，Sidecar能够以此来报告给Eureka注册中心该应用是up还是down状态。

在你的项目中使用Sidecar，需要添加依赖，其group为`org.springframework.cloud`，artifact id为`spring-cloud-netflix-sidecar`。(这是以maven依赖的方式)


启用Sidecar，创建一个Spring Boot应用程序，并在在应用主类上加上`@EnableSidecar`注解。该注解包含`@EnableCircuitBreaker`, `@EnableDiscoveryClient`以及`@EnableZuulProxy`。Run the resulting application on the same host as the non-jvm application. (这句不太会翻译，我的理解为：在与非jvm应用程序相同的主机上运行生成的应用程序)注：这里的生成应该是通过代理产生的服务。

配置Sidecar，在application.yml中添加`sidecar.port`和`sidecar.health-uri`。`sidecar.port`属性是非jre程序监听的端口号，这就是Sidecar可以正确注册应用到Eureka的原因。`sidecar.health-uri`是非jre应用提供的一个对外暴露的可访问uri地址，在该地址对应的接口中需要实现一个模仿Spring Boot健康检查指示器的功能。它需要返回如下的json文档。(**注**：通过返回一个json，其用status字段来标识你的应用的服务状态，是up还是down，sidecar会将该状态报告给eureka注册中心从而实现你的服务的状态可用情况。**简单的说就是用来控制sidecar代理服务的状态！**)
health-uri-document. 

**health-uri-document.**(heal-uri指向的接口地址需要返回的json文档) 
```json
{
  "status":"UP"
}
```

这里是一个Sidecar应用程序的application.yml配置示例：

**application.yml**
```
server:
  port: 5678
spring:
  application:
    name: sidecar

sidecar:
  port: 8000
  health-uri: http://localhost:8000/health.json
```

API `DiscoveryClient.getInstances()`所对应的访问方式是`/hosts/{serviceId}`，这是访问`/hosts/customers`后的响应示例，它返回了两个不同主机上的实例(可以看到主机地址不一样)。
非jre程序可以访问这个api，如果sidecar的端口号为5678，那么完整url则为：`http://localhost:5678/hosts/{serviceId}`.

**/hosts/customers.** 
```json
[
    {
        "host": "myhost",
        "port": 9000,
        "uri": "http://myhost:9000",
        "serviceId": "CUSTOMERS",
        "secure": false
    },
    {
        "host": "myhost2",
        "port": 9000,
        "uri": "http://myhost2:9000",
        "serviceId": "CUSTOMERS",
        "secure": false
    }
]
```

Zuul代理会自动为每个在Eureka注册中心上的服务添加路由到`/serviceId`上，所以上面那个customers的服务可以通过`/customers`访问。非Jre应用可以通过`http://localhost:5678/customers`来访问Customer Service(假设Sidecar的监听端口为5678)

如果Config Server注册到了Eureka，非jre应用就可以通过Zuul代理访问它。如果ConfigServer的serviceId为`configserver`并且Sidecar的端口为5678，那么可以通过http://localhost:5678/configserver 的方式来访问Config Server。

非Jvm应用可以利用Config Server的能力来获取Config Server返回的YAML文档，通过访问 http://sidecar.local.spring.io:5678/configserver/default-master.yml 就可以获取到类似下面的YAML文档结果
```yml
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
  password: password
info:
  description: Spring Cloud Samples
  url: https://github.com/spring-cloud-samples
```
