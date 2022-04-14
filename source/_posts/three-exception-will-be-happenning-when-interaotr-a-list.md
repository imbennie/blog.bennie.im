---
title: 遍历List集合时出现的3种异常
date: 2017-04-10 21:29:48
tags:
    - Java
categories:
    - 编程开发
---

参考: 
http://blog.csdn.net/izard999/article/details/6708738
http://bbs.itheima.com/thread-41997-1-1.html

## 异常1 
异常: **java.util.ConcurrentModificationException** (并发修改异常)

link: http://bbs.itheima.com/thread-41997-1-1.html 此贴描述了第一种异常.
当我们在使用foreach这个增强型for循环遍历List时, 除了`System.out.println();`打印可以之外, 其他add, remove等操作会发生异常(`执行set方法不会抛出异常`).

<!-- more -->


```java
public class AAA {

    // 要求： 查找集合中有没有zhangsan这个字符串。如果有，则再添加一个lisi进去。

    public static void main (String[] args) {
        // 创建集合对象
        List<String> list = new ArrayList<String>();

        list.add("zhaoliu");
        list.add("zhangsan");
        list.add("wangwu");

        // 普通for循环
        for ( int x = 0; x < list.size(); x++ ) {
            String s = list.get(x);
            if ( "zhangsan".equals(s) ) {
                list.add("lisi");
            }
        }
        System.out.println("list:" + list);

        System.out.println("******************************************");

        //增强for循环
        for ( String s : list ) {
            if ( "zhangsan".equals(s) ) {
                list.add("lisi");
            }
        }
        System.out.println("list:" + list);
    }
}

```



如上代码在增强for循环遍历时执行add方法会抛出

```
D:\Java\jdk1.8.0_112\bin\java 
java.util.ConcurrentModificationException
    at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:901)
    at java.util.ArrayList$Itr.next(ArrayList.java:851)
```

ConcurrentModificationException翻译为: 并发修改异常.
这就代表同时发生了一个操作.
那么借由上面链接中的帖子来解释说在使用foreach遍历的时候, 其实是通过一个迭代器进行迭代, 而在迭代的过程中不允许对List集合进行增删之类的操作.
下面是发生其异常的原因, 也可以参考: http://bbs.itheima.com/forum.php?mod=viewthread&tid=41997&page=1&authorid=75804 这里的解释.

```java
at java.util.AbstractList$Itr.checkForComodification(Unknown Source)
at java.util.AbstractList$Itr.next(Unknown Source)
```

**java.util.AbstractList$Itr 中$符号后面的Itr表示Itr是AbstractList中的一个内部类.**

在AbstractList$Itr这个类中实现了Iterator接口，当使用增强的for循环时，
应该是使用迭代器进行迭代了，如果你在这期间使用了**add或remove**方法的话，在ArrayList类中执行了这样的代码

```java
public boolean add(E e) {
    ensureCapacity(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}

public E remove(int index) {
    rangeCheck(index);

    modCount++;
    E oldValue = elementData(index);

    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
    elementData[--size] = null; // clear to let GC do its work

    return oldValue;
}
```

**add方法中调用了ensureCapacity方法.**

```java
public void ensureCapacity(int minCapacity) {
    modCount++;
    int oldCapacity = elementData.length;
    if (minCapacity > oldCapacity) {
        Object oldData[] = elementData;
        int newCapacity = (oldCapacity * 3)/2 + 1;
            if (newCapacity < minCapacity)
            newCapacity = minCapacity;
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
}
```

add和remove方法都引起了AbstractList$Itr中的modCount属性增加值，然后当下一次遍历List, 迭代器调用next方法时调用了checkForComodification()方法.

```java
public E next() {
    checkForComodification();
    try {
        E next = get(cursor);
        lastRet = cursor++;
        return next;
    } catch (IndexOutOfBoundsException e) {
        checkForComodification();
        throw new NoSuchElementException();
    }
}
```

但`checkForComodification()`方法进行了modeCount和expectedModCount(翻译为: 预期修改次数)判断, 发现不一致, 所以抛出了异常.

```java
final void checkForComodification() {
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}
```


## 异常2
异常: **java.lang.IllegalStateException** (非法状态异常)
情景如下:

我们知道`Arrays.asList(T ... t);`可以将一个数组变成一个List.
代码如下:

```java
@Test public void testRemove () {
    List<String> list = Arrays.asList("fd", "fds", "2341f");

    Iterator<String> it = list.iterator();
    while ( it.hasNext() ) {
        it.remove();
    }
}
```

在执行到`it.remove();`时会触发异常.
首先`Arrays.asList("fd", "fds", "2341f");`会返回一个List, 那么这个List是什么类型呢? 通过查看源代码可以发现

```java
public static <T> List<T> asList(T... a) {
    return new ArrayList<>(a);
}
```

看起来没什么问题, 但是这里有必要说明一下, 此ArrayList非`java.util.ArrayList`这个ArrayList. what??? 难道还有两个ArrayList, 是的.. 那么我们看一下这个ArrayList到底是哪里的, Ctrl + T按下发现这里的ArrayList原来是Arrays这个类中维护的一个内部类, `当然他也是继承自AbstractList`
wtfuck...jdk大佬真会玩. 但此ArrayList中并没有提供Iterator()方法, 所以调用Iterator方法还是执行的父类AbstractList中的Iterator方法, 


