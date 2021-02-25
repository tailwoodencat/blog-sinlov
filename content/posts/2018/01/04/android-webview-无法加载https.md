---
title: "Android WebView 无法加载Https/Http"
date: 2018-01-04T00:01:32+08:00
description: "desc Android WebView 无法加载Https"
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

Android 中webView无法加载https协议URL，特别是6.0以后都出现问题
webView 从 Lollipop 开始默认不开

[MixedContentMode](https://developer.android.com/reference/android/webkit/WebSettings.html#setMixedContentMode(int))

## 原因

Android WebView 6.0 以后默认不允许使用混合模式打开 http 页面，比如：从 https 页面重定向到 http 页面

## 修复方法

```java
webView.setWebViewClient(new WebViewClient(){
  @Override
  public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error){
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      webView.getSettings()
      .setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
    }
  }
);
```

> tips: 由于加载的页面，本身 https 设置问题导致的，上面的方法也无法解决，需要抓包分析

### 会被警告的修复方法

重写 `WebViewClient`的`onReceivedSslError`

添加`handler.proceed` 方法，但 App如果上架GooglePlay会被警告

```java
webView.setWebViewClient(new WebViewClient(){
    @Override
    public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error){
      handler.proceed();
    }
  }
);
```

## android 9 以上，http 无法在 webview 加载

> 因为 Android 9.0 以后，默认禁止了 http 请求

创建配置文件 `res/xml/network_security_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
     <base-config cleartextTrafficPermitted="true" />
</network-security-config>
```

在 `AndroidManifest.xml` 中配置

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    >
</application>
```

如果出现 `Manifest merger failed with multiple errors, see logs` 则配置为

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    tools:replace="android:networkSecurityConfig"
    >
</application>
```