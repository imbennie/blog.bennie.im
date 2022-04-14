---
title: JS属性访问表达式之对象访问属性点方式与中括号方式的区别
date: 2016-03-14 23:30:41
tags:
	- JavaScript
	- 前端

categories:
	- 编程开发

---

js中属性访问表达式,通过表达式访问对象或者数组中的属性.
本文只讲解对象部分.

### js提供了2种语法:

1. expression.identifier // person.name
    这种写法是一个表达式后面加上一个点再加上标识符.
    表达式代表对象,标识符表示要访问属性的名称.

2. expression[expression] // person["name"]
    该方法由一个表达式后跟随一个中括号,并且中括号里面也算一个表达式.
    这种写法一般适用于对象和数组.第二个表达用于指定要访问的属性名或者数组的索引.
<!-- more -->
### 区别:
1. 一般点后面跟上的是对象的属性名标识符,注意是标识符而不是字符串.
例如: 
person.name //正确
person."name" // 语法错误

2. 中括号内跟的是属性名的字符串表示方式.
person["name"]// 正确
person[name]// 返回undefined

处理机制:
1. 不论方式1或方式2,在点和中括号之前的表达式也会进行计算.意思是说如果对象或者数组为undefined或者为null,那么就抛出类型错误异常.因为一个是未定义一个是空都无法包含属性.

2. 如果使用方式1也点访问属性,那么则直接在对象中查找点后标识符对应的属性,并返回该值.
如果使用方式2以中括号访问,那么先把中括号内的变量转换成为字符串再再对象中查找.(关于中括号方式下面我会继续说明)


### 代码说明

#### Code1
```javascript
<script type="text/Javascript">
    
    var person = {name:"Tom"}; // 对象Person
    
    console.log(person.name); // Tom,直接用name标识符去对象中找对应的属性找到了就返回(上面已经提过了.)
    console.log(person."name"); // 语法错误.
    
    console.log(person["name"]; // Tom
    console.log(person[name]); // undefined
</script>
```
代码1需要说明处:
`console.log(person["name"];`
// 输出结果:Tom
这里还需要说明一个过程.
js再创建对象的时候,实际上`var person = {name:"Tom"}`和`var person = {"name":"Tom"}`是相等的.也就是说你不加双引号,他也会自己给加上.
所以他根据中括号中的name字符串去对象中自然就可以找到对应的值.

`console.log(person[name]); `
// 输出结果:undefined
为什么会输出为undefined?
首先他先计算变量name的值尝试将它转成String类型.但是我们并没有定义name这个变量.所以中括号内的表达式计算结果为undefined,再去对象中找undefined显然是找不到的所以最终输出为undefined.

#### Code2
```Javascript
<script type="text/Javascript">
    var person = {name:"Tom"}; // 对象Person
    var namestr = "name";
    
    console.log(person.nameStr); // undefined
    console.log(person[nameStr]); // Tom
</script>
```
代码2需要说明的地方:
`console.log(person.nameStr); `
// 输出结果:undefined
为什么会是undefined?
这很好解释,他直接去对象中找nameStr属性,对象中并没有这个属性,自然就为undefined.

`console.log(person[nameStr]);`
这里可以输出Tom则是因为nameStr自动转换成了"name"这个字符串.这点上面提到了.
中括号里面的算是一个表达式,如果是一个变量,那么会自动转成字符串类型.
所以自然可以取到属性值. 



### 总结
以点的方式访问,那么一般都是写属性名.
而以中括号的方式访问,需要把属性名用双引号括起来.
如果中括号内是一个变量,那么会自动把变量转成字符串,再去对象中查找.

本文参考:《Javascript权威指南》4.4节:属性访问表达式.