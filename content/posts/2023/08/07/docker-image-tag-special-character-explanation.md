---
title: "docker 镜像 tag 特殊字符解释"
date: 2023-08-07T14:11:30+08:00
description: "解释 docker 镜像 tag 标签中出现的特殊字符"
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

## `-alpine`

基于 [alpinelinux](https://alpinelinux.org/) 制作的镜像

apline是Alpine Linux操作系统，它是一个独立发行版本，相比较Debian操作系统来说Alpine更加轻巧，而通过Docker镜像搭建微服务倡导的就是一个“轻量级”概念，所以很多语言、应用也都发布了Alpine版本的Docker基础镜像

- 这个镜像一般非常小
- 一般来说，很多软件不能直接运行，需要安装依赖库，包括 驻守进程 之类的非常基础的工具都默认不安装
	- alpine 本身使用 容器编排来控制，所以本身不需要做驻守
	- 容器内的驻守进程，如果不经过处理，非常容易变成僵尸子进程，不清楚容器运行流程的不要在容器内使用驻守运行
- apline 没有使用 [glibc](https://www.gnu.org/software/libc/)，而是使用 [musl](http://www.musl-libc.org/)，所以有一些奇怪的问题
	- 如果你使用的业务实现，跟 glibc 强关联，不要使用 apline 做为基底镜像
- 因为不只是 alpine 一种轻量化的解决方案，不要强行使用

## `-slim`

通过 [docker slim](https://github.com/slimtoolkit/slim) 工具，给 docker 镜像瘦身后的镜像标记

这种镜像的特点是

- 包含某个环境的最少依赖包
- 一般建议生产环境使用这个
- 生产环境，镜像大小严重影响服务编排效率，所以更小的镜像肯定更优
	- 如果有特殊情况，才使用完整系统镜像

## Debian 家族

[Debian](https://www.debian.org) 是一个非常流行，且广泛使用的一个 linux 发行版

像Node、PHP、Python、Ruby、Rust 之类，对运行 OS 环境有要求的技术栈，会大量使用基于 Debian 搭建 Docker 基础镜像

> 注: 大量使用的原因是，这些编程语言官方镜像，一直稳定提供基于 Debian 的基底镜像。
> 这类编程语言或者使用这类语言实现业务时，对 [glibc](https://www.gnu.org/software/libc/) 依赖导致，并且除去依赖的成本不低。
> 当然这些编程语言官方也提供基于 alpine 的镜像，但在实际生产时，因为 alpine 本身设定导致的问题没有解决的话，使用 Debian 系做为基地镜像是保底操作。

不同的 bebian 版本 完整版本信息见 [https://wiki.debian.org/DebianReleases](https://wiki.debian.org/DebianReleases)

| code | version | EOL LTS | EOL ELTS |
|:------|:------|:-------|:------|
| bookworm  | debian 12 | | |
| bullseye  | debian 11 | | |
| buster   | debian 10 | 2024-06-30 | |
| stretch | debian 9 | 2022-07-01 | 2027-06-30 |
| jessie | debian 8 | 2020-06-30 | 2025-06-30 |

目前除了 LTS 其他版本已经不再提供技术支持了，所以我们非必要情况下还是不要选择过低版本

### `-bookworm`

bookworm 是基于 Debian Linux发行的一个版本， 2023-06-10 正式发布

### `-bullseye`

bullseye 是基于 Debian Linux发行的一个版本， 2021-08-14 正式发布

### `-buster`

buster是基于 Debian Linux发行的一个版本，2019-07-06 正式发布

经过长时间的证明(主要为 2019 到 2023 年段)，这个版本受广大Debian爱好者的好评

### `-stretch` or `-jessie`

jessie or stretch are the suite code names for releases of [Debian](https://wiki.debian.org/DebianReleases)
jessie or stretch 是 Debian 发行版

stretch是Debian Linux发现的一个版本，这个版本在Debian Linux已经算是比较老旧的版本

## `-windowsservercore`

基于 [Windows Server Core (microsoft/windowsservercore)](https://hub.docker.com/r/microsoft/windowsservercore/) 构建的镜像

# 参考

- [https://stackoverflow.com/questions/54954187/docker-images-types-slim-vs-slim-stretch-vs-stretch-vs-alpine](https://stackoverflow.com/questions/54954187/docker-images-types-slim-vs-slim-stretch-vs-stretch-vs-alpine)
- [Supported tags and respective Dockerfile links](https://github.com/docker-library/docs/blob/d4f015a4a99883c6b8691ec6aaf24a74cd02916a/openjdk/README.md)
- [openjdk image-variants](https://github.com/docker-library/docs/blob/master/openjdk/README.md#image-variants)
