---
title: "windows QQNT 版本占用 GPU 过高"
date: 2024-02-26T15:20:57+08:00
description: "解决 windows QQNT 版本占用 GPU 过高"
draft: false
categories: ['tips']
tags: ['tips', 'windows', 'electron']
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

QQNT 框架是基于 [electron](https://www.electronjs.org)，默认启用硬件加速

windows 默认以高性能模式渲染 QQNT

## 解决方法

在 qq 快捷方式 后面加 `--disable-gpu`

- 安装在 `"C:\Program Files\Tencent\QQNT"` 中的 QQ
- 在启动的快捷方式上，右键属性
- 弹出的属性中，选中标签 `快捷方式`
- 在栏目 `目标(T)` 中改为

```conf
"C:\Program Files\Tencent\QQNT\QQ.exe" --disable-gpu
```

- 保存后，关闭所有 QQ 重新使用这个修改过的快捷方式打开即可

## 扩展知识

[electron 继承了来自 Chromium 的多进程架构](https://www.electronjs.org/docs/latest/tutorial/process-model#the-multi-process-model)

不管使用哪种方式，electron 开发的客户端 `启动的时候会启动 4 个进程`

- 主进程
- 渲染器进程
- Preload 脚本
- 效率进程

```bash
foo.exe
foo.exe --type=gpu-process --disable-features=SpareRendererForSitePerProcess
foo.exe --type=renderer --disable-features=SpareRendererForSitePerProcess
foo.exe --type=utility --disable-features=SpareRendererForSitePerProcess
```


关闭 GPU 渲染的方法 [Rendering Modes](https://www.electronjs.org/docs/latest/tutorial/offscreen-rendering#rendering-modes)

```js
// 必须在app ready之前调用
app.disableHardwareAcceleration();
```

或者启动 electron 前加入

```
foo.exe --disable-gpu
```

如何验证是否关闭了gpu渲染?

- 如果使用gpu渲染，手动关闭gpu进程，程序会出现黑屏，当gpu进程回复之后，黑屏消失
- 如果没有使用gpu渲染，手动关闭gpu进程，程序不会出现黑屏
