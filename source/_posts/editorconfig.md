---
title: EditorConfig使用和介绍
date: 2016-12-24 19:57:39
tags:
	- EditorConfig
categories:
	- 工具
---


官网: EditorConfig: http://editorconfig.org/
首先从官网下载安装插件到你需要的编辑器或者IDE中.

然后建立一个`.editorconfig`文件. 书写配置文件
例如: 
```
root = true

[*]
indent_style = tab
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```
<!-- more -->

然后将`.editorconfig`文件放到项目根目录中. 这时候插件就会根据配置生效了.
这个插件主要就是通过配置生效.
具体的使用很简单, 主要就是需要知道都有哪些东西可以配置.
下面是我翻译官网首页的一些内容, 供大家参考使用.

----------


**说明**: 下面英语原文中的`EditorConfig files`, 指的是EditorConfig的配置文件, 也就是: `.editorconfig`文件, 我会翻译成`EditorConfig配置文件`


## What is EditorConfig? | 啥是EditorConfig?

EditorConfig helps developers define and maintain consistent coding styles between different editors and IDEs. 
> EditorConfig帮助开发人员在不同的编辑器和IDE之间定义和维持始终如一的代码风格.

The EditorConfig project consists of **a file format** for defining coding styles and a collection of **text editor plugins** that enable editors to read the file format and adhere to defined styles.
> EditorConfig项目由一个文件格式构成用于规定代码风格, 文本编辑器插件让编辑器能够读取文件格式并跟随之前定义的样式.

EditorConfig files are easily readable and they work nicely with version control systems.
> EditorConfig文件的内容(配置信息)阅读起来是非常容易的, 他们于版本控制系统相结合的也很好(解释一下: 因为这个配置文件是以.editorconfig命名的, 所以老外才这么说).

## What's an EditorConfig file look like? | EditorConfig的配置文件看起来是啥样子的?

### Example file | 示例文件
Below is an example .editorconfig file setting end-of-line and indentation styles for Python and Javascript files.
> 下面是一个为Python和Javascript文件设置了行尾(end-of-line)和缩进风格(indentation styles)的示例配置文件.

```
# EditorConfig is awesome: http://EditorConfig.org

# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
insert_final_newline = true

# Matches multiple files with brace expansion notation
# Set default charset
[*.{js,py}]
charset = utf-8

# 4 space indentation
[*.py]
indent_style = space
indent_size = 4

# Tab indentation (no size specified)
[Makefile]
indent_style = tab

# Indentation override for all JS under lib directory
[lib/**.js]
indent_style = space
indent_size = 2

# Matches the exact files either package.json or .travis.yml
[{package.json,.travis.yml}]
indent_style = space
indent_size = 2
```

Check the Wiki for some real-world examples of [projects using EditorConfig files][1].
检查wiki看看那些在真实世界中使用了EditorConfig的项目.

### Where are these files stored? 这些文件在哪里保存?
When opening a file, EditorConfig plugins look for a file named .editorconfig in the directory of the opened file and in every parent directory. A search for .editorconfig files will stop if the root filepath is reached or an EditorConfig file with root=true is found.
> 当打开一个文件时, EditorConfig插件在打开文件的目录中寻找一个命名.editorconfig的文件, 并寻找每一个父目录! 当寻找到文件根路径的时候或EditorConfig的配置中配置了`root=true`则会停止搜索.

EditorConfig files are read top to bottom and the closest EditorConfig files are read last. Properties from matching EditorConfig sections are applied in the order they were read, so properties in closer files take precedence.
> EditorConfig的配置文件是从上往下读取的并且最近的EditorConfig配置文件会被最先读取. 匹配EditorConfig配置文件中的配置项会按照读取顺序被应用, 所以最近的配置文件中的配置项拥有优先权.

**For Windows Users**: To create an .editorconfig file within Windows Explorer, you need to create a file named .editorconfig., which Windows Explorer will automatically rename to .editorconfig.

> **Windows用户**: 在资源管理器(文件夹 - -)中创建一个`.editorconfig`文件时你需要创建一个`.editorconfig.`命名的文件, windows资源管理器会自动重命名为`.editorconfig`(这是闲的没事吗- -, 为什么不直接就命名为.editorconfig)


## File Format Details | 文件格式详情

EditorConfig files use an INI format that is compatible with the format used by [Python ConfigParser Library][2], but [ and ] are allowed in the section names. 
> EditorConfig配置文件使用一个INI格式的配置(就是ini配置文件的键值对格式, 和java里面的.properties文件的书写格式差不多), 这和Python ConfigParser库所使用的格式兼容.但是`[`和`]`在配置名中是允许的.


