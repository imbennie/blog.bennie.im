---
title: JS拖拽图片简单例子
date: 2017-01-01 04:50:00
tags:
	- Javascript
categories:
	- 前端

---


Reference: http://w3schools.bootcss.com/jsref/dom_obj_event.html

在H5中所有的元素都是可以被拖拽的, 通过给元素添加`draggable="true"`属性.

相关的地方: 
1. `ondragover` 事件发生在: 元素`拖拽`到`拖放`的目标元素之上时.(事件处理程序多次调用)
2. `ondragstart` 事件发生在: 元素`开始拖拽`之时(事件处理程序1次调用)
3. `ondrop` 事件发生在: `被拖拽`的元素`完成拖放`到目标元素盒子区域这一动作.(事件处理程序1次调用)
4. `事件的默认行为`, 比如说在复选框上点击按钮会发生选中或取消选中事件. 这里需要在ondragover事件里阻止浏览器默认打开的行为. 
5. [dataTransfer对象](https://developer.mozilla.org/zh-CN/docs/Web/API/DataTransfer). 在进行拖放操作时，进行数据的存储, 这个对象也保存了拖拽元素的数据.

<!-- more -->

```
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>JS拖拽图片简单例子</title>

	<style type="text/css">
		.drop-target {
			border: 1px solid black;
			width: 300px;
			height: 300px;
		}
		img#img {
			width: 200px;
			height: 200px;
		}
	</style>

	<script type="text/Javascript">
		function allowDrop(e) {
			e.preventDefault();
		}
		function dragStart(event) {
			var dataTransfer = event.dataTransfer;
			dataTransfer.setData("id", event.target.id);
		}

		function drop(event) {
			var dataTransfer = event.dataTransfer;
			var imgId = dataTransfer.getData("id");
			var img = document.getElementById(imgId);
			
			var div = event.target;
			div.appendChild(img);
		}

	</script>
</head>
<body>

<div class="drop-target" ondragover="allowDrop(event)" ondrop="drop(event)">
请将图片拖放到这里来.
</div>

<img id="img" ondragstart="dragStart(event)" src="https://ooo.0o0.ooo/2017/08/20/599865a851d49.png" draggable="true">
</body>
</html>

```
在ondragstart那里获取图片的id属性值, 然后在drop方法里获取属性值获取图片对象, 接着添加到div里即可. 在ondragover事件里做处理操作, 让div取消默认行为, 接受图片的放入.

另外, event对象的两次target分别是被拽放对象img和拖放接受对象div.