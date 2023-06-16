---
title: "Android 编译警告 AAPT err libpng warning iCCP Not recognizing known"
date: 2016-11-15T00:21:34+08:00
description: "desc Android 编译警告 AAPT err libpng warning iCCP Not recognizing known"
draft: false
categories: ['Android']
tags: ['Android']
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

## 错误信息

```log
AAPT err(1728717418): xxx.png: libpng warning: iCCP: Not recognizing known sRGB profile that has been edited
```

## 原因


主要是因为在项目中，使用了一些不是很规范的 png 图片

美术在提供 png 图片的时候，可能跟他们使用的 PhotoShop 工具有关，在生成 png 图片的时候，在文件的头部加入了一些特殊的元数据(invalid metadata)

iCC：International Color Consortium [https://en.wikipedia.org/wiki/International_Color_Consortium](https://en.wikipedia.org/wiki/International_Color_Consortium)


ICCP 就是 iCC profile
每个 png 图片中都有一个 iCCP 的 chunk
Android 的 png 图片需要正确设置 iCPP 信息

## 忽略办法

在有问题的 module 的 `build.gradle` 中设置

```gradle
android{
    aaptOptions.cruncherEnabled = false

    aaptOptions.useNewCruncher = false
}
```

## 解决办法

使用图片工具来进行优化修复

- [pngcrush](http://pmt.sourceforge.net/pngcrush/)
- [optipng](http://optipng.sourceforge.net/)

下载地址

- [https://sourceforge.net/projects/pmt/files/pngcrush-executables/](https://sourceforge.net/projects/pmt/files/pngcrush-executables/)
- [https://sourceforge.net/projects/optipng/files/OptiPNG/](https://sourceforge.net/projects/optipng/files/OptiPNG/)

```base
pngcrush -ow -rem allb -brute -reduce image.png
optipng -o7 image.png
```

### Mac

安装软件

```bash
$ brew install pngcrush optipng
pngcrush -h
optipng -h
```

编写脚本 `png_fix_iccp` 内容为

```bash
#!/bin/bash
echo "start fix png res!"

for i in `find . -name "*.png"`; do
	echo -e "\tTry fix png ${i}"
    pngcrush -ow -rem allb -brute -reduce $i
    optipng -o7 $i
    echo -e "\tFix png ${i} success"
done
echo -e "fix all png res!"
```

赋予脚本运行权限，将脚本加入环境变量

在需要刷png资源的目录使用`png_fix_iccp`命令即可递归修复

### Linux

脚本类似mac，区别是安装方式

### Windows

需要安装 windows 版本的修复工具后，使用脚本

```bat
@echo off
@echo."Start Fix PNG iCCP"

for /r %%i in (*.png) do ( %~dp0/pngcrush_1_8_10_w32.exe -ow -rem allb -brute -reduce "%%i" & %~dp0/optipng.exe -o7 "%%i" )

@echo."Finish Fix PNG iCCP"
```

配置脚本文件目录到环境变量，在任意目录cmd执行 `png_fix_iccp.bat` 即可递归修复