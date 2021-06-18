---
title: "Android stuido 开发调优"
date: 2018-02-05T21:42:57+08:00
description: "desc Android stuido 开发调优"
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

## Android 缓存清理

运行到一定程度， AndroidStudio 无法正常使用，打开新工程卡顿，甚至完全卡死在打开工程上

```sh
rm -rf ~/Library/Caches/AndroidStudio3.0/caches
rm -rf ~/Library/Caches/AndroidStudio3.0/index
```

> 非 macOS 请找到对应目录，删除后会重新索引

## Android Studio 调优参数

`在 help 菜单` 中选择 `Edit Custom VM Options`，如果没有建立，点击确认建立，内容为

```properties
# custom Android Studio VM options, see https://developer.android.com/studio/intro/studio-config.html

-Xms512m
-Xmx2048m
-Xmn512m
-XX:SurvivorRatio=8
-XX:PermSize=512m
-XX:MaxPermSize=1024m
-XX:ReservedCodeCacheSize=512m
-XX:SoftRefLRUPolicyMSPerMB=0
-XX:+UseCompressedOops
-ea
-Duser.name=yourname
#-Duser.country=EN
#-Duser.language=us
#-Dfile.encoding=UTF-8
```
> 可以根据当前设备的配置，调整参数，yourname 更换为开发者名即可

### 标准参数

verbose 标准参数

```
-verbose:class
 输出jvm载入类的相关信息，当jvm报告说找不到类或者类冲突时可此进行诊断。
-verbose:gc
 输出每次GC的相关情况。
-verbose:jni
 输出native方法调用的相关情况，一般用于诊断jni调用错误信息。
```

- 非标准参数又称为扩展参数

一般用到最多的是
```
-Xms512m  设置JVM促使内存为512m。此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存。

-Xmx512m ，设置JVM最大可用内存为512M。

-Xmn200m：设置年轻代大小为200M。整个堆大小=年轻代大小 + 年老代大小 + 持久代大小。持久代一般固定大小为64m，所以增大年轻代后，将会减小年老代大小。此值对系统性能影响较大，Sun官方推荐配置为整个堆的3/8。

-XX:SurvivorRatio=8: 值默认为8, eden区, From 区 , to 区.
也就是 年轻代大小 + 年老代大小 + 持久代大小 比例为8:1:1

-Xss128k：设置每个线程的堆栈大小。JDK5.0以后每个线程堆栈大小为1M，以前每个线程堆栈大小为256K。更具应用的线程所需内存大小进行调整。在相同物理内 存下，减小这个值能生成更多的线程。但是操作系统对一个进程内的线程数还是有限制的，不能无限生成，经验值在3000~5000左右。

-ea: 用-ea 可打开断言机制，不加<packagename>和classname时运行所有包和类中的断言，如果希望只运行某些包或类中的断言，可将包名或类名加到-ea之后

-XX:SoftRefLRUPolicyMSPerMB=0: Soft reference在虚拟机中比在客户集中存活的更长一些。其清除频率可以用命令行参数 -XX:SoftRefLRUPolicyMSPerMB=<N>来控制，这可以指定每兆堆空闲空间的 soft reference 保持存活（一旦它不强可达了）的毫秒数，这意味着每兆堆中的空闲空间中的 soft reference 会（在最后一个强引用被回收之后）存活1秒钟。注意，这是一个近似的值，因为 soft reference 只会在垃圾回收时才会被清除，而垃圾回收并不总在发生。系统默认为一秒，如果这个值设置大了，会导致 Indexing 非常长
```

### 性能调优参数列表

| 参数及其默认值                | 描述                                  |
| ----------------------------- | ------------------------------------- |
| -XX:LargePageSizeInBytes=4m   | 设置用于Java堆的大页面尺寸            |
| -XX:MaxHeapFreeRatio=70       | GC后java堆中空闲量占的最大比例        |
| -XX:MaxNewSize=size           | 新生成对象能占用内存的最大值          |
| -XX:MaxPermSize=64m           | 老生代对象能占用内存的最大值          |
| -XX:MinHeapFreeRatio=40       | GC后java堆中空闲量占的最小比例        |
| -XX:NewRatio=2                | 新生代内存容量与老生代内存容量的比例  |
| -XX:NewSize=2.125m            | 新生代对象生成时占用内存的默认值      |
| -XX:ReservedCodeCacheSize=32m | 保留代码占用的内存容量                |
| -XX:ThreadStackSize=512       | 设置线程栈大小，若为0则使用系统默认值 |
| -XX:+UseLargePages            | 使用大页面内存                        |

### 行为参数

