---
title: "docker 清理磁盘占用"
date: 2024-08-20T00:53:02+08:00
description: "docker cleans up disk occupancy"
draft: false
categories: ['container']
tags: ['container', 'docker']
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

## 查看 docker 的磁盘占用

```bash
$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          74        16        23.37GB   20.19GB (86%)
Containers      18        8         2.223MB   28.9kB (1%)
Local Volumes   19        9         4.338GB   156.6MB (3%)
Build Cache     167       0         67.93MB   67.93MB
```

docker 使用磁盘的 4 种类型

| type | desc |
|:----|:------|
| Images | 所有镜像占用的空间，包括拉取下来的镜像，和本地构建 |
| Containers | 运行的容器占用的空间，表示每个容器的读写层的空间 |
| Local Volumes | 容器挂载本地数据卷的空间 |
| Build Cache | 镜像构建过程中产生的缓存空间 18.09 后可用 |

## 自动清理磁盘占用

命令 `docker system prune` 可以用于清理磁盘，删除关闭的容器、无用的数据卷和网络，以及 dangling 镜像(无 tag)

`docker system prune -a` 清理得更加彻底，可以将没有容器使用 Docker 镜像都删掉

> 注意: 请注意使用，system prune 会把暂时关闭的容器，以及暂时没有用到的 Docker 镜像都删掉

## docker build cache 缓存清理

- [https://docs.docker.com/engine/reference/commandline/builder_prune/](https://docs.docker.com/engine/reference/commandline/builder_prune/)

```bash
# 清理全部 构建
$ docker builder prune

# 保留最近10天的缓存
$ docker builder prune --filter 'until=240h'
```

## docker image 清理

```bash
docker image prune
```

## 容器清理

```bash
docker container prune
```

## 存储清理

```bash
docker volume prune
```
