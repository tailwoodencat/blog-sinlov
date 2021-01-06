---
title: "Android gradle 编译命令使用及解释"
date: 2016-03-22T16:55:44+08:00
description: "Android gradle 管理构建时，各种使用方法及对应解释"
draft: false
categories: ['Android', 'gradle']
tags: ['Android', 'gradle']
toc:
  enable: true
  auto: true
code:
  copy: true
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## gradle 介绍

gradle 是google开发的基于[groovy语言](http://www.groovy-lang.org/) ，用于代替 ant 构建的一种配置型语言
gradle 是基于groovy语言实现（基于JVM的语法和java类似的脚本语言）的一个Android编译系统， google针对Android编译用groovy语言开发了一套 DSL 语言
有额外需要，可以直接使用groovy，Kotlin 或者java代码进行编写
[安装 gradle 命令行](https://docs.gradle.org/current/userguide/installation.html) 后，执行如下命令

```bash
$ mkdir test-gradle
$ cd test-gradle
$ gradle init
Select type of project to generate:
  1: basic
  2: application
  3: library
  4: Gradle plugin
Enter selection (default: basic) [1..4]

Select build script DSL:
  1: Groovy
  2: Kotlin
Enter selection (default: Groovy) [1..2]

Project name (default: test-gradle):

> Task :init
Get more help with your project: https://guides.gradle.org/creating-new-gradle-builds
```

一路回车，就可以创建一个默认的 gradle 管理的工程，文件结构为

```bash
.
├── build.gradle
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradlew
├── gradlew.bat
└── settings.gradle
```

### gradle wrapper

每个基于gradle构建的工程都有一个gradle本地代理，叫做 gradle wrapper

> tips: gradle wrapper 是为了保证每代编译工具链的版本特性隔离，防止新老编译特性冲突

在 `/gradle/wrapper/gralde-wrapper.properties` 目录中声明了指向目录和版本

官方的各个版本的代理下载地址 https://services.gradle.org/distributions/

> tips: `如果 gradle 初次构建缓慢，可以手动下载 gradle zip 包，解压 `${USER}/.gradle/wrapper/dists` 下`

### gradle module

gradle 工程是由工程根目录的 `build.gradle` 和 `settings.gradle` 来确认的，所以 settings.gradle 只有一个生效

> 上面步骤生成的 settings.gradle 包含一个地址，里面有当前版本的 `multi_project_builds` 帮助文档

这里只简单说明在 Android 工程中，设置 settings.gradle 配置

```gradle
include ':app'
```
表示为，将当前目录下的 app 目录作为一个 module 引入
- module 要求必须含有 `build.gradle` 文件
- 且每个 `build.gradle` 文件继承工程跟目录的 `build.gradle` 配置

> tips: 介于操作文件系统 windows 和 macOS 是不分大小写的，那么 `module 命名规则为，路径强制小写`，防止出现无法编译的问题

通过在根目录 `build.gradle` 配置 android 编译工具 `com.android.tools.build:gradle`

```gradle
buildscript {
    repositories {
        jcenter()
        google()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:4.0.0'
    }
}
```

而子模块 app 下的 build.gradle 中包含 android 插件

```gradle
apply plugin: 'com.android.application'
```

## gradle 配置文件

### gradle.properties

在每个 gradle 工程中，包含很多固定叫 `gradle.properties` 的文件

> properties 文件本质为 `key=value` 键值对，也支持配置域 `[域名称]`

并且 gradle 支持 module 模式，那么每次编译时，就会按照 `默认 -> 全局 -> 工程 -> 模组` 的顺序加载 `gradle.properties`
那么同一个 key 的值，按照 `默认 -> 全局 -> 工程 -> 模组` 的顺序依次覆盖

### gradle 全局配置文件

本地建立文件 `gradle.properties` 或者在用户的 `.gradle`目录下建立 `gradle.properties` 文件作为全局设置，参数有

```properties
# 开启并行编译
org.gradle.parallel=true
# 开启守护进程
org.gradle.daemon=true
# 按需编译 4.6 废弃
#org.gradle.configureondemand=true
# 设置编译jvm参数
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
# 设置代理
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=10384
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=10384
# 开启JNI编译支持过时API
android.useDeprecatedNdk=true
```

> tips: 安装一个全局的gradle，并配置好Path变量，避免每个项目重复下载，这样后面编译项目就可以直接覆盖默认配置

## gradle 常用命令

> 注意:在window下可以直接运行 `gradlew` 或者 gradlew.bat, 如果是Linux 或者 mac 命令为 `gradle gradlew` 这里都简写成 `./gradlew`

### gradle 任务查询命令

- 所有后面的命令，都必须在 tasks --all 可见，不然报告找不到这个任务

```bash
# 查看任务
./gradlew tasks
# 查看所有任务 包括缓存任务等
./gradlew tasks --all
# 对某个module [moduleName] 的某个任务[TaskName] 运行
./gradlew :moduleName:taskName
```

> 说明，module 定义在 工程根 `settings.gradle` 下，由 `include 指定`

子模块通过 apply plugin 来加载插件，这些插件导致每个子模块任务不一样
所以子模块需要单独查询

## 常用构建命令

```bash
# 查看构建版本
./gradlew -v

# 清除build文件夹
./gradlew clean

# 检查依赖并编译打包
./gradlew build

# 编译并安装debug包
./gradlew installDebug

# 编译并打印日志
./gradlew build --info

# 编译并只打印核心日志
./gradlew build -q

# 译并输出性能报告，性能报告一般在 构建工程根目录 build/reports/profile, 通过这个报告来调优构建
./gradlew build --profile

# 调试模式构建并打印堆栈日志
./gradlew build --info --debug --stacktrace

# 强制更新最新依赖，清除构建并构建
./gradlew clean build --refresh-dependencies
```

> tips: `build`命令把 `debug、release`环境的包都打出来的

### gradle 指定构建目标命令

```bash

# 编译并打Debug包
./gradlew assembleDebug

# 这个是简写 assembleDebug 也就是取首字母
./gradlew aD

# 编译并打Release的包
./gradlew assembleRelease

# 这个是简写 assembleRelease
./gradlew aR
```

### gradle 构建并安装调试命令


```bash
# 编译并打Debug包
./gradlew assembleDebug
# 编译app module 并打Debug包
./gradlew install app:assembleDebug
# 编译并打Release的包
./gradlew assembleRelease
# Release模式打包并安装
./gradlew installRelease
# 卸载Release模式包
./gradlew uninstallRelease
```

### gradle 多渠道打包

> assemble还可以和productFlavors结合使用，如果出现类似 `Task 'install' is ambiguous in root project` 这种错误，请查看配置的多个渠道然后修改命令为

`./gradlew install[productFlavorsName] app:assembleDebug`

来用命令构建调试

```bash
# Release模式打包并安装
./gradlew installRelease
# 卸载Release模式包
./gradlew uninstallRelease
```
输出对应渠道包
```bash

# Release模式全部渠道打包
./gradlew assembleRelease
# Release模式 test 渠道打包
./gradlew assembleTestRelease
# debug release模式全部渠道打包
./gradlew assemble
```


## gradle 依赖管理

gradle 依赖本质是 maven 管理的，那么就支持多个仓库，拉取 maven 格式的依赖

> maven 本质是一个 OSS(对象存储系统)，由特定格式的路径和 xml 配置文件来标记和校验具体依赖项

### 依赖设置仓库

默认是 jcenter 也可以是mavenCentral， 当然也可以是私有仓库

```gradle
repositories {
    // gralde 4.0 以后出现，访问仓库为 https://dl.google.com/dl/android/maven2/
    google()
    // 私有，或者国内镜像仓库配置方法
    maven { url "http://maven.oschina.net/content/groups/public" }
    // maven centeral 由Sonatype公司提供的服务，它是ApacheMaven、SBT和其他构建系统的默认仓库
    mavenCentral()
    // jcenter 由JFrog公司提供的Bintray中的Java仓库,是GoovyGrape内的默认仓库，Gradle内建支持
    jcenter()
    // mavenCentral 和 jcenter 搜索库 http://mvnrepository.com/
}
```

> repositories 仓库的写作顺序，会影响到拉取的速度，因为 groovy 脚本执行时，是按数组下标进行的

### gradle 依赖版本号

gradle 依赖写法为 `group: name: version:` 三段

比如 [公共仓库 gson](https://mvnrepository.com/artifact/com.google.code.gson/gson)

```gradle
compile group: 'com.google.code.gson', name: 'gson', version: '2.8.6'
// 通过 : 分割简写为
implementation 'com.google.code.gson:gson:2.8.6'
```

> 注意 group 和 name 由 [a-zA-Z.-] 组成，不可使用 `: @`


gradle 的版本号(version) 风格为 [semver 语义化风格](https://semver.org/), 具体版本号见 semver 文档

- version 默认情况下是可以同时加载 `jar` 和 `aar` 包
- 如果写成 `version@jar` 那么只加载 jar 包
- 如果写成 `version@aar` 那么只加载 aar 包

### gradle 依赖特性

- 动态依赖特性

```gradle
dependencies {

    // 任意一个版本 1.*
    compile group:'b',name:'b',version:'1.+'

    // 最后的版本
    compile group:'a',name:'a',version:'latest.integration'
}
```

> tips: 动态版本依赖，会导致编译过程不断询问依赖版本，最终导致 CI 时长明显加长，建议固定版本号，开启依赖传递

- 传递依赖特性

```gradle
dependencies {
    transitive true
}
```

> tip: 手动配置transitive属性为false，阻止依赖的下载

- 对某个一个依赖进行设置

```gradle
dependencies {
    implementation('com.xxx:xxx:1.0.0@aar') {
        transitive = true
        changing = true
        force = true
        exclude group: 'com.xxx', module: 'xxx'
    }
}
```

- 强制指定全部编译版本

```gradle
configurations.all{

  // 强制指定版本 需要先关闭依赖传递
  // transitive false
  resolutionStrategy{
    force 'org.hamcrest:hamcrest-core:1.3'
  }

  // 强制某个依赖组，忽略编译
  all*.excludegroup: 'org.hamcrest', module:'hamcrest-core'

  }
}
```

### gradle 查看依赖

gradle 本身完全靠 maven 管理，甚至 gradle 本身也是可以跟踪依赖版本的
这也就导致 gradle 不能简单打印出依赖，依赖分为

- 基础工程编译依赖
- 基础工程测试依赖
- 基础工程发布依赖

> 并且 gradle 默认支持 debug releas 发布环境，那么上面每项依赖就乘以发布环境

并且 gradle 支持 module 套娃，导致最终依赖非常复杂

```bash
# 查看当前工程的依赖
./gradlew dependencies

# 或者模组的 依赖
./gradlew app:dependencies

# 检索依赖库
./gradlew app:dependencies | grep CompileClasspath

# windows 没有 grep 命令
./gradlew app:dependencies | findstr "CompileClasspath"

# 将检索到的依赖分组找到 比如 multiDebugCompileClasspath 就是 multi 渠道分发的开发编译依赖
./gradlew app:dependencies --configuration multiDebugCompileClasspath

# 一般编译时的依赖库，不是固定配置方式，建议检索后尝试
./gradlew app:dependencies --configuration compile

# 一般运行时的依赖库，不是固定配置方式，建议检索后尝试
./gradlew app:dependencies --configuration runtime
```

> tips: 如果是 shell 用户 可以使用[脚本工具 gradle-depend.sh 相对快速查看依赖](https://raw.githubusercontent.com/sinlov/maintain-python/master/language/gradle/gradle-depend.sh)
> 使用方法 gradle-depend.sh 配置到 PATH 目录下，查看使用帮助 `gradle-depend.sh -h`


### gradle 更新最新依赖问题

这个是困扰不少开发者的问题，其实研究一下就知道

- gradle 相对 maven 做了一层本地缓存 `${user}/.gradle/caches/modules-2`（默认缓存更新是 24小时）
- gradle 在当前工程也做了一层缓存 `${project.root}/.gradle`
- 使用 IDE 这种集成开发环境，也加了一层缓存(在 IDE 的缓存目录里面)
- 工程开发配置文件（当前工程下 .idea .vsc 等等），这个会影响到代码提示

所以，经常出现 gradle 命令更新到最新依赖代码，IDE 不显示的问题，你需要自行处理好缓存
一般命令行 加入 `--refresh-dependencies` 可以更新 gradle 部分，但不会影响到 IDE
如果想要 IDE 在写代码时知道更新，你需要刷新或者修改 IDE 的缓存，具体怎么操作需要根据情况自行解决
这里提供2个工具脚本辅助

- [脚本工具 当前目录 IDEA 类工程清理工具](https://raw.githubusercontent.com/sinlov/maintain-python/master/ide/jetbrain/idea_project_fix.py)
- [脚本工具 gradle 本地缓存 SNAPSHOT 清理工具](https://raw.githubusercontent.com/sinlov/maintain-python/master/language/gradle/clean_gradle_snapshot.py)

> 脚本工具由 python2 编写，怎么做到全局使用，请配置在环境变量中，需要额外功能，请自行修改脚本


## gradle编译参数

### 守护进程编译

```bash
./gradlew build --daemon
```

### 并行编译模式

```bash
./gradlew build --parallel --parallel-threads=N
```

> tips: 这里 parallel-threads 最大为当前可用 CPU 数量

### 使用离线模式

```bash
./gradlew build --offline
```

### 按需编译模式

```bash
./gradlew build --configure-on-demand
```

> tips: 在 gralle 4.6 以后，在工程跟目录的 gradle.properties 文件中设置 org.gradle.configureondemand=false 禁用按需配置
否则会报错

```log
Configuration on demand is not supported by the current version of the Android Gradle plugin since you are using Gradle version 4.6 or above.
Suggestion: disable configuration on demand by setting org.gradle.configureondemand=false in your gradle.properties file or use a Gradle version less than 4.6.
```

## 设定编码

```
allprojects {
...
    tasks.withType(JavaCompile){
        options.encoding = "UTF-8"
    }
...
}
```

> tips: 一般不建议修改，除非特殊项目编码问题，不过更建议统一源码的编码，而不是改编译的编码设置

## Android Studio 提速

### 禁用插件

去掉一些没有用的插件，这个不是固定的，如果你能解决网络问题，开启这些插件对你写代码有好处
Google Cloud Testing、Google Cloud Tools For Android Studio、Goole Login、Google Services、JavaFX、SDK Updater、TestNG-J

### android studio 2.2.2新特性 编译缓存

工程根目录 `gradle.properties` 文件里加上

```conf
android.enableBuildCache=true
```

这个设置可以让Android Studio 会把依赖的 jar 或 arr 缓存到本地，并且把模块名称设置为 hash 值

> 这个开启后，可能导致 includeJarFilter 配置失效，Android Studio 升级到 2.3.0修复这个问题

每次编译生成的缓存在 `$HOME/.android/build-cache`
如果缓存过多可以手动删除该目录进行清除

## 升级到 Android Studio 2.3 后编译不兼容问题

升级到 Android Studio 2.3 后，Gradle Plugin 也升级到 2.3.0

- 对应推荐使用的 Gradle 版本是 3.3


这时候会发现工程模块目录下 `{module name}/build/intermediates/exploded-aar/`

目录没了

它会在 `$HOME/.android/build-cache` 下生成一部分缓存文件，来代替 `exploded-aar`

如果需要生成`exploded-aar`，可以配置项目目录下的 `gradle.properties` ，添加一行内容

```conf
android.enableBuildCache=false
```

然后重新构建项目即可在 `{module name}/build/intermediates/`看到 exploded-aar 目录
