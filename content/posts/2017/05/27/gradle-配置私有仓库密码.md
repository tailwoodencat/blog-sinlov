---
title: "gradle 配置私有仓库密码"
date: 2017-05-27T16:52:42+08:00
description: "gradle 配置私有仓库密码 及如何在 CI 中实践密码配置"
draft: false
categories: ['gradle']
tags: ['gradle', 'Android', 'maven']
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

## 原因

引用 `private` 的 `branch`, 但是密码又不能存储在代码里

## 配置方法

### gradle 编译配置加载

- 全局加载 `$HOME/.gradle/gradle.properties`

```properties
NEXUS_XXX_USER="neuxs"
NEXUS_XXX_PWD="password"
```

- 也可以在具体工程的根目录设置 `gradle.properties` 来做工程加载

### 带账号密码的引用

```groovy
allprojects {
  repositories {
    google()
    jcenter()
    maven {
        url 'https://nexus.xxx.com/xxx/sdk/master'
        credentials {
            username NEXUS_XXX_USER
            password NEXUS_XXX_PWD
        }
        authentication {
            basic(BasicAuthentication)
        }
    }
    maven { url 'https://maven.fabric.io/public' }
  }
}
```

## 配置 gradle 全局初始化仓库和密码

可以在 init 中完成任意工程的私有仓库依赖配置

打开 `$GRADLE_HOME` -> `init.d`目录，创建 init 配置文件 `init.gradle`

```groovy
allprojects {
    repositories {
        mavenLocal()
        maven {
          url 'https://nexus.xxx.com/xxx/sdk/master'
          credentials {
            username "neuxs"
            password "password"
          }
        }
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public/' }
        mavenCentral()
    }
}
```

## 延伸

- 可以配置环境变量，用 gradle 读取环境变量来隐藏私有仓库
- 编译期生成 gradle 配置文件
- 编译期给 `gradle.properties` 追加配置也可以做到隐藏私有仓库
