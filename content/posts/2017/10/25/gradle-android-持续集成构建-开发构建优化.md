---
title: "gradle Android 持续集成构建 开发构建优化"
date: 2017-10-25T16:58:07+08:00
description: "gradle Android 工程 持续集成构建 开发构建优化"
draft: false
categories: ['Android', 'gradle']
tags: ['gradle', 'Android', 'maven','optimize']
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

## gradle 任务优化

gradle 是基于 tasks 的，每个task作为一个构建耗时单元，task就是构建优化的单元

gradle 编译优化就是对

- 构建链的 `task组合方式` 优化
- 链上节点 `task耗时` 优化
- 链上节点 `task性能` 优化

### 查看任务

```bash
# 查看某个模块的任务
./gradlew :[moduleName]:task
# 等效
./gradlew :[moduleName]:tasks
# 查看所有任务
./gradlew tasks --all
```

### 查看当前构建耗时

```bash
./gradlew [task] --profile
```

在工程的根目录的 `build/reports/profile/` 下有最新一次构建的耗时统计

针对不同的耗时问题，可以对构建需要优化的 task 进行优化

### 增加构建内存

- 内存不够报错

```
android studio java.lang.OutOfMemoryError: Java heap space
```

解决方法 `工程根 gradle.properties` 加入配置

```properties
# JNI编译支持过时API
# android.useDeprecatedNdk=true
# 守护进程
# org.gradle.daemon=true
# 按需编译
# org.gradle.configureondemand=true
org.gradle.parallel=true
# 设置编译jvm参数
org.gradle.jvmargs=-Xmx2048m
# org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
# org.gradle.jvmargs=-Xmx5120M -XX:+HeapDumpOnOutOfMemoryError -XX:MaxPermSize=512m -XX:ReservedCodeCacheSize=90m
```

> 旧方式其实是无效的，警告如下

```
Warning:The `android.dexOptions.incremental` property is deprecated and it has no effect on the build process.
```

原因是在`build.gradle`加入

```gradle
　　dexOptions {
    　　incremental true
    　　javaMaxHeapSize "4g"
　　}
```

这个配置其实可以删除

### 按需禁用不必要的 task 加速

例如

```gradle
android {
    buildTypes {
        debug {
            project.gradle.startParameter.excludedTaskNames.addAll([
                    'lint',
                    'check',
            ])
        }
}
```

意思是在 android 构建的debug模式下，禁止 带有 lint check 的任务

### 禁用 Lint 检查加速构建

Android Lint是在ADT16引入的一个新工具，它能够扫描到安卓项目中的潜在bug，它既可以作为命令行使用，也可以在eclipse和as等集成环境中使用

http://tools.android.com/tips/lint

Lint 可以检查的问题有

- Missing translations (and unused translations)
- Layout performance problems (all the issues the old layoutopt tool used to find, and more)
- Unused resources
- Inconsistent array sizes (when arrays are defined in multiple configurations)
- Accessibility and internationalization problems (hardcoded strings, missing contentDescription, etc)
- Icon problems (like missing densities, duplicate icons, wrong sizes, etc)
- Usability problems (like not specifying an input type on a text field)
- Manifest errors

Lint 工具是与集成开发环境无关，本身检查会比较耗时，可以禁用掉

> 禁用Lint会导致一些副作用，比如开发者写作垃圾代码之类

#### Android 插件下禁用

在需要禁用的子模块 `build.gradle` 中添加

```gradle
android {
    lintOptions {
        abortonError false
    }
}
```

或者

```gradle
android {
    lintOptions {
        tasks.lint.enabled = false
    }
}
```

#### gradle DSL 方式禁用


工程 `根目录 build.gradle` 中添加

```gradle
beforeEvaluate {
    if (task.name.contains("lint")) {
        task.enabled = false
    }
}
// 这方法会导致出现问题
task lintCheck() {
    getAllTasks(true).each {
        def lintTasks = it.value.findAll { it.name.contains("lint") }
        lintTasks.each {
            it.enabled = false
        }
    }
}
```

或者 在需要禁用的子模块 `build.gradle` 中`apply plugin: 'com.android.application'`之前

```gradle
beforeEvaluate {
    if (task.name.contains("lint")) {
        task.enabled = false
    }
}

// 这段可能报错，建议有上面的
tasks.whenTaskAdded { task ->
    if (task.name.equals("lint")) {
        task.enabled = false
    }
}
```


## gradke 编译依赖优化

### 管理依赖配置

在工程根目录创建文件 `package.gradle`，内容为

