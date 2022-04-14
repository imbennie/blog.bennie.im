---
title: 利用反射实现BaseDao
date: 2016-12-01 00:47:17
tags:
    - Java
categories: 
    - 编程开发    
---

在web开发中, 我们需要用dao从数据库中查询数据, 此时我们可以定义一个BaseDao, 就是用于做一些增删改查的基础DAO, 其后的其他的具体DAO, 只需要继承这个DAO, 然后再根据具体的业务逻辑去写具体方法就行, 实现代码重用.

这是增删改查的基础代码, 利用DBUtils写的.

下面是具体的代码, 我一一对其解释.
<!-- more -->

```java
package com.xxx.dao;

import com.xxx.utils.JDBCUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

/**
 * Created on 11/30/2016 11:24 PM.
 * 定义对数据库的基础操作, 用于被其他DAO继承.
 *
 */
public class BaseDao<T> {

    private QueryRunner runner = new QueryRunner();
    private Class<T> type;

    public BaseDao () {
        Class<? extends BaseDao> clz = this.getClass();
        System.out.println("BaseDao构造器被执行, clz为: " + clz);

        Type genericSuperclass = clz.getGenericSuperclass();
        System.out.println("带泛型的父类类型实际类型为: " + genericSuperclass.getClass());

        ParameterizedType p = (ParameterizedType) genericSuperclass;
        Type[] types = p.getActualTypeArguments();
        type = (Class<T>) types[0];
    }

    /**
     * 查询一个对象.
     *
     * @param sql
     * @param params
     * @return
     */
    public T getBean (String sql, Object... params) {
        T t = null;
        Connection conn = JDBCUtils.getConnection();
        try {
            t = runner.query(conn, sql, new BeanHandler<T>(type), params);
        } catch ( SQLException e ) {
            e.printStackTrace();
        } finally {
            JDBCUtils.releaseConnection(conn);
        }
        return t;
    }

    /**
     * 查询一组对象列表
     *
     * @param sql
     * @param params
     * @return
     */
    public List<T> getBeanList (String sql, Object... params) {
        List<T> list = null;
        Connection connection = JDBCUtils.getConnection();
        try {
            list = runner.query(connection, sql, new BeanListHandler<T>(type),
                    params);
        } catch ( SQLException e ) {
            e.printStackTrace();
        } finally {
            JDBCUtils.releaseConnection(connection);
        }
        return list;
    }

    /**
     * 更新数据库操作的方法, 可以实现增删改.
     *
     * @param sql
     * @param params
     * @return update count!
     */
    public int update (String sql, Object... params) {
        int count = 0;
        Connection conn = JDBCUtils.getConnection();
        try {
            count = runner.update(conn, sql, params);
        } catch ( SQLException e ) {
            e.printStackTrace();
        } finally {
            JDBCUtils.releaseConnection(conn);
        }
        return count;
    }
}


```


其中udpate方法, 可以实现增删改.
查询方法, 单独查询一个对象和查询一组对象.
要说的部分在查询这里. 在BeanListHandler和BeanHandler这里后面都有一个type参数传到了构造器中, 这个参数就是具体要查询类的Bean对象. 由于我们这里是在BaseDao里无法写具体的子类Class, 所以我们先`private Class<T> type;`声明了一个type给他传递了一个引用.

那么我们这个BaseDao被子类继承后, 如何传递这个具体的bean对象过来呢.
就是说在这个Dao的查询方法里, 他怎么知道查询后的数据赋给哪个bean对象?

本文重点要说的就是这里了. 
我们将BaseDao传递一个泛型参数, 写成: `public class BaseDao<T>`
然后我们将具体的子类对象通过泛型传递过来, 接着在构造器中获取具体的泛型类型.
解释一下这个构造器的作用.
首先来说一下, 这个BaseDao的构造器会在何时执行.

在JAVA基础那里我们知道, 在初始化子类之前会初始化父类的构造器, 在子类中, 我们也是把super()语句写在子类构造器的第一行, 且java规定必须是第一行, 这样的目的就是让子类在初始化之前确保父类被初始化,
而这个super()就是调用父类的构造器, `所以在BaseDao这个构造器中的this, 它的指针是指向的具体实现类的子类引用.`
那么this.getClass()获取到的就是子类的类型.

其次, 我们再通过反射获取这个子类的父类类型, 毫无疑问它的父类肯定就是这个BaseDao.
由于这个BaseDao<T>是带泛型的, 所以我们应该调用`clz.getGenericSuperclass();`这个方法, 而不是调用`clz.superClass();`

获取到了带泛型的父类之后, 由于这个泛型真实类型是参数化泛型, 所以我们还需要强转成`ParameterizedType p = (ParameterizedType) genericSuperclass;`.

接下来, `Type[] types = p.getActualTypeArguments();`这个方法开始真正的获取泛型列表了, 因为我们知道泛型可以写多个, 所以这里返回值是一个数组. 但我们这里只有一个泛型,
所以`type = (Class<T>) types[0];`直接获取数组下标为0那个泛型就可以.

经过这一些列的获取, 我们就可以拿到传递过来的具体子类Bean对象.
然后之前通过`private Class<T> type;`声明的type就被赋值为子类的类型, 就可以用于BeanListHandler和BeanHandler使用了.


```java
Class<? extends BaseDao> clz = this.getClass();
System.out.println("BaseDao构造器被执行, clz为: " + clz);

Type genericSuperclass = clz.getGenericSuperclass();
System.out.println("带泛型的父类类型实际类型为: " + genericSuperclass.getClass());
```

上面2条语句的输出为: 

> BaseDao构造器被执行, clz为: class com.xxx.dao.impl.UserDaoImpl
>
> 带泛型的父类类型实际类型为: class sun.reflect.generics.reflectiveObjects.ParameterizedTypeImpl

