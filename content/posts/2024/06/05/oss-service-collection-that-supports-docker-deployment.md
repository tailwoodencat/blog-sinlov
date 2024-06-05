---
title: "OSS service collection that supports docker deployment"
date: 2024-06-05T09:59:12+08:00
description: "desc OSS service collection that supports docker deployment"
draft: false
categories: ['container']
tags: ['container', 'docker', 'oss']
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

## minio

- [https://github.com/minio/minio](https://github.com/minio/minio)

[![GitHub license](https://img.shields.io/github/license/minio/minio)](https://github.com/minio/minio)

- MinIO中国加速站[https://dl.minio.org.cn/](https://dl.minio.org.cn/)
- 官方 中文文档 [https://www.minio.org.cn/docs/minio/container/index.html](https://www.minio.org.cn/docs/minio/container/index.html)

[![docker hub version semver](https://img.shields.io/docker/v/minio/minio?sort=semver)](https://hub.docker.com/r/minio/minio/tags?page=1&ordering=last_updated)
[![docker hub image size](https://img.shields.io/docker/image-size/minio/minio)](https://hub.docker.com/r/minio/minio)
[![docker hub image pulls](https://img.shields.io/docker/pulls/minio/minio)](https://hub.docker.com/r/minio/minio/tags?page=1&ordering=last_updated)

- k8s
	- [helm/bitnami/minio](https://artifacthub.io/packages/helm/bitnami/minio)
	- [hub.grapps.cn-Bitnami Object Storage based on MinIO](https://hub.grapps.cn/marketplace/apps/877)

Minio主体的许可证是GNU AGPL v3，等于说你的产品必须要开源

minio的SDK程序的许可证是Apache License 2.0，你拿去随便用都行。但是很明显，明明亚马逊有更好的接口库，为什么非得用它的。(本人在产品上用过MINIO SDK，个人认为相比于官方的SDK，本身更加精简，也是能完美支持各家的云服务。但是缺点就是不支持各家云服务的特殊API，尤其是自定义下载链接限速)

## moosefs

- [https://github.com/moosefs/moosefs](https://github.com/moosefs/moosefs)
- [https://hub.docker.com/r/moosefs/master](https://hub.docker.com/r/moosefs/master)

GPL-2.0 license

[![GitHub license](https://img.shields.io/github/license/moosefs/moosefs)](https://github.com/moosefs/moosefs)

MooseFS – 开源、PB、耐故障、高性能、可扩展的网络分布式文件系统（软件定义存储）

## curve

[https://github.com/opencurve/curve](https://github.com/opencurve/curve)

[![GitHub license](https://img.shields.io/github/license/opencurve/curve)](https://github.com/opencurve/curve)

Curve是一个由CNCF基金会托管的沙盒项目。它是云原生、高性能且易于操作。Curve是一个用于块和共享文件存储的开源分布式存储系统。

## glusterfs

- [https://github.com/gluster/glusterfs](https://github.com/gluster/glusterfs)

GPL-2.0, LGPL-3.0 licenses found

[![GitHub license](https://img.shields.io/github/license/gluster/gogfapi)](https://github.com/gluster/gogfapi)

Gluster文件系统：在几分钟内构建您的分布式存储

## fastdfs

- [https://github.com/happyfish100/fastdfs](https://github.com/happyfish100/fastdfs)

[![GitHub license](https://img.shields.io/github/license/happyfish100/fastdfs)](https://github.com/happyfish100/fastdfs)

FastDFS是一个开源的高性能分布式文件系统（DFS）。它的主要功能包括：文件存储、文件同步和文件访问，以及高容量和负载平衡设计。

