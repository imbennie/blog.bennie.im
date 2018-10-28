---
title: js对象(object)与文本(string)互转
date: 2016-09-03 16:59:48
tags:
	- Javascript
	- Json
categories:
	- 前端

---

曾经我天真的以为json对象和js对象是一个样子的.. 后来入了坑才知道其实是不一样的- -. 所以在开始之前我先强调一下**js对象**和**json对象**这两个对象的**文本表现形式**的书写格式.

**在下文我会按照以下规则对变量进行命名加以区分, 以免混乱:** 

<!-- more --> 

**对象，以Obj结尾**
1. json对象：jsonObj
2. js对象：jsObj



**对象文本表现形式，以ObjStr结尾**

1. json对象字符串：jsonObjStr
2. js对象字符串：jsObjStr




**语法格式**
```Javascript
var jsObj = {name: "tom", age: 12}; // js对象
var jsObjStr = '{name: "tom", age: 12}'; // js对象文本表现形式

var jsonObj = {"name": "jerry", "age": 13}; // json对象
var jsonObjStr = '{"name": "jerry", "age": 16}'; // json对象文本表现形式
```

可以看到**js对象的属性名**没有用引号进行包裹, 而**json对象的属性名用了引号包裹.**

虽然在Javascript里JSON对象也称为js对象的一种, 在很大程度上都是类似的, 但是在数据传输时我们都是用的JSON来传递, 所以在书写时应该注意相应的格式. **不然在使用Jquery的时候会出现服务端传递的不是json字符串出现错误导致success回调函数无法执行.**



-----



上面说完了, 下面开始说一下互相转换.

### **js对象**、**json对象**转**文本**
```Javascript
var jsObj = {name: "tom", age: 15};
var jsObjStr = JSON.stringify(jsObj);
console.log(jsObjstr);

var jsonObj = {"name": "jerry", "age": 16};
var jsonObjStr = JSON.stringify(jsonObj);
console.log(jsonObjStr );
```
JSON.stringify()方法, 不管传递的是js对象还是json对象都会转成字符串. 而且当传递是一个是js对象时, 转换后的字符串中的属性会自动包裹引号.(实际上是转成json对象字符串了)


### **文本**转**js对象**、**json对象**

使用**eval函数**可以直接将文本转成对象。

```Javascript
var jsObjStr = '{name: "tom", age: 15}';
var jsObj = eval('('+ jsObjStr +')');
console.log(jsObj);

var jsonObjStr = '{"name": "jerry", "age": 16}';
var jsonObj = eval('('+ jsonObjStr +')');            
console.log(jsonObj);
```

除了上面用eval函数转换**json对象文本**到**json对象**以外，还可以用`JSON.parse(jsonObjStr)`方法来转换，但此方法只用于将**json对象文本**转为**json对象**。

如果参数传递是**js对象文本**的话, 那么就会报语法错误：

> 
**VM2253:1 Uncaught SyntaxError: Unexpected token n in JSON at position 1**

```Javascript
var jsonObjStr = '{"name": "jerry", "age": 16}'; 
var jsonObj = JSON.parse(jsonObjStr);
console.log(jsonObj); // OK
            
var jsObjStr = '{name: "tom", age: 15}';
var jsObj = JSON.parse(jsObjStr);  // Error
console.log(jsObj);
```


### 总结:
1. 如果是对象转文本. 用`JSON.stringify(obj)`方法
2. 如果是文本转对象, 用`eval('('+ xxObjStr +')')`方法, 要用**()**包裹要转换的字符串变量. 
3. `JSON.parse(jsonObjStr)`方法只用于将**json对象文本**转成**json对象**.


如果本人说的不易理解, 也可参考: http://www.haorooms.com/post/js_jsons_h