---
title: "gradle 缓存目录结构 缓存策略"
date: 2018-06-07T17:09:39+08:00
description: "gradle 缓存目录结构 缓存策略 详细说明"
draft: false
categories: ['gradle', 'Android']
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

## gradle 缓存策略

Gradle 的缓存策略中，对于 `SNAPSHOT 版本默认的缓存周期是 24 小时`，也就是从我上次更新之后，24小时内都会使用上次的缓存

Gradle 对于动态版本和变化模块的缓存时间默认是 24 小时。

动态版本 是什么
你见过的像 `3.+` 这种就是动态版本，它会取检查到的最高的版本号。又比如 `latest.integration`，它也是动态版本
而变化模块
就是像 `0.2-SNAPSHOT` 这种后面带 SNAPSHOT 的快照版本，不是动态版本，不会更新
这两者的区别就是

- `xxx+` 尽管你代码中的版本号写法不变但实际上它仍然是去取仓库的最新版本
- 而` latest.integration`它在仓库中的版本号还是一样，仍然是 xxx-SNAPSHOT，但实际上这个版本所对应的内容已经变了
- 配置动态版本，会导致额外的构建查询时间，具体可以输出构建性能报告，自行比较

## Gradle 缓存周期修改

- 执行型

```bash
./gradlew aD --refresh-dependencies
```

- 配置型

```gradle
configurations.all {
    // 动态版本
    resolutionStrategy.cacheDynamicVersionsFor 10, 'minutes'
    // 变化模块
    resolutionStrategy.cacheChangingModulesFor 10, 'minutes'
}
```

> https://discuss.gradle.org/t/refresh-dependencies-should-use-cachechangingmodulesfor-0s/556

## gradle 缓存目录

### `.gradle目录`


| 目录 | 描述 |
|-----|-----|
| caches | gradle缓存目录 |
| daemon | daemon日志目录 |
| native | gradle平台相关目录 |
| wrapper | gradle-wrapper下载目录 |


### caches目录

 | 目录 | 描述 |
|-----|-----|
| 2.14.1 | gradle程序的脚本（gradle程序版本） |
| 3.2.1 | gradle程序的脚本（gradle程序版本） |
| jars-1 | 未知 |
| jars-2 | 未知 |
| modules-2 | 下载缓存目录 |

### caches/modules-2 目录

| 目录 | 描述 |
|-----|-----|
| files-2.1 | gradle下载的jar目录 |
| metadata-2.16 | gradle-2.14.1的描述文件 （不确定） |
| metadata-2.23 | gradle-3.2.1的描述文件 （不确定） |

files-2.1的目录组织

```
${org}/${package}/${version}/${shanum1}/${package-version}.pom
${org}/${package}/${version}/${shanum2}/${package-version}.jar
```

- 例如

```
https://jcenter.bintray.com/com/android/tools/lint/lint-api/25.1.3/lint-api-25.1.3.jar
对应的目录为
.gradle/caches/modules-2/files-2.1/com.android.tools.lint/lint-api/25.1.3/${shasum1}/lint-api-25.1.3.jar
```

### daemon目录

`不必要依赖离线`

用于存放gradle daemon的运行日志 `按gradle程序版本存放`

| 目录 | 描述 |
|-----|-----|
| 2.14.1 | gradle-2.14.1运行的日志 |
| 3.2.1 | gradle-3.2.1运行的日志 |

### native目录

`不必要依赖离线`

用于存放平台相关（Win/Linux/Mac）的库

| 目录 | 描述 |
|-----|-----|
|19 | gradle-2.14.1对应的lib目录，按平台存放，如osx-amd64 |
|21 | gradle-3.2.1对应的lib目录，按平台存放，如osx-amd64 |
|jansi | 未知 |

### wrapper 目录

用于存放 `gradle-wrapper` 下载 `gradle的zip包和解压后的文件夹

- wrapper的目录规则

```
wrapper/dists/gradle-2.14.1-all/base36/gradle-2.14.1-all.zip
wrapper/dists/gradle-2.14.1-all/base36/gradle-2.14.1-all.zip.lck
wrapper/dists/gradle-2.14.1-all/base36/gradle-2.14.1-all.zip.ok
```

#### base36规则

- 从 `gradle/wrapper/gradle-wrapper.properties` 中得到 distributionUrl

即 [https://services.gradle.org/distributions/gradle-2.14.1-all.zip](https://services.gradle.org/distributions/gradle-2.14.1-all.zip) ，注意文件中的`\`不算

- 对 distributionUrl 计算 md5

例如

```bash
printf "https://services.gradle.org/distributions/gradle-2.14.1-all.zip" | md5
```

得到 8c9a3200746e2de49722587c1108fe87

- 利用 `0x8c9a3200746e2de49722587c1108fe87` 构造一个 `uint 128位整数`

- 将整数利用 `base36` 得到 `base36的值`（取小写）

```java
import java.math.BigInteger;
import java.security.MessageDigest;

public class Hash {

    public static void main(String[] args) {
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
            byte[] bytes = args[0].getBytes();
            messageDigest.update(bytes);
            String str = new BigInteger(1, messageDigest.digest()).toString(36);
            System.out.println(str);
        } catch (Exception e) {
            throw new RuntimeException("Could not hash input string.", e);
        }
    }
}
```

> 代码见 [https://github.com/xiaoyur347/gradlew/blob/f3c8a48e2fc9ce560a1302fd33a8768bae269a1c/helper/Hash.java#L4](https://github.com/xiaoyur347/gradlew/blob/f3c8a48e2fc9ce560a1302fd33a8768bae269a1c/helper/Hash.java#L4)

## Error fix

### IDEA 代码提示不更新

```bash
rm -rf ./.idea/libraries/*.xml
# then run IDEA `Sync with File System`
```

 > 注意这个方法可能失效，你需要自行理解`构建缓存加载`，和 `IDE缓存加载` 的区别，他们不是同一个主体在干活
