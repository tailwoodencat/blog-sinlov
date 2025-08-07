---
title: "Windows Scoop 软件包管理器使用"
date: 2021-03-25T12:40:12+00:00
description: "Windows scoop package manager usage"
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

请在 powershell  中执行

## 安装

- 在线安装

```ps1
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

可参考的国内 scoop 安装方式
- [https://github.com/duzyn/scoop-cn](https://github.com/duzyn/scoop-cn)
- 国内环境的 scoop 安装 下载安装脚本

```ps1
Set-ExecutionPolicy RemoteSigned -scope CurrentUser

irm get.scoop.sh -outfile 'install.ps1'

.\install.ps1 -RunAsAdmin
```

- 测试安装结果

```ps1
scoop help
```

- 使用前需要更新

```ps1
scoop update
```

- scoop通过aria2来实现多线程下载,建议安装

```ps1
scoop install main/aria2
```

Scoop有一个与Scoop捆绑在一起的主存储桶，它始终可作为安装应用程序的主要来源

### scoop bucket

默认情况下，当您运行时 `scoop install <app>`，它会在主存储桶中显示，但是也可以从其他存储桶中进行安装

查看目前公开的存储桶,可以调用 `scoop bucket known`

需要从某个桶里面下载,则需要 `scoop bucket add bucketname` 把这个桶加入进来.

比如: `scoop bucket add jetbrains` 把jetbrains的安装包加进来

方便起见，添加 extras 桶的工具包

```ps1
> scoop bucket add extras
```

### 代理(可选)

```ps1
# 添加代理 根据实际需要，填写http代理信息
scoop config proxy 127.0.0.1:4412

# 删除代理
scoop config rm proxy
```

### 更新所有 scoop 安装的软件

```bash
scoop update --all --quiet

# no cache
scoop update --all --quiet --no-cache
```

## scoop 常用软件

```ps1
# main 默认包含直接安装
> scoop install main/7zip

> scoop bucket add extras

# svn 在扩展里面需要添加 extras
> scoop install extras/tortoisesvn
```

### scoop  管理开发依赖

#### scoop  基础开发工具

```ps1
# cli 辅助
> scoop install main/file
> scoop install main/dust
> scoop install main/bottom

# 编译工具
> scoop install main/gcc
> scoop install main/llvm
```

#### node 开发工具

```ps1
> scoop install main/fnm
> scoop install main/nodejs
> scoop install main/yarn
> scoop install main/pnpm
```

#### python 开发工具

```ps1
> scoop install main/python
> scoop install main/uv
> scoop install main/poetry
```

#### golang 开发工具

```ps1
> scoop install main/go
> scoop install main/golangci-lint
> scoop install main/goreleaser
```

#### java 开发工具

```ps1
> scoop bucket add java

# 切换 jdk 就是设置不同的 env:JAVA_HOME
> scoop install java/zulu-jdk
> scoop install java/zulu17-jdk
> scoop install java/zulu11-jdk
> scoop install java/zulu8-jdk

# 需要先实则 env:GRADLE_USER_HOME 再使用
> scoop install main/gradle
> scoop install main/maven
> scoop install main/kotlin
> scoop install main/scala
```

### scoop 安装的常用GUI软件

```ps1
# 磁盘空间分析器
> scoop install extras/wiztree

# stranslate 划词翻译
> scoop install extras/stranslate
# screentogif 屏幕截图动画
> scoop install extras/screentogif
# carnac 显示键鼠操作
> scoop install extras/carnac

# windterm 远程命令行工具
> scoop install extras/windterm
```

### scoop  三方软件

#### open hash tab

- from [https://github.com/namazso/OpenHashTab](https://github.com/namazso/OpenHashTab)

```ps1
> scoop install nonportable/openhashtab-np
```

## 修改Scoop安装目录

用户安装的程序和 scoop 本身位于 `$env:USERPROFILE\scoop`
全局安装的程序 `--global` 位于 `$env:ProgramData\scoop`

可以通过环境变量更改这些设置

```ps1
$env:SCOOP='E:\UserScoop'
[Environment]::SetEnvironmentVariable('USERSCOOP', $env:SCOOP, 'User')
```

```ps1
$env:SCOOP_GLOBAL='E:\GlobalScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
```

## 迁移

1.  备份 scoop 目录
2.  备份的目录放到新的安装位置
3.  若安装目录非默认情况下，重新设置安装目录


*   `$env:SCOOP='C:\scoop'`
*   `[environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')`

1.  检查环境变量 path 中有：`%SCOOP%\shims`
2.  执行 `/apps/scoop/current/bin` 里面的 `refresh.ps1` 和 `scoop.ps1` 脚本
3.  执行：`scoop reset *`

reset 失败：[https://github.com/ScoopInstaller/Scoop/issues/4684](https://github.com/ScoopInstaller/Scoop/issues/4684)

## 清理

scoop 安装会产生很多历史版本，清理使用

```ps1
scoop cleanup <app>
```

## scoop 镜像

> 使用前注意维护可行性，更建议使用代理

- 更改为国内的源 添加国内的bucket仓库

```ps1
scoop config SCOOP_REPO 'https://gitee.com/glsnames/scoop-installer'
# 拉取新库地址
scoop update

# need git install
scoop bucket add extras https://gitee.com/scoop-bucket/extras
scoop bucket add nerd-fonts https://gitee.com/scoop-bucket/nerd-fonts.git
scoop bucket add versions https://gitee.com/scoop-bucket/versions.git
scoop bucket add backit https://gitee.com/scoop-bucket/backit.git
scoop bucket add dorado https://gitee.com/scoop-bucket/dorado.git
```

[https://gitee.com/glsnames/scoop-installer](https://gitee.com/glsnames/scoop-installer) 包含如下分支

| 分支| 含义|基于原版分支|
|-|-|-|
|master| 代理分流，内网和国内的IP默认放行|master|
|develop|代理分流，内网和国内的IP默认放行|develop|
|proxyall|全局代理，不对资源链接进行解析，直接走代理（360用户可用，但不推荐）|master|
|archieve|原版，无代理无修改|master|

安装默认选择`master`分支，想要切换到其他分支，可执行如下命令
```powershell
# 切换分支到develop
scoop config scoop_branch develop
# 重新拉取git
scoop update
```


若依旧不能更新，请用记事本打开config文件(`scoop安装目录\apps\scoop\current\.git\config`)，手动去掉其中url行中的引号，修改保存后再重新执行更新命令。
显示为如下内容为正常。
```
***省略
[remote "origin"]
	url = https://gitee.com/glsnames/scoop-installer
	fetch = +refs/heads/*:refs/remotes/origin/*
***省略
```

- 国内 bucket 源
	- [https://gitee.com/scoop-bucket](https://gitee.com/scoop-bucket)

替换安装 scoop 脚本（已安装的跳过）

```ps1
iwr -useb https://gitee.com/glsnames/scoop-installer/raw/master/bin/install.ps1 | iex
```

替换国内镜像

```ps1
scoop config SCOOP_REPO https://gitee.com/glsnames/scoop-installer

# 已安装的bucket
cd $env:SCOOP\buckets\Main
git remote set-url origin https://gitee.com/scoop-bucket/main.git
```

- 切换回官方镜像

```ps1
scoop config SCOOP_REPO https://github.com/ScoopInstaller/Scoop
# 重新添加 bucket
scoop bucket rm main
scoop bucket add main
```