---
title: Mybatis插入记录后获取主键id
date: 2015-12-23 05:10:56
tags:
	- Java
	- MyBatis

categories:
	- IT Notes

---


### Oracle数据库
Oracle数据库插入记录后获取id主键,首先建立一个序列（就是每次查询会自动增加值的绝不重复的对象，比如每次加1或每次加10）语法：
```sql
CREATE SEQUENCE 序列名
[INCREMENT BY n]     --每次加几
[START WITH n]       --序列从几开始
[{MAXVALUE/ MINVALUE n|NOMAXVALUE}] --最小值、最大值的限制,或者没有最大值.
```
比如`CREATE SEQUENCE s_test start with 1 increment by 1;` 
就是建立了一个从1开始每次加1的序列.
访问序列时,用`序列名称.nextval`的语法。

而在实际代码中,我们可以通过使用`SelectKey`来获取到id,selectKey会自动把数据库的主键id赋值给对应javabean的id属性.
在更新和插入的时候,都是可以通过SelectKey来获取插入的id主键.

<!-- more -->

- 注解版的方式
配置4个属性:
1. `statement`在这里用select语句来查询下一个id主键值.
2. `before`就是值在insert语句之前执行
3. `keyProperty="id"`注意:这个配置的是对应数据库主键javabean的属性名,而不是数据库的字段名!
4. `resultType` 返回的主键id值的类型,最好是和javabean的id属性类型对应.

```java
@SelectKey(statement="select user_seq.nextval from dual", before=true, keyProperty="id", resultType=Integer.class)
@Insert("insert into users (id,name) values (#{id},#{name})")
void saveUser(User user);
```

- 配置文件方式
配置3个属性:
1. `keyProperty="id"`注意:这个配置的是对应数据库主键javabean的属性名,而不是数据库的字段名!
2. 这里的`order="BEFORE"`属性设置为BEFORE就是和注解版的`before=true`是一个意思.
3. `resultType` 返回的主键id值的类型,最好是和javabean的id属性类型对应.

```xml
<insert id="saveUser" parameterType="com.xxx.entities.User">
   insert into users (id,name) values (#{id},#{name})
   <selectKey keyProperty="id" order="BEFORE" resultType="Integer">
    select user_seq.nextval from dual
   </selectKey>
</insert>
```

### MySql数据库

由于MySql数据库是支持自动生成主键的,所以我们只需要设置一些属性就可以获取到主键了.

- 注解版的方式

```java
@Insert("INSERT INTO Employees (name, age, birth, registerTime, salary) "
			+ "VALUES (#{name}, #{age},#{birth},#{registerTime}, #{salary})")
void addEmployee(Employee employee);
```

- 配置文件方式
配置2个属性:
1. `keyProperty="id"`注意:这个配置的是对应数据库主键javabean的属性名,而不是数据库的字段名!
2. `useGeneratedKeys="true"` 使用自动生成key设置为true  注意:这个配置的是对应数据库主键javabean的属性名,而不是数据库的字段名!

```xml
<insert id="addEmployee" parameterType="Employee" keyProperty="id" useGeneratedKeys="true">
	INSERT INTO Employees
	(name, age, birth, registerTime,salary)
	VALUES
	(#{name}, #{age}, #{birth},#{registerTime}, #{salary})
</insert>
```