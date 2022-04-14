title: 谷歌验证码jar包Kaptcha的使用和运行过程
date: 2017-04-17 23:25:36

tags:
	- Java
categories:
	- 编程开发

---

首先说一下使用方法, 然后下面说一下运行过程!

### 使用方法

首先在web.xml中加入KaptchServlet

```xml
<servlet> 
    <servlet-name>Kaptcha</servlet-name>
    <servlet-class>com.google.code.kaptcha.servlet.KaptchaServlet</servlet-class>
</servlet> 
<servlet-mapping>
    <servlet-name>Kaptcha</servlet-name>
    <url-pattern>/kaptcha.jpg</url-pattern>
</servlet-mapping>
```

<!-- more -->


然后页面写一个form表单和一个验证码代码.

```jsp
<%@ page language="java" contentType="text/html;charset=UTF-8"
         pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>验证码</title>
<body>
<table>
    <tr>
        <td><img src="/kaptcha.jpg" id="kaptchaImage"></td>
        <td align="top">
            <form method="POST">
                <br>验证码:<input type="text" name="kaptchafield"><br/>
                <input type="submit" name="submit">
            </form>
        </td>
    </tr>
</table>

<%
    // 从session中获取验证码的值!
    String c = (String) session.getAttribute(
            com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);
    // 获取输入的验证码值!
    String parm = (String) request.getParameter("kaptchafield");

    if ( c != null && parm != null ) {
        if ( c.equals(parm) ) {
            out.println("<b>验证码正确</b>");
        } else {
            out.println("<b>验证码错误</b>");
        }
    }
%>

<!-- 引用Jquery之后再写这个代码就可以通过点击图片换验证码了. -->


<script type="text/Javascript">
    $(function() {
        $('#kaptchaImage').click(function () { 
            $(this).attr('src', '/kaptcha.jpg?' + Math.floor(Math.random()*100) ); 
        });
    });
</script>

</body>
</html>
```

使用就是这么简单. 下面说一下运行流程.

### 运行过程
**建议使用开启debug后跟着下面的描述看一下运行流程.**

这个框架是帮我们生成验证码用的, 验证码就是一个图片.
那么在生成的时候肯定要请求一个地址, 通过这个地址返回一个图片.
那么我们需要找到这个jar包用于生成验证码的servlet. 

在 https://code.google.com/archive/p/kaptcha/wikis/HowToUse.wiki 
查看查看谷歌的wiki()之后, 发现需要配置`com.google.code.kaptcha.servlet.KaptchaServlet`这个servlet. 配置格式为:

```xml
<servlet> 
    <servlet-name>Kaptcha</servlet-name>
    <servlet-class>com.google.code.kaptcha.servlet.KaptchaServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>Kaptcha</servlet-name>
    <url-pattern>/kaptcha.jpg</url-pattern>
</servlet-mapping>
```

好了, 这样在页面上再写一个img标签, 让src指向这个url-pattern里面的路径就可以拿到图片验证码了!
`<img src="/kaptcha.jpg"/>`
由于url-pattern是自定义的, 所以可以换成别的也可以.

这样基本的就搞定了, 打开`com.google.code.kaptcha.servlet.KaptchaServlet`这个servlet看一下里面的源码, 发现就两个方法, 一个init初始化, 一个doget处理请求的方法.

```java
@Override
public void init(ServletConfig conf) throws ServletException {
	super.init(conf);

	// Switch off disk based caching.
	ImageIO.setUseCache(false);

	Enumeration<?> initParams = conf.getInitParameterNames();
	while ( initParams.hasMoreElements() ) {
		String key = (String) initParams.nextElement();
		String value = conf.getInitParameter(key);
		this.props.put(key, value);
	}

	Config config = new Config(this.props);
	this.kaptchaProducer = config.getProducerImpl();
	this.sessionKeyValue = config.getSessionKey();
	this.sessionKeyDateValue = config.getSessionDate();
}
```

init方法就是通过servletconfig对象获取配置信息.
获取了所有的初始化参数, 然后放到一个Properties对象中.
然后把Properties对象传递过去, 创建Config对象, 

```java
public Config(Properties properties) {
	this.properties = properties;
	this.helper = new ConfigHelper();
}
```

可以看到没做什么额外的事情.
接下来config.getProducerImpl(), 获取一个验证码生成器对象.

```java
public Producer getProducerImpl() {
	String paramName = Constants.KAPTCHA_PRODUCER_IMPL;
	String paramValue = this.properties.getProperty(paramName);
	
	Producer producer = (Producer) this.helper.getClassInstance(paramName, paramValue, new DefaultKaptcha(), this);
	return producer;
}
```

前两句就是获取配置文件里有没有通过kaptcha.producer.impl配置自定义的验证码生成器对象.
this.helper.getClassInstance()就是通过ConfigHelper对象获取验证码生成器对象, 这里强转是干了一个向上转型的事!
getClassInstance()这个方法就是判断有没有在servlet的初始化参数里配置自定义的验证码生成器, 没有的话就返回传递过去的new DefaultKaptcha()对象.

