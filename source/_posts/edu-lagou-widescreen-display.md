---
title:   拉勾教育宽屏调整油猴脚本
date: 2022-01-28 12:02:22
tags:
    - 脚本
categories:
    - 折腾
---

拉勾教育课程文章页的显示宽度太窄，看起来不舒服，用css处理了下。
使用：加载脚本，点击“展开目录”后便可以更宽的显示效果。

<!-- more -->

```javascript

// ==UserScript==
// @name         拉勾宽屏
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       Bennie
// @match        https://kaiwu.lagou.com/course/*
// @icon         https://s0.lgstatic.com/mds-icon-fed/kaiwu/logo@2x.png
// @grant        none
// ==/UserScript==

window.onload = function() {
    let element = document.querySelector("div.item-wrap:nth-child(1)")
    element.addEventListener("click", function(){
        let status = getStatus();
        console.log(status);
        if (status === 1) {
            setWidthMode();
        } else {
            resetOrigin();
        }
    });
}

function getStatus() {
    return document.querySelector("div.item-wrap:nth-child(1) > div:nth-child(2)").innerText === "展开目录" ? 1 : 0;
}

function resetOrigin() {
   let lcw = document.querySelector("div.left-content-wrap");
   lcw.removeAttribute("style");

    let rcw = document.querySelector("div.right-content-wrap")
    rcw.removeAttribute("style");

    document.querySelector("div.main-wrap").removeAttribute("style");
}

function setWidthMode() {
    document.querySelector("div.left-content-wrap").setAttribute("style", "left:0%")
    let right = document.querySelector("div.right-content-wrap")
    right.setAttribute("style", "margin-left: 0%; width:100%")

    document.querySelector("div.main-wrap").setAttribute("style", "max-width: 100%; margin: 50px")

    // 代码块调整
    //document.querySelector("div.right-content-wrap pre").setAttribute("style", "width:100%")
    loadCssCode("div.right-content-wrap pre { width: 100% }");
}


function loadCssCode(code){
    var style = document.createElement('style');
    style.type = 'text/css';
    style.rel = 'stylesheet';
    //for Chrome Firefox Opera Safari
    style.appendChild(document.createTextNode(code));
    //for IE
    //style.styleSheet.cssText = code;
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(style);
}


```