The section names are filepath [globs][3], similar to the format accepted by [gitignore][4]. Forward slashes (/) are used as path separators and octothorpes (#) or semicolons (;) are used for comments. Comments should go on their own lines. EditorConfig files should be UTF-8 encoded, with either CRLF or LF line separators.

> 配置名是一个[文件路径的通配形式][5], 类似于[gitignore][6]的公认格式. 斜线(/)被用作为一个路径分隔符并且井号(#)或分号(;)被用作于注释. 注释需要写在注释符号同一行(Comments should go on their own lines. 这里只能这么翻译...想不出别的翻译了). 


Filepath glob patterns and currently-supported EditorConfig properties are explained below.

> EditorConfig配置文件需要是UTF-8字符集编码的, 以回车换行或换行作为一行的分隔符.
下面的路径通配符模式和EditorConfig配置文件中当前支持的配置在下面说明




### Wildcard Patterns | 通配符模式

Special characters recognized in section names for wildcard matching:

|符号|说明|说明|
|:--:|:--:|:--:|
|* | Matches any string of characters, except path separators (/)|匹配字符串中的任意字符, 除路径分隔符(/)以外.|
| **| Matches any string of characters| 匹配字符串中的任意字符|
|? |Matches any single character |匹配一个单一的字符 |
|[name] |Matches any single character in name | 匹配name中的任意一个单一字符|
|[!name]|Matches any single character not in name|匹配不存在name中的任意一个单一字符|
|{s1,s2,s3}|Matches any of the strings given (separated by commas) (**Available since EditorConfig Core 0.11.0**)|匹配给定的字符串中的任意一个(用逗号分隔) 自EditorConfig核心0.11.0可用|
|{num1..num2}|Matches any integer numbers between num1 and num2, where num1 and num2 can be either positive or negative|匹配num1到num2之间的任意一个整数, 这里的num1和num2可以为正整数也可以为负整数|

Special characters can be escaped with a backslash so they won't be interpreted as wildcard patterns.
> 特殊字符可以通过一个反斜线符号转义, 所以它们不会被解释为通配符模式.

### Supported Properties | 已支持的配置

Note that not all properties are supported by every plugin. The wiki has a [complete list of properties][7].
注意不是每一个插件都支持所有的配置. 这里的wiki有一个[完整的配置列表][8](英文的没翻译!)!

- **indent_style**: set to tab or space to use hard tabs or soft tabs respectively.**设置缩进或空格用于硬缩进或者软缩进(tab就是硬缩进, 空格就是软缩进)**

- **indent_size**: a whole number defining the number of columns used for each indentation level and the width of soft tabs (when supported). When set to tab, the value of tab_width (if specified) will be used.**一个整数定义的列数用于每一个缩进的级别和软缩进的宽度(若支持). 当设置了缩进(indent_style属性值为tab时), tab_width属性的值也会被应用(如果指定tab_width属性)**

- **tab_width**: a whole number defining the number of columns used to represent a tab character. This defaults to the value of indent_size and doesn't usually need to be specified. **整数定义的列数用于表示制表符, 默认是indent_size的值并且通常不不需要指定**

- **end_of_line**: set to lf, cr, or crlf to control how line breaks are represented. **值: lf, cr或crlf, 用于控制换行符是如何表示的.**

- **charset**: set to latin1, utf-8, utf-8-bom, utf-16be or utf-16le to control the character set. Use of utf-8-bom is discouraged. **值: latin1, utf-8, utf-8-bom, utf-16be或utf-16le, 用于控制字符集, 使用utf-8-bom是discouraged的(- - 这个单词.. 心灰意冷的意思? 大概就是让我们不要使用utf-8-bom的意思吧.)**

- **trim_trailing_whitespace**: set to true to remove any whitespace characters preceding newline characters and false to ensure it doesn't.**设置true则在新行之前移除所有的空格字符, false则确保不会.**

- **insert_final_newline**: set to true to ensure file ends with a newline when saving and false to ensure it doesn't.(**设置true则在保存文件时在结尾添加一个新行, false则确保不会!**)

- **root**: special property that should be specified at the top of the file outside of any sections. Set to true to stop .editorconfig files search on current file. **特殊的配置, 需要被放在所有配置之上. 设置为true停止.editorconfig文件在当前文件上搜索!**

Currently all properties and values are case-insensitive. They are lowercased when parsed. Generally, if a property is not specified, the editor settings will be used, i.e. EditorConfig takes no effect on that part.

> 目前所有的配置和值都是忽略大小写的. 解析时它们都是小写的, 如果一个配置没有指定, 编辑器的设置会被使用, 例如对这部分EditorConfig插件不影响.

It is acceptable and often preferred to leave certain EditorConfig properties unspecified. For example, tab_width need not be specified unless it differs from the value of indent_size. Also, when indent_style is set to tab, it may be desirable to leave indent_size unspecified so readers may view the file using their preferred indentation width. Additionally, if a property is not standardized in your project (end_of_line for example), it may be best to leave it blank.


> 这是可以接受的, 通常更加喜欢留下一些EditorConfig配置不去指定. 例如, tab_width 不是必须指定的除非它和indent_size的值不一样. 同样, 当indent_style设置为tab时, 也许不指定indent_size正是我们想要的. 所以读者可能查看文件使用他们首选的缩进宽度. 此外, 如果一个属性在你的项目里不符合标准(例如end_of_line), 那么也许最好的是让他留下一个空白.

More details can be found on the [Plugin-How-To wiki page][9].
更多细节可以在[Plugin-How-To wiki 页面][9]找到.

------------------------


仅供大家参阅, 翻译有点生硬存在一些问题, 并且对理解也存在一些不到之处, 各位也可以参考这里的翻译: http://www.alloyteam.com/2014/12/editor-config/


[1]: https://github.com/editorconfig/editorconfig/wiki/Projects-Using-EditorConfig
[2]: https://docs.python.org/2/library/configparser.html
[3]: https://en.wikipedia.org/wiki/Glob_%28programming%29
[4]: http://manpages.ubuntu.com/manpages/intrepid/man5/gitignore.5.html#contenttoc2
[5]: https://en.wikipedia.org/wiki/Glob_%28programming%29
[6]: http://manpages.ubuntu.com/manpages/intrepid/man5/gitignore.5.html#contenttoc2
[7]: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties
[8]: https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties
[9]: https://github.com/editorconfig/editorconfig/wiki/Plugin-How-To