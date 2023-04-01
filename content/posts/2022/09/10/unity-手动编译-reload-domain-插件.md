---
title: "Unity 手动编译 Reload Domain 插件"
date: 2022-09-10T21:30:00+00:00
description: "Unity 手动编译 Reload Domain 插件 使用说明"
draft: false
categories: ['unity']
tags: ['unity']
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

在unity工作流中,`修改脚本->编译脚本->reload domain(重载域)-> 进入play`

通过区分assembly能加快编译,但是reload domain 却很慢,每次编译之后都要reload domain,而且进入播放前也会reload domain

写程序经常会`Ctrl+s`,一旦保存,就会重新编译,继而触发reload. 有时候会返回Unity编辑器,只是查看场景,并不想reload,会让我们漫长等待.

Unity有个Enter Play Mode Setting  [可配置的进入运行模式 - Unity 手册](https://docs.unity.cn/cn/2021.3/Manual/ConfigurableEnterPlayMode.html)

禁用`Reload Domain` 可以快速进入播放模式.但是每次修改完脚本还是会重新reload.

还有就是对于`静态数据如果没有重新 Reload 还是会保持之前的数据`(**建议不要禁用**) 具体查看: [https://docs.unity.cn/cn/2021.3/Manual/DomainReloading.html](https://docs.unity.cn/cn/2021.3/Manual/DomainReloading.html)

当然有些通过禁用`Auto refresh`,使用`ctrl+r`,来手动刷新也可以,但是如果导入的是图片等其他资源,也要刷新

所以还是要手动 Reload 最可靠

## 使用方法

- 支持 unity 2019, 2020, 2021, 以及更高版本

脚本导入Editor文件夹之后,菜单栏`Tools->Tools/Manual/ScriptCompile/Open Reload Domain`

然后需要 reload 时候按下 `ctrl + t/cmd + t` 即可

`如果开启,新建脚本或者导入插件的时候,都手动 reload 一下`

当然如果关闭了 `Auto Refresh`，那么需要手动执行，按下 `ctrl/cmd + r` 再按 `ctrl/cmd + t` 即可

### 插件日志

- 默认工作日志是不开启的，可以点击 `Tools->Tools/Manual/ScriptCompile/Log Open` 来查看日志

## 解决 频繁Reload 原理

要做的就是,添加新脚本或者修改脚本后,经过确认无误之后

我们才 Reload, 而且在进入 play 模式时，如果已经 reload 不会二次 reload

unity 提供了两个API

- `EditorApplication.LockReloadAssemblies();` 加锁
- `EditorApplication.UnlockReloadAssemblies();` 解锁

配合` Enter Play Mode Setting` 就可以大大减少等待时间

获取 `CanReloadAssemblies` 是通过

[https://github.com/INeatFreak/unity-background-recompiler](https://github.com/INeatFreak/unity-background-recompiler) 来自这个库来反射获取是否锁住

