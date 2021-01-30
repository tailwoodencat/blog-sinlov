---
title: "Android L executables (PIE) are supported"
date: 2017-06-20T00:08:54+08:00
description: "desc Android L executables (PIE) are supported"
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

## 表现

在 Android L 及以上的系统中运行 elf 文件显示

```log
error: only position independent executables (PIE) are supported.
```

## 原因

[PIE (Position Independent Executable)](https://en.wikipedia.org/wiki/Position-independent_code) support（程序加载地址随机化）

这个安全机制从4.1引入，但是Android L之前的系统版本并不会去检验可执行文件是否基于PIE编译出的因此不会报错
但是 `Android L (Android 5.0 API 21)` 已经开启验证 - non-PIE linker support removed
如果调用的可执行文件不是基于PIE方式编译的，则无法运行，并报上面的错误

## 解决方法

在 NDK 编译时，Android.mk 中加入如下 flag

```make
LOCAL_CFLAGS += -pie -fPIE
LOCAL_LDFLAGS += -pie -fPIE
```
