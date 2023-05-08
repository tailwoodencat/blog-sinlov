---
title: "drone untrusted repositories cannot mount host volumes"
date: 2022-10-17T15:51:00+00:00
description: "drone untrusted repositories cannot mount host volumes"
draft: false
categories: ['basics']
tags: ['basics', 'drone']
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

## error log

```log
linter: untrusted repositories cannot mount host volumes
```

## 原因

在定义 drone.yml 中添加了 volumes 尝试使用挂载时出现该问题

```yaml
volumes:
  - name: go_cache
    host:
      path: /tmp/cache/go
```

那么原因就是 登录 drone 的用户不是 管理员 或者在 SETTINGS 的 Main 部分，未勾选 Trusted

> 在官方文档中，有说明 [https://docs.drone.io/pipeline/kubernetes/examples/service/docker/#basic-example](https://docs.drone.io/pipeline/kubernetes/examples/service/docker/#basic-example)，In the below example we demonstrate a pipeline that connects to the host machine Docker daemon by mounting a volume. `For security reasons, only trusted repositories can mount volumes.` Furthermore, mounting the host machine Docker socket is highly insecure, and should only be used in trusted environments. Unlike docker pipelines, on kubernetes you cannot mount files or sockets, you need to mount folders.

## 解决方法

仓库勾选 `Trusted` 选项

![drone-project-settings-trusted-5fQDCh](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/05/08/drone-project-settings-trusted-5fQDCh.png)

### 未找到 Trusted 选项

如果需要设置这个需要 drone server 能够是管理员

```yaml
		environment:
			- DRONE_USER_CREATE=username:yourUsername,admin:true
```

`DRONE_USER_CREATE=username:yourUsername,admin:true` 这行，加上之后，使用 yourUsername 用户名登录 drone 便成为了管理员，如果不加，则看不到Trusted那个按钮