```gradle
subprojects {

    apply plugin: 'idea'

    ext {
        test_depends = [
                junit : 'junit:junit:4.6',
                mockito_core : 'org.mockito:mockito-core:2.7.22',
                robolectric : 'org.robolectric:robolectric:3.3.2',
                robolectric_shadows_support_v4: 'org.robolectric:shadows-support-v4:3.3.2',
                easymock : 'org.easymock:easymock:3.4',
                powermock_core : 'org.powermock:powermock-core:1.6.5',
                powermock_module_junit4 : 'org.powermock:powermock-module-junit4:1.6.5',
                powermock_api_easymock : 'org.powermock:powermock-api-easymock:1.6.5',
        ]
        android_test_depends = [
                robotium_solo: 'com.jayway.android.robotium:robotium-solo:5.5.4'
        ]
        apt_compiler = [
                butterknife_compiler: 'com.jakewharton:butterknife-compiler:8.1.0',
        ]
        provided_depends = [
        ]
        depends = [
                com_android_support_support_v4 : 'com.android.support:support-v4:25.0.1',
                com_android_support_appcompat_7 : 'com.android.support:appcompat-v7:25.0.1',
                com_android_support_support_annotations: 'com.android.support:support-annotations:25.0.1',
                com_android_support_recyclerview_v7 : 'com.android.support:recyclerview-v7:25.0.1',
                com_android_support_cardview_v7 : 'com.android.support:cardview-v7:25.0.1',
                com_android_support_design : 'com.android.support:design:25.0.1',
                com_android_constraint_layout : 'com.android.support.constraint:constraint-layout:1.0.2',
                butterknife : 'com.jakewharton:butterknife:8.1.0',
        ]
        component_depends = [
                recyclerview_helper: 'com.define.android:recyclerview-helper:1.1.1',
                define_dialog : 'com.define.android:define-dialog:1.1.0',
        ]
        res_provided = [
        ]
        res_depends = [
        ]
    }
}
```

开发依赖库被分为 三级，分别是

- depends 三方依赖 provided_depends 三方非执行依赖
- component_depends 组件依赖
- res_depends 资源模块依赖 res_provided 资源模块非执行依赖

> 分类的依赖的目的是为了便于管理，`语义化依赖结构`

在`工程根目录的 build.gradle` 第一行添加

```gradle
apply from: rootProject.file("package.gradle")
```

所有`模块 build.gradle` 中就可以使用`package.gradle`配置的

```gradle
dependencies {
// implementation fileTree(include: ['*.jar'], dir: 'libs')
    // test start
    testImplementation test_depends.junit,
                test_depends.mockito_core,
                test_depends.robolectric,
                test_depends.robolectric_shadows_support_v4
    androidTestImplementation android_test_depends.robotium_solo
    // test end
    apt apt_compiler.butterknife_compiler
    implementation depends.com_android_support_support_v4,
            depends.com_android_support_appcompat_7,
// implementation.com_android_support_recyclerview_v7,
// implementation.com_android_support_cardview_v7,
// implementation.com_android_support_design,
            depends.butterknife,
            project(':yourMoudle')
    implementation component_depends.recyclerview_helper
}
```

### 查询依赖配置

```bash
./gradlew -q :[module]:dependencies --refresh-dependencies
```
> 可以去掉 --refresh-dependencies 强制更新最新依赖

#### 查询某个生产线的编译依赖

这个需求在 `多生产线 productFlavors` 构建时特别重要

`因为产品线的依赖，是在真实构建合并依赖并输出的，不是配置什么就依赖什么！`

```bash
# 查询输出模块 app 下所有的生产线的编译依赖名称
./gradlew app:dependencies | grep CompileClasspath
# 查询输出模块 app 下所有的生产线的发布模式编译依赖名称
./gradlew app:dependencies | grep ReleaseCompileClasspath
# 输出生产线 gray 发布模式编译依赖详情，configuration 后面跟的参数输入必须在查询中存在
./gradlew app:dependencies --configuration grayReleaseCompileClasspath
```

