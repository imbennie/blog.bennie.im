---
title: A标签onclick事件取消默认行为
date: 2017-11-24 21:16:01
tags:
	- Javascript
categories:
	- 前端

---


在开发中，经常会碰到为a标签绑定单击事件，由于a标签默认有跳转的行为，所以会影响到我们的onclick事件的处理代码。

我们需要屏蔽掉他的默认行为，下面是一些常用的方式。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>

<h1>方式1: href="javascript:void(0)"</h1>
<a href="javascript:void(0)" onclick="alert('方式1, 执行一段代码.')">情形1: 执行一段代码.</a> <br/>
<a href="javascript:void(0)" onclick="popup()">情形2: 调用一个已声明的js函数.</a> <br/>
<a href="javascript:void(0)" id="manual_bind_click_way1">情形3: 手动绑定click事件</a> <br/>

<h1>方式2: onclick="return false;"</h1>
<a href="http://www.google.com" onclick="alert('方式2, 执行一段代码.'); return false;">情形1: 执行一段代码.</a> <br/>
<a href="http://www.google.com" onclick="popup(); return false;">情形2: 调用一个已声明的js函数.</a> <br/>
<a href="http://www.google.com" id="manual_bind_click_way2">情形3: 手动绑定click事件</a>
<script>

    // 已声明函数popup
    function popup() {
        alert("弹窗测试.");
    }
    
    // 手动绑定click
    window.onload = function () {
        var aEle_way1 = document.getElementById("manual_bind_click_way1"); // 方式1 a标签.
        aEle_way1.onclick = function () {
            alert("手动绑定click事件.");
        }

        var aEle_way2 = document.getElementById("manual_bind_click_way2"); // 方式2 a标签.
        aEle_way2.onclick = function () {
            alert("手动绑定click事件.");
            return false;
        }
    }
</script>
</body>
</html>
```


在实现上大概有两种方式：

1. **方式1:** 为href属性添加`javascript:void(0)`来**构造伪链接, **即为：`href="javascript:void(0)"`
2. **方式2:** 添加onclick属性并在事件处理代码中通过`return false;`来**屏蔽默认行为**, 即为：`onclick="return false;"`(**这种方式表示希望保留href属性的内容**.)

这两种方式都会直接的**屏蔽跳转行为**.


----

我们在开发中可能会遇到如下3种情况, 比如说

1. 单击a标签后, 执行一段js代码. (**如情形1**)
2. 单击a标签后, 调用js中已经声明的函数. (**如情形2**, 这种情况大家一般传递this对象, 即: `onclick="popup(this)"`)
3. 我们想要手动为a标签绑定单击事件, 但是在事件执行后依然不希望a标签跳转. (**如情形3**)



需要说明的是如果以方式2的来实现情形3, 那么需要onclick事件处理最后返回false, 即return false, 否则执行完click事件后依然会跳转.
