---
title: "drone fatal: could not read Username for ‘xxxx‘: terminal prompts"
date: 2023-05-08T11:17:28+08:00
description: "drone fatal: could not read Username for ‘xxxx‘: terminal prompts"
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

## 表现

```log
Initialized empty Git repository in /drone/src/.git/
+ git fetch origin +refs/heads/main:
fatal: could not read Username for 'https://xxxx': terminal prompts disabled
```

## 原因

- drone 默认情况下不会做公开代码库的认证，即不会在拉取公开仓库时验证 git 账号
- 使用本地模式运行，默认 git 仓库的 所有操作都要验证用户信息，即使是 pull 公开的代码仓库也不会认证

## 解决方法

启动 drone 的时候传递一个环境变量 `DRONE_GIT_ALWAYS_AUTH=true`

- 官方文档[https://docs.drone.io/server/reference/drone-git-always-auth/](https://docs.drone.io/server/reference/drone-git-always-auth/)
