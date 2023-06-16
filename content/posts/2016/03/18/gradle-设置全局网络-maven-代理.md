---
title: "gradle 设置网络代理, 全局 maven 仓库代理"
date: 2016-03-18T16:37:25+08:00
description: "gradle 设置网络代理，全局 maven 代理 ，使用私有仓库，本地目录仓库"
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

[TOC]

## 针对单个项目设置 gradle 网络代理

修改项目中的 gradle.properties 文件，增加配置项：

```gradle
# org.gradle.jvmargs=-DsocksProxyHost=127.0.0.1 -DsocksProxyPort=51087
# socks proxy
systemProp.socks.proxyHost=127.0.0.1
systemProp.socks.proxyPort=51087
# http proxy
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=51087
# https proxy
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=51087
# no proxy
systemProp.https.nonProxyHosts=192.168.*|localhost
systemProp.http.nonProxyHosts=192.168.*|localhost
```

## 针对所有的gradle项目设置代理

可以在 `GRADLE_USER_HOME` 下, 新建文件 `gradle.properties`，然后设置代理

`GRADLE_USER_HOME` 的路径一般如下:

|系统|路径|
|:--|:--|
|Linux| `/home/<username>/.gradle/` |
|OS X| `/Users/<username>/.gradle/` |
|Windows| `C:\Users\<username>\.gradle\` |

### gradle.properties 说明

在每个 gradle 工程中，包含很多固定叫 `gradle.properties` 的文件

> properties 文件本质为 `key=value` 键值对，也支持配置域 `[域名称]`

并且 gradle 支持 module 模式，那么每次编译时，就会按照 `默认 -> 全局 -> 工程 -> 模组` 的顺序加载 `gradle.properties`
那么同一个 key 的值，按照 `默认 -> 全局 -> 工程 -> 模组` 的顺序依次覆盖


## 所有 maven 仓库按需配置代理

### 使用 kts 插件方式

> gradle 4.0 以后支持 kts 插件，官方迁移文档 [https://docs.gradle.org/current/userguide/migrating_from_groovy_to_kotlin_dsl.html](https://docs.gradle.org/current/userguide/migrating_from_groovy_to_kotlin_dsl.html)

在 `$USER_HOME/.gradle` 目录下，创建目录 `init.d`，在目录中创建文件 `.init.gradle.kts` 内容为

```kotlin
apply<AliyunMavenRepositoryPlugin>() // cancel global maven proxy annotation this line

class AliyunMavenRepositoryPlugin: Plugin<Gradle> {

    override fun apply(gradle: Gradle) {
        gradle.allprojects {
            // https://maven.aliyun.com/mvn/guide
            repositories {
                jcenter { // http://jcenter.bintray.com/
                    name = "aliyunJcenter"
                    url = uri("https://maven.aliyun.com/repository/public")
                }
                google { // https://maven.google.com/
                    name = "aliyunGoogle"
                    url = uri("https://maven.aliyun.com/repository/google")
                }
                mavenCentral { // https://repo1.maven.org/maven2/
                    name = "aliyunMavenCentral"
                    url = uri("https://maven.aliyun.com/repository/central")
                }
            }
        }
    }

}
```

- 不管是安卓还是其他项目，只要是用到 gradle 的项目，在启动时都会自动加载这个插件，将`对应的 maven 仓库地址`转换到阿里云
- 取消使用这个插件，只需要注释 `apply<AliyunMavenRepositoryPlugin>()` 这句即可
- 其他仓库的代理，设置方法类似

### gradle 4.0 以下设置全局代理

> 因为 gradle 4.0 以下不支持 kts 故使用下面的方式来配置代理仓库

在 `$USER_HOME/.gradle` 目录下，创建目录 `init.d`，在目录中创建文件 `init.gradle` 内容为

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/public/' }
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/google' }
    }
}

```

- 更优的做法是同时移除被代理的仓库，当然前提是代理仓库可用

