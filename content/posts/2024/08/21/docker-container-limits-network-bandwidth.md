---
title: "docker 容器限制网络带宽"
date: 2024-08-21T12:34:41+00:00
description: "Docker container limits network bandwidth"
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

## 容器限制带宽

使用到 限流工具

- [tc-docker](https://github.com/CodyGuo/tc-docker)

原理  通过控制容器中运行 Traffic Control Docker 守护进程

然后对任意目标容器进行流量限速

## 启动限速容器

- compose 启动限速容器实例

```yml
networks:
  default:
    external: true
    name: host

services:
  network-tc-docker:
    container_name: network-tc-docker
    image: codyguo/tc-docker:latest # https://hub.docker.com/r/codyguo/tc-docker/tags
    privileged: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/run/docker/netns:/var/run/docker/netns:shared
    environment:
      DOCKER_HOST: "unix:///var/run/docker.sock"
      # DOCKER_API_VERSION: "1.40"
    network_mode: host
    restart: always # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: "json-file"
      options:
        max-size: "2m"
```

## 对容器限速

- `org.label-schema.tc.enabled` 当设置为 `1` 时，启用限速
- `org.label-schema.tc.rate` 容器的带宽或速率限制，限制此类及其所有子类的最大速率
  - 后跟单位，或设备速度的百分比值
  - 可用 1tbps 2gbps 10mbps 100kbps 500bps
  - 也可以 bit, kbit, mbit, gbit, tbit
- `org.label-schema.tc.ceil` 容器的带宽或最大速度限制，如果类的父类有空余带宽，子类可以发送的最大速率
  - 后跟单位，或设备速度的百分比值
  - 可用 1tbps 2gbps 10mbps 100kbps 500bps
  - 也可以 bit, kbit, mbit, gbit, tbit

配置 被限制的容器

```yml
services:
  web:
    image: nginx
    labels:
      - "org.label-schema.tc.enabled=1"
      - "org.label-schema.tc.rate=2mbps"
      - "org.label-schema.tc.ceil=10mbps"
```

or

```bash
docker run --name gcloud-cli -d \
  --label "org.label-schema.tc.enabled=1" \
  --label "org.label-schema.tc.rate=10mbps" \
  --label "org.label-schema.tc.ceil=50mbps" \
  -v /data/gcloud:/data/gcloud \
  gcr.io/google.com/cloudsdktool/google-cloud-cli:latest \
  tail -f /dev/null
```

## 验证容器限速

```yaml
services:
  utils-iperf-server: # https://hub.docker.com/r/iitgdocker/iperf-server
    container_name: 'utils-iperf-server'
    image: iitgdocker/iperf-server:3.10.1 # https://hub.docker.com/r/iitgdocker/iperf-server/tags
    labels:
      - "org.label-schema.tc.enabled=1"
      - "org.label-schema.tc.rate=2mbps"
      - "org.label-schema.tc.ceil=10mbps"
    ports:
      - "59990:5201/tcp" # use as: iperf3 -p 59990 -c [ip]
      - "59990:5201/udp" # use as: iperf3 -p 59990 -c [ip] -u
    volumes:
      - ./data/utils-iperf-server/data:/data
```

客户端打流测试

```bash
iperf3 -p 59990 -c <iperf-server-ip>
# 回路测试
iperf3 -p 59990 -c <iperf-server-ip> -R
```
