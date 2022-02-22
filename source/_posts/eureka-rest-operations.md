---
title: 使用其他(非java)语言开发Eureka客户端
date: 2017-09-06 17:13:42
tags:
	- Eureka
	- 微服务
categories:
	- 微服务
---


### 前言
公司需要调研Eureka在非JAVA语言中的使用，我在Eureka的官方github上找到了一份wiki，是官方提供的Eureka一些REST操作API，其他语言可以使用这些API来实现对Eureka Server的操作从而实现一个非jvm语言的Eureka Client。

<!-- more -->

这篇博文主要是对Eureka官方的提供的REST操作的WIKI做了翻译，**并没有提供具体的实际案例代码。**
不过今天（2017-9-20）我在阅读《Spring Cloud与Docker微服务架构实战》书中看到了有这部分的使用说明，其中4.9节介绍了详细使用过程。如果有需要的话可以参考一下。
另外如果感兴趣可以看看书中8.11节“使用Sidecar整合非JVM微服务”这部分，关于这部分的内容本人博客也有两篇相关博文：
[Spring Cloud Netflix多语言/非java语言支持之Sidecar](/2017/09/12/polyglot-support-with-sidecar/)
[使用Sidecar将Node.js引入Spring Cloud](/2017/09/11/using-sidecar-to-integration-with-nodejs-in-springcloud)

### 版本说明
**Eureka REST operations**
**翻译的版本为David Liu 在2016年2月26编辑的版本。**
英文原文地址：https://github.com/Netflix/eureka/wiki/Eureka-REST-operations

### 正文翻译

下面是可用于非JAVA应用的Eureka REST操作。

**appID**是应用程序的名称，**instanceID**是与服务实例相关联的唯一id。在AWS云中，instanceID是服务实例的**实例id**，在其他数据中心(非AWS环境)，它是服务实例的主机名。

对下面的JSON/XML格式而言，内容的类型必须是**application/xml** 或 **application/json**。

