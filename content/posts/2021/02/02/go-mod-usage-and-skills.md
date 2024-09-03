---
title: "go mod 使用及技巧"
date: 2021-02-02T12:55:02+08:00
description: "Go mod usage and skills"
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

## 首先

本文是建立在 go 1.12 及以上， 在 go 1.16版本成为默认构建模式，替代了原先的 GOPATH 构建模式
官方文档 [https://blog.golang.org/using-go-modules](https://blog.golang.org/using-go-modules)

## 常用go mod命令

```bash
go mod init 初始化当前文件夹, 创建go.mod文件
go mod edit 编辑go.mod文件
go mod graph 打印模块依赖图
go mod tidy 增加缺少的module，删除无用的module
go mod vendor 将依赖复制到vendor下
go mod verify 校验依赖
go mod why 解释为什么需要依赖
go mod download 下载依赖的module到本地cache（默认为$GOPATH/pkg/mod目录）
```

## 更新规则

### 向前兼容性和toolchain规则 1.21+

Go 1.21版本之前，Go语言在向前兼容性方面却存在一定的不确定性问题
[Go 1.21版本对此进行了改进，并引入了go toolchain 规则](https://go.dev/blog/toolchain)
	- [Go Toolchains reference](https://go.dev/doc/toolchain)

> 在Go 1.21版本之前，Go module中的go directive用于声明建议的Go 版本，但并不强制实施

同时使用 `go directive` 和 `toolchain directive` 来提供对go版本和go工具链的依赖信息

- `go directive` 它不再是建议，而是指定了module 最小可用的 Go版本， 仅使用本地go工具链的情况下，如果Go编译器版本低于go.mod中的go版本，将无法编译代码
-  `toolchain directive` 在Go 1.21版本及以后，go 还提供了自动Go工具链管理，如果go发现本地工具链版本低于go module要求的最低go版本，那么go会自动下载高版本的go工具链，缓存到 go module cache中(不会覆盖本地安装的go工具链) ，并用新下载的go工具链对module进行编译构建

管理原则 `将 go版本 和 go toolchain版本 作为一个 "module的依赖" 来管理`

```
// go.mod
module foo

go 1.20.14

toolchain go1.23.0
```

同时和使用 go get 可以改变 go.mod 的 require块中的依赖的版本一样，通过 go get 也可以修改 go.mod 中 go 和 toolchain 指示的版本

```bash
$go get go@1.21.13
$go get toolchain@go1.23.0
```

#### GOTOOLCHAIN环境变量与toolchain版本选择

1. 当 go 命令捆绑的工具链 与 module 的 go.mod 的 go或工具链版本一样时或更新时，go 命令会使用自己的捆绑工具链

例如

```
module foo

go 1.21.0

toolchain go1.21.3
```

2. 当在 foo module 的 go.mod 包含有 go 1.21.0 时，如果 go 命令绑定的工具链是 Go 1.21.3 版本，那么将继续使用初始toolchain 的版本，即 Go 1.21.3

如果 go.mod 中的 go 版本写着 go 1.21.9

```
module foo

go 1.21.9

toolchain go1.21.3
```

那么go 命令捆绑 的工具链版本 1.21.3 显然不能满足要求，那此时就要看GOTOOLCHAIN环境变量的配置

#### go toolchain switches

当 Go 工具在编译 module 依赖项时发现当前 go toolchain 版本无法满足要求时，会进行 go toolchain switches(切换)，切换的过程就是从可用的 go toolchain 列表中取出一个最适合的

go命令有三个候选版本(以当前发布的最新版Go 1.21.1为例，这些版本也是Go当前承诺提供support的版本)

- 尚未发布的Go语言版本的最新候选版本（1.22rc1）
- 最近发布的 Go 语言版本的最新补丁 (1.21.1)
- 上一个Go语言版本的最新补丁版本(1.20.8)

当 GOTOOLCHAIN 设置为带 auto 形式的值的时候，Go会下载这些版本
当 GOTOOLCHAIN 设置为代 path 形式的值的时候，Go会在PATH路径搜索适合的go工具链列表
接下来，go会用 mvs(最小版本选择) 来确定究竟使用哪个toolchain版本

具体例子

- 假设 example.com/widget@v1.2.3 需要 Go 1.24rc1 或更高版本
	- go命令会获取可用工具链列表，并发现两个最新Go工具链的最新补丁版本是Go 1.28.3和Go 1.27.9，候选版本Go 1.29rc2也可用
	- 在这种情况下，go 命令会选择Go 1.27.9
- 如果 example.com/widget 需要 Go 1.28或更高版本
	- go命令会选择 Go 1.28.3，因为 Go 1.27.9 太旧了
- 如果widget需要Go 1.29或更高版本
	- go命令会选择Go 1.29rc2，因为Go 1.27.9和Go 1.28.3都太老

##### auto (等价于 local+auto)，默认值配置

- auto 的语义是当go.mod中工具链版本低于go命令捆绑的工具链版本，则使用go命令运行捆绑的工具链
- 反之，自动下载对应的工具链版本，缓存起来并使用

```bash
$cat go.mod
module foo

go 1.23.1
toolchain go1.23.1

$GOTOOLCHAIN=auto go build
go: downloading go1.23.1 (darwin/amd64)
```

##### `local`

- 当 GOTOOLCHAIN 设置为 local 时，go 命令总是运行捆绑的 Go 工具链
- 如果 go.mod 中工具链版本高于 local 的版本，则会停止编译过程

```bash
$cat go.mod
module foo

go 1.23.1
toolchain go1.23.1

$GOTOOLCHAIN=local go build
go: go.mod requires go >= 1.23.1 (running go 1.21.0; GOTOOLCHAIN=local)
```

##### `<name>+auto` 配置

- `GOTOOLCHAIN=go1.21.0`。go命令将始终运行该特定版本的go工具链
	- 如果本地存在该版本工具链，就使用本地的
	- 如果不存在，会下载、缓存起来并使用
	- 如果 go.mod 中的工具链版本高于name版本，则停止编译

- 当 `GOTOOLCHAIN设置为<name>+auto` 时，go命令会根据需要选择并运行较新的Go版本
	- 它会查询go.mod文件中的工具链版本和go version
	- 如果go.mod 文件中有toolchain行，且toolchain指示的版本比默认的Go工具链(name)新，那么系统就会调用toolchain指示的工具链版本
	- 反之会使用默认工具链

效果为

```bash
$cat go.mod
module foo

go 1.23.1
toolchain go1.23.1

$GOTOOLCHAIN=go1.24.1+auto go build
go: downloading go1.24.1 (darwin/amd64) // 使用name指定工具链，但该工具链本地不存在，于是下载。

$GOTOOLCHAIN=go1.20.1+auto go build
go: downloading go1.23.1 (darwin/amd64) // 使用go.mod中的版本的工具链
```

##### `<name>+path` 配置

当 `GOTOOLCHAIN设置为<name>+path` 时，go命令会根据需要选择并运行较新的Go版本

- 查询go.mod文件中的工具链版本和go version
- 如果go.mod 文件中有toolchain行，且toolchain指示的版本比默认的Go工具链(name)新，那么系统就会调用toolchain指示的工具链版本
- 反之会使用默认工具链
- 如果决策得到的工具链版本在PATH路径下没有找到，那么go命令执行过程将终止

```bash
$cat go.mod
module foo

go 1.23.1
toolchain go1.23.1

$GOTOOLCHAIN=go1.24.1+path go build // 使用name指定工具链，但该工具链本地不存在，于是编译停止
go: cannot find "go1.24.1" in PATH

$GOTOOLCHAIN=go1.20.1+path go build // 使用go.mod中的版本的工具链，但该工具链本地不存在，于是编译停止
go: cannot find "go1.23.1" in PATH
```

##### `path (等价于 local+path)`

- path的语义是当go.mod中工具链版本低于go命令捆绑的工具链版本，则使用go命令运行捆绑的工具链
- 反之，在PATH中找到满足go.mod中工具链版本的go版本
	- 如果没找到，则会停止编译过程

```bash
$cat go.mod
module foo

go 1.23.1
toolchain go1.23.1

$GOTOOLCHAIN=path go build
go: cannot find "go1.23.1" in PATH
```

## 依赖替换 replace

在国内访问golang.org/x的各个包都需要翻墙，你可以在go.mod中使用replace替换成github上对应的库

```
replace (
golang.org/x/crypto v0.0.0-20180820150726-614d502a4dac => github.com/golang/crypto v0.0.0-20180820150726-614d502a4dac
golang.org/x/net v0.0.0-20180821023952-922f4815f713 => github.com/golang/net v0.0.0-20180826012351-8a410e7b638d
golang.org/x/text v0.3.0 => github.com/golang/text v0.3.0
)
```

### 加载本地模块

使用 `replace` 配置，让一个模块可以读取本地一个目录

```
require github.com/zhouzme/snail-go v0.0.0-20190401091717-1f0218b38bc8
replace github.com/zhouzme/snail-go => ~\go\src\ github.com/zhouzme/snail-go
```

## 整理依赖

- 我们在代码中删除依赖代码后，`相关的依赖库并不会在go.mod文件中自动移除`
- `这种情况下我们可以使用go mod tidy命令更新go.mod中的依赖关系`

## 使用代理

- https://goproxy.cn
- https://mirrors.aliyun.com/goproxy/
- https://goproxy.io/
- https://gocenter.io
- 设置全局 go env 使用

```bash
# golang 1.13 后可用，对应代理配置可以改变
$ go env -w GOPROXY=https://goproxy.cn,direct
# 出现错误是因为 windows 系统，需要自行配置环境变量
warning: go env -w GOPROXY=... does not override conflicting OS environment variable
# 设置忽略和 验证
$ go env -w GOPRIVATE='*.gitlab.com,*.gitee.com'
$ go env -w GOSUMDB="sum.golang.org"
```

- 直接使用

```sh
GOPROXY="https://goproxy.cn" GO111MODULE=on go build
GOPROXY="https://goproxy.cn" GO111MODULE=on go install -v -a
```

在golang 1.11版本推出go mod的同时
还推出了一个新的环境变量GOPROXY
它的作用类似http(s)_proxy，用于为golang代码仓库做镜像代理

export GOPROXY=https://goproxy.cn

> 注意，GOPROXY开启以后，若失败不会自动回源

GoCenter还推出了goc工具，它可以自动回源
如果你有使用Athens私有仓库，可以将GOPROXY设置为Athens，然后将GoCenter设置为Athens的remote repository

## 私有仓库验证

可以设置 GOSUMDB="sum.golang.google.cn"， 这个是专门为国内提供的sum 验证服务，不过现在已经失效

```bash
go env -w GOSUMDB="sum.golang.google.cn"
# 默认为
go env -w GOSUMDB="sum.golang.org"
```
> -w 标记 要求一个或多个形式为 NAME=VALUE 的参数， 并且覆盖默认的设置

> 如果在运行go mod vendor时，提示Get https://sum.golang.org/lookup/xxxxxx: dial tcp 216.58.200.49:443: i/o timeout，则是因为Go 1.13设置了默认的GOSUMDB=sum.golang.org，这个网站是被墙了的，用于验证包的有效性，可以通过如下命令关闭

```bash
go env -w GOSUMDB=off
```

### 跳过私有库

比如常用的Gitlab或Gitee

```bash
go env -w GOPRIVATE=*.gitlab.com,*.gitee.com
```

## 开启 vendor 优先查找

设置 `GO15VENDOREXPERIMENT=1` 它将开启 go 的 vendor 功能
简单来说 vendo r就是go 在编译的时候优先查找 vendor 文件夹下的对应文件

vendor 文件夹可以固化依赖文件

## edit 编辑go.mod

### go.mod格式化

因为我们可以手动修改go.mod文件，所以有些时候需要格式化该文件
```sh
go mod edit -fmt
```

#### 添加依赖

```bash
# 查询目标库版本
$ go list -m -versions github.com/gin-gonic/gin
go: finding github.com/gin-gonic/gin v1.5.0
github.com/gin-gonic/gin v1.1.1 v1.1.2 v1.1.3 v1.1.4 v1.3.0 v1.3.0+incompatible v1.4.0 v1.5.0
# 如果已经设置了各种 go env 环境等等
# 这里演示 https://github.com/gin-gonic/gin 版本 v1.4.0 库的添加
$ go mod edit -require=github.com/gin-gonic/gin@v1.4.0
# 添加完成后，请立刻 vendor 到当前目录
$ go mod vendor

# 如果对方没有做完善的版本管理，直接执行
# 例如库 https://github.com/gopherjs/gopherjs
$ go list -m -versions github.com/gopherjs/gopherjs
github.com/gopherjs/gopherjs
# 输出无版本所以，没法通过 go mod 直接添加
# 目前解决方法是，先显示写代码，引入包，并实现，然后执行
$ go mod vendor
# 就会自动添加一个依赖，一般版本号为 v0.0.0-[提交时间]-[提交码前12位]

# 如果是CI系统上，建议使用完整命令行添加依赖

# 这里演示的是 https://github.com/bar-counter/monitor 这个库，使用对应版本 v1.1.0 代码
$ GO111MODULE=on go mod edit -require=github.com/bar-counter/monitor@v1.1.0
$ GO111MODULE=on go mod vendor
```

> 更建议 vendor 到当前工作目录，且将 `vendor目录` `go.sum文件` 忽略版本管理

#### 输出当前全部依赖

```bash
go list -m -json all
```

### 添加私有仓库依赖

`配置好私有仓库 ssh` 确认私有仓库可用使用
```bash
ssh -T {host}
```
访问
让后推一个仓库代码，然后在 go mod 工程下面，用命令测试

go list -m -versions {host}/{group}/{repo}.git

也就是平时测试比如
go list -m -versions github.com/gin-gonic/gin 后面加 .git 使用 ssh 协议

> 注意只对 私有仓库，配置好 ssh 生效

## Error

### in multiple modules

```sh
build command-line-arguments: cannot load github.com/ugorji/go/codec: ambiguous import: found github.com/ugorji/go/codec in multiple modules:
github.com/ugorji/go v1.1.4 ($GOPATH\pkg\mod\github.com\ugorji\go@v1.1.4\codec)
github.com/ugorji/go/codec v0.0.0-20190320090025-2dc34c0b8780 ($GOPATH\pkg\mod\github.com\ugorji\go\codec@v0.0.0-20190320090025-2dc34c0b8780)
mingw32-make: *** [Makefile:114: buildMainMod] Error 1
```

- fix in `go.mod` add item

```
require (
github.com/ugorji/go v1.1.7 // indirect
)
```

and run

```sh
go mod download && go mod tidy
```

- fix just try in [https://github.com/ugorji/go/issues/43#issuecomment-507727104](https://github.com/ugorji/go/issues/43#issuecomment-507727104)

