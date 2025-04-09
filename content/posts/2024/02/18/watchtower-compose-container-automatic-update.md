---
title: "watchtower compose 容器自动更新"
date: 2024-02-18T12:34:50+00:00
description: "watchtower compose container automatic update"
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

## 介绍

[watchtower](https://containrrr.dev/watchtower/) 是一个可以自动更新 Docker 容器的应用程序（轮询）。它监视运行中的容器，并在`检测到容器镜像有更新时，自动拉取新镜像`并 `使用相同的参数重新启动容器`

当然，GitOps 是一种更现代的方法，它通过 Git 仓库作为单一事实来源来管理基础设施和应用部署。比如使用 ArgoCD 或 Flux 这样的工具，可以实现更复杂的部署策略，但是对于小型项目，GitOps 可能有点 `杀鸡用牛刀`

Watchtower 提供了一个简单有效的解决方案，它和 Docker 无缝集成，几乎不需要额外配置，特别适合个人项目。

- 公共仓库，没有docker认证
- 缺乏一些企业级功能（如高级部署策略和自动回滚），但对于大多数小型项目来说，这些限制并不是问题

### 使用前注意

- `使用相同的参数重新启动容器`，也就是说升级的容器使用 不标记版本 例如 `latest`，则为每次仓库更新同版本，就会更新，不会修改 compose 的配置

> 注意: 这里特别说明一下，仓库的镜像版本是可以覆盖的， 默认版本也就是 latest  就是不断覆盖的，也包括某个具体版本，虽然不推荐具体版本覆盖推送

所以 watchtower 只适合

- `可控下的 latest 最新版本覆盖式更新`
- 这个镜像就是自己维护，完全自己控制
- 开发过程自动化更新开发容器这种`简单场景`
- `本地构建镜像不纳入远程仓库管理`，节省自动部署容器步骤

> 注意: 复杂开源工程，不同版本有各种不同特性，不同配置参数，不要勉强使用 watchtower

- watchtower 的更新检查时间策略
	- 轮询间隔 也就是，定时多少时间扫描一次，单位秒
	- [Cron 表达式](https://pkg.go.dev/github.com/robfig/cron#hdr-CRON_Expression_Format) 更新，可以定时到具体时间
- watchtower 的更新检查类型
	- 可以排出已经退出的容器
	- 可以标记只检查，不拉取（用于本地构建的容器）

## 配置自动更新

- 设置参考 [https://containrrr.dev/watchtower/usage-overview/](https://containrrr.dev/watchtower/usage-overview/)

### 更新代理设置

```yaml
services:
  utils-watchtower:
    container_name: 'utils-watchtower'
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      ## 代理设置 172.17.0.1 为同设备 docker 网络地址
      HTTP_PROXY: "http://192.168.50.50:7890"
      HTTPS_PROXY: "http://192.168.50.50:7890"
      # https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/
      NO_PROXY: "localhost,127.0.0.1,192.168.,.npmmirror.com,goproxy.cn,.tuna.tsinghua.edu.cn,.ustc.edu.cn,rsproxy.cn,maven.aliyun.com"
```

### 全局扫描更新-推荐模式

- 开启全局扫描服务

```yaml
services:
  utils-watchtower-global:
    container_name: 'utils-watchtower-global'
    image: 'containrrr/watchtower:1.7.1' # https://hub.docker.com/r/containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      # WATCHTOWER_DEBUG: true
      # NO_COLOR: true
      # 只监控并更新设置了 com.centurylinklabs.watchtower.enable 标签为true的容器
      WATCHTOWER_LABEL_ENABLE: true
      # DOCKER_HOST: 'unix:///var/run/docker.sock'
      # 3600 # 每 1 小时（ 3600 秒）检查一次更新
      # WATCHTOWER_POLL_INTERVAL: 60
      # Cron expression in 6 fields
      # 0 2 0 * * 6 At 00:10
      WATCHTOWER_SCHEDULE: 0 10 0 * * *
      # 更新后删除旧图像，全局模式根据需求开启
      # WATCHTOWER_CLEANUP: true
      # 容器强制停止前的超时
      WATCHTOWER_TIMEOUT: 20
      # 当设置标签不是选项时，这可用于排除特定容器。即使列出的容器将启用过滤器设置为true，它们也会被排除在外
      # WATCHTOWER_DISABLE_CONTAINERS: ""
      # 还将包括已创建和退出的容器
      WATCHTOWER_INCLUDE_STOPPED: true
      # 启动任何已更新图像的停止容器，必须 WATCHTOWER_INCLUDE_STOPPED 开启
      WATCHTOWER_REVIVE_STOPPED: true
      # 还将包括重启容器
      WATCHTOWER_INCLUDE_RESTARTING: true
    restart: always # on-failure:3 or unless-stopped default "no"
    logging:
      driver: "local" # https://docs.docker.com/config/containers/logging/configure/#supportedz-logging-drivers
      options:
        max-size: 8m
    deploy:
      resources: # https://docs.docker.com/compose/compose-file/deploy/#resources
         limits:
            memory: 1G
         reservations:
            memory: 8M
```

- 对需要更新的容器添加设置

```yaml
services:
  foo:
    container_name: 'foo'
    image: 'some-image' # latest 或者具体版本，不会修改这里设置的版本号
    labels:
      - "com.centurylinklabs.watchtower.enable=true" # 开启 watchtower 更新检测
```

###  指定某个容器更新

```yaml
services:
  # https://hub.docker.com/r/swaggerapi/swagger-editor
  utils-swagger-editor:
    container_name: 'utils-swagger-editor'
    image: 'swaggerapi/swagger-editor' # https://hub.docker.com/r/swaggerapi/swagger-editor
    ports:
      - '59900:8080'
    labels:
      - "com.centurylinklabs.watchtower.enable=true" # 开启 watchtower 更新检测
    restart: always # on-failure:3 or unless-stopped default "no"
  utils-swagger-editor-watchtower:
    container_name: 'utils-swagger-editor-watchtower'
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      # WATCHTOWER_DEBUG: true
      # NO_COLOR: true
      # DOCKER_HOST: 'unix:///var/run/docker.sock'
      # 3600 # 每 1 小时（ 3600 秒）检查一次更新
      # 21600 # 每 6 小时（ 21600 秒）检查一次更新
      # WATCHTOWER_POLL_INTERVAL: 60
      # Cron expression in 6 fields
      # 0 2 0 * * 6 At 00:02 on Saturday
      WATCHTOWER_SCHEDULE: 0 2 0 * * 6
      # 更新后删除旧图像
      WATCHTOWER_CLEANUP: true
      # 只会监控本地图像缓存的更改。如果您直接在Docker主机上构建新映像，而不将它们推送到仓库，打开这个选项
      # WATCHTOWER_NO_PULL: true
      # 容器强制停止前的超时
      WATCHTOWER_TIMEOUT: 10
      # 还将包括重启容器
      WATCHTOWER_INCLUDE_RESTARTING: true
    command: utils-swagger-editor # 指定目标更新
    restart: always # on-failure:3 or unless-stopped default "no"
```