| 参数及其默认值            | 描述                                                      |
| :------------------------ | :-------------------------------------------------------- |
| -XX:-DisableExplicitGC    | 禁止调用System.gc()；但jvm的gc仍然有效                    |
| -XX:+MaxFDLimit           | 最大化文件描述符的数量限制                                |
| -XX:+ScavengeBeforeFullGC | 新生代GC优先于Full GC执行                                 |
| -XX:+UseGCOverheadLimit   | 在抛出OOM之前限制jvm耗费在GC上的时间比例                  |
| -XX:-UseConcMarkSweepGC   | 对老生代采用并发标记交换算法进行GC                        |
| -XX:-UseParallelGC        | 启用并行GC                                                |
| -XX:-UseParallelOldGC     | 对Full GC启用并行，当-XX:-UseParallelGC启用时该项自动启用 |
| -XX:-UseSerialGC          | 启用串行GC                                                |
| -XX:+UseThreadPriorities  | 启用本地线程优先级                                        |

- 串行（SerialGC）是jvm的默认GC方式，一般适用于小型应用和单处理器，算法比较简单，GC效率也较高，但可能会给应用带来停顿；
- 并行（ParallelGC）是指GC运行时，对应用程序运行没有影响，GC和app两者的线程在并发执行，这样可以最大限度不影响app的运行；
- 并发（ConcMarkSweepGC）是指多个线程并发执行GC，一般适用于多处理器系统中，可以提高GC的效率，但算法复杂，系统消耗较大；

### 调试参数列表

| 参数及其默认值                                 | 描述                                                        |
| :--------------------------------------------- | :---------------------------------------------------------- |
| -XX:-CITime                                    | 打印消耗在JIT编译的时间                                     |
| -XX:ErrorFile=./hs_err_pid<pid>.log            | 保存错误日志或者数据到文件中                                |
| -XX:-ExtendedDTraceProbes                      | 开启solaris特有的dtrace探针                                 |
| -XX:HeapDumpPath=./java_pid<pid>.hprof         | 指定导出堆信息时的路径或文件名                              |
| -XX:-HeapDumpOnOutOfMemoryError                | 当首次遭遇OOM时导出此时堆中相关信息                         |
| -XX:                                           | 出现致命ERROR之后运行自定义命令                             |
| -XX:OnOutOfMemoryError="<cmd args>;<cmd args>" | 当首次遭遇OOM时执行自定义命令                               |
| -XX:-PrintClassHistogram                       | 遇到Ctrl-Break后打印类实例的柱状信息，与jmap -histo功能相同 |
| -XX:-PrintConcurrentLocks                      | 遇到Ctrl-Break后打印并发锁的相关信息，与jstack -l功能相同   |
| -XX:-PrintCommandLineFlags                     | 打印在命令行中出现过的标记                                  |
| -XX:-PrintCompilation                          | 当一个方法被编译时打印相关信息                              |
| -XX:-PrintGC                                   | 每次GC时打印相关信息                                        |
| -XX:-PrintGC Details                           | 每次GC时打印详细信息                                        |
| -XX:-PrintGCTimeStamps                         | 打印每次GC的时间戳                                          |
| -XX:-TraceClassLoading                         | 跟踪类的加载信息                                            |
| -XX:-TraceClassLoadingPreorder                 | 跟踪被引用到的所有类的加载信息                              |
| -XX:-TraceClassResolution                      | 跟踪常量池                                                  |
| -XX:-TraceClassUnloading                       | 跟踪类的卸载信息                                            |
| -XX:-TraceLoaderConstraints                    | 跟踪类加载器约束的相关信息                                  |

### 查看设置JVM内存信息

```
Runtime.getRuntime().maxMemory(); //最大可用内存，对应-Xmx

Runtime.getRuntime().freeMemory(); //当前JVM空闲内存

Runtime.getRuntime().totalMemory(); //当前JVM占用的内存总数，其值相当于当前JVM已使用的内存及freeMemory()的总和

关于maxMemory()，freeMemory()和totalMemory()：

maxMemory()为JVM的最大可用内存，可通过-Xmx设置，默认值为物理内存的1/4，设值不能高于计算机物理内存；

totalMemory()为当前JVM占用的内存总数，其值相当于当前JVM已使用的内存及freeMemory()的总和，会随着JVM使用内存的增加而增加；

freeMemory()为当前JVM空闲内存，因为JVM只有在需要内存时才占用物理内存使用，所以freeMemory()的值一般情况下都很小，而 JVM实际可用内存并不等于freeMemory()，而应该等于maxMemory()-totalMemory()+freeMemory()。及其 设置JVM内存分配。
```

## 调优参数说明

> 参数是`-X`开头的，表示非标准的参数。什么叫非标准的呢？
> 因为JVM有很多个实现，Oracle的，OpenJDK等等
> 这里的`-X`参数，是 Oracle 的 JVM 实现使用的，OpenJDK 不一定能使用，也就是没有将这些参数标准化，让所有的JVM实现都能使用

> 参数是 -XX 开头，为标准参数，见说明 http://www.oracle.com/technetwork/systems/vmoptions-jsp-140102.html

