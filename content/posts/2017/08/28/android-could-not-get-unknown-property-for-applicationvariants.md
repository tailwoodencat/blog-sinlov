---
title: "Android could not get unknown property for applicationVariants"
date: 2017-08-28T00:06:00+08:00
description: "desc Android could not get unknown property for applicationVariants"
draft: false
categories: ['Android']
tags: ['Android', 'gradle']
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
```
could not get unknown property for 'applicationVariants' for BuildType xxxx
```
## 原因
```
buildTypes {
    release {
        applicationVariants.all { variant ->
            appendVersionName(variant, defaultConfig)
        }
    }
}
```
`applicationVariants` 只包含在 `apply plugin: 'com.android.application'` 插件中
## 修复方法

如果使用 `apply plugin: 'com.android.library'`
```gradle
buildTypes {
    release {
       libraryVariants.all { variant ->
            appendVersionName(variant, defaultConfig)
        }
    }
}
```
## 说明

- `applicationVariants` 只在 `com.android.application`
- `libraryVariants` 只在 `com.android.library`
- `testVariants` 都含有，但一般只有默认的 debug

