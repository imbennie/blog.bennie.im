---
title: Java中finally和return的执行顺序
date: 2018-06-27 02:12:26
tags:
 - Java
categories:
 - Java

---


try...catch…finally语句中return语句的执行测试.



有时候想起来finally和return语句的执行顺序上会有一些混乱, 这里写了几个测试例子来弄清楚它们的执行顺序, 虽然网上也有很多这样的文章, 但还是觉得自己实际写个例子体会一下会更加映像深刻些.



大致有2种形式, 分别是带有catch语句和不带catch语句: 

**不带有catch语句**

1. try中有return语句, finally中没有return语句.
2. try代码块和finally中都有return语句.

**带有catch语句**

1. try…catch…语句块中都有return语句, 但finally中没有return语句.
2. try…catch…finally...语句块中都有return语句.



<!-- more -->



这里考虑catch语句的情况是因为, catch语句的加入会影响try语句的执行, 如果try和catch的语句块中都有return语句, 那么当try语句块中代码发生异常时, 那么就相当于if else的选择, 只能有一个return语句会被执行. 这个下文中会列举具体的情形代码.

我们先从简单的不带有catch代码块的情形开始出发来了解.



## 不带有catch语句的情形

### 1. try中有return语句, finally中没有return语句.

```java
public class ReturnAndFinalTest {

    public static void main(String[] args) {
        int i = new ReturnAndFinallyTest().test();
        System.out.println("test方法返回值: " + i);
    }

    public int test() {
        int i = 100;

        try {
            
            System.out.println("try代码块");
            i += 10;
            return i;
        } finally {
            
            System.out.println("finally代码块, i = " + i);
            i += 20;
        }

    }

}

```

执行结果:

> try代码块
> finally代码块, i = 110
> test方法返回值: 110



通过这个测试结果可以看到以下现象:

1. finally中的语句是在try中的return语句之后执行的.
2. try中的return语句并没有真正的让方法返回. 
3. main方法中获取到值是110, 说明方法返回值不是finally中修改后的i变量值. **所以可以确定try中return语句的i变量值在执行finally语句之前就已经确定了.**



**结论**: try中的return语句不会让方法真正返回, 但在return语句执行时就确定了方法最终的返回值, 真正的方法返回是在执行了finally语句块中的代码之后.

