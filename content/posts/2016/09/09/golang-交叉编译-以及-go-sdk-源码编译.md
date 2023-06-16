---
title: "golang 交叉编译 以及 go SDK 源码编译"
date: 2016-09-09T11:13:52+08:00
description: "golang 交叉编译说明 以及 go SDK 源码交叉如何交叉编译成开发 sdk"
draft: false
categories: ['golang']
tags: ['golang']
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

# 交叉编译演示

注意：本文交叉编译需要 1.5 以上

## 简单演示 Golang macOS 下编译 windows 64位程序

```sh
➜ ~CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o test_win_x64.exe test.go
```

## 简单演示 Golang macOS 下编译 Linux 64位程序

```sh
➜ ~CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o test_linux_x64 test.go
```

## 交叉编译执行程序

```sh
# 如果你想在Windows 32位系统下运行
➜ ~CGO_ENABLED=0 GOOS=windows GOARCH=386 go build test.go

# 如果你想在Windows 64位系统下运行
➜ ~CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build test.go

# 如果你想在OS X 32位系统下运行
➜ ~CGO_ENABLED=0 GOOS=darwin GOARCH=386 go build test.go

# 如果你想在OS X 64位系统下运行
➜ ~CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build test.go

# 如果你想在Linux 32位系统下运行
➜ ~CGO_ENABLED=0 GOOS=linux GOARCH=386 go build test.go

# 如果你想在Linux 64位系统下运行
➜ ~CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build test.go
```

- CGO_ENABLED = 0 表示设置CGO工具不可用
- GOOS 程序构建环境的目标操作系统
- GOARCH 表示程序构建环境的目标计算架构

## 编译支持设置范例

```sh
GOOS=windows go build -v
GOOS=linux go build -v
GOOS=darwin go build -v
```

## golang 交叉编译支持查询

查询当前的交叉编译支持，执行命令

```sh
➜ go tool dist list
```

# golang 交叉编译问题

## 平台差异的问题

### undefined: syscall.Dup2

编译ARM版本的代码时，报错好几个系统调用找不到
```bash
undefined: syscall.Dup2
undefined: syscall.SYS_FORK
```
解决方案：对比golang源码实现 go/src/syscall/zsyscall_linux_amd64.go和go/src/syscall/zsyscall_linux_arm64.go
发现arm平台未实现Dup2但是提供了Dup3，并且参数略有差异，那么修改调用的地方
```go
// - syscall.Dup2(oldfd, newfd)
syscall.Dup3(oldfd,newfd,0)
```
`SYS_FORK`的调用，查找之下发现golang的ARM实现根本没有实现fork的系统调用，没有SYS_FORK这个宏或替代品

无奈只能修改项目代码，将fork的系统调用改为别的方式实现

## macOS 编译问题

### OS X codesign only works with -ldflags -s

这个是历史遗留问题，目前无解
https://github.com/golang/go/issues/11887

### undefined: syscall.Flock

# golang SDK源码编译

## 预备交叉编译环境

因为 go 在 1.5 以后使用了golang 1.4 来编译自己(自举)，所以需要先下载golang1.4

### linux 准备

[https://dl.google.com/go/go1.4.3.linux-amd64.tar.gz](https://dl.google.com/go/go1.4.3.linux-amd64.tar.gz)

设置环境变量 `GOROOT_BOOTSTRAP`

解压到

```sh
tar zxvf go1.4.3.linux-amd64.tar.gz
cp go/ $home/go-bootstrap/
```

```sh
GOROOT_BOOTSTRAP=$home/go-bootstrap/
export GOROOT_BOOTSTRAP
```

### Mac 准备

[https://dl.google.com/go/go1.4.3.darwin-amd64.pkg](https://dl.google.com/go/go1.4.3.darwin-amd64.pkg)

设置环境变量 `GOROOT_BOOTSTRAP`

解压到

```sh
tar zxvf go1.4.3.darwin-amd64.tar.gz
cp go/ $home/go-bootstrap/
```

```sh
GOROOT_BOOTSTRAP=$home/go-bootstrap/
export GOROOT_BOOTSTRAP
```

### Windows 准备

下载
http://tdm-gcc.tdragon.net/download
需要下载 32 和 64 安装 TDM-GCC 32位 64位 并设置 path

下载
https://dl.google.com/go/go1.4.3.windows-amd64.zip
解压后

设置环境变量 `GOROOT_BOOTSTRAP` 到解压目录(禁止任何中文，编码问题)

进入需要配置交叉编译的目录，执行

```sh
cd %GOROOT%/src
set CGO_ENABLED=0 | set GOOS=linux | set GOARCH=amd64 | make.bat
```

## golang SDK 跨平台交叉编译

- 需要 进入 `$GOROOT/go/src` 源码所在目录执行
- 需要 golang 1.4.x 的环境

```sh
# 如果你想在Windows 32位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=windows GOARCH=386 ./make.bash

# 如果你想在Windows 64位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=windows GOARCH=amd64 ./make.

# 如果你想在OS X 32位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=darwin GOARCH=386 ./make.bash

# 如果你想在OS X 64位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 ./make.bash

# 如果你想在Linux 32位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=linux GOARCH=386 ./make.bash

# 如果你想在Linux 64位系统下运行
➜ ~cd $GOROOT/src
➜ ~CGO_ENABLED=0 GOOS=linux GOARCH=amd64 ./make.bash
```

执行结束后，才可以使用交叉编译

> 并不是重新编译Go，因为安装Go的时候，只是编译了本地系统需要的东西，而需要跨平台交叉编译，需要在Go中增加对其他平台的支持，所以会有 `./make.bash` 这么一个过程

## Error Set $GOROOT_BOOTSTRAP

```sh
##### Building Go bootstrap tool.
cmd/dist
ERROR: Cannot find /Users/xxx/go1.4/bin/go.
Set $GOROOT_BOOTSTRAP to a working Go tree >= Go 1.4.
```
