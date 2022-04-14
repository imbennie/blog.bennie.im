---
title:  Jackson中转换JsonNode（ArrayNode）到Java中的List对象
date: 2021-12-03 14:52:56
tags:
    - Jackson
    - Java
categories:
    - 编程开发

---

Jackson用的不多，这里先记一下。

https://stackoverflow.com/questions/48287292/how-do-you-convert-a-jackson-jsonnode-to-a-list-of-some-user-defined-object

<!-- more -->

```json
{
  "objects":"that",
  "I":"dont care about",
  "objectsiwant":[{object1, object2,...}]
}
```


<!-- more -->


使用readerFor或readerForListOf

```

ObjectMapper mapper = new ObjectMapper();
JsonNode rootNode = mapper.readTree(json);
JsonNode internalNode = rootNode.path("objectsiwant");

// ----------------

List<MyPojo> myPojoList = mapper.readerFor(new TypeReference<List<MyPojo>>(){}).readValue(internalNode);

// 或者

List<MyPojo> myPojoList = mapper.readerForListOf(MyPojo.class).readValue(internalNode);
```