### -Xms

The -Xms option sets the initial and minimum Java heap size. The Java heap (the “heap”) is the part of the memory where blocks of memory are allocated to objects and freed during garbage collection.

JVM启动的起始堆内存，堆内存是分配给对象的内存,`影响打开 android studio 速度`, 默认 128m

### -Xmx

AndroidStudio能使用的最大heap内存, 默认 750m
其`影响 Android Stuido 执行的可用总内存大小，根本的执行效率，GC出现的频率`等等
一般来说越大越好（能够用的最大量）

建议

- 8G 内存调整为 2048m
- 16G 内存调整为 4096m

> 量力调整，毕竟其他进程也需要资源

### -XX:MaxPermSize

指定最大的Permanent generation大小, 默认 350m
这个参数`影响编译速度`
设置太小，执行GC执行次数明显增多，设置太大，浪费内存，且GC执行过程加长
这里我选择 `-Xmx` 的一半

> Permanent Generation (non-heap): The pool containing all the reflective data of the virtual machine itself, such as class and method objects. With Java VMs that use class data sharing, this generation is divided into read-only and read-write areas.

Permanent Generation也是一块内存区域，跟heap不同
主要是虚拟机为java永久生成对象（Permanate generation）如，class对象、方法对象这些可反射（reflective）对象分配内存限制，这些内存不包括在Heap（堆内存）区之中
包括类本身（不是对象），以及方法，一些固定的字符串等等
可以通过 `-XX:PermSize` 指定初始分配大小
详细介绍见 https://blogs.oracle.com/jonthecollector/entry/presenting_the_permanent_generation

### -XX:ReservedCodeCacheSize

> ReservedCodeCacheSize (and InitialCodeCacheSize) is an option for the (just-in-time) compiler of the Java Hotspot VM. Basically it sets the maximum size for the compiler's code cache.

设置JIT java compiler在compile的时候的最大代码缓存，默认 90m
`影响JIT优化效率，比较影响高负载下的编译执行速度`
设置太小，编译线程一直高，设置大了，浪费内存
这个缓存不用开太大，也别太少，建议为 `-XX:MaxPermSize` 的一半

这个是JIT（Just In Time）编译器在编译代码的时候，需要缓存一些东西，这个参数指定最多能使用多大内存来缓存这些东西

编程语言分两种

- 编译型，先将人写的代码整个编译成汇编语言或机器语言，一条一条代码然后执行
- 解释型，不需要编译，将人写的代码一条一条拿过来一次执行，先取一条，执行，完了再取下一条，然后在执行

对于Java来说，这个情况就比较特殊了，因为在Java这里，JVM先是将Java代码整个编译成bytecode，然后在JVM内部再一条一条执行bytecode代码。你说它是编译型的吧，bytecode又不用编译成机器代码，二是一条条bytecode一次执行。
在bytecode层面，代码是解释执行的。解释型的语言会比较慢，因为它没有办法根据上下文对代码进行优化
而编译型的语言则可以进行优化。Java的JIT技术，就是在bytecode解释执行的时候，它不一定是一条条解释执行的
二是取一段代码，编译成机器代码，然后执行，这样的话就有了上下文，可以对代码进行优化了，所以执行速度也会更快

### -XX:+UseCompressedOops

允许系统将代码里面的引用(reference)类型用32位存储，同时却能够让引用能够使用64位的内存大小，默认不一定开启，设置即开启
`影响执行效率，能开开启一下`

现代的机器基本都是64位的，在这种情况下，Java代码里面的reference类型也变成了用64位来存储，这就导致了两个问题

1. 64位比32为更大，占的内存更多，这是显然的，当然这个问题在整个程序看来根本不显然，因为哪怕系统同时有1000个引用存在，那多出来的内存也就4M
2. 相对于内存，CPU的cache就小的可怜了，当reference从32bit变成64bit时，cache里面能存放的reference数量就顿时少了很多。所以64bit的reference对cache是个大问题，于是就有了这个选项，可以允许系统用32bit来存储reference，让cache里面能存放更多的reference，同时又不影响reference的取址范围


### -D

Oracle JVM 可选参数

|参数名称|描述|
|-------|---|
|Duser.name|jvm 虚拟机用户名称，影响 ${user} 值|
|Duser.country|默认国家名|
|Duser.language|默认语言|
|Dfile.encoding|编码参数，默认 类 UNIX 系统使用 UTF-8, 如果是windows，则使用对应语言版本的编码|

## 完全重置 AndroidStudio

```sh
rm -Rf /Applications/Android\ Studio.app
rm -Rf ~/Library/Preferences/AndroidStudio*
rm ~/Library/Preferences/com.google.android.studio.plist
rm -Rf ~/Library/Application\ Support/AndroidStudio*
rm -Rf ~/Library/Logs/AndroidStudio*
rm -Rf ~/Library/Caches/AndroidStudio*
```