在java.util.AbstractList$Itr中我们可以看到next和remove方法.

```java
/**
 * Index of element returned by most recent call to next or
 * previous.  Reset to -1 if this element is deleted by a call
 * to remove.
 */
int lastRet = -1;

public void remove() {
    if (lastRet < 0)
        throw new IllegalStateException();
    checkForComodification();

    try {
        AbstractList.this.remove(lastRet);
        if (lastRet < cursor)
            cursor--;
        lastRet = -1;
        expectedModCount = modCount;
    } catch (IndexOutOfBoundsException e) {
        throw new ConcurrentModificationException();
    }
}
```

由于这里的lastRet 初始值为-1, 所以执行remove方法时触发异常.

## 异常3
异常: **java.lang.UnsupportedOperationException** (不支持的操作异常)
代码如下:

```java
public void testRemove () {
    List<String> list = Arrays.asList("fd", "fds", "2341f");

    Iterator<String> it = list.iterator();
    while ( it.hasNext() ) {
        String s = it.next();
        if ( "fd".equals(s) ) {
            it.remove();
        }
    }
}
```

这里同样是使用java.util.AbstractList$Itr迭代器进行获取. 但为什么和上面的情况不一样呢, 也就是为什么没有触发`java.lang.IllegalStateException`异常, 原因是因为我们在remove之前调用了next()方法, 改变了lastRet的值, 绕过了remove方法前面的if判断.

```java
/**
 * Index of element to be returned by subsequent call to next.
 */
int cursor = 0;

/**
 * Index of element returned by most recent call to next or
 * previous.  Reset to -1 if this element is deleted by a call
 * to remove.
 */
int lastRet = -1;

public E next() {
    checkForComodification();
    try {
        int i = cursor; // i 为0
        E next = get(i);
        lastRet = i; // lastRet接收i的赋值后变成了0.
        cursor = i + 1;
        return next;
    } catch (IndexOutOfBoundsException e) {
        checkForComodification();
        throw new NoSuchElementException();
    }
}

public void remove() {
    if (lastRet < 0) // 所以判断不成立, 跳出下面的异常
        throw new IllegalStateException();
    checkForComodification(); 
    try {
        AbstractList.this.remove(lastRet); 
        if (lastRet < cursor)
            cursor--;
        lastRet = -1;
        expectedModCount = modCount;
    } catch (IndexOutOfBoundsException e) {
        throw new ConcurrentModificationException();
    }
}
```

```java
if (lastRet < 0)
        throw new IllegalStateException();
```

当跳出这个判断后, 执行`AbstractList.this.remove(lastRet);`这一句的时候, this代表是迭代器也就是`java.util.AbstractList$Itr`, 这里的remove方法是java.util.AbstractList#remove中的方法, 这个方法什么也没做, 直接抛出了一个异常. 因此上面的代码抛出异常.

```java
public E remove(int index) {
    throw new UnsupportedOperationException();
}
```

## 总结
三种异常都发生在迭代器之上.
其中第一种最常见, 也是最容易犯的一种.
原因在于一边在遍历, 一边在修改, 导致底层实现代码出现错误, 从而出现异常.

第二和第三则在于Arrays.asList()方法所产生的ArrayList并不是java.util.ArrayList, 而是Arrays内部类中的ArrayList. 而这个内部ArrayList是没有覆盖父类java.util.AbstractList的add和remove方法的(但覆盖了set get, 所以这2个方法不受影响), 所以不管是通过获取这个List的迭代器来进行remove(**迭代器没有提供add方法**)操作(上面说了迭代器最后调用remove方法还是java.util.AbstractList提供的方法), 还是调用这个List本身继承过来的add/remove方法进行操作, 最后都是调用的父类中的方法, 而父类中的方法, 就只有一行抛出异常的代码. 所以会发生异常.

我们在开发时, 只需要记住. 在通过迭代器的方法遍历集合时不要对其进行remove和add操作就可以了. 至于set方法是可以的.

## 其它
有的公司面试时会问到这样的问题, 所以这里记录一下分享给大家, 也算是本人一个学习记录分享.

面试的时候先看面试给你的是通过Arrays.asList()方式获取的集合还是直接new ArrayList()的方式, 如果是前者, 那么可以使用
> google上对怎么解决ConcurrentModificationException的方案已经很多, 例如用Collections.synchronizedCollection() 去同步集合,  但是这样可能会影响效率,  JDK5之后concurrent包里面有个CopyOnWriteArrayList, 这个集合迭代的时候可以对集合进行增删操作,  因为迭代器中没有checkForComodification!

这种方式进行删除, **其次不管是增强型for遍历还是普通for遍历都不可以删除, 因为前者的ArrayList是调用的父类中的remove方法, 会抛出不支持操作异常.** 
如果是后者, **那么可以你关心的就是遍历的时候是否通过迭代器的方式, 也就是增强型for循环, 如果是普通for遍历方式, 我想面试官不会问你 - -. 如果是增强型for, 那么就回答不可以, 会抛出并发操作异常.**

