---
title: "docker init 进程工具 tini"
date: 2022-11-28T15:51:00+00:00
description: "docker init 进程工具 tini"
draft: false
categories: ['docker']
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

## 介绍

docker镜像为了节省空间，通常是没有安装systemd或者sysvint这类初始化系统的进程

一旦容器的起始进程不稳定将会产生大量的僵尸进程，影响宿主系统的运行

安全的启动方式会使用 `init系统`

`init 系统` 有以下几个特点：

`init系统` 的第一个进程，负责产生其他所有用户进程

以守护进程方式存在，是所有其他进程的父进程

它主要负责：

1. 启动守护进程
2. 回收孤儿进程
3. 将操作系统信号转发给子进程

以 dockerfile 为例：

```Dockerfile
FROM nginx

ENTRYPOINT ["nginx", "-c"]
CMD ["/etc/nginx/nginx.conf"]
```

当 docker 容器启动时，`PID 1` 即容器启动程序将会是 nginx, 只要这个程序停止，容器就会跟住停止

但由于 nginx 不具备 `init 系统` 上述的功能，`PID 1` 是无法回收异常退出进程，异常退出的进程变成僵尸进程，继续占用系统资源

当多个容器运行在一个宿主机上的时候,为了避免一个容器消耗完我们整个宿主机进程号资源

docker 会配置 `PID CGROUP` 来限制每个容器的最大进程数目

> 也就是说，进程数目在每个容器中也是有限的，是一种很宝贵的资源
> linux 机器上的进程总数目是有限制，如果进程数据过多，比如你想 ssh 登录到机器上就不行

解决方法是使用 [tini](https://github.com/krallin/tini)

## 使用 tini 初始化系統

 [tini](https://github.com/krallin/tini) 是一套更简单的 init 系统，专门用来执行一个子程序(spawn a single child)，并等待子程序结束，即便子程序已经变成僵尸程序也能捕捉到，同时也能转送 Signal 给子程序

如果你使用 docker 来跑容器，可以非常简便的在 `docker run` 的时候用 `--init` 参数，就会自动注入tini程式

例如

```Dockerfile
FROM nginx

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/user/bin/tini","--","/opt/nginx/docker-entrypoint.sh"]
ENTRYPOINT ["nginx", "-c"]
CMD ["/etc/nginx/nginx.conf"]
```

## 安装 tini 模板

- fast

```Dockerfile
ARG GITHUB_PROXY=https://ghproxy.com/
ENV TINI_VERSION v0.19.0
ADD ${GITHUB_PROXY}https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
# Run your program under Tini
CMD ["/your/program", "-and", "-its", "arguments"]
```

- wget and check

```Dockerfile
ARG GITHUB_PROXY=https://ghproxy.com/
ENV TINI_VERSION v0.19.0
RUN wget --no-check-certificate --no-cookies --quiet -O /usr/bin/tini  \
	${GITHUB_PROXY}https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    && wget --no-check-certificate --no-cookies --quiet -O /usr/bin/tini.sha256sum \
	${GITHUB_PROXY}https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.sha256sum \
	echo 'Calculated checksum: '$(sha256sum /usr/bin/tini) && \
    && echo "$(cat tini.sha256sum)" | sha256sum -c
```

- curl and check

```Dockerfile
ENV TINI_VERSION v0.19.0
RUN wget --no-check-certificate --no-cookies --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 \
    && wget --no-check-certificate --no-cookies --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64.sha256sum \
    && echo "$(cat tini-amd64.sha256sum)" | sha256sum -c

ENV TINI_VERSION v0.19.0
RUN export TINI_SHA=00185b9bc952713e1b91d4a9ea7a5e0ffc2e8f8f && \
    curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini -o /usr/bin/tini && \
    echo 'Calculated checksum: '$(sha1sum /bin/tini) && \
    chmod +x /usr/bin/tini && echo "$TINI_SHA  /bin/tini" | sha1sum -c
```
