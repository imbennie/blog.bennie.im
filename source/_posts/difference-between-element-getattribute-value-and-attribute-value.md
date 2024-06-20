---
title: HTML DOM基本概念及Element.getAttribute("value") 与Attribute.value差异
date: 2016-09-09 01:17:35
tags:
  - Frontend
  - HTML
categories:
	- IT Notes

---


今晚整理博客一个小功能的时候写个js, 发现了一个坑.. 一不小心就掉进去的坑..
弄明白之后, 本想针对此坑写写见解就完了, 但觉得趁这个机会顺便再次说一下HTML DOM相关的东东以加深理解及知识的相关性.

我一般喜欢以提问然后解决问题的方式学习, 在开始之前我先提出3个问题并对其说明及解释, 然后再引出后面的一些小问题及表述.
此文也算是作为本人个人的学习笔记, 与大家共勉.

<!-- more -->


## HTML DOM是什么?
HTML DOM 的全称为: HTML Document Object Model, 意思是: 文档对象模型. 我们常说的DOM, 就是HTML DOM. DOM是对HTML文档里所有的一个统称, 一个规范.

打开 w3c的网站 http://www.w3school.com.cn/htmldom/index.asp
这里对HTML DOM做出了解释.
第一句话就是: 
> 
HTML DOM 定义了访问和操作 HTML 文档的标准方法。
DOM 将 HTML 文档表达为树结构。

![image_1as55s16qgogk1qpqvun3gj813.png-71.2kB](/images/2018-05-29-173817.png)

由上面我们可以知道, HTML DOM只是一种定义, 用来定义HTML文档的访问和操作的一种方法而已.
那么图中的HTML DOM树, 就是用HTML DOM用来将HTML的结构定义成一种树状结构而已.

在点开 http://www.w3school.com.cn/htmldom/dom_intro.asp 这个页面, 可以看到这么一段.
![image_1as560dia1o9ccd51c6po751drq1g.png-22.6kB](/images/2018-05-29-173818.png)
w3c又说DOM是W3C的标准. 可见, DOM只是用来定义HTML的一种规范一个标准而已.


## HTML DOM节点是什么?
由上面我们知道DOM是用来定义东西的.
那么他是怎么定义的呢?
打开 http://www.w3school.com.cn/htmldom/dom_nodes.asp , 看到下面的这个说明.
![image_1as5644t41p5hc12ec61bpv1nai1t.png-39kB](/images/2018-05-29-173820.png)
那么我们知道DOM是把HTML中的所有东西都定义成节点, 或者通俗点的说在DOM的世界里他认为**HTML文档中的所有东西都是节点**(理解一下这个加粗的文本).
把节点分为以下5个类型.
1. 整个文档是一个**文档节点**
2. 每个 HTML 元素是**元素节点**
3. HTML 元素内的文本是**文本节点**
4. 每个(HTML元素中的) HTML 属性是**属性节点**
5. 注释是**注释节点**

好了, 通过这个, 我们知道HTML DOM节点是上面的那5种类型.
那么有人之前可能还疑惑HTML元素和HTML DOM节点什么关系? 其实通过上面, 我们已经知道HTML元素只是HTML DOM节点的其中一种类型.
但我们大多数人一想到**HTML DOM节点**就会条件反射的认为不就是**HTML元素**嘛, 其实不然, HTML元素只是HTML DOM节点的中的一种.

<font color="red">**注意**:</font> 虽然**HTML元素(节点)**只是**DOM节点**的一种, 但我们操作DOM节点时, 实际上是用元素方法,属性,事件来操作HTML元素, 所以我们会认为大部分的时候我们操作的DOM节点都是HTML元素.
**再次强调**: HTML元素不等于HTML DOM节点, HTML元素只是HTML DOM节点中的其中一种, HTML元素也更不等于HTML DOM, HTML DOM是用来定义HTML文档中**所有内容**的一种规范. 注意是所有内容而不是单单代表HTML元素.


## HTML DOM对象是什么?

我们打开: http://www.w3school.com.cn/jsref/index.asp
这个页面, 我们可以看到在左侧有个这一栏目.
![image_1as57jhg911npb868dmj4mf182n.png-3.4kB](/images/2018-05-29-173821.png)
下面4个子项. 可以看到: 

