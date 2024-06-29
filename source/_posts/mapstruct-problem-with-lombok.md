---
title: Mapstruct与lombok的冲突问题 
date: 2024-06-29 18:52:40
tags:
	- Frontend
	- JavaScript
categories:
	- IT Notes

---

记一下在mapstruct结合lombok使用的冲突问题：
- 编译时提示`@Mapping`配置的属性找不到。
- 在生成Mapper的impl实现类时不能生成正确的bean的getter/setter语句。

<!-- more -->

解决方法：
需要在maven-compiler-plugin的`annotationProcessorPaths`中同时配置lombok及mapstruct-processor。
并且lombok配置需要在前面。


{% codeblock pom.xml lang:xml %}
<plugins>
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
    </plugin>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <configuration>
            <annotationProcessorPaths>
                <path>
                    <groupId>org.projectlombok</groupId>
                    <artifactId>lombok</artifactId>
                    <version>${lombok.version}</version>
                </path>
                <path>
                    <groupId>org.mapstruct</groupId>
                    <artifactId>mapstruct-processor</artifactId>
                    <version>${mapstruct.version}</version>
                </path>
            </annotationProcessorPaths>
        </configuration>
    </plugin>
</plugins>
{% endcodeblock  %}
