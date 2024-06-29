---
title: Maven中的一些概念及笔记
date: 2018-07-24 15:36:13
tags:
    - Java
    - Maven
categories:
    - IT Notes

---

以前粗浅的学习过Maven的一些概念，但后来时间长了忘记了。虽然也会用，但做项目期间也经常断断续续的查找Maven相关的概念及知识，总觉得不是个事没有建立起比较整体的概念，所以这里写个笔记记录一下Maven的一些概念以及使用方面的东西，方便以后查阅。

<!-- more -->

记得以前看到过一句话，说是如果你无法向别人讲清楚一个东西，那说明你没有真正的掌握它。所以我记东西或者说写博客有个特点，会将自己做为第三者的角度去对待，一方面是为了记录下来能让自己以后一个参考，一方面也是为了想让自己和别人理解这个东西，所以文章可能写的有些唠叨，因为记录了一些在了解过程中的疑问及想法，毕竟学习的时候总有点好奇心不是。

### Maven生命周期和插件

在开始之前先说明一下，Maven的生命周期和插件是两个东西，Maven的生命周期实际上不负责任何实际的东西，实际执行生命周期的阶段时是依靠绑定其绑定到的插件目标上来完成的。可以理解为，生命周期中定义了一些阶段行为，执行阶段行为时，会去寻找其绑定插件对应的目标来完成指定的操作。光说概念还是有点抽象，下面来详细说一下生命周期和插件是个什么东东以及它们如何完成相互配合的。



#### 生命周期

在生命周期中首先要明白两个概念：

- **生命周期：**Maven拥有三套**相互独立**的生命周期，它们分别为clean、default和site。
- **生命周期中的阶段**：每个生命周期包含一些阶段（phase），这些阶段是有顺序的，并且后面的阶段依赖于前面的阶段，**用户和Maven最直接的交互方式就是调用这些生命周期阶段。**(这句话如何理解，下文会说)

那这时候我们就想要知道，每个生命周期中都有哪些阶段？都负责些什么操作。

> 在Maven的官网文档，我们可以查阅**Maven各生命周期包含的阶段**：https://maven.apache.org/ref/3.5.3/maven-core/lifecycles.html ，还可以**查阅这里了解一下各阶段的功能介绍**：https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference



这里以clean生命周期为例，可以看到它包含的阶段有pre-clean、clean和post-clean。

```Xml
<phases>
  <phase>pre-clean</phase>
  <phase>clean</phase>
  <phase>post-clean</phase>
</phases>
<default-phases>
  <clean>
    org.apache.maven.plugins:maven-clean-plugin:2.5:clean
  </clean>
</default-phases>
```

下面的`default-phases`中将clean生命周期中的clean阶段绑定到了插件`org.apache.maven.plugins:maven-clean-plugin:2.5`的clean目标上。**那这个意思就是说，生命周期中的某个具体的阶段可以绑定到插件的某个具体的目标上。**

同样，我们可以再看看site生命周期中与插件的绑定关系。

```xml
<phases>
  <phase>pre-site</phase>
  <phase>site</phase>
  <phase>post-site</phase>
  <phase>site-deploy</phase>
</phases>
<default-phases>
  <site>
    org.apache.maven.plugins:maven-site-plugin:3.3:site
  </site>
  <site-deploy>
    org.apache.maven.plugins:maven-site-plugin:3.3:deploy
  </site-deploy>
</default-phases>
```

看完clean以及site的生命周期阶段与插件目标的绑定关系后，我还想要看看default生命周期中的绑定关系是怎样的。我这里留到最后说default生命周期是因为它有一些特殊，如果你打开上文给的生命周期各阶段的链接后，你会发现官网告诉你说default生命周期没有关联到任何插件，然后又告诉你说绑定到这个生命周期中的插件是取决于packing的打包类型来单独定义的。