----


接下来到init方法里的`this.sessionKeyValue = config.getSessionKey();`这一段代码.
这段代码是干嘛的呢, 作用就是看我们有没有在servlet里通过`kaptcha.session.key`配置用于给谷歌设置验证码值的session key初始化参数.
如果没有就返回`KAPTCHA_SESSION_KEY`这个字符串作为session的key.
可能大家不太理解为什么我这样说, 下面我会解释.
然后执行`this.sessionKeyDateValue = config.getSessionDate();`, 这个代码和上一段代码类似, 就是去初始化参数里找`kaptcha.session.date`的值, 用于session的key, 如果初始化参数里没有那么让`KAPTCHA_SESSION_DATE`这个字符串作为session的key.
这两个代码的作用一会我会解释.

----



执行完`this.sessionKeyDateValue = config.getSessionDate();`这段代码后, 整个`com.google.code.kaptcha.servlet.KaptchaServlet`的init方法完毕了, 也就是servlet的初始化完了.

不过这时候还没开始下发验证码, 那么上面时候下发呢.
当然是KaptchaServlet这个servlet的dopost或者doget方法被调用的时候执行.

但KaptchaServlet只有一个doget方法, 不提供doPost方法的原因就在于img标签src属性发起的是一个get请求而不是post请求.
所以聪明的google自然也没必要写一个多余的dopost了.
那么当浏览器加载img标签, 检查到src属性, 发起了一个可爱的get请求之后, KaptchaServlet开始执行doGet方法.
这个就是doGet的处理代码, 我们来研究一下.


```java
@Override
public void doGet(HttpServletRequest req, HttpServletResponse resp)
		throws ServletException, IOException {
	// Set to expire far in the past.
	resp.setDateHeader("Expires", 0);
	// Set standard HTTP/1.1 no-cache headers.
	resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
	// Set IE extended HTTP/1.1 no-cache headers (use addHeader).
	resp.addHeader("Cache-Control", "post-check=0, pre-check=0");
	// Set standard HTTP/1.0 no-cache header.
	resp.setHeader("Pragma", "no-cache");

	// return a jpeg
	resp.setContentType("image/jpeg");

	// create the text for the image
	String capText = this.kaptchaProducer.createText();

	// store the text in the session
	req.getSession().setAttribute(this.sessionKeyValue, capText);

	// store the date in the session so that it can be compared
	// against to make sure someone hasn't taken too long to enter
	// their kaptcha
	req.getSession().setAttribute(this.sessionKeyDateValue, new Date());

	// create the image with the text
	BufferedImage bi = this.kaptchaProducer.createImage(capText);

	ServletOutputStream out = resp.getOutputStream();

	// write the data out
	ImageIO.write(bi, "jpg", out);
}
```

前面那几行设置响应信息的代码就不看了.


```java
// create the text for the image
String capText = this.kaptchaProducer.createText();
```


这个代码, 看注释就知道是创建用于验证码的文本. 就是验证码的文本内容.

this.kaptchaProducer还记得这个值是啥吗?
看名字是验证码生成器的意思, 这个值早在init方法加载的时就被赋值了.
就是在`com.google.code.kaptcha.util.Config#getProducerImpl`这个方法里赋值的.
上面我已经说过这个方法了, 就是返回了谷歌自己的默认验证码生成器对象: **DefaultKaptcha**
然后`this.kaptchaProducer.createText()`就是调用DefaultKaptcha里面的createText()方法,
就是创建了一个文本. 我这里简单的讲解下文本的创建过程.感兴趣的朋友可以自己看底层代码.
底层代码在: `com.google.code.kaptcha.impl.DefaultKaptcha#createText`
主要实现过程就是先检查`KaptchaServlet`初始化参数里有没有配置`kaptcha.textproducer.impl`的值, 这个是配置自定义的文本生成器.

如果没有配置就创建谷歌自己的 DefaultTextCreator(默认文本生成器)对象.
调用createText()这个方法, 这个方法就是获取`KaptchaServlet`初始化参数为`kaptcha.textproducer.char.length`配置的一个字符串.
这个参数就是配置生成的验证码的字母数, 也就是字符数量. 如果没有配置, 那么底层传递的默认值是5个!
然后获取`KaptchaServlet`初始化参数中的`kaptcha.textproducer.char.string`配置的值, 这个配置就是生成验证码提供的字符串.
底层就是通过将这个字符串转成char数组, 然后根据长度随机取出5个字符作为验证码. 如果不提供这个值, 底层自己提供了一个默认的字符串.
这样就返回了验证码的文本.


这里提醒一下, 上面说到会获取初始化参数有没有配置`kaptcha.textproducer.impl`, 那么就是说我们可以通过实现TextProducer这个接口自己实现一个验证码文本生成器来生成自定义的文本.
然后`DefaultTextCreator`对象是`TextProducer`的实现类,  还有`ChineseTextProducer`和`FiveLetterFirstNameTextCreator` 两个实现类, 英文好的同学这里就知道这2个实现类是干啥子的了.
ChineseTextProducer 中文文本生成器, FiveLetterFirstNameTextCreator 以5个字母组成的人的名字生成器.
这两个类就比较简单了, 直接是提供一个string数据, 内置了一些字符串, 然后随机取其中一个返回.

