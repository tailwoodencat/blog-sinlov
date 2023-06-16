---
title: "Android Can only use lower 16 bits for requestCode"
date: 2018-11-16T23:49:55+08:00
description: "desc Android Can only use lower 16 bits for requestCode"
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

## 错误日志

```bash
java.lang.IllegalArgumentException: Can only use lower 16 bits for requestCode
...
...
```

## 原因

`context.startActivityForResult` 的 `requestCode` 有对应限制

对应源码为

```java
@Override
public void startActivityForResult(Intent intent, int requestCode) {
    if (requestCode != -1 && (requestCode&0xffff0000) != 0) {
      throw new IllegalArgumentException("Can only use lower 16 bits for requestCode");
    }
    super.startActivityForResult(intent, requestCode);
}
```