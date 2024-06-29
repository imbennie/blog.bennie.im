---
title: Coze对话窗口放大、还原调整代码
date: 2024-05-21 11:12:00
tags:
    - Scripts
categories:
    - IT Notes

---

窗口大小受到这两个CSS类控制，可以用JS动态移除添加。
使用：打开浏览器的开发者工具，在控制台粘贴回车即可。

{% codeblock lang:objc %}
// 放大
document.querySelector(".IoQhh3vVUhwDTJi9EIDK").style.display='none';
document.querySelector("div.sidesheet-container.UMf9npeM8cVkDi0CDqZ0").classList.remove('UMf9npeM8cVkDi0CDqZ0');
{% endcodeblock %}


{% codeblock lang:objc %}
// 还原
document.querySelector(".IoQhh3vVUhwDTJi9EIDK").style.display = '';
document.querySelector("div.sidesheet-container").classList.add('UMf9npeM8cVkDi0CDqZ0');
{% endcodeblock %}


