---
title:  Shell命令：如果存在指定类型文件名后缀，执行重命名操作移除后缀。 
date: 2019-10-31 15:43:56
tags:
    - Shell
categories:
    - IT Notes 


---

如果存在制定类型文件名后缀，执行重命名操作移除后缀。

```shell
if `ls *.flv.tmp 1> /dev/null 2>&1`; then `rename .flv.tmp .flv *.flv.tmp`; fi;
```

参考文章：https://codeday.me/bug/20170407/9041.html

rename命令用法自行了解。
