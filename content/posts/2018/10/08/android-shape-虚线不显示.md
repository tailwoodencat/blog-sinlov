---
title: "Android shape 虚线不显示"
date: 2018-10-08T23:51:32+08:00
description: "desc Android shape 虚线不显示"
draft: false
categories: ['Android']
tags: ['Android']
toc:
  enable: true
  auto: false
math:
  enable: false
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 虚线资源

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="line">
    <stroke
        android:width="0.5dp"
        android:color="#DDDDDD"
        android:dashGap="4dp"
        android:dashWidth="4dp" />
    <size android:height="1dp" />
</shape>
```

## 虚线显示需要注意

- `stroke` 标签里的 `android:width` 必须比 `size` 标签里面的 `android:height` 小
- 在使用这个资源的时候，需要加属性 `android:layerType="software"`

例子

```xml
<View
        android:layout_width="match_parent"
        android:layout_height="2dp"
        android:layout_marginTop="@dimen/margin_20"
        android:background="@drawable/shape_dotted_line_gray_1dp"
        android:layerType="software"
```
