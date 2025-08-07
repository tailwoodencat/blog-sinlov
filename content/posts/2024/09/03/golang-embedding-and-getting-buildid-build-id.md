---
title: "golang 预埋和获取 buildID 构建标识"
date: 2024-09-03T18:04:43+08:00
description: "Golang embedding and getting buildID build ID"
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

## 构建预埋 buildID

通常情况下，你可能希望在编译时就 预埋 buildID ，在运行时直接读取 构建 id ，这通常在构建流程进行改造

例如在 Dockerfile 中或者 CI/CD 流水线中，你可以在构建命令中添加 `-ldflags` 参数来设置或访问

```bash
# 添加 buildID
go build -ldflags "-X main.buildID=your-build-id"
```

你的代码中使用标记访问这个值

```go
package main

import "fmt"

var buildID string

func init() {
	if buildID == "" {
		buildID = "unknown"
	}
}

func main() {
	fmt.Println("BuildID:", buildID)
}

```

每次构建时都可以根据需要设置不同的 buildID

```
# 比如 git 版本号
git --no-pager rev-parse --short HEAD

# 比如 svn 版本号
svn info | grep '^Revision' | awk '{print $2}'
```

## 使用 zymosis 工具 预埋

[https://github.com/convention-change/zymosis](https://github.com/convention-change/zymosis)

提供 golang 构建版本资源预埋

```bash
# init project need code
$ zymosis init
# if want update code, just use
$ zymosis init --coverage-exist-file

# then before CI or release binary run as
$ zymosis -g go
```

go code show res mark code

```golang
fmt.Println(zymosis.MainProgramRes())
```
