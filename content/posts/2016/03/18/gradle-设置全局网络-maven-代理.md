---
title: "gradle 设置全局网络 maven 代理"
date: 2016-03-18T16:37:25+08:00
description: "gradle 设置全局代理设置，包括 网络代理 maven 本地目录设置"
draft: false
categories: ['gradle']
tags: ['gradle', 'Android', 'maven']
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

## 针对单个项目设置gradle代理

修改项目中的gradle.properties文件，增加配置项：

```gradle
    systemProp.http.proxyHost=127.0.0.1
    systemProp.http.proxyPort=10384
    systemProp.https.proxyHost=127.0.0.1
    systemProp.https.proxyPort=10384
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

在 `$USER_HOME/.gradle` 目录下，创建目录 `init.d`，在目录中创建文件 `.init.gradle.kts` 内容为

```kotlin
apply<AliyunMavenRepositoryPlugin>() // cancel global maven proxy annotation this line
class AliyunMavenRepositoryPlugin: Plugin<Gradle> {
    override fun apply(gradle: Gradle) {
        gradle.allprojects {
            repositories {
                jcenter {
                    name = "aliyunJcenter"
                    url = uri("https://maven.aliyun.com/repository/jcenter")
                }

                google {
                    name = "aliyunGoogle"
                    url = uri("https://maven.aliyun.com/repository/google")
                }

                mavenCentral {
                    name = "aliyunMavenCentral"
                    url = uri("https://maven.aliyun.com/repository/public")
                }
            }
        }
    }
}

```

- 不管是安卓还是其他项目，只要是用到 gradle 的项目，在启动时都会自动加载这个插件，将`对应的 maven 仓库地址`转换到阿里云
- 取消使用这个插件，只需要注释 `apply<AliyunMavenRepositoryPlugin>()` 这句即可
- 其他仓库的代理，设置方法类似

### 使用 gradle 全局初始化脚本

在 `$USER_HOME/.gradle` 目录下，创建文件 `init.gradle`

```groovy
allprojects{
    repositories {
        def REPOSITORY_URL = 'http://maven.aliyun.com/nexus/content/groups/public/'
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2') || url.startsWith('https://jcenter.bintray.com/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $REPOSITORY_URL."
                    remove repo
                }
            }
        }

        maven {
            url REPOSITORY_URL
        }
    }
}
```

> 这个方法同 kts 插件 会相互干扰，优先加载 init.gradle，然后再生效 kts 插件，建议直接使用 kts 插件，更加直观容易配置

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