----
| **操作** | **HTTP action** | **描述** |
|:---|:---|:---|
| 注册新的应用实例 | POST /eureka/v2/apps/**appID** | 接受JSON/XML格式请求，返回204响应码表示成功 |
| 取消注册(de-register)应用实例| DELETE /eureka/v2/apps/**appID**/**instanceID** | 返回响应码200表示成功|
| 发送应用实例心跳 | PUT /eureka/v2/apps/**appID**/**instanceID** | 返回响应码200表示成功，404表示**instanceID**不存在|
| 查询所有实例 | GET /eureka/v2/apps |返回响应码200表示成功，响应内容格式JSON/XML|
| 为所有**appID**实例做查询(Query for all **appID** instances) | GET /eureka/v2/apps/**appID** | 返回响应码200表示成功，响应内容格式JSON/XML |
| 为特定的**appID**/**instanceID**做查询 | GET /eureka/v2/apps/**appID**/**instanceID** | 返回响应码200表示成功，响应内容格式JSON/XML|
| 为特定的**instanceID**做查询 | GET /eureka/v2/instances/**instanceID** | 返回响应码200表示成功，响应内容格式JSON/XML|
| 停止服务实例(Take instance out of service) | PUT /eureka/v2/apps/**appID**/**instanceID**/status?value=OUT_OF_SERVICE| 返回响应码200表示成功，500失败。 |
| 将实例恢复到服务(移除覆盖) | DELETE /eureka/v2/apps/**appID**/**instanceID**/status?value=UP  (value=UP是可选的，它被建议用于fallback状态，由于取消了覆盖)| 返回响应码200表示成功，500失败。 |
| 更新元数据| PUT /eureka/v2/apps/**appID**/**instanceID**/metadata?key=value| 返回响应码200表示成功，500失败。  |
| 查询特定**vip address** 下的所有实例| GET /eureka/v2/vips/**vipAddress** | 返回响应码200表示成功，响应内容格式：JSON/XML，返回404表示**vipAddress**不存在|
| 查询特定**secure vip address**下所有实例 | GET /eureka/v2/svips/**svipAddress** | 返回响应码200表示成功，响应内容格式：JSON/XML，返回404表示****svipAddress****不存在|



**服务注册**

在进行注册时，你需要提交符合该XSD的XML(或JSON):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified" attributeFormDefault="unqualified">
    <xsd:element name="instance">
        <xsd:complexType>
            <xsd:all>
                <!-- hostName in ec2 should be the public dns name, within ec2 public dns name will
                    always resolve to its private IP -->
                <!-- ec2中的主机名应该是公告的dns名称，在ec2内，公共dns名称将
始终对其私有IP进行解析 -->
                <xsd:element name="hostName" type="xsd:string" />
                <xsd:element name="app" type="xsd:string" />
                <xsd:element name="ipAddr" type="xsd:string" />
                <xsd:element name="vipAddress" type="xsd:string" />
                <xsd:element name="secureVipAddress" type="xsd:string" />
                <xsd:element name="status" type="statusType" />
                <xsd:element name="port" type="xsd:positiveInteger" minOccurs="0" />
                <xsd:element name="securePort" type="xsd:positiveInteger" />
                <xsd:element name="homePageUrl" type="xsd:string" />
                <xsd:element name="statusPageUrl" type="xsd:string" />
                <xsd:element name="healthCheckUrl" type="xsd:string" />
              <xsd:element ref="dataCenterInfo" minOccurs="1" maxOccurs="1" />
                <!-- optional 可选 -->
                <xsd:element ref="leaseInfo" minOccurs="0"/>
                <!-- optional app specific metadata -->
                <xsd:element name="metadata" type="appMetadataType" minOccurs="0" />
            </xsd:all>
        </xsd:complexType>
    </xsd:element>

    <xsd:element name="dataCenterInfo">
        <xsd:complexType>
            <xsd:all>
                <xsd:element name="name" type="dcNameType" />
                <!-- metadata is only required if name is Amazon -->
                <xsd:element name="metadata" type="amazonMetdataType" minOccurs="0"/>
            </xsd:all>
        </xsd:complexType>
    </xsd:element>

    <xsd:element name="leaseInfo">
        <xsd:complexType>
            <xsd:all>
                <!-- (optional) if you want to change the length of lease - default if 90 secs -->
                <!-- 可选， 如果你想更改租约的时间。 - 默认情况下90 秒。(该值会在下面会进行说明。) -->
                <xsd:element name="evictionDurationInSecs" minOccurs="0"  type="xsd:positiveInteger"/>
            </xsd:all>
        </xsd:complexType>
    </xsd:element>

    <xsd:simpleType name="dcNameType">
        <!-- Restricting the values to a set of value using 'enumeration' -->
        <!-- 使用'enumeration'(枚举)将值限制为一组值  -->
        <xsd:restriction base = "xsd:string">
            <xsd:enumeration value = "MyOwn"/>
            <xsd:enumeration value = "Amazon"/>
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:simpleType name="statusType">
        <!-- Restricting the values to a set of value using 'enumeration' -->
        <!-- 使用'enumeration'(枚举)将值限制为一组值  -->
        <xsd:restriction base = "xsd:string">
            <xsd:enumeration value = "UP"/>
            <xsd:enumeration value = "DOWN"/>
            <xsd:enumeration value = "STARTING"/>
            <xsd:enumeration value = "OUT_OF_SERVICE"/>
            <xsd:enumeration value = "UNKNOWN"/>
        </xsd:restriction>
    </xsd:simpleType>

    <xsd:complexType name="amazonMetdataType">
        <!-- From <a class="jive-link-external-small" href="http://docs.amazonwebservices.com/AWSEC2/latest/DeveloperGuide/index.html?AESDG-chapter-instancedata.html" target="_blank">http://docs.amazonwebservices.com/AWSEC2/latest/DeveloperGuide/index.html?AESDG-chapter-instancedata.html</a> -->
        <xsd:all>
            <xsd:element name="ami-launch-index" type="xsd:string" />
            <xsd:element name="local-hostname" type="xsd:string" />
            <xsd:element name="availability-zone" type="xsd:string" />
            <xsd:element name="instance-id" type="xsd:string" />
            <xsd:element name="public-ipv4" type="xsd:string" />
            <xsd:element name="public-hostname" type="xsd:string" />
            <xsd:element name="ami-manifest-path" type="xsd:string" />
            <xsd:element name="local-ipv4" type="xsd:string" />
            <xsd:element name="hostname" type="xsd:string"/>      
            <xsd:element name="ami-id" type="xsd:string" />
            <xsd:element name="instance-type" type="xsd:string" />
        </xsd:all>
    </xsd:complexType>

    <xsd:complexType name="appMetadataType">
        <xsd:sequence>
            <!-- this is optional application specific name, value metadata --> 
            <!-- 这是可选的应用专用名，值的元数据。 -->
            <xsd:any minOccurs="0" maxOccurs="unbounded" processContents="skip"/>
        </xsd:sequence>
    </xsd:complexType>

</xsd:schema>
```

**evictionDurationInSecs**：
默认情况下Eureka Server会每隔60秒检测失效的服务，失效的服务是超过一定时间没有发送心跳进行续约的服务。
这里的evictionDurationInSecs用来定义服务租约的超时时间。

该值定义在`org.springframework.cloud.netflix.eureka.EurekaInstanceConfigBean#leaseExpirationDurationInSeconds`
表示eureka server至上一次收到client的心跳之后，等待下一次心跳的超时时间，在这个时间内若没收到下一次心跳，则将移除该instance，**默认为90秒**。
* 如果该值太大，则很可能将流量转发过去的时候，该instance已经不存活了。
* 如果该值设置太小了，则instance则很可能因为临时的网络抖动而被摘除掉。
* 该值至少应该大于leaseRenewalIntervalInSeconds

**服务续约**

示例 : PUT /eureka/v2/apps/MYAPP/i-6589ef6
```
Response:
Status: 
200 (on success)
404 (eureka doesn't know about you, Register yourself first)
500 (failure)
```




**服务关闭/服务下线**

**(If Eureka doesn’t get heartbeats from the service node within the evictionDurationInSecs, then the node will get automatically de-registered )**
如果Eureka在服务租约超时时间内没有从服务节点获得心跳续约，那么服务节点将自动取消注册。

示例 : DELETE /eureka/v2/apps/MYAPP/i-6589ef6

```
Response:
Status:
200 (on success)
500 (failure)
```

----------------