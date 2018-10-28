title: 初始化Servlet时配置Log4j, 并将日志保存在磁盘上.
date: 2016-03-17 21:53:56
tags:
	- Servlet
	- Log4j
	- Java
categories:
	- Java


---

通过Servlet初始化参数配置Log4j, 并将日志保存在磁盘上.

### 新建Servlet并配置启动参数
新建一个Servlet: log4jInit.java, 建立完之后,前往web.xml文件找到配置项, 添加初始化名和参数值.
```xml
<servlet>
    <display-name>Log4jInit</display-name>
    <servlet-name>Log4jInit</servlet-name>
    <servlet-class>com.xxxx.util.Log4jInit</servlet-class>
	
    <init-param>
	  <!-- 初始化参数名. -->
      <param-name>log4j</param-name> 
	  
	  <!-- 配置log4j.properties的位置(该路径为项目部署后的路径) -->
      <param-value>WEB-INF/classes/log4j.properties</param-value> 
    </init-param>
	
    <load-on-startup>1</load-on-startup>
  </servlet>
```
<!-- more -->
### 回到Servlet的init()方法中配置log4j
```java
package com.xxxx.util;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;

import org.apache.log4j.PropertyConfigurator;


public class Log4jInit extends HttpServlet {
       
	public void init(ServletConfig config) throws ServletException {
		
		/**
		 * 1. 获取项目磁盘上的真实(物理)路径.
		 * 
		 * 地址类似于:
		 E:\Program\Eclipse\workspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\你的项目名\
		 * (以路径分隔符结尾, windows为\ linux为/)
		 */
		String projectRealPath = getServletContext().getRealPath("/");
		
		/**
		 * 2. 在JVM系统中设置一个全局变量.
		 * 设置后我们可以在log4j.properties文件中以${projectRealPath}这样的形式来引用项目真实路径.
		 * 这样子设置, 我们可以用来把日志动态保存到硬盘的某一处。
		 * 该方法详情见: http://blog.csdn.net/yong199105140/article/details/8425454
		 */
		System.setProperty("projectRealPath", projectRealPath);
		
		
		/**
		 * 3. 根据指定的InitParameter获取我们在web.xml配置的InitParameter参数值.
		 * 也就是获取我们配置在web.xml中配置的log4j.properties的文件路径(WEB-INF/classes/log4j.properties).
		 * 
		 * 也可以用getServletContext().getInitParameter("log4j");来获取.
		 * 与这种方式的区别是, config.getInitParameter("log4j");获取的是当前Servlet中的.
		 * 
		 * 而getServletContext().getInitParameter("log4j");
		 * 是在整个上下文中获取(可以理解为配置在web.xml中的所有Servlet的配置中获取)
		 */
		String log4jPropertiesFilePath = config.getInitParameter("log4j");
		
		/**
		 * 4. 如果获取到配置在servlet初始化参数中的log4j.properties的文件路径.
		 * 我们则用Log4j提供的方法进行配置.
		 */
		if (log4jPropertiesFilePath != null) {
			PropertyConfigurator.configure(projectRealPath + log4jPropertiesFilePath);
		}
	}
}
```
<!-- more -->


### log4j.properties中引用项目路径.
`${projectRealPath}/log/logFile.log`代表我们将log文件生成在项目所在的目录里面,这也是我们在Servlet中通过`System.setProperty("projectRealPath", projectRealPath); //`设置的一个系统属性.
```
log4j.rootLogger=debug,stdout,D

log4j.appender.stdout = org.apache.log4j.ConsoleAppender  
log4j.appender.stdout.Target = System.out  
log4j.appender.stdout.layout = org.apache.log4j.PatternLayout  
log4j.appender.stdout.layout.ConversionPattern = [%-5p] [%d{yyyy-MM-dd HH\:mm\:ss}] [method\:%l]%n%m%n  

### 用于将日志保存在磁盘上.
log4j.appender.D = org.apache.log4j.DailyRollingFileAppender # 日志的记录周期为每天保存一次。
log4j.appender.D.File =${projectRealPath}/log/logFile.log # 日志保存的路径。
log4j.appender.D.Append = true
log4j.appender.D.Threshold = DEBUG   
log4j.appender.D.layout = org.apache.log4j.PatternLayout  
log4j.appender.D.layout.ConversionPattern=[%-5p] [%d{yyyy-MM-dd HH\:mm\:ss}] [method\:%l]%n%m%n
```