-------



上面创建了验证码的文本, 到了下面的2个代码

```java
// store the text in the session
req.getSession().setAttribute(this.sessionKeyValue, capText);

// store the date in the session so that it can be compared
// against to make sure someone hasn't taken too long to enter
// their kaptcha
req.getSession().setAttribute(this.sessionKeyDateValue, new Date());
```

上面给大家埋了一个关子, 就是在KaptchaServlet初始化的时候获取了2个sessionKey.
这里来通过sessionKey往session里设置了刚才创建的验证码文本, 以及一个时间对象.
具体的作用, 这2个代码的注释说了. 存储验证码文本到session中, 以及存储当前的时间到session里,
然后存储当前时间可以依照这个来对比确保用户是不是过了很久才输入验证码.
这个有啥用呢, 就是说谷歌给我们提供了一个验证码超时的时间, 然后我们从session中获取这个key, 然后根据这个时间写一个判断是不是要让验证码失效. 因为我们有时候会需要让验证码失效的功能, 如果在一定的时间内没有输入.
至于第一个那个设置验证码文本到session中就是让我们更好的获取验证码的值来判断用户输入的是不是对的验证码.
比如我们在jsp中就可以写一个判断验证码对不对, 然后再决定要不要提交表单!

剩下的3行代码没什么好说的了, 底层的东西了, 设计到什么画图啊2d啊的东西, 本人还不懂, 就暂时不介绍了, 感兴趣的朋友自己研究吧.
主要就是把文本弄到一个图片上, 然后发送给浏览器.

```java
// create the image with the text
BufferedImage bi = this.kaptchaProducer.createImage(capText);

ServletOutputStream out = resp.getOutputStream();

// write the data out
ImageIO.write(bi, "jpg", out);
```



上面说了一堆, 其实还有很多地方没有说, 但这些已经差不多就是主要的流程了.
其他的特别细致的地方这里就不再说明.

简单说一下, 首先我们配置KaptchaServlet, 然后写一个url-pattern.
然后读取我们配置在Servlet中的初始化参数来生成验证码.
在生成验证码的时候会把验证码放到session中, session的key就是我们通过kaptcha.session.key配置的值.
如果没有配置那么session的key就是KAPTCHA_SESSION_KEY. 然后我们可以通过key来获取验证码的值, 来进行判断验证码是否正确!



补充: 上面说的很多可以在KaptchaServlet初始化参数中配置的东西, 可以在`com.google.code.kaptcha.Constants`这个类中看到.
定义了很多常量, 用于配置生成验证码的参数!

下面是整理的一些参数的意思: 

|配置项 |默认值 |说明 |
|:--:|:--:|:--:|
| kaptcha.border|yes | 验证码图片的边框，可以设置yes或者no|
| kaptcha.border.color|black | 边框的颜色reg值。合法值 rgb，black，blue，white|
|kaptcha.border.thickness | 1| 边框的厚度|
| kaptcha.image.width| 200| 图片的宽度|
|kaptcha.image.height |50 |图片的高度 |
| kaptcha.producer.impl| com.google.code.kaptcha.impl.DefaultKaptcha|验证码生成器实现类, 可以实现Producer接口自定义一个!|
| kaptcha.textproducer.impl|com.google.code.kaptcha.text.impl.DefaultTextCreator |生成验证码文字的实现类, 具体我上面描述过了. |
|kaptcha.textproducer.char.string |abcde2345678gfynmnpwx | 验证码中使用的字符|
| kaptcha.textproducer.char.length| 5|验证码中字符的数量|
| kaptcha.textproducer.font.names|Arial, Courier | 验证码的字体|
| kaptcha.textproducer.font.size| 40|字体的大小 |
| kaptcha.textproducer.font.color| black| 字体颜色 rgb值，颜色单词|
| kaptcha.textproducer.char.space|2 | 两个字符之间的间距|
| kaptcha.noise.impl| com.google.code.kaptcha.impl.DefaultNoise|干扰线生成类 |
|kaptcha.noise.color|black |干扰线颜色 |
|kaptcha.obscurificator.impl |com.google.code.kaptcha.impl.WaterRipple(水波效果) |模糊迷惑器的实现类.用于干扰验证码的识别! |
|kaptcha.background.impl |com.google.code.kaptcha.impl.DefaultBackground| 背景颜色设置类|
|kaptcha.background.clear.from |light grey |渐变颜色 左到右 |
| kaptcha.background.clear.to|white | 渐变颜色 右到左|
|kaptcha.word.impl | com.google.code.kaptcha.text.impl.DefaultWordRenderer|文本渲染器 |
| kaptcha.session.key| KAPTCHA_SESSION_KEY|配置获取验证码的sessionKey |
| kaptcha.session.date| KAPTCHA_SESSION_DATE|配置获取验证码生成的时间的session key.|






