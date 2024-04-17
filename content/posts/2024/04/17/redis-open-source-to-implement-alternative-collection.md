---
title: "redis 开源实现替代收集"
date: 2024-04-17T22:32:43+08:00
description: "可以无缝切换的开源 redis 实现"
draft: false
categories: ['tips']
tags: ['tips', 'redis']
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

## dragonfly

[https://github.com/dragonflydb/dragonfly](https://github.com/dragonflydb/dragonfly)

[![GitHub Repo stars](https://img.shields.io/github/stars/dragonflydb/dragonfly)](https://github.com/dragonflydb/dragonfly)

使用协议: Business Source License 1.1 BSL 1.1 ![GitHub License](https://img.shields.io/github/license/dragonflydb/dragonfly)

> BSL 协议为 个人免费开源，商业必须付费使用

官网 [https://www.dragonflydb.io/](https://www.dragonflydb.io/)

主语言：C++

它与当下最流行的两款内存数据库 Redis 和 Memcached 的 API 完全兼容，无需修改代码即可完成迁移


## garnet

[https://github.com/microsoft/garnet](https://github.com/microsoft/garnet)

[![GitHub Repo stars](https://img.shields.io/github/stars/microsoft/garnet)](https://github.com/microsoft/garnet)

官网 [https://microsoft.github.io/garnet/](https://microsoft.github.io/garnet/)

使用协议: MIT ![GitHub License](https://img.shields.io/github/license/microsoft/garnet)

> MIT 基本随便干啥都行，作者只想保留版权,而无任何其他了限制.也就是说,你必须在你的发行版里包含原许可协议的声明

主语言：C#

微软用 C# 开发的一款高性能分布式缓存系统，兼容各种编程语言的 Redis 客户端。性能方面相较于 Redis 具有更高的吞吐量、更少的成本和更低的延迟，支持 List、有序集合、HyperLogLog、Bitmap 等数据结构，以及集群模式、事务性存储过程、故障转移等功能

## KeyDB

[https://github.com/Snapchat/KeyDB](https://github.com/Snapchat/KeyDB)

[![GitHub Repo stars](https://img.shields.io/github/stars/Snapchat/KeyDB)](https://github.com/Snapchat/KeyDB)

官网 [https://keydb.dev/](https://keydb.dev/)

使用协议:  BSD-3-Clause ![GitHub License](https://img.shields.io/github/license/Snapchat/KeyDB)

> Berkerley Software Distribution 基本上使用者可以自由的使用，修改源代码，也可以将修改后的代码作为开源或者专有软件再发布。但是，不可以用开源代码的作者/机构名字和原来产品的名字做市场推广。

主语言：C++

支持多线程的 Redis，它具有高性能、更高的吞吐量、完全兼容 Redis 协议等特点。有了多线程就可以放心大胆地执行 KEYS 和 SCAN 命令，不用再担心阻塞 Redis

## valkey

[https://github.com/valkey-io/valkey](https://github.com/valkey-io/valkey)

[![GitHub Repo stars](https://img.shields.io/github/stars/valkey-io/valkey)](https://github.com/valkey-io/valkey)

官网 [https://valkey.io/](https://valkey.io/)

使用协议:  BSD-3-Clause ![GitHub License](https://img.shields.io/github/license/valkey-io/valkey)

底层操作和接口设计上与 Redis 保持了高度兼容的实现

允许现有Redis用户无缝过渡，无需担心API的向后不兼容问题