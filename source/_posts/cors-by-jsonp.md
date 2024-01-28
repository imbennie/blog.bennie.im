---
title: 使用JsonP进行跨域请求
date: 2016-03-16 22:15:00
tags:
	- Frontend
	- CORS
categories:
	- Programming

---


以前有一个使用Jquery的$.post(...);来发请求想加载其他网站数据的想法，但是弹出如下错误：

> XMLHttpRequest cannot load http://s.music.163.com/search/get/?type=1&filterDj=true&s=%E7%88%B1%E5%B0%B1%E7%88%B1%E4%BA%86&limit=3&offset=0. No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'null' is therefore not allowed access.

那时候还不知道这个是什么问题, 搜索了下才知道是跨域请求的问题. 后来一直心里记挂着这个事. 于是今天在闲暇之余去了解了一下. 本文会对以Jsonp方式进行的跨域请求解决办法进行说明.

<!-- more -->

学习过程中参考的网页链接, 下文的一些说明也有引用自下方链接的网页.
1. 什么是JS跨域访问？(基本的了解)
https://www.zhihu.com/question/26376773/answer/32736193
1. 跨域与跨域访问.(跨域请求问题的出现及解决过程)
http://blog.csdn.net/notechsolution/article/details/50394391
1. 说说JSON和JSONP，也许你会豁然开朗，含jQuery用例.(推荐此文, 通俗易懂.)
http://www.cnblogs.com/dowinning/archive/2012/04/19/json-jsonp-jquery.html
1. Jsonp-维基百科(相关介绍及原理说明)
https://zh.wikipedia.org/wiki/JSONP

## 跨域请求是什么?
跨域请求简单的来说就是指:
服务器网页A在请求B服务器网页上的资源数据时, 那么当协议, 域名, 端口号三者其一有不同时, 那么就会出现跨域请求的问题.浏览器会检查服务器B的HTTP头(HEAD请求)，如果Access-Control-Allow-Origin中有A，或者是通配符*，浏览器就会允许跨域。
例如:
>a.baidu.com访问b.baidu.com  是跨域
a.baidu.com:8080访问a.baidu.com:80 是跨域
http://a.baidu.com访问https://a.baidu.com 是跨域

还有一点比较重要，限制跨域是浏览器的行为，而不是JS的行为。
## 为什么浏览器要限制跨域访问呢？
参见：http://blog.csdn.net/notechsolution/article/details/50394391#t1
## 为什么要跨域以及跨域的作用是什么？
参见：http://blog.csdn.net/notechsolution/article/details/50394391#t2


