---
title: "godoc 命令和 golang 代码文档管理"
date: 2019-02-02T11:25:13+08:00
description: "desc godoc 命令和 golang 代码文档管理"
draft: false
categories: ['golang']
tags: ['golang']gst
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
- godoc 是 golang 自带的文档查看器，更多的提供部署服务
- go doc 和 godoc 在 golang 1.13 被移除了，可以自行安装 [golang.org go1.13 godoc](https://golang.org/doc/go1.13#godoc)

```bash
go get golang.org/x/tools/cmd/godoc
# 使用代理安装
GOPROXY='https://goproxy.cn,direct' go get -v golang.org/x/tools/cmd/godoc
godoc
```
- godoc 基础使用

```sh
# 查看包内的文档，这里是查看 fmt 包中 Printf Println 的的文档
godoc fmt Printf Println
# 查看文档并包含源码
godoc -src fmt Printf
# 查看的同时显示示例代码
godoc -ex fmt Printf
# 显示文档的web版本 http -> 端口
godoc -http=:6060
# 显示 http 文档并开启本地索引
godoc -http=:6060 -index
```

> 要使用-index标记开启搜索索引，这个索引会在服务器启动时创建并维护。

否则无论在Web页面还是命令行终端中提交查询都会返回错误"Search index disabled: no results available"

如果不想提供如此多的结果条目，可以设置小一些的值

>甚至，如果不想提供全文本搜索结果，可以将标记 `-maxresults` 的值设置为0，这样服务器就只会创建标识符索引，而根本不会创建全文本搜索索引
>标识符索引即为对程序实体（变量、常量、函数、结构体和接口）名称的索引

- go doc 这个是golang语言自带的文档查看工具

```sh
# 文档工具使用说明
go help doc
# 查看当前包的文档索引
go doc
# 查看目标包的文档索引
go doc [targetPackage]
# 查看目标包的某内容的文档索引
go doc [targetPackage].[函数名]
# 或者空格隔开也显示某内容的文档
go doc [targetPackage] [函数名]
# 子包的文档注释
go doc [targetPackage]/[subpackage]
```

## golang发布查询代码注释文档


### 发布文档

```
godoc -http=:9090 -index
```

这样就在本机使用 [http://127.0.0.1:9090/pkg/](http://127.0.0.1:9090/pkg/) 查看发布的包
当然你可以使用 [http://127.0.0.1:9090/pkg/github.com/github.com/sinlov/XXXServer/userbiz/](http://127.0.0.1:9090/pkg/github.com/github.com/sinlov/XXXServer/userbiz/) 来查询自己代码 包 `github.com/sinlov/XXXServer/userbiz` 下面的文档

### 查询发布文档

通过 godoc -q 命令查询发布文档服务，一般用于在另一个命令行终端甚至另一台能够与本机联通的计算机中通过如下命令进行查询

```sh
# 在本机用godoc命令启动了Go文档Web服务器，且IP地址为192.168.2.201、端口为9090
godoc -q -server="192.168.2.201:9090" Listener
```

- 标记 `-q` 开启了远程查询的功能
- 标记 `-server="192.168.2.201:9090"` 则指明了远程文档服务器的IP地址和端口号

如果不指明远程查询服务器的地址，那么该命令会自行将地址 `:6060` 和 `golang.org` 作为远程查询服务器的地址

> 这个地址 golang.org:6060 即是默认的本机文档Web站点地址和官方的文档Web站点地址

# golang 代码文档管理

## 代码文档编写

其实只要按 go 的标准注释写法编写，就可以显示代码文档了

比如 定义在 `github.com/sinlov/XXXServer/userbiz` 种有个文件 `biz.go`

```golang
// Biz implements a business
type Biz struct {
}

// business initialization
func (b *Biz) Init() {
}
```
> 注意 `//` 后面跟空格，才开始解析文档
>> 如果需要展示代码需要 `//`后紧跟 `[[:tab]]` tab，那么 go doc 就会把这行当做代码来看
>> 可惜的是，go没法自行在注释里面添加使用链接，而是解析器跟踪使用来生成链接

查看这个代码的文档命令就是 `godoc github.com/sinlov/XXXServer/userbiz`
查看某个函数的文档，比如 Init 函数 就是 `godoc github.com/sinlov/XXXServer/userbiz Init`

## 代码文档导出

就使用上面文章中提到的 `godoc -q -server=` 指令，直接部署在服务器中就行