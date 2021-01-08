---
title: "Android Studio 修复插件安装错误"
date: 2021-01-09T00:29:33+08:00
description: "desc Android Studio 修复插件安装错误"
draft: false
categories: ['Android']
tags: ['Android']
toc:
  enable: true
  auto: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 插件错误日志

```log
Plugin "Easy Gradle" is incompatible supported only in IntelliJ IDEA
Plugin "Android WiFi ADB" is incompatible (supported only in IntelliJ IDEA).
Plugin "Name That Color" is incompatible (supported only in IntelliJ IDEA). Plugin "Json2Pojo" is incompatible (supported only in IntelliJ IDEA).
```

## 问题原因

更新 Android Studio 版本后，老插件无法支持，也没自动卸载

## 修复方法

找到当前 Android Studio 对应版本插件的错误位置

比如在 4.1 版本的 Android Studio

```bash
# macOS
cd ~/Library/Application\ Support/Google/AndroidStudio4.1/plugins
# windows
cd %AppData%\Google\AndroidStudio4.1\plugins
```

- 删除不再支持的插件

```bash
rm EasyGradle.jar
rm AndroidWifiADB.jar

# windows
rd \q EasyGradle.jar
rd \q AndroidWifiADB.jar
```

- 重启 Android Studio 即可