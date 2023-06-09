---
title: "valgrind qcachegrind 性能分析工具"
date: 2023-06-09T10:50:59+08:00
description: "查看 C/C++ 性能检测内存泄露的工具"
draft: false
categories: ['c']
tags: ['c', 'c++']
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

# 介绍

qcachegrind 查看 valgrind 性能检测结果的工具

- 官方地址 [https://kcachegrind.github.io/html/Home.html](https://kcachegrind.github.io/html/Home.html)

# Valgrind 分析

- [https://valgrind.org/downloads/current.html](https://valgrind.org/downloads/current.html)
- 分析工具 kcachegrind [https://apps.kde.org/kcachegrind/](https://apps.kde.org/kcachegrind/)

## macOS

- [https://github.com/LouisBrunner/homebrew-valgrind](https://github.com/LouisBrunner/homebrew-valgrind)

> [https://stackoverflow.com/questions/69792467/memory-check-on-macos-12-monterey](https://stackoverflow.com/questions/69792467/memory-check-on-macos-12-monterey)

## install windows tool

### wincachegrind

- 分析工具 wincachegrind [https://sourceforge.net/projects/wincachegrind/](https://sourceforge.net/projects/wincachegrind/)

### kcachegrind

- 分析工具 kcachegrind [https://apps.kde.org/kcachegrind/](https://apps.kde.org/kcachegrind/)
- 使用文档 [https://docs.kde.org/stable5/en/kcachegrind/kcachegrind/index.html](https://docs.kde.org/stable5/en/kcachegrind/kcachegrind/index.html)

安装：kcachegrind ，由于kcachegrind只能在kde环境下运行，所以需要安装 kdewin-installer-gui

下载地址为：[http://winkde.org/pub/kde/ports/win32/installer/](http://winkde.org/pub/kde/ports/win32/installer/)

安装 kdewin-installer-gui 时选择全部安装（为了省事，其中也包括了kcachegrind）

另外在windows下 kcachegrind 需要dot (linux下的画图工具，有windows版的,在graphviz工具集中的，[http://www.graphviz.org/](http://www.graphviz.org/) 的支持
安装: wincachegrind

下载地址：[http://sourceforge.net/projects/wincachegrind/](http://sourceforge.net/projects/wincachegrind/)

### 图形工具：qcachegrind

- [https://sourceforge.net/projects/qcachegrindwin/](https://sourceforge.net/projects/qcachegrindwin/)

## useage

### gcc

> gcc 编译参数需要加上 -O0

```bash
# build need -O0
$ gcc -O0 main.c -o main


$ valgrind --tool=memcheck --leak-check=full --show-error-list=yes [tagetBinary]
# for kcachegrind
$ valgrind --tool=callgrind main
```