```groovy
allprojects {
    repositories {
        // proxy repository start doc see: https://maven.aliyun.com/mvn/guide
        // def PROXY_URL_REPO_GRADLE_PLUGIN = "https://maven.aliyun.com/repository/gradle-plugin"
        def PROXY_URL_REPO_CENTRAL= "https://maven.aliyun.com/repository/central"
        def PROXY_URL_REPO_GOOGLE = "https://maven.aliyun.com/repository/google"
        def PROXY_URL_REPO_PUBLIC = "https://maven.aliyun.com/repository/public"
        def PROXY_URL_REPO_JCENTER = "https://maven.aliyun.com/repository/public"
        def PROXY_URL_REPO_SPRING = "https://maven.aliyun.com/repository/spring"
        def PROXY_URL_REPO_SPRING_PLUGIN = "https://maven.aliyun.com/repository/spring-plugin"
        def PROXY_URL_REPO_GRAILS_CORE = "https://maven.aliyun.com/repository/grails-core"
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                def url = repo.url.toString()
                // if (url.startsWith("https://plugins.gradle.org/m2/")) {
                //     project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_GRADLE_PLUGIN."
                //     remove repo
                // }
                if (url.startsWith("https://repo1.maven.org/maven2/")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_CENTRAL."
                    remove repo
                }
                if (url.startsWith("https://maven.google.com/")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_GOOGLE."
                    remove repo
                }
                if (url.startsWith("http://jcenter.bintray.com/")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_PUBLIC."
                    remove repo
                }
                if (url.startsWith("http://repo.spring.io/libs-milestone/")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_SPRING."
                    remove repo
                }
                if (url.startsWith("http://repo.spring.io/plugins-release/")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_SPRING_PLUGIN."
                    remove repo
                }
                if (url.startsWith("https://repo.grails.org/grails/core")) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $PROXY_URL_REPO_GRAILS_CORE."
                    remove repo
                }
            }
        }
        // maven {
        //     url PROXY_URL_REPO_GRADLE_PLUGIN
        // }
        maven {
            url PROXY_URL_REPO_CENTRAL
        }
        maven {
            url PROXY_URL_REPO_GOOGLE
        }
        maven {
            url PROXY_URL_REPO_PUBLIC
        }
        maven {
            url PROXY_URL_REPO_SPRING
        }
        maven {
            url PROXY_URL_REPO_SPRING_PLUGIN
        }
        maven {
            url PROXY_URL_REPO_GRAILS_CORE
        }
        // proxy repository end
    }
}
```

> 这个方法同 kts 插件 会相互干扰，优先加载 init.gradle，然后再生效 kts 插件，建议直接使用 kts 插件，更加直观容易配置

## 使用私有 maven 仓库，并包含密码

增加 `$USER_HOME/.gradle` 目录下，目录 `init.d` 中，文件 `init.gradle` 内容

```groovy
allprojects {
    repositories {
        maven { //custom maven repository host like nexus.custom.com
            credentials {
                username 'username' // username as base-auth
                password 'password' // password as base-auth
            }
            url "https://nexus.custom.com/repository/android-maven-group/"
        }
        ...
        // proxy repository start ...
        // proxy repository end
    }
}
```

> 建议，把私有 maven 地址放到代理仓库前，这样寻找依赖更迅速

## 使用本地的 gradle 代理

修改 `gradle-wrapper.properties` 文件中的 `distributionUrl` 属性

`不推荐使用，如果使用请使用模板`

```properties
#distributionUrl=https\://services.gradle.org/distributions/gradle-2.4-all.zip
distributionUrl=file\:/User/home/....
```

### 使用本地 maven 仓库

```groovy
allprojects {
    repositories {
        maven {
          url 'file:///Users/sinlov/Downloads/mvn-repo/SNAPSHOT/'
        }
    }
}
```

> 注意格式 `file://` 协议