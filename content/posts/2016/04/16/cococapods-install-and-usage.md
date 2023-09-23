---
title: "cococapods install and usage"
date: 2016-04-16T12:20:31+00:00
description: "CocoaPods 安装和使用"
draft: false
categories: ['ruby']
tags: ['ruby', 'iOS']
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

## CocoaPods 是干什么用的

[官方地址 cocoapods](https://cocoapods.org/)

CocoaPods 是一个iOS开发的类库管理工具，本身使用 ruby 编写，托管于 github，用于项目中一个类库用到其他类库的依赖管理

很多开源iOS项目都支持 CocoaPods

## 安装 CocoaPods

### 安装前准备

* 检查 Ruby 环境

```bash
$ ruby -v
```

> 当然OS X 10.8 以上系统是默认带有 Ruby 和 Python，也可以使用 brew 安装的 ruby

```bash
$ brew info ruby
# set proxy
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l

## 配置环境变量 ~/.zshrc 添加

# for brew install ruby
export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
# for gem install xxx --user-install
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH


## then install pod as brew install ruby
$ gem install cocoapods
```

### 安装执行

终端键入

```bash
$ gem install cocoapods
$ pod repo update

$ cd ~/.cocoapods/repos
$ git clone https://github.com/CocoaPods/Specs

# or use tsinghua
$ pod repo remove master
$ git clone https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git master

$ pod repo list
$ pod setup
```

等候安装就行，如果出现无法安装，请尝试镜像

安装成功校验

```bash
$ pod --help
```

能正常打印 pod 帮助文档即可

#### pod 依赖异常

```bash
# Install clean
$ sudo gem install cocoapods-clean
# Run deintegrate in the folder of the project
$ pod deintegrate

# Modify your podfile (delete the lines with the pods you don't want to use anymore) and run
$ pod install
$ pod update
```


### 更改Cocoapods github仓库

* 检查网络

因为某种不可抗力，Ruby的资源站点访问会非常吃力，不妨试验一下官方地址 [https://rubygems.org/](https://rubygems.org/)

能打开说明可能安装成功，当然也可以使用国内镜像，这里推荐镜像 [https://gems.ruby-china.com/](https://gems.ruby-china.com/)

```bash
# 添加淘宝镜像
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
# 检查淘宝镜像
$ gem sources -l
```

### 以工程为单位添加 CocoaPods 镜像

```sh
# 新版的 CocoaPods 不允许用pod repo add直接添加master库了，但是依然可以
$ cd ~/.cocoapods/repos
$ pod repo list
$ pod repo remove master
$ git clone https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git master
# 最后进入自己的工程，在自己工程的podFile第一行加上
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

# 恢复
$ pod repo remove master
$ pod repo add master https://github.com/CocoaPods/Specs.git

# 旧版 pod
$ pod repo remove master
$ pod repo add master https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git
$ pod repo update
$ pod setup

# 常用指令

pod install --verbose --no-repo-update
pod update --verbose --no-repo-update
```


- 官方地址 [https://github.com/CocoaPods/Specs.git](https://github.com/CocoaPods/Specs.git)

- coding.net 镜像 [https://gitcafe.com/akuandev/Specs.git](https://gitcafe.com/akuandev/Specs.git)

- 清华地址 [https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/](https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/)

- cocoapodscn 镜像 [http://cocoapodscn.com/](http://cocoapodscn.com/)

重置为官方


```sh
$ cd ~/.cocoapods/repos
$ pod repo remove master
$ git clone https://github.com/CocoaPods/Specs master

$ pod repo update
$ pod setup

# 最后进入自己的工程，在自己工程的podFile第一行加上
sources 'https://github.com/CocoaPods/Specs'
```

## 使用CocoaPods

### 搜索可用依赖库

```bash
$ pod search AFNetworking
```

稍等片刻就会输出 目前最新的AFNetworking的版本信息

### 导入依赖库

在你想导入的XCode项目目录中创建文件

```bash
vim Podfile
```

在文件中键入文字

```bash
platform :ios, '8.0'
pod "AFNetworking", "~> 3.0.4"
```

当前AFNetworking支持的iOS最高版本是iOS 8.0, 要下载的AFNetworking版本是3.0.4

具体支持请查阅 [AFNetworking]( https://github.com/AFNetworking/AFNetworking)

确认文件内容，保存后在这个工程目录下运行

```bash
$ pod install
```

运行成功后，文件夹内会出现额外的一个文件 **\*.xcworkspace**，一定使用 **\*.xcworkspace** 打开

### 使用AFNetworking

在iOS代码中，使用

```objectc
import <AFNetworking.h>
import "AFNetworking.h"
```

## cocoapods 自有本地镜像

首先拉取完整镜像

```sh
$ git clone --mirror https://github.com/CocoaPods/Specs.git
```

编辑镜像配置 `.git/config`

```conf
[core]
repositoryformatversion = 0
filemode = true
bare = true
[remote "origin"]
fetch = +refs/heads/*:refs/heads/*
fetch = +refs/tags/*:refs/tags/*
mirror = true
url = https://github.com/CocoaPods/Specs.git
[remote "mirrors"]
url = your.git.remote/Specs.git
mirror = true
skipDefaultUpdate = true
```

定期同步 脚本 `specssync.sh `

```sh
git fetch remote
git push mirrors
```

配置同步任务 `cronjob`

```cron
30 * * * * /home/git/specssync.sh > /var/log/specssync.log 2>&1
```

这里是每半小时同步一次
