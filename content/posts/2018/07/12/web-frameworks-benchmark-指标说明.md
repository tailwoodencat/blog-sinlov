---
title: "Web Frameworks Benchmark 指标说明"
date: 2018-07-12T11:05:00+00:00
description: "desc Web Frameworks Benchmark 指标说明"
draft: false
categories: ['basics']
tags: ['basics']
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

## Requests per second 吞吐率

也写为 Requests/Second

服务器并发处理能力的量化描述，单位是reqs/s，指的是某个并发用户数下单位时间内处理的请求数

某个并发用户数下单位时间内能处理的最大请求数，称之为最大吞吐率

计算公式：总请求数 / 处理完成这些请求数所花费的时间

## The number of concurrent connections 并发连接数

某个时刻服务器所接受的请求数目，简单的讲，就是一个会话

## The number of concurrent users，Concurrency Level 并发用户数

要注意区分这个概念和并发连接数之间的区别，一个用户可能同时会产生多个会话，也即连接数

## Time per request 用户平均请求等待时间

计算公式：处理完成所有请求数所花费的时间 / （总请求数 / 并发用户数）

## Time per request: across all concurrent requests 服务器平均请求等待时间

计算公式：处理完成所有请求数所花费的时间 / 总请求数

`是吞吐率的倒数`

也可以这么计算

用户平均请求等待时间/并发用户数

## P50 Latency

过去的10秒内最慢的 50% 请求的平均延时

## P90 Latency

过去的10秒内最慢的 10% 请求的平均延时

## P95 Latency

过去的10秒内最慢的 5% 请求的平均延时

## P99 Latency

过去的10秒内最慢的 1% 请求的平均延时

p99 1.103 表示过去的10秒内最慢的 1% 请求的平均延时为1.103秒

## P99.9 Latency

过去的10秒内最慢的 0.1% 请求的平均延时

p99.9 1.503 表示过去的10秒内最慢的 0.1% 请求的平均延时为1.503秒


## Average Latency

平均延时

Average Latency (64) 64 个并发下的平均延时

## Minimum Latency

最小延时

## Maximum Latency

最大延时


