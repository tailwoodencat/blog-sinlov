---
title: "ollama 本地安装部署"
date: 2024-04-29T17:15:00+00:00
description: "ollama local installation and deployment"
draft: false
categories: ['AI']
tags: ['AI', 'ollama' ,'docker']
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

## 准备

- 良好的网络
- [确认好 docker GPU支持](https://docs.docker.com/compose/gpu-support/)
	- 本文使用 windows 部署，linux 请自行解决显卡驱动问题
	- 解决不了显卡驱动，请不要使用
- 安装好 [docker](https://docs.docker.com/desktop/) 不同系统自行解决
- 下载 [ollama](https://ollama.com/download)
	- windows 的话 建议 C 盘大亿点点，后面会用到

### 容器安装 ollama

- [https://docs.openwebui.com/getting-started/env-configuration/](https://docs.openwebui.com/getting-started/env-configuration/)

创建一个目录 ollama ， 用来保存下载模型，以及运行日志等文件

```bash
mkdir ollama
```

创建 ollama 容器 docker-compose.yml

```yml
# copy right by sinlov at https://github.com/sinlov
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
networks:
  default:
    # Use a custom driver
    #driver: custom-driver-1
services:
  ollama-runner:
    container_name: "ollama-runner"
    image: ollama/ollama:0.1.33-rc5 # https://hub.docker.com/r/ollama/ollama/tags
    ports:
      - "11434:11434"
    volumes:
      - "./ollama:/root/.ollama"
    # https://docs.docker.com/compose/gpu-support/
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

### 进入 ollama 容器

```bash
docker exec -it ollama-runner bash
```

## 本地使用 ollama

**注意**：这个模式下，ollama 和 外部编排容器运行的是冲突的， 建议 ollama 自己管理自己的容器，不要外部掺和编排，所以请移除上面的容器安装运行方式，就是这么设定的，阿门

#### windows 下需要注意的

Windows上的Ollama将文件存储在几个不同的位置。你可以查看它们

使用  `<cmd>+R` 键入内容 :
- `explorer %LOCALAPPDATA%\Ollama` 包含日志和下载的更新
    - *app.log* 包含来自GUI应用程序的日志
    - *server.log* 包含服务日志
    - *upgrade.log* 包含用于升级的日志输出
- `explorer %LOCALAPPDATA%\Programs\Ollama` 包含二进制文件 (The installer adds this to your user PATH)
- `explorer %HOMEPATH%\.ollama` 包含模型和配置
- `explorer %TEMP%` 包含一个或多个 `ollama*` 目录中包含临时可执行文件

需要不小的 C 盘空间就是

### 自定义启动 ollama 服务

这里在 windows powershell 环境下部署的， 因为好显卡在 windows，换其他环境请自己转换脚本

```ps1
$env:OLLAMA_HOST="0.0.0.0:11433" ;
$env:OLLAMA_MODELS="$((pwd).Path)\ollama" ;
$env:OLLAMA_KEEP_ALIVE="30m"
# 这里留空即可
$env:OLLAMA_ORIGINS=""
# https://github.com/ollama/ollama/issues/300  说这样可以其实不一定
$env:OLLAMA_ORIGINS="http://192.168.50.0:*"

# ollama 启动！！！
ollama serve
```

> 这里说明一下，不同的 环境变量可以部署多套 ollama

- [OLLAMA 支持的环境变量和用途见 源码](https://github.com/ollama/ollama/blob/main/envconfig/config.go)
- `OLLAMA_HOST` 定义当前运行 服务 host
- `OLLAMA_MODELS` 模型文件存储位置，这个选项可以告别 windows 爆掉 C 盘的问题
- `OLLAMA_ORIGINS` 跨域配置，这个需要点跨域知识，实在不会问生成式AI，大不了错几次

### 本地 open-webui 使用ollama 服务

> **注意**： ollama 是一组后台服务， 使用 大模型 的交互行前端，需要另外的部署，这里演示的是 open-webui

- docker-compose
	- environment
		- `WEBUI_SECRET_KEY` webui secret key 可以通过 `openssl rand -hex 16` 生成
		- `OLLAMA_BASE_URL` 这个根据实际情况配置
		- `HF_ENDPOINT` 可以加速模型下载
	- volumes
		- `./open-webui/data:/app/backend/data` 这个为 当前 `docker-compose.yml` 文件相对目录存储数据
	- ports
		- `11435:8080` 这个是 webUI 对外服务的 端口 设置 映射到 `11435`，如果端口占用可以跟换
		- `network_mode: host` 如果开启，就是 8080

```yml
# copy right by sinlov at https://github.com/sinlov
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
#version: '3.8' # https://docs.docker.com/compose/compose-file/compose-versioning/
services:
  ollama-local-open-ui:
    container_name: "ollama-local-open-ui"
    # image: dyrnq/open-webui:git-e9ba8d7-cuda # https://hub.docker.com/r/dyrnq/open-webui/tags
    image: ghcr.io/open-webui/open-webui:main
    pull_policy: if_not_present
    environment: # https://docs.openwebui.com/getting-started/env-configuration/
      - 'OLLAMA_BASE_URL=http://127.0.0.1:11433' # 这里需要注意，这个地址连不上，使用完整 IP address 即可
      - 'HF_ENDPOINT=https://hf-mirror.com' # 从 https://hf-mirror.com 镜像，而不是https://huggfacing.co 官网下载所需的模型
      - 'WEBUI_SECRET_KEY=e2ac9c8f3462a9831b238601b8546807' # webui secret key
      # - 'PORT=11435'
    extra_hosts:
      - host.docker.internal:host-gateway
    ports:
      - "11435:8080"
    # network_mode: host
    volumes:
      - "./open-webui/data:/app/backend/data"
    restart: unless-stopped # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: json-file
      options:
        max-size: 2m
```

## 使用 ollama 命令

ollame 本身是一个 管理大模型的工具

### ollama cli 基本使用

- `list` List models on your computer
- `pull` 拉取模型
- `run`  run 除了拉取模型，还同时将模型对应的交互式控制台运行了起来，不建议这么做，限定死了启动方式
- `rm` 移除本地下载的模型
- `serve` 启动 大模型后台服务

###  常用模型

[查找模型的链接](https://ollama.com/library)

- 模型格式 `<name>:<num><arg>`
	- name 为模型发布名称，后面 `<num><arg>` 多少 B 表示模型有 多少 十亿 参数
	- 参数规模规格为  `B 十亿` `M 百万` `K 千`
	- 参数越多，所需 显存 越大，30b 左右差不多需要 20G 专有显存推理
	- 参数多不代表准确，不过太小参数的 LLM 容易出现幻觉(瞎扯给结果)

```bash
## 多模态模型，可以混和图文处理
ollama pull llava:13b
ollama pull llava:34b
ollama pull bakllava:7b

## 文本大模型，只针对文本处理
ollama pull qwen:14b
ollama pull qwen:32b
ollama pull codeqwen:7b
ollama pull llama3:8b
# 70b 4090 24G 显存会不够必须集群跑
ollama pull llama3:70b
```

### Modelfile 自定义模型

- [https://github.com/ollama/ollama/blob/main/docs/modelfile.md](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)

查找 [模型](https://ollama.com/library) 配置例子

```bash
# 先需要拉取
ollama pull llama3:8b

ollama show --modelfile llama3:8b
```
