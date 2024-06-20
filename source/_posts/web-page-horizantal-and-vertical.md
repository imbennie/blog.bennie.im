---
title: 网页文本完全水平+垂直居中
date: 2017-08-01 23:20:57

tags:
    - Frontend
    - CSS
categories:
    - IT Notes
---


### 实现方式1

定义一个表格，并套上tr及td：

```html
<table css="table">
    <tr>
        <td>文本</td>
    </tr>
</table>
```
<!-- more -->

加上css样式

```css
.table {
    width: 100%;
    height: 100%;
    position: absolute;
    top: 0;
    left: 0;
    text-align: center;
    /*vertical-align: middle;*/
    /*The default value is middle can inherit from tbody tag, so it's not necessary.*/ 
}
```

这个css样式的思路就是：
1. 首先将table变成和浏览器窗口一样的大小。通过设置`width: 100%; height: 100%;`
2. 其次设置`text-align: center;`让文本水平居中。
3. 接着让它的position为absolute表示，让它的子元素相对于它来定位，同时我们设置top和left为0，这时候它现在的位置就是从浏览器左上角00的位置开始了，同时因为absolute的设置可以让它的子元素就是相对于浏览器的最上最左的位置进行定位。
4. 最后我们其实可以设置一个`vertical-align: middle;`的样式，但是因为浏览器在处理table标签的时候会默认生成一个tbody标签，这个标签会自动有一个`vertical-align: middle;`样式，所以在tbody里面的tr和td元素会默认继承这个样式，所以这个样式我们就不用定义了。


### 实现方式2
同实现方式1同样的css样式，html代码改为以下：

```html
<div class="table" style="display: table">
    <span style="display: table-cell; vertical-align: middle;">这是要居中的文本</span>
</div>
```

方式2的实现思路就是将span应用`display: table-cell`样式后让其拥有和td一样的功能，就相当于将span变成了td元素，然后再通过`vertical-align: middle;`让其可以居中显示。