---
title: "Android ListView 滑动背景变黑色或者闪烁黑色"
date: 2018-04-18T23:54:37+08:00
description: "desc Android ListView 滑动背景变黑色或者闪烁黑色"
draft: false
categories: ['Android']
tags: ['Android']
toc:
  enable: true
  auto: false
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 现象

手指在 ListView 上下滚动时，ListViewItem背景变黑

## 原因

因为在滚动的时候为了提升性能做了优化，为提高滚动的性能

Android 框架在 `ListView` 中引入`CacheColorHint` 属性

如果该值为非0，则说明该ListView绘制在单色不透明的背景上

在默认情况下该值为 `#191919`  也就是黑色主题中的黑色背景颜色值

这样当ListView滚动的时候就会使用该值来绘制ListView的背景

## 两种解决办法

- in Layout

```xml
android:cacheColorHint="#00000000"
```
- in code

```java
listview.setCacheColorHint(Color.TRANSPARENT);
```

> tips: 也可以使用其他颜色来防止这种问题
