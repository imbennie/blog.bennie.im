---
title: JS获取项目路径
date: 2016-12-25 19:06:27
tags:
	- Frontend
	- JavaScript
categories:
	- Programming

---



写程序的时候在JS里面需要用到项目路径, 所以网上找了个例子, 然后看了下, 差不多如下.

```Javascript
function getRootPath() {
	// 获取主机地址, 如: http://example.com:8080
	var hostPath = document.location.origin;

	/**
	 * 获取URL中路径部分.
	 *
	 * 假设当前的URL是: http://example.com:8080/project_name/test.html
	 * 返回: /project_name/test.html
	 */
	var pathName = document.location.pathname;

	/**********************获取项目名****************************/
	var str = pathName.substr(1); // 返回: project_name/test.html
	var index = str.indexOf('/'); // 获取/所在的位置.

	/**
	 * 从 /project_name/test.html 截取项目名
	 * 这里加上1是因为index是在str的位置, 也就是在project_name/test.html中的位置
	 * 而这时候的截取是从/project_name/test.html这里开始的, 多了个长度, 所以要加上1.
	 */
	var projectName = pathName.substring(0, index + 1);

	/**
	 * 上面的三步可以直接这么写.
	 * var projectName = pathName.substring(0, pathName.substr(1).indexOf('/') + 1);
	 */

	return hostPath + projectName;
}
```

<!-- more -->

代码还是比较通用的, 主要利用`document.location.pathname;` 获取路径地址, 然后截取出项目名. 适用于下面2种情况:

1. **如果路径没有项目名**: `http://example:8080/test.html`
那么返回的是`http://example:8080`
2. **如果路径带了项目名**: `http://example:8080/project_name/test.html`
那么返回的是: `http://example:8080/project_name`


**如果路径没有项目名**时, 是这样的情况: 

```Javascript
var str = pathName.substr(1); //这里获取到的是test.html 
var index = str.indexOf('/'); // 这里返回-1.
var projectName = pathName.substring(0, index + 1); // 这里截取到的是空字符串.
```

**而如果路径带了项目名**, 我在上面代码注释里已经写了步骤介绍了过程. 这里就不再啰嗦了.


--------------------


另外说一下, 网上的例子在获取主机路径的时候是这样的写法.

```Javascript
// 先拿到当前页面的地址.
var currentPagePath = document.location.href;

// 然后获取URL中路径部分.
var pathName = document.location.pathname;

// 接着根据pathName在整个路径中的位置截取获取到主机路径.
var hostPath = currentPagePath.substring(0, currentPagePath.indexOf(pathName);
```

但是我debug的时候发现`document.location`里面有一个origin属性(**查了国内w3c并没有这个属性的介绍**), **这个属性值就是主机的路径**. 所以省的我们自己计算了, 同时我也测试过在带项目路径和没有项目路径这2种情况下, origin属性都是可以拿到主机路径的.

英文的W3C Location对象介绍页面有Origin这个属性: http://w3schools.bootcss.com/jsref/prop_loc_origin.html
