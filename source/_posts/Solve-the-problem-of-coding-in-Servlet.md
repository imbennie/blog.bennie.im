title: Servlet Get及Post请求字符编码问题解决方法
date: 2016-06-04 20:06:09
tags:
	- 字符集
	- Servlet
	- 字符编码
	- Java
categories:
	- Java

---

## **前言**
在浏览器与服务器传递数据的时候有时候会因为字符集(char-set)不同而发生乱码的问题,一般我们将浏览器与服务器的编码都设置为UTF-8字符集编码.如果服务器和浏览器编码不一致,那么服务器获取浏览器的请求数据时就会出现乱码,同时给浏览器下发的数据浏览器解析出来的也是乱码.这里以Tomcat为例,说明一下如何设置字符集..
<!-- more -->

## **页面设置UTF-8编码**
首先我们需要确保传递给服务器的是UTF-8的字符集编码.我们就要更改一下网页的字符集编码,在建立jsp文件(或其他网页文件)之后,在代码中找到这样的代码.
```jsp
<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
```

将**charset**和**pageEncoding**设置为UTF-8.
如果新建的网页文件不是utf-8编码,那么在Eclipse中打开Preferences -> web 将css, html, jsp编码设置为UTF-8.设置后上面的代码字符集就会自动生成为UTF-8.

## **服务器设置UTF-8编码与解码**
Tomcat服务器默认以ISO8859-1这个字符集来处理数据的编码解码.
服务器获取浏览器的请求数据时是一个解码的过程<font color="Red">(浏览器将请求数据编码发给服务器, 服务器再进行解码)</font>
向浏览器响应数据的时候是一个编码过程.<font color="Red">(服务器将响应数据编码发给浏览器, 浏览器再进行解码)</font>
**所以我们需要设置请求编码和响应编码.**

### **设置请求解码**
把请求编码也设置为与页面上设置的UTF-8编码一样,这样获取到的请求数据就不会出现乱码的问题了.**但请求分为两种,Get和Post.**

1. Get请求设置编码
get请求是通过url地址传递的查询字符串来请求的,Tomcat会自动对Get请求过来的数据解码,但Tomact默认是ISO8859-1这个字符集,所以我们需要更改一下Tomcat的字符集配置. 在Eclipse中我们配置了Tomcat服务器之后,会在`Package Explorer`窗口中显示一个`Servers`的项目, 打开这个项目之后再打开`server.xml`文件, 按下CTRL+L输入68定位到68行,插入`URIEncoding="utf-8"`然后保存,设置完成之后是这样子的.
    ```xml
    <Connector URIEncoding="utf-8" connectionTimeout="20000" port="8080" protocol="HTTP/1.1" redirectPort="8443"/>
    ```

2. Post请求设置编码
post请求是指在收到浏览器发来的请求时对请求中的报文进行解码.
在Servlet中的doPost方法中通过`request.setCharacterEncoding("UTF-8");`这行代码来设置字符集编码.
<font color="red">注意:</font>需要先设置字符集编码,然后再接收请求,否则默认的编码字符集是iso8859-1还是会导致乱码问题.

### **设置响应解码**
服务器给浏览器响应的时候, 先要设置想要数据的编码, 然后以请求头的方式告诉浏览器以该编码来解码,这样子浏览器收到的响应才不会乱码.
这也是Servlet Api中这部分的解释.

> 容器必须让客户端了解将用于 servlet 响应的 writer 的字符编码，如果协议提供了实现上述操作的方法。在使用 HTTP 的情况下，字符编码是作为文本媒体类型的 Content-Type 头的一部分传送的。注意，如果 servlet 未指定内容类型，则字符编码不能通过 HTTP 头传送；但是，它仍然用于编码通过 servlet 响应的 writer 编写的文本。

所以我们需要用如下两行代码设置
```java
response.setCharacterEncoding("utf-8");
response.setHeader("Content-type", "text/html;charset=utf-8");
```
作用是先设置字符集编码为utf-8,然后添加响应头Content-type值为text/html;charset=utf-8,告诉浏览器以utf-8解码.
通过查看servlet的api可以知道,`setCharacterEncoding("utf-8");`这个方法需要在响应数据前或者`response.getWriter();`方法被调用之前调用.

<font color="red">实际上:</font>上面的两行代码相当于`response.setContentType("text/html;charset=utf-8");`这一行代码.作用是一样的.

## **总结**
确定页面设置的是UTF-8以及配置了Tomcat的Server.xml文件中的编码后.
在Servlet中的**doPost**方法中,我们插入两行以下代码.
```java
// 用于对请求数据解码
request.setCharacterEncoding("UTF-8");

// 用于对响应数据编码并通知浏览器以该字符集对响应解码.
response.setContentType("text/html;charset=utf-8");
```
而**doGet**方法只要插入`response.setContentType("text/html;charset=utf-8");`这一句就行.