- [gradle 依赖官方文档](https://docs.gradle.org/current/userguide/introduction_dependency_management.html)
- [gradle 依赖配置for android 文档](https://developer.android.google.cn/studio/build/dependencies#dependency_configurations)
- [gradle 依赖查看帮助](https://docs.gradle.org/current/userguide/inspecting_dependencies.html)


### 锁定依赖提高编译效率

不要在 gradle 中配置动态版本的依赖，如下这几种写法

```gradle
    implementation group.id.1.+;
    implementation group.id.latest.integration;
    implementation group.id.latest.release;
```

因为这个会大大提高依赖查找的复杂度，导致gradle在编译准备起大量超时，如果是做了生产线分离的项目，耗时尤其突出

一种解决方案是 去掉所有的动态版本标识
另一种，使用 gradle 在 2.0 以后提供的依赖锁功能

```gradle
configurations.all {
    resolutionStrategy {
        force 'group:id:x.x.x'
    }
}
```

[依赖锁官方文档 https://docs.gradle.org/current/userguide/dependency_locking.html](https://docs.gradle.org/current/userguide/dependency_locking.html)

### 快照版本的依赖更新缓慢

在工程的根下配置,设置动态版本只在 10min 内有效

```gradle
configurations.all {
  resolutionStrategy {
    // cache dynamic versions for 10 minutes
    cacheDynamicVersionsFor 10*60, 'seconds'
    // don't cache changing modules at all
    cacheChangingModulesFor 10*60, 'seconds'
  }
}
```

或者，每次`包含编译任务的task`执行 `--refresh-dependencies`


## 开发构建优化

> 全局的 `~/.gradle/gradle.properties` 放置适合本机的内存配置

[https://docs.gradle.org/current/userguide/build_environment.html#sec:gradle_configuration_properties](https://docs.gradle.org/current/userguide/build_environment.html#sec:gradle_configuration_properties)

## 编译工具链优化

在 `gradle.properties` 文件中加入

```properties
# 启用gradle缓存
org.gradle.caching=true

# 开启Dex编译器D8 https://developer.android.google.cn/studio/releases/index.html#preview-the-new-d8-dex-compiler
android.enableD8=true
# 开启新一代资源编译器aapt2（按需开启）
android.enableAapt2=true

# AS 2.3正式版 以后开启 https://developer.android.google.cn/studio/build/build-cache.html
android.enableBuildCache = true
# 构建缓存的目录 (使用 `./gradlew cleanBuildCache` 指令清除cache内容)
# Build Cache默认的存储目录~/.android/build-cache
# more info https://developer.android.com/studio/build/build-cache.html
android.buildCacheDir=buildCacheDir/
```

## 编译任务优化

### 分包优化

```gradle
android{
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', "arm64-v8a", "x86", "x86_64"
            universalApk false
        }
        language {
            enable true
            include "en",
                    "zh,zh-TW,zh-CN"
        }
    }
}
```

> 只导出对应平台的和对应语言的包，减少包大小

构建时使用特定目标， 输入独立产品线，构建类型, 减少出包时间

```bash
./gradlew app:assemble[ProductFlavors][BuildTypes]
./gradlew :app:assembleTestDebug
./gradlew :app:assembleTestRelease
```

> 多产品线 productFlavors 使用后，会明显加大构建时间，因为每个产品线是单独做 资源依赖调整，资源依赖检查，资源依赖合并，编译，合包，签名的
> 故多一条产品线，将多出20%到40%的额外出包时间


### 区分开发依赖和发布依赖

首先区分是否为开发，添加函数

```gradle
boolean isDev() {
    String[] behaviorMark = ['install']
    // if want other behavior just add like below
// String[] behaviorMark = ['install', 'assemble']
    // if add other buildType just add more. Warning initial capitalization!
    String[] buildTypeMark = ['Debug']
    def taskNames = gradle.startParameter.taskNames
    for (tn in taskNames) {
        for (behavior in behaviorMark) {
            if (tn.contains(behavior)) {
                return true
            }
        }
        for (buildType in buildTypeMark) {
            if (tn.contains(buildType)) {
                return true
            }
        }
    }
    return false
}
```

### 开启增量编译

> 这个是否开启，建议测试后再说

```gradle
android {
    compileOptions {
        // 是否开启增量编译
        incremental isDev()
    }
}
```

### 禁用 png 压缩

`cruncher` 这个是在很多开发机上性能的祸首，这个配置默认开启，会将 png 压缩成 WebP

```gradle
android {
    aaptOptions { //禁用cruncher, 以加速编译
        cruncherEnabled = !isDev()
        cruncherProcesses = 0
    }
    buildTypes {
        debug {
            // 关闭 crunchPng 优化, 以加快构建
            crunchPngs false
        }
    }
}
```

### 避免编译不必要的资源

避免编译和打包您没有测试的资源（例如其他语言本地化和屏幕密度资源）

```gradle
android {
  ...
  productFlavors {
    dev {
        // English stringresources and xxhdpi screen-density resources.
        resConfigs "en", "xxhdpi"
    }
}
```

### multdex 分包优化

把 minSdkVersion 配置成 21 或者以上

[https://developer.android.com/studio/build/multidex.html](https://developer.android.com/studio/build/multidex.html)

### Fabric 优化

[https://developer.android.com/studio/build/optimize-your-build](https://developer.android.com/studio/build/optimize-your-build)

如果您不需要运行 Crashlytics 报告，请按以下步骤操作来停用插件，以便加快您的调试构建的速度

```gradle
android {
  ...
  buildTypes {
    debug {
        // minSdkVersion >= 21 生效，禁用 Crashlytics 报告，默认enableCrashlytics 默认值为true
        ext.enableCrashlytics = false
        // 要阻止 Crashlytics 不断更新其构建 ID 和上面的配置一起生效
        ext.alwaysUpdateBuildId = false
    }
}
```

### 编译使用的内存设置

> 这个配置某些版本会不生效，建议还是在 `gradle.properties` 中配置

```gradle
android {
    dexOptions {
        preDexLibraries true
        javaMaxHeapSize "4g"
        maxProcessCount 8
    }
}
```
