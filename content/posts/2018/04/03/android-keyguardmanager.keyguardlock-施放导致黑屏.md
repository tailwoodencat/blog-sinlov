---
title: "Android KeyguardManager.KeyguardLock 施放导致黑屏"
date: 2018-04-03T23:55:53+08:00
description: "desc Android KeyguardManager.KeyguardLock 施放导致黑屏"
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

## 错误表现

调用

```java
keyguardManager = (KeyguardManager) getSystemService(KEYGUARD_SERVICE);
keyBoardLock = keyguardManager.newKeyguardLock("unLock");
keyBoardLock.disableKeyguard();
```

后按 `home键` 会导致黑屏，只在某些ROM出现

## 原因

调用 `disableKeyguard()` 后
即使调用 `keyBoardLock.reenableKeyguard()` 也出现问题
如果点击 `home` 键会触发 `keyguard的保护机制`，直到解锁才能够重新回复界面

## 修复方法

一般是ROM的问题，要么授予 锁定权限 时，禁止响应 HOME
要么，重新绘制锁屏界面

主要关注类 `StatusBarKeyguardViewManager.java` 的 `show()`方法
如果需要适配 ROM 解决，hook 锁屏界面相关代码 如: `KeyguardBouncer.java` 修复设置屏幕背光流程