通过上面的知识我们知道了跨域的问题根本以及跨域的作用以及何时需要跨域！
下面就是真正面对面接触了。
## Jsonp跨域的原理是什么以及如何进行跨域？
这里本人粗浅的说一下本人的理解, 具体的大家可以去[Jsonp-维基百科](https://zh.wikipedia.org/wiki/JSONP)这里了解.
以前我在听别人说跨域请求的时候, 大概只是在脑海里知道a站访问b站有时候会出现安全问题, 而无法获取到数据什么的.
随后在引用其他其他js文件的时候发现, 为什么这样子就可以拿到其他网站的资源?
```
<script type="text/Javascript" src="http://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js"></script>
```
那时候就隐约觉得这个事有点蹊跷, 不过那时候还不知道是跟跨域有关系.
当在维基百科上看到原理的介绍时, 才恍然大悟.原来Jsonp就是基于的这个实现的.
现在知道一些带有src属性的标签都可以不受浏览器的约束而获取到其他网站的数据.

以代码的方式来说一下原理.
首先我们知道, 如果使用script标签的src属性引用了一个js文件, 那么不管这个js文件在哪里都是可以执行的, 为什么会执行, 因为他返回了一个Javascript文本或者Javascript对象.

例如假设在一个服务器上的 http://xxx.com/test.js 内容是:

```
alert("Test JS Execute!");
```


```
<!DOCTYPE html>
<html>
<head>
	<title>Test</title>
	<script type="text/Javascript" src="http://xxx.com/test.js"></script>
</head>
<body>
</body>
</html>
```

那么当你引用JS文件之后，在也面加载的时候，页面会弹出`Test JS Execute!`。
用这个举例子就是想说明一个事， 那就是script标签可以加载远程的js代码并且执行!
基于这个原理, jsonp的实现方式是: `通过远程的服务器返回一个函数调用的代码来调用我们事先定义的函数`.

这里先建立一个1.html文件写上这段代码, 定义一个testFunction这个函数.

```
<script type="text/Javascript">
	var testFunction = function (data) {
		console.log(data);
    };
</script>		
```

定义这个函数之后, 我可以通过 `testFunction(data);` 来调用执行它的是吧? 
那么OK, 我让远程是文件返回一个这样的函数调用代码过来, 然后让他加载到script标签里面这样不就可以调用这个函数了么? 而这个函数中的data就是我们希望跨域传过来的json数据. 所以我在服务端把这个json数据准备好, 然后拼接成调用js方法的代码返回给页面不就可以了么?

例如我向页面输出这样的内容:

```
String json = "{\"result\":\"测试JSONP"}";
// 输出到页面为: {"result":"测试JSONP"}

response.getWriter().writer("testFunction(" + json + ");");
// 输出到页面为: testFunction({"result":"测试JSONP"});

```

这样子之后, 我再把1.html改成这样子

```
<script type="text/Javascript">

	// 定义一个函数
	var testFunction = function (data){
		console.log(data);
    };
    
    // 生成script标签来调用上面的函数.
    var url ="http://xxx.com/TestFunctionServlet";
	var script = document.createElement('script');
	script.setAttribute('src',  url);

	// 把script标签加入head标签.这个时候就可以调用我们上面定义的testFunction函数了.
	document.getElementsByTagName('head')[0].appendChild(script);
</script>		
```

上面的代码会生成一个script标签.

```
<script type="text/Javascript" src="http://xxx.com/TestFunctionServlet"></script>
```

这个script标签执行之后, 就会调用我们定义的函数. 这就是跨域请求的原理和基本实现.

-------

JQuery给我们提供了`$.ajxx();`这个方法, 但是他和jsonp是2个东西, 但是原理也是和这个一样的.只是他在内部做了封装处理, 还为了提供了很多方便的地方.
具体参考: http://www.cnblogs.com/dowinning/archive/2012/04/19/json-jsonp-jquery.html 这个文章, 在文章结尾上方说明了JQuery的代码实现.


另外还有一点就是, 大家可能会问, 服务器端那里给我写数据的时候他怎么就知道我页面定义的函数名字是什么?
这个就需要用到查到字符串, 我们可以在url后面加上callback这个查询字符串然后写上你的本地函数名, 传递到服务器服务器解析出来, 写出的时候再传递给页面, 这样就是动态的过程了.

大家如果观察过别人网站的url地址时是可以发现callback这个东西的.
例如网易云这个URL我加上callback, 随便给一个函数名字.
大家可以访问 http://s.music.163.com/search/get/?type=1&filterDj=true&s=%C2%A0%E7%88%B1%E5%B0%B1%E7%88%B1%E4%BA%86&limit=3&offset=0&callback=testJsonp
他在下发数据的时候就会加上这个函数名. 点开这个网页看看就可以看到`testJsonp(jsonObj)`的括号里面套了一个json对象.
如果看到的json是乱七八糟的网页源文件, 那么谷歌浏览器可以安装一个jsonview插件, 这样就显示了格式化之后的json.

本文针对jsonp方式的跨域请求进行简单的说明, 大家也可以去研究下JQuery提供的解决方案，理解了这个，那个就很容易了。
最后，跨域通信手段大概有：jsonp，document.domain，window.name，hash传值，possMessage，Access-Control-Allow-Origin看起来方法挺多，但是应用场景都有一定要求，按需使用吧。

