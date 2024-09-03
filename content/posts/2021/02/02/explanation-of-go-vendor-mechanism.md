---
title: "go vendor 机制讲解"
date: 2021-02-02T13:08:02+08:00
description: "Explanation of go vendor mechanism"
draft: false
categories: ['golang']
tags: ['golang', 'gomod']
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

##  vendor 机制

vendor 是 go 1.5 以后支持的，1.6 默认开启，可以关闭则直接 在GOPATH下面查找依赖包

## vendor 编译原则

vendor 原则：
- 当前包下有vendor目录,则从其下查找第三方的包,如果没有找到,则继续执行下一步操作
- 当前包目录下没有vendor目录,则沿当前包目录向上逐级目录查找vendor目录, ,直到找到 $GOPATH/src下的vendor目录
- go 1.12 以后，也默认开启 go mod， 那么如果 vendor目录没找到是不会去 GOPATH 寻找，则尝试 go get 如果失败则编译失败
- go 1.12 以前，在GOPATH下面查找依赖包
- 在GOROOT目录下面查找依赖包

> 故兼容的情况下，请使用 GOPATH 保证不出错，兼容 GOPATH 和 go mod 请设置环境变量 GO111MODULE="on"

## vendor 优点
vendor 将原来放在 `$GOPATH/src` 的第三方包放到当前工程的vendor目录中进行管理

- 为工程独立的管理自己所依赖第三方包提供了`版本切换的保证`
- 多个工程独立地管理自己的第三方依赖包，它们之间`不会相互影响`

vendor保证了当前工程目录下`代码的完整性`

- vendor将原来包共享模式转换为每个工程`独立维护依赖`
- 将工程代码复制到其他同样 go编译环境,  不需要再去下载第三方包，直接就能编译，缓存依赖包可以大大`加速编译`
- 可为`校验三方依赖提供依据`

## vendor 缺点

- 对外部依赖的第三方包的版本管理，如果出现差别，`无法断言使用哪个来保证代码安全`（godep go mod 可以解决这个问题）
- 如果三方库工程，手动使用 vendor 来覆盖依赖，则会出现`代码版本失控`（当然这个问题是三方库的问题，得修复）

## 开启 vendor 优先查找

设置 `GO15VENDOREXPERIMENT=1` 它将开启 go 的 vendor 功能
简单来说 vendo r就是go 在编译的时候优先查找 vendor 文件夹下的对应文件
