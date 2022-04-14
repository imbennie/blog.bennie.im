---
title: java多态中的虚方法调用
date: 2017-02-19 00:17:27
tags:
    - Java
categories:
    - 编程开发

    
---



今天偶然看到这个东西, 想起来以前学的时候有点绕糊, 这里随笔记一下吧.

个人认为虚方法的调用发生在多态中.
例如以下两个类, 一个是Employee, 一个是Programmer

<!-- more -->

----

类: Employee 

```java
public class Employee {

    protected int salary;
    protected int age;
    protected String name;

    public void showInfo() {
        System.out.println("Employee中的showInfo方法");
        System.out.println("姓名: " + this.getName() + ", 年龄: " + this.getAge()
                + ", 工资: " + this.getSalary());
        System.out.println();
    }

    /**
     * 以下getter setter方法省略
     */
}
```

------

类Programmer:
```java
public class Programmer extends Employee {

    @Override
    public void showInfo() {
        System.out.println("Programmer中的showInfo方法" + "\n");
        System.out.println("姓名: " + this.getName() + ", 年龄: " + this.getAge()
                + ", 工资: " + this.getSalary());
    }
}
```

通过这两个类我们知道Programmer是Employee的子类, 所以拥有其中所有的方法, 包括我们重写的showInfo方法以及未重写的getter和setter方法.

然后我们再来看下这个代码来了解一下在多态的情况下, 以不同的实例对象调用重写的方法会发生什么情况:
```java
public class TestVitrualMethodInvoke {
    public static void main(String[] args) {
        Programmer programmer = new Programmer();
        programmer.setAge(23);
        programmer.setName("张三");
        programmer.setSalary(8000);
        
        Employee employee = new Programmer();
        employee.setAge(30);
        employee.setName("李四");
        employee.setSalary(5000);
        
        programmer.showInfo();
        employee.showInfo();
    }
}
```
首先我们new了2个Programmer, 但用不同的引用接收. 分别是Employee和Programmer引用.
我们知道: `Employee employee = new Programmer();`这段代码是一个多态的写法, 就是**父类的引用接收子类的实例对象.**

概念: **当父类的引用接收子类的实例对象时, 这时候调用重写的方法, 实际上调用的是重写后的方法, 也就是调用子类的方法, 虽然用于接收实例对象的引用是父类类型.**

> 下面是输出结果: 
Programmer中的showInfo方法
姓名: 张三, 年龄: 23, 工资: 8000

> Programmer中的showInfo方法
姓名: 李四, 年龄: 30, 工资: 5000

两次输出都是子类中被重写的方法.
这就是多态中的虚方法调用, 所以我们在今后的开发中需要注意这点.
如果我们想调用非子类中重写的方法, 那么就需要用父类的实例对象.
或者我们在子类中可以使用super.showInfo()这种方式来调用.

补充说明: jvm在执行这两段代码时是这样工作的.
```
Employee employee = new Programmer();
employee.showInfo();
```

首先`编译期间`先检查Employee中有无showInfo方法, 若无则无法编译通过.
然后在`运行期间`, 发现这个employee的实际引用的实例对象是Programmer, 所以就去调用Programmer中showInfo()方法, 这就是造成 上述现象的原因.
所以我们说多态的对象只有在运行期才可以确定.