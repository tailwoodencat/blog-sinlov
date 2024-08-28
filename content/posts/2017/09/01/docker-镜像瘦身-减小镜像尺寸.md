---
title: "docker 镜像瘦身 减小镜像尺寸"
date: 2017-09-01T11:40:39+08:00
description: "docker 镜像瘦身 减小镜像尺寸 docker管理技巧 镜像尺寸变大的原因"
draft: false
categories: ['container']
tags: ['docker']
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

## 镜像尺寸变大的原因

- 无用文件，比如编译过程中的依赖文件
- 对编译或运行无关的指令被引入到镜像
- 系统镜像冗余文件多
- 各种日志文件，缓存文件
- 重复编译中间文件
- 重复拷贝资源文件
- 运行无依赖文件

## 工程配置优化

### 使用.dockerignore

在使用 Dockerfile 构建镜像时使用 `.dockerignore` 在镜像上下文中忽略文件
这样不仅可以减少一些非必要文件的导入，也可以提高安全性，避免将一些配置文件打包到镜像中

## 构建流程优化

### 使用精简的镜像开始构建

使用精简版 Linux发行版 镜像开始构建

- alpine https://hub.docker.com/_/alpine
- scratch https://hub.docker.com/_/scratch

### 清理编译环境和跟程序运行无关的软件和文件

编译完成后

```Dockerfile
RUN apt-get update && \
apt-get install -y git make gcc libssl-dev && \
……
# 编译完成后，清理编译环境和跟程序运行无关的软件
apt-get purge -y git make gcc libssl-dev
# 清理编译过程日志，或者清理编译源码
rm -rf ./src &&\
rm -rf ./dist
```

### Dockfile 指令优化

一个常见的案例是打包元数据和缓存

在安装完编译和运行相关的依赖包之后，这些下载的文件就没有存在的必要了

类似 clean 的指令可以在很多仓库（如Docker Hub）的 Dockerfile 中发现，它们用于清理这类文件

比如

```DockerFile
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/

# RUN apt-get update
# RUN apt-get install -y curl
RUN apt-get autoclean
RUN apt-get clean
# RUN apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*
```

> Docker 镜像的尺寸是每一个独立镜像层的尺寸之和，这也就是联合文件系统的工作机制。因此，`clean 步骤并没有真正删掉相应的硬盘空间`

查询构建过程即可知道

```bash
docker build -t demo .
docker history demo
```

Dockerfile 中每一个指令要么保持镜像尺寸不变，要么增加它的尺寸
同时，每一步还会引入新的元数据信息，使得整体尺寸在增大

`为了降低整个镜像的尺寸，清除操作应该在同一镜像层中执行。于是，解决方案是将先前的多条指令合并成一条`

使用Bourne shell 提供的&&操作符来实现链接

```DockerFile
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
COPY ./sources.list /etc/apt/

# debian or ubuntu
RUN apt-get autoclean \
&& apt-get clean \
&& autoremove \
&& rm -rf /var/lib/apt/lists/*

# apline
RUN apk -U --no-cache add git
# or
RUN apk -U add git && \
rm -rf /var/cache/apk/*
```

### 多段构建 multi-stage

