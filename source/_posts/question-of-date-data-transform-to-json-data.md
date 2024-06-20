title: Date型数据转成json数据时出现的问题
date: 2016-02-17 19:35:08
tags: 
	- Java
categories:
	- IT Notes

---

今天在项目中遇到2个问题,关于从数据库读取日期类型数据和将Date型数据解析成JSON.
1. 问题1:
在页面上希望显示的日期格式为:`yyyy-MM-dd HH:mm:ss`,而读取数据库数据时返回的是英文格式的日期时间.
2. 问题2:
需要传递json数据给页面.而在解析该Date类型的属性时,输出的json字符串却类似于这样显示为时间戳.
```json
{"nanos":0,"time":-27076233600000,"minutes":0,"seconds":0,"hours":0,"month":11,"timezoneOffset":-480,"year":-789,"day":5,"date":22}  
```
很明显这不是我们想要的.

<!-- more -->

---

## 问题1
首先在读取数据库时就返回英文格式日期时间,所以首先得解决该问题.
本人数据库里的字段类型是Tiemstamp
然后我尝试将javabean属性类型改为下面两种类型
1. javabean的属性类型改为`java.util.date`, 进行数据库读取时,输出格式为英文的日期格式.
2. javabean的属性类型改为`java.sql.date`, 进行数据读取时,同样输出为英文的日期格式.

这两种方式都尝试过,但返回的数据依然不是我们想要的格式.

### 解决方案:
首先将Javabean属性的类型改为`java.sql.Timestamp`
```java
import java.sql.Timestamp;
private Timestamp createTime;
```

接着在框架的返回值类型那里同样映射为Timestamp.
以mybatis为例,在resultMap中增加`jdbcType="TIMESTAMP"`
```xml
<result column="message_createtime" property="createTime"
			jdbcType="TIMESTAMP" />
```
这样子数据库读取后就会返回中文的日期格式.

## 问题2

现在问题1解决了,以为在解析json时就会顺其而然的解析成功了.
但是却将那个其中createTime转换成了时间戳的格式.这样的格式在页面上显示肯定是不行的.
问题出在json解析这一块,于是我想着是不是现在用的json解析jar包的问题呢?
第一次用的gson解析,第二次换成了json-lib来解析,发现还是有这样的问题.

### 解决方案:

#### 使用Json-lib解决
于是就觉得这可能是个通病,打开谷歌一搜,看到如下如下文章(感谢该博主分享):
[JSONObject转换JSON--将Date转换为指定格式](http://zhourrr1234-126-com.iteye.com/blog/2067235)

照做一遍问题解决了.

---

这是Json-lib提供的一个转换器接口,实现他之后,我们根据自己的需要进行转换.

1. 第一步:
    ```java
    public class JsonDateValueProcessor implements JsonValueProcessor {  
        
        // 转换的格式
        private String format ="yyyy-MM-dd HH:mm:ss";  
          
        public JsonDateValueProcessor() {  
            super();  
        }  
          
        public JsonDateValueProcessor(String format) {  
            super();  
            this.format = format;  
        }  
      
        
        @Override  
        public Object processArrayValue(Object paramObject,  
                JsonConfig paramJsonConfig) {  
            return process(paramObject);  
        }  
      
        @Override  
        public Object processObjectValue(String paramString, Object paramObject,  
                JsonConfig paramJsonConfig) {  
            return process(paramObject);  
        }  
          
        // 定义方法自己进行自定义处理.
        private Object process(Object value){  
            if(value instanceof Date){    
                SimpleDateFormat sdf = new SimpleDateFormat(format, Locale.CHINA);    
                return sdf.format(value);  
            }    
            return value == null ? "" : value.toString();    
        }  
      
    }  
    ```

2. 第二步
    在转换成json字符串之前进行配置.
    
    ```java
    // 在使用JSONObject之前创建JsonConfig对象
    JsonConfig jsonConfig = new JsonConfig();  
    
    //注册我们自定义的date转换器
    jsonConfig.registerJsonValueProcessor(Date.class, new JsonDateValueProcessor());  
    ```

3. 第三步
    在使用JSONObject时,添加JsonConfig对象,例如我在把这个`jsonMap`转换为json时,就可以在后面加上jsonConfig对象.
    ```java
    JSONObject.fromObject(jsonMap, jsonConfig);
    ```

#### 使用Gson解决.
在创建Gson对象的使用
```
Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
```
这样输出的数据就是`yyyy-MM-dd HH:mm:ss`我们看上有好感的格式了.