**HTML DOM对象**一共包含:
1. **DOM Document对象**(文档对象)
2. **DOM Element对象**(元素对象)
3. **DOM Attribute对象**(属性对象)
4. **DOM Event对象**(事件对象)

![image_1as5ah07sphn8ol1r943ccmr534.png-17.2kB](/images/2018-05-29-173822.png)
![image_1as5ahdc71hs74ud1hnq9qc1ob53h.png-10kB](/images/2018-05-29-173823.png)
![image_1as5ahl871ibqdr1m421tqv1hmg3u.png-4.6kB](/images/2018-05-29-173824.png)
![image_1as5ahsdm1e1j113711qs1f32ae74b.png-7.7kB](/images/2018-05-29-173825.png)

上面4个图是w3c官方给的解释, 这几个对象也就是为HTML DOM的一种封装, 这样子就方便我们操作, 同时这些对象在JS里都是可以访问的.
他们作用的就是将整个文档以及HTML元素封装成对象, 并对元素属性和事件也做封装, 让我们可以很方便的操作DOM.

-----------


上面介绍完了, 下面说一下我遇到的坑..
DOM对象中的**Element对象**和**Attribute对象**, 他们的关系是: **Element对象**是对HTML 元素的封装, **Attribute对象**则是对象HTML元素中的属性进行封装.

听起来有点绕, 以代码来说, 请运行一下下面这段代码. 
```Javascript
<form action="#" method="get" name="form">
  <input type="text" name="aa" value="123"/>
</form>
<button onclick="cc()">get value</button>
<script type="text/Javascript">
  function cc() {
    alert("Attribute对象访问value属性方式: " + document.form.aa.value); // 这个会弹出你输入的值.
    alert("Element对象调用getAttribute()方法方式: " + document.form.aa.getAttribute("value")); // 而这个每次都弹出123, 就是通过代码写的value=123
  }
</script> 
```
打开页面之后, input输入框中默认值为123, 就是我们在代码里写的`value="123"`.
此时页面打开了, 我们先把原来的123删掉, 输入一些别的东西.
然后单击按钮弹出2个提示框, 看一下前后2个值. 就知道两个值不一样了.

例如我在input输入框中输入12312321321321, 我的输出结果是: 

```
Attribute对象访问value属性方式: 12312321321321
Element对象调用getAttribute()方法方式: 123
```

因为一个拿到的是Element对象, 一个拿到的是Attribute对象.
2者区别是: 
1. Attribute对象拿到的是输入框中的数据.
2. Element对象拿到的是元素的初始数据(不知道这样说准不准确, 暂时这么说, 如果大家有标准的说法, 请回复告诉我.).

**什么叫元素的初始数据?**
可以理解为你写代码时value值里写的值, 元素中的数据是不会变的. 
我们可以通过审查元素来看看.
如图所示, 我在输入**12312321321321**之后, 元素里的123并没有改变.
![image_1as5brodmi731r5f1ptc6riv974o.png-35.2kB](/images/2018-05-29-173826.png)

现在我们知道区别了. 但我想大家可能还有个疑惑的地方, 那就是大家可能还想要知道Attribute对象里面都可以访问哪些属性和方法.
可以在 http://www.w3school.com.cn/jsref/dom_obj_attributes.asp 这里看到有以下这些属性.
![image_1as5c00fs9isij1kfu1jkmi5755.png-30.5kB](/images/2018-05-29-173829.png)

```Javascript
var input = document.getElementById("in");// 我们知道这个是拿到input这个HTML元素对象.

/***********************分隔符******************************/
// 这样写就是以Attribute对象的方式去访问元素value属性.
var value = input.value; 

// 而这样写是用Input这个Element对象去调用getAttribute方法的方式去访问元素的value属性值.
var value1 = input.getAttribute("value"); 
/***********************分隔符******************************/

// 以及在属性上面也是不一样的.
input.value = "ABC123"; // 这样写是以Attribute对象的方式去设置属性.
input.setAttribute("value", "ABC123"); // 这样就是用Element对象的方式去设置属性.
```

那么我遇到的坑就是我用了Element对象想要修改input的value值, 然后想当然的提交到表单, 结果发现压根本就没有获取到修改后的值..
所以在表单提交时, 这是一个坑. 如果要设置值, 用Attribute对象的方式去访问元素的属性然后设置值.

------

此文到此结束, 为了想将意思都说出来也是删删改改. 花了不少时间, 希望对大家有帮助. 共勉, cheers!