> `default` lifecycle is defined **without** any associated plugin. Plugin bindings for this lifecycle are [defined separately for every packaging](https://maven.apache.org/ref/3.5.3/maven-core/default-bindings.html)

点开链接后我们就可以看到在default生命周期的处理上，针对不同的packing类型提供了不同的阶段到插件目标的绑定关系。一开始我没弄明白为什么要这么干，后来觉得应该是不同的打包类型取决于不同的应用场景，所以要根据需要使用不同的插件（个人理解）。例如packing类型为pom的通常不需要测试、编译这些处理。然后其他的打包类型，虽然大部分像资源处理、测试、编译都是需要的，但可以看到打包时所使用的插件还是不一样的。

例如packing类型为jar的和为war的package阶段绑定的插件就不一样。

```xml
<!-- packing为jar -->
<package>
    org.apache.maven.plugins:maven-jar-plugin:2.4:jar
</package>
 
 <!-- packing为war -->
<package>
    org.apache.maven.plugins:maven-war-plugin:2.2:war
</package>
```


> 上面简单看了一下各个生命周期与插件目标的绑定关系，也对各个阶段的基本功能有了一些了解。但另一点我对Maven中**default生命周期中大部分的阶段都没有绑定到实际的插件目标**有些不太理解，[在这里](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference)可以看到default生命周期中定义了一系列的阶段，但是将网页往下拉一点的[Built-in_Lifecycle_Bindings](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Built-in_Lifecycle_Bindings)中可以仔细看一下就可以发现default生命周期中并不是所有的阶段都绑定到了插件目标上。例如`generate-test-sources`、`process-test-classes`、`integration-test`等就没有具体的绑定关系，所以我猜想如果这些阶段得以执行的话，那么可能是Maven内部做了一些绑定处理，否则就是它们不会有实际的行为。，这点目前还需要进一步证实。



上面介绍完了maven中三大生命周期阶段到插件目标的绑定关系，对生命周期应该有一个初步的理解了。

在一开始对生命周期阶段的描述中提到了**“阶段是有顺序的，而且后面的阶段会依赖前面的阶段。”**

这里还以clean生命周期来举例说明：
> 当用户调用pre-clean的时候（在命令行输入mvn pre-clean的时候），只有pre-clean阶段得以执行；
> 当用户调用clean的时候，pre-clean和clean阶段会按顺序执行；
> 当用户调用post-clean的时候，pre-clean、clean和post-clean会按顺序执行。

并且上面说到生命周期是相互独立的，意思是说，我们可以调用某个生命周期中的某个具体的阶段，而命令执行时，不同的生命周期之间不会有影响。

用clean来举例只是帮助理解概念，事实上真正核心的生命周期是default，它里面定义了一系列的阶段。那么这时候我们就知道，我们执行default生命周期的install阶段时，在install阶段之前的所有阶段都会执行，从而可以帮我们完成validate、initialize、resources、compile、test等一系列的操作，从而来简化我们的工作。

这就是生命周期方便的地方以及它所完成的事情。



**这里介绍一下在使用时如何执行生命周期的目标来完成相应的任务：**

我们在命令行如果想要执行生命周期中的阶段时，可以不需要输入生命周期的名字，直接输入具体的阶段名称就可以。Maven会自己去找这个阶段是属于哪个生命周期，然后并执行他前面所有的阶段。例如想要执行default中的packge阶段完成打包操作，那么执行`mvn packge`就可以了。

**此外**，Maven也允许多个阶段一起执行（可以是不同生命周期中）

例如`mvn clean deploy site-deploy`执行了clean生命周期的clean阶段、default生命周期的deploy阶段，以及site生命周期的site-deploy阶段。实际执行的阶段为clean生命周期的pre-clean、clean阶段，default生命周期的所有阶段，以及site生命周期的所有阶段。

通常我们在使用时，会经常用到`mvn clean package`来在执行打包前清理上一次的构建。



#### 插件和目标





### 聚合和继承




