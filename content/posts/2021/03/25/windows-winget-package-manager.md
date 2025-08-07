---
title: "windows winget 包管理器"
date: 2021-03-25T12:30:11+00:00
description: "Windows Winget package manager"
draft: false
categories: ['basics']
tags: ['basics', 'dev-kits']
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
## winget 介绍

[https://learn.microsoft.com/windows/package-manager/winget/](https://learn.microsoft.com/windows/package-manager/winget/)

用户可以在 Windows 10 和 Windows 11 计算机上使用 winget 命令行工具来发现、安装、升级、删除和配置应用程序

此工具是 Windows 程序包管理器服务的客户端接口

- [https://github.com/microsoft/winget-cli](https://github.com/microsoft/winget-cli)

### winget 安装

注意: win 11 默认直接支持 winget ， 不用额外安装

```ps1
# 确认是否 winget 可用
> winget --help

# 不可用再安装
```

WinGet 命令行工具仅在 Windows 10 1709（版本 16299）或更高版本上受支持。

在首次以用户身份登录 Windows 之前，WinGet 将不可用，触发 Microsoft 应用商店将Windows 程序包管理器注册为异步进程的一部分。 如果最近已经以用户身份进行了首次登录，但发现 WinGet 尚不可用

则可以打开 PowerShell 并输入以下命令来请求此 WinGet 注册

```
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbw
```

安装位置在 `$env:LOCALAPPDATA\Microsoft\WindowsApps` 下

## winget 使用

```ps1
## search
> winget search gsudo
> winget search Git.Git

## show
> winget show Git.Git
> winget show nushell
# now all install
> winget list

## install <some>
> winget install <some>
# install git
> winget install --id Git.Git

## uninstall
> winget uninstall <some>
> winget uninstall --id Git.Git

## update all
> winget upgrade --all --silent
```

## winget 配置代理

```ps1
## 全局设置需要管理员权限
# 开启代理
sudo winget settings --enable ProxyCommandLineOptions

# 使用管理员配置
sudo winget settings set DefaultProxy http://127.0.0.1:7890
# 关闭代理配置
sudo winget settings reset DefaultProxy

# 用户安装使用代理，不需要管理员权限
winget install Git.Git --proxy http://127.0.0.1:7890
```

### winget 配置源代理

WinGet 源 中科大代理

```ps1
sudo winget source remove winget
sudo winget source add winget https://mirrors.ustc.edu.cn/winget-source
```

- 重置为官方源

```ps1
sudo winget source reset winget
# 显示当前源
sudo winget source list
```

## winget 常用软件安装

- sudo ， 可以让普通用户使用申请管理员权限的工具
- 虽然有官方 https://github.com/microsoft/sudo ，需要额外开启，导致不太方便，可以安装一个三方的 sudo 来过渡

```ps1
# https://github.com/gerardog/gsudo
winget install --accept-package-agreements gsudo
```

### winget 必备软件

```ps1
# git
winget show --id Git.Git
winget install --accept-package-agreements --id Git.Git
# git-lfs
winget install --accept-package-agreements --id GitHub.GitLFS

# GeekUninstaller
winget install --id GeekUninstaller.GeekUninstaller

# everything
winget install --id voidtools.Everything

# https://learn.microsoft.com/en-us/windows/powertoys/
winget install --id Microsoft.PowerToys

# utools https://www.u-tools.cn/index.html
winget install --id Yuanli.uTools
```

- 手心输入法 [https://apps.microsoft.com/detail/xp8bsfwg2mhb3n?hl=zh-Hans-CN&gl=CN](https://apps.microsoft.com/detail/xp8bsfwg2mhb3n?hl=zh-Hans-CN&gl=CN)

### winget 管理依赖

- dotnet 因为特性，最好使用 winget 管理安装，可以保证多个版本同时存在且不冲突

```ps1
# dotnet sdk
sudo winget install --id Microsoft.DotNet.SDK.9
sudo winget install --id Microsoft.DotNet.SDK.8
sudo winget install --id Microsoft.DotNet.SDK.7
sudo winget install --id Microsoft.DotNet.SDK.6
sudo winget install --id Microsoft.DotNet.SDK.5

# dotnet runtime
sudo winget install --id Microsoft.DotNet.Runtime.9
sudo winget install --id Microsoft.DotNet.Runtime.8
sudo winget install --id Microsoft.DotNet.Runtime.7
sudo winget install --id Microsoft.DotNet.Runtime.6
sudo winget install --id Microsoft.DotNet.Runtime.5
```

## winget 软件安装位置

[用户的范围与计算机的范围](https://learn.microsoft.com/zh-cn/windows/package-manager/winget/troubleshooting#scope-for-specific-user-vs-machine-wide)

设置安装位置
- [portablePackageUserRoot 设置](https://learn.microsoft.com/zh-cn/windows/package-manager/winget/settings#portablepackageuserroot-setting) 影响在 `User` 范围内安装包的默认根目录，未设置在
  `%LOCALAPPDATA%/Microsoft/WinGet/Packages/`
- [portablePackageMachineRoot 设置](https://learn.microsoft.com/zh-cn/windows/package-manager/winget/settings#portablepackagemachineroot-setting)  影响在 `Machine` 范围内安装包的默认根目录，未设置值或值无效，则默认为 ``%PROGRAMFILES%/WinGet/Packages/`

- `-l, --location` 指定本地安装位置

```bash
# 注意不是每个软件都支持
winget install JanDeDobbeleer.OhMyPosh -l "D:\Program_Files\winget\OhMyPosh"
```
