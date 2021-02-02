---
title: "golang 编程规范 编程风格 整理"
date: 2021-02-02T12:45:02+08:00
description: "golang 编程规范 编程风格 编程风格检查工具"
draft: false
categories: ['golang']
tags: ['golang', 'lint']
toc:
  enable: true
  auto: false
math:
  enable: false
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

# 介绍

本文更多的介绍代码管理和检查工具而不是大篇幅风格文档，毕竟文档只能那里看，不如工具有时效性和可行性，毕竟`说到不如做到`

- 官方代码编程风格文档 [https://golang.org/doc/effective_go.html](https://golang.org/doc/effective_go.html)
- uber golang 代码规范 [https://github.com/uber-go/guide](https://github.com/uber-go/guide)
- uber golang 代码规范中文 [https://github.com/xxjwxc/uber_go_guide_cn](https://github.com/xxjwxc/uber_go_guide_cn)

## 代码目录规范

目录结构 推荐目录结构 [https://github.com/golang-standards/project-layout](https://github.com/golang-standards/project-layout)

### GOPATH 设置规范

`建议保留 GOPATH 规则，便于维护代码`

- 建议只使用一个 GOPATH
- 不建议使用多个 GOPATH，如果使用多个GOPATH，编译生效的 bin 目录是在第一个 GOPATH 下

> golang 在 1.11 以后，弱化了 GOPATH 规则，已有代码(很多库肯定是在1.11之前建立的)肯定符合这个规则
>> go mod 工具链在 GOPATH 代码下，需要额外打开环境变量配置 GO111MODULE=on
>> go 1.13 以后可以设置兼容

```bash
$ go env -w GO111MODULE='on'
```

## 工程根目录规范

golang工程结构很重要，决定了代码是否可以共享和维护

编写的代码在`$GOPATH/src/` 下

按维护需求`必须这样放置`

`${GOPATH}/src/${GIT_HOST}/{$GIT_USER}|${GIT_GROUP}/${PROJ_ROOT}`

- `GIT_HOST` git 仓库 host
- `GIT_USER` git 用户名称 同 GIT_GROUP 二选一
- `GIT_GROUP` git 工作组名称 GIT_USER 二选一
- `PROJ_ROOT` 项目根

例如 `github.com/sinlov/go-cli-fast-temp` golang CLI 工具模板项目
就在 `$GOPATH/src/` 下 github.com 的host sinlov 用户 go-cli-fast-temp 工程名

> 工程名，在模板或者非产品工程，使用 `-` 分割，如果是产品线级，防止跨平台兼容问题请使用 `全小写无分割符的 c 风格`

### 工程子包名规范

- `代码包名`必须和当前文件路径的父目录同名，增强可读性
- 防止跨平台兼容问题请使用 `全小写无分割符的 c 风格`
- 不要使用任何 golang 官方包已经存在的包名
- 必须使用 `git 全路径来定义新的包名`，防止命名冲突
- 不要使用 DI 注入工具编写业务代码，防止引用错误

## golang代码文件命名规范

- 工具代码文件 `驼峰命名描述工具作用`，暴露 Pascal 风格的操作名
- 模型代码文件，`全小写，描述单一模型`，暴露 Pascal 风格的模型 type 或者 interface
- 业务代码文件 `全小写，描述业务合辑`，不得暴露工具类意图
- 测试代码文件，必须为某个代码的 `_test.go` 不得跨文件编写测试代码

## golang编码实现规范

- 不要在 init 函数里做与变量初始化无关的工作
- 不要在 业务代码里面写 test 或者其他非输出的代码

更多规范建议看

- uber golang 代码规范 [https://github.com/uber-go/guide](https://github.com/uber-go/guide)
- uber golang 代码规范中文 [https://github.com/xxjwxc/uber_go_guide_cn](https://github.com/xxjwxc/uber_go_guide_cn)

## 编程规范检查工具

golang 生态链本身提供很多代码规范的工具，不用额外制定规范

### 静态检查工具

> 静态检查工具在 CI/CD 链中集成，即时发现即时补救

#### go vet

`go vet` 是一个用于检查Go语言源码中静态错误的简单工具
go vet命令可以接受 `-n` 标记和 `-x` 标记

#### go tool vet

go tool vet 命令的作用是检查Go语言源代码并且报告可疑的代码编写问题

比如，在调用Printf函数时没有传入格式化字符串，以及某些不标准的方法签名，等等

> 该命令使用试探性的手法检查错误，因此并不能保证报告的问题确实需要解决。它确实能够找到一些编译器没有捕捉到的错误。

go tool vet 命令的标记

```sh
-all 进行全部检查。如果有其他检查标记被设置，则命令程序会将此值变为false。默认值为true。
-asmdecl 对汇编语言的源码文件进行检查。默认值为false。
-assign 检查赋值语句。默认值为false。
-atomic 检查代码中对代码包sync/atomic的使用是否正确。默认值为false。
-buildtags 检查编译标签的有效性。默认值为false。
-composites 检查复合结构实例的初始化代码。默认值为false。
-compositeWhiteList 是否使用复合结构检查的白名单。仅供测试使用。默认值为true。
-methods 检查那些拥有标准命名的方法的签名。默认值为false。
-printf 检查代码中对打印函数的使用是否正确。默认值为false。
-printfuncs 需要检查的代码中使用的打印函数的名称的列表，多个函数名称之间用英文半角逗号分隔。默认值为空字符串。
-rangeloops 检查代码中对在```range```语句块中迭代赋值的变量的使用是否正确。默认值为false。
-structtags 检查结构体类型的字段的标签的格式是否标准。默认值为false。
-unreachable 查找并报告不可到达的代码。默认值为false。
```

more info see [go 命令教程](https://www.kancloud.cn/cattong/go_command_tutorial/261356)

#### race condition 竞争检查

资源竞争检查，并发时遇到的问题，会导致并发能力下降, 长时间运行一般会出现这个错误

```sh
panic: runtime error: invalid memory address or nil pointer dereference
```

- 检查方法

```golang
# 任意代码，构建时加入参数`-race`
go build -race
```

文档见 [http://blog.golang.org/race-detector](http://blog.golang.org/race-detector)

### 风格检查

> 不建议制定风格检查文档，又冗长，又无法实施

#### golint

安装方法

```sh
go get -v github.com/golang/lint
go install github.com/golang/lint
```

使用

```sh
golint [dir or file]
```

风格检查样例 [https://github.com/golang/lint/tree/master/testdata](https://github.com/golang/lint/tree/master/testdata)

> golint 检查范围就非常广了，也很严格，可以配合 vscode 的 go 插件，或者 goland 的 golint 来检查代码风格
