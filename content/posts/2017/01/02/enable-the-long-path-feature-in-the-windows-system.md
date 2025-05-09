---
title: "Windows 系统中启用长路径功能"
date: 2017-01-02T12:56:31+00:00
description: "如何在 Windows 系统中启用长路径功能 和 注意事项"
draft: false
categories: ['basics']
tags: ['basics']
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

## 开启前注意

> 注意: 开启长路径功能之后，并非所有应用程序都支持长路径，比如 Windows 自带的文件资源管理器，即使开启长路径功能也无法处理超长路径的文件

有编辑超长路径文件的需求，建议使用第三方的更强大的工具

 - [One Commander](https://onecommander.com/)

```bash
scoop install extras/onecommander
```

## 开启原因

Windows 系统中较为保守的最大路径长度限制一直为人所诟病。在 Windows 系统的默认配置下，最大路径长度为 MAX_PATH，定义为 260 个字符。

除去路径开头的驱动器号、冒号、反斜杠以及路径末尾的终止字符，实际可用的部分只有 256 个字符。而在 Windows 的文件资源管理器中，由于一些额外保留字符限制，实际可使用的路径长度会更短一些。

从 Windows 10 版本 1607 开始，可以启用长路径功能

有三种启用长路径的方法，可以根据自身情况进行选择

## PowerShell

- `管理员模式`启动 PowerShell，`重启计算机生效`

```ps1
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

## 修改注册表文件

- 通过注册表文件 (.reg) 进行设置，`重启计算机生效`

新建一个 `.txt` 文本文件, 将文件后缀名改为 `.reg`， 再 双击 `.reg` 文件执行

```Reg
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"LongPathsEnabled"=dword:00000001
```

## 策略编辑器

- 通过组策略编辑器进行设置  `需要 Windows 专业版`

使用 Windows键 + R 组合键调出 运行 窗口，输入 `gpedit.msc` 启动组策略编辑器

按以下路径选择配置项，开启长路径功能，`重启计算机生效`

```
# 英文路径
Computer Configuration > Administrative Templates > System >
Filesystem > Enable Win32 long paths

# 中文路径
计算机配置 > 管理模板 > 系统 > 文件系统 > 启用 Win32 长路径
```
