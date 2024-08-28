---
title: "drone fatal gitlab ACTIVATE REPOSITORY 500"
date: 2023-05-07T22:03:00+00:00
description: "drone fatal gitlab ACTIVATE REPOSITORY 500 导致无法激活"
draft: false
categories: ['CI']
tags: ['basics', 'CI', 'drone']
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

## 故障表现

drone 能查看 Repository 但在点击 `ACTIVATE REPOSITORY` 时报错 500

## 原因

drone 是通过 webhook 来根 gitlab 通信的，需要 gitlab 打开某些安全设置

gitlab 配置，参加官方文档 [https://docs.gitlab.com/ee/security/webhooks.html](https://docs.gitlab.com/ee/security/webhooks.html)

## 修复方法

勾选 `Allow requests to the local network from webhooks and integrations` checkbox

![gitlab-webhooks-Allow-requests-to-the-local-network-from-webhooks-lHidTR](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/05/08/gitlab-webhooks-Allow-requests-to-the-local-network-from-webhooks-lHidTR.png)