**关于现象3, 我们会想到一个问题**: 
在try中return语句返回的是一个基本类型int, 所以在finally中做赋值操作不会影响到返回的值, 但如果是一个引用类型, 我在finally中将引用的内容更改掉会不会影响try中return语句的返回的内容. 关于这点可以参考后文中的[返回值为引用类型时是否会修改返回值](#返回值为引用类型时是否会修改返回值)



### 2. try代码块和finally中都有return语句.

```java
public class ReturnAndFinallyTest {

    public static void main(String[] args) {
        int i = new ReturnAndFinallyTest().test();
        System.out.println("test方法返回值: " + i);
    }

    public int test() {
        int i = 100;

        try {

            System.out.println("try代码块");

            // 这里做一次赋值操作.

            return i += 10;

        } finally {
            System.out.println("finally代码块, i = " + i);

            i += 20;
            return i;
        }

    }

}

```

执行结果:

> try代码块
> finally代码块, i = 110
> test方法返回值: 130



通过这个测试结果可以看到以下现象:

1. finally中获取到的i变量为110说明try中的return语句赋值操作生效了.
2. 方法最终的返回为130说明try中return语句并没有真正的让方法返回. 
3. test方法返回值为130表示finally中的return语句生效了, 说明finally中的return让方法最终返回.

**结论**: try中的return语句虽然执行了但并没有引起方法的返回并且即使其中有return语句, 还是会执行finally中的代码, 当发现finally中也有return语句时, 就使用该return语句作为方法的最终返回值.





## 带有catch语句



###1. try…catch…语句块中都有return语句, 但finally中没有return语句. 

```java
public class ReturnAndFinallyTest {

    public static void main(String[] args) {
        int i = new ReturnAndFinallyTest().test();
        System.out.println("test方法返回值: " + i);
    }

    public int test() {
        int i = 100;

        try {
            System.out.println("try代码块");
            // 触发一个异常
            int a = i / 0;
            return i += 10;
        } catch (Exception e) {
            System.out.println("catch代码块");
            return i += 1;
        } finally {
            System.out.println("finally代码块, i = " + i);
            i += 20;
        }
    }
    
}
```



执行结果:

> try代码块
> catch代码块
> finally代码块, i = 101
> test方法返回值: 101

通过这个测试结果可以看到以下现象:

1. try中的代码发生异常后, try代码块的return语句没有起作用.
2. 方法返回值为101, 说明catch语句让方法返回了.



**结论**: 

1. 所以我们可以得出一个结论, try和catch其实从某个角度理解就像是if else, 如果try中有异常, 那就走catch流程, 如果没有那就走自己的流程. 所以具体执行try和catch中的哪个return语句是取决于try中是否有异常发生. 
2. 同时我们也可以看到在try和catch中都有return语句时, test方法就不需要在方法最末尾再去写return语句了, 因为try和catch中的return语句总有一个会执行.



### 2. try…catch…finally...语句块中都有return语句. 

```java
public class ReturnAndFinallyTest {

    public static void main(String[] args) {
        int i = new ReturnAndFinallyTest().test();
        System.out.println("test方法返回值: " + i);
    }

    public int test() {
        int i = 100;

        try {
            System.out.println("try代码块");
            int a = i / 0;
            return i += 10;
        } catch (Exception e) {
            System.out.println("catch代码块");
            return i += 1;
        } finally {
            System.out.println("finally代码块, i = " + i);
            i += 20;
            return i;
        }

    }
}
```



执行结果:

> try代码块
> catch代码块
> finally代码块, i = 101
> test方法返回值: 121



通过这个测试结果可以看到以下现象:

1. 方法返回值为121, 说明是catch中的return语句的赋值操作生效了, 但并没有让方法返回.
2. 最后让方法返回是的finally中的return语句.

**结论**: 无论try和catch语句中是否有return, 都会执行finally中的代码并且如果finally中有return语句, 那么就以该return语句作为方法的返回. (这一点和之前的现象一样)



## 返回值为引用类型时是否会修改返回值

```java
class User {
    private String name;
    private int age;

    public User() {
    }

    public User(String name, int age) {
        this.name = name;
        this.age = age;
    }

    // getter and setter

   // toString
}

public class ReturnAndFinallyTest {

    public static void main(String[] args) {
        User user = new ReturnAndFinallyTest().test();
        System.out.println("test方法返回值: " + user);
    }

    public User test() {
        User user = null;
        User u1 = new User("用户1", 11);
        User u2 = new User("用户2", 12);

        try {

            System.out.println("try代码块");
            user = u1;
            return user;
        } finally {
            System.out.println("finally代码块");
            user = u2;
            
            // user.setAge(13);
        }

    }

}
```

我们用到一个User类用来模拟一个对象, 然后再try代码块里面为`User user`引用, 赋值了u1这个对象, finally代码块里面为`User user`赋值为u2. 如果`user = u2;`语句影响到try代码块里的`return user;`的返回结果, 那么说明可以对引用的对象内容进行修改.

执行结果:

```
try代码块
finally代码块
test方法返回值: User{name='用户1', age=11}
```



通过这个测试结果可以看到以下现象:

1. main方法的输出结果说明, finally中对user的引用地址进行的修改是未生效的.
2. 同样的和之前的基本数据类型int的测试结果一样, 在finally代码块的代码执行之前try中`return user;`的user引用就已经被确定下来, 无法将引用更改到其他的User对象上.



结论:

1. 不管try中返回是基本类型还是引用类型, 在finally中是无法对try中return语句的返回值做修改的, 这里的返回值, 如果是基本类型, 那么传递的基本类型的变量值; 如果是引用类型, 那么传递的是引用类型的对象引用地址. 
2. 虽然在finally中更改try中return语句的引用地址, 但可以修改它引用的对象的内容, 例如上面注释的`user.setAge(13);`是可以操作成功的.

**其实根本上就是java中的值传递问题, 基本类型传递的是值, 引用类型传递的是对象引用地址.**



## 最后总结



总结内容是从参考文章中的评论里拷贝过来的. (因为懒得自己写了...)



>  finally块的语句在try或catch中的return语句执行之后返回之前执行且**finally里的修改语句不能影响try或catch中 return已经确定的返回值**，若finally里也有return语句则覆盖try或catch中的return语句直接返回。



> 1. 执行时机问题。finally总会执行（除非是System.exit()），正常情况下在try后执行，抛异常时在catch后面执行，即使try和catch中存在return语句
> 2. finally中是否有return语句，决定了方法是否最终从finally中返回。
> 3. 返回值问题。可以认为try（或者catch）中的return语句的返回值放入线程栈的顶部：如果返回值是基本类型则顶部存放的就是值，如果返回值是引用类型，则顶部存放的是引用。finally中的return语句可以修改引用所对应的对象，无法修改基本类型。但不管是基本类型还是引用类型，都可以被finally返回的“具体值”具体值覆盖 
> 4. 不建议在finally中使用return语句，如果有，eclipse会warning“finally block does not complete normally”







**参考文章:** 
[Java finally语句到底是在return之前还是之后执行？](https://www.cnblogs.com/lanxuezaipiao/p/3440471.html)