[多段构建官方文档 https://docs.docker.com/develop/develop-images/multistage-build/](https://docs.docker.com/develop/develop-images/multistage-build/)

> 从Docker 17.05开始，一个Dockerfile文件可以使用多条FROM语句，每条FROM语句可以使用不同的镜像

可以把Docker的构建阶段分层多个阶段，以`两个FROM语句`(两段构建)为例
1. 我们可以使用一个镜像编译我们的程序；
2. 另一个镜像使用更精简的镜像，拷贝上一阶段的编译的结果;

在使用FROM语句时
- 我们可以用 `AS` 为不同的镜像起别名，方便后续操作;
- 用 `COPY` 命令从其他镜像拷贝文件时，可以用 `--from=alias src dst` 从别的阶段复制文件；

> 如果没有为镜像起别名

- 第一个镜像的ID为0
- 第二个为1，我们可以用ID从别的阶段拷贝文件 `--from=0 src dst`

例如: 如下一个 二段构建例子

```Dockerfile
FROM golang:1.9-alpine as builder
RUN apk --no-cache add git
WORKDIR /go/src/github.com/go/helloworld/
RUN go get -d -v github.com/go-sql-driver/mysql
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest as prod
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/go/helloworld/app .
CMD ["./app"]
```

> 另外很多镜像，比如 node yarn 有 `distroless` 镜像，只包含应用程序及其运行时依赖，常用于多段构建后面的精简镜像

### 分离编译镜像和部署镜像

导致镜像过大的无用文件是编译过程中的依赖文件
例如在编译应用程序过程中所依赖的源代码库，如编译文件和头文件

一旦应用程序编译完毕，这些文件就不再有用，因为运行该应用仅需要相关的依赖库

- 使用 `docker cp -L` 命令 复制运行容器中的可执行文件到Docker 宿主机
- 然后使用 `ADD` 指令添加必要二进制文件

> 这种分离优化技术的最佳实践案例是在一个可持续开发流程中的应用程序的场景，并且它由于镜像太大导致传输时间太长

分离后, 对应镜像是这种结构

```bash
env_image -> framework_1 -> work_compile_one_framework_1 -> work_containt_group_one_framework_1
           |
           \ framework_2 -> work_compile_one_framework_2 -> work_containt_group_one_framework_2
                          |
                          |
                          \ work_compile_two_framework_2 -> work_containt_group_two_framework_2
```

- env_image 是基础环境镜像 比如: ubuntu alpine
- framework_${name} 是依赖环境镜像 比如: go node java等
- work_compile_${name}_framework 是工作组编译依赖 比如: 工作组模板工程，或者具体代码，也可以是已经配置好资源的 node 工程，用于编译
- work_containt_group_one_${name} 是具体用于部署的镜像, CI 自动化时生产镜像，再由 k8s k3s 之类的管理工具部署

### 编译型语言发布优化

比如 go 可以完全发布二进制文件来运行，这样就可以做到一个
`无依赖镜像 + 10MB 二进制文件 + 1k 配置文件` 的最简直接运行镜像

> 注意，go build 默认输出的二进制文件有平台依赖，支持这种发布需要输出无依赖二进制文件

例如: 一个基于 [gin](https://github.com/gin-gonic/gin) 的 web app，输出时需添加参数

```bash
CGO_ENABLED=0 \
GOOS=linux \
go build \
-a -installsuffix cgo -ldflags '-w' -i \
-tags netgo \
-o ${ENV_GO_OUT_PATH} \
${ENV_GO_PROJECT_MAIN_FILE}
```

参数说明

```
CGO_ENABLED=0：指明cgo工具是否可用的标识，在这里0表示禁用。

GOOS=linux：目标平台（编译后的目标平台）的操作系统（darwin、freebsd、linux、windows） 查询使用 go tool dist list

-a：强制重新编译所有涉及的go语言代码包

-installsuffix：为了使当前的输出目录与默认的编译输出目录分离，可以使用这个标记。

cgo 指令如下：
  -ldflags：给cgo指定命令
  '-w'：关闭所有警告信息
  -i：标志安装目标的依赖包

-tags netgo
  包含 net 包，web 类运行依赖 net

-o 目录/生成的程序：${ENV_GO_OUT_PATH} 这里使用环境变量

${ENV_GO_PROJECT_MAIN_FILE}：编译的入口地址，当然很多时候写成 main.go
```

## 镜像构建后优化

### 使用 docker-slim 瘦身

[https://github.com/docker-slim/docker-slim](https://github.com/docker-slim/docker-slim)

安装后使用

```bash
docker-slim build --from-dockerfile build/docker/Dockerfile --tag [group/imagename]:[tagname]
```

或者交互式使用

[![asciicast](https://github.com/docker-slim/docker-slim/raw/master/assets/images/dslim/DockerSlimIntPromptDemo.gif)](https://asciinema.org/a/311513)

> 注意: slim 会导致某些依赖文件，比如`必须的二进制依赖文件丢失`,使用时需加入 `--include-path` 保留文件夹

```bash
docker-slim build --http-probe=false --include-path=/var/lib/mysql-files --include-path=/var/run/mysqld mysql:5.7
```

### 使用 dive 优化镜像内部文件

使用 [https://github.com/wagoodman/dive](https://github.com/wagoodman/dive) 工具来优化镜像文件

这是一个浏览查看 docker image 文件，用于找出缩小镜像的工具

- 官方演示

[![demo.gif](https://github.com/wagoodman/dive/raw/master/.data/demo.gif)](https://github.com/wagoodman/dive#dive)

- 安装
建议使用 docker 镜像安装方法，方便且易于管理，`注意 windows 用户就别用这个方法了，环境限制`

```bash
$ sudo curl -s -L https://raw.githubusercontent.com/bridgewwater/docker-exec-tools/master/dive/v0.9.2/run.sh -o /usr/local/bin/dive
$ sudo chmod +x /usr/local/bin/dive
```

如果docker安装有问题，或者喜欢二进制安装，可以[直接下载二进制文件](https://github.com/wagoodman/dive/releases)

配置环境变量后使用

- 使用 dive

```bash
# 比如分析 docker/getting-started
docker run -dp 50080:80 --rm --name docker-getting-started docker/getting-started
dive docker/getting-started
# 注意每次会加载镜像进行分析，如果你镜像本身很大就会加载时间过长
```
- dive 快捷键

常用快捷键

- <kbd>Tab</kbd> 切换布局
- <kbd>Space</kbd> 收起/展开文件树
- <kbd>Ctrl + Space</kbd> 收起/展开所有文件树
- <kbd>Ctrl + F</kbd> 查找文件
- <kbd>PageUp</kbd> 上翻页
- <kbd>PageDown</kbd> 下翻页

详细快捷键见 [https://github.com/wagoodman/dive#keybindings](https://github.com/wagoodman/dive#keybindings)

----------------

参考

[「Allen 谈 Docker 系列」之深刻理解 Docker 镜像大小](http://m635674608.iteye.com/blog/2337225)
[如何让Docker基础镜像变得更小](https://www.58jb.com/html/150.html)
[CentOS Dockerfile减少构建镜像大小的方法](http://www.cnblogs.com/ericnie/p/7991218.html)

