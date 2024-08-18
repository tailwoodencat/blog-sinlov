---
title: "UGOS Pro 系统 apt 以及 docker-compose 的使用"
date: 2024-06-04T11:52:16+08:00
description: "Use of UGOS Pro system apt and docker compose"
draft: false
categories: ['hardware']
tags: ['hardware', 'UGOS Pro']
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

- 有使用 debian / ubuntu 类linux 系统经验
- UGOS 开启 `ssh`
- 客户端机器，可以连接到 UGOS Pro 服务器

## 配置代理

> UGOS Pro 是基于 debian 的所以，apt 可以使用国内代理，速度更快

```bash
# 备份代理配置
$ sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 配置阿里云代理
$ sudo sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
$ sudo sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 更新验证 apt 代理
sudo apt update

# 更新依赖软件并自动清理
sudo apt upgrade -y && sudo apt autoclean -y && sudo apt autoremove -y
```

## 安装基础软件

```bash
# 基础维护软件
sudo apt install -y tmux git vim wget curl

# 资源监控软件
sudo apt install -y htop btop
```

### 配置基础风格

- `~/.vimrc`

```bash
tee ~/.vimrc <<-'EOF'
" open syntax
syntax on
" set not show line number can change by :set nu
:set nonu
" set show line number when in edit
:set ruler
" set tab button stop
" default tabstop=8
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
" use keyboard F11 to change paste mode
:set pastetoggle=<F11>
" insert mode to use Shift + tab to insert table
:inoremap <S-Tab> <C-V><Tab>
" normal is :set nolist | show hide is :set invlist
:set nolist

" fix mac vim keyboard delete can not delete error, so as set backspace=indent,eol,start
set backspace=2

" insert mode shortcut
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-d> <DELETE>


EOF
```

## 安装 docker-compose

### 使用已经安装的 docker-compose

- UGOS Pro 系统版本`1.0.0.1281` 版本后，是以 docker-compose-plugin 模式安装好了
- 不能在 ssh 内直接使用，安装到路径 /usr/libexec/docker/cli-plugins/docker-compose
- 如果希望在 ssh 使用的，把 /usr/libexec/docker/cli-plugins  加入环境变量即可

```bash
# docker-compose by cli-plugins
export PATH=$PATH:/usr/libexec/docker/cli-plugins
```

### 手动安装某个版本的 docker-compose

> 这里直接跳过 docker 安装，因为 UGOS Pro 应用市场有一个 docker 安装

- 配置 docker 国内镜像 配置在 `/etc/docker/daemon.json`

```json
{
  "registry-mirrors": [
    "https://dockerproxy.com/"
  ]
}
```

> 使用其他镜像代理，请自行修改

- 生效 镜像配置

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

- 快速安装 docker-compse，该模式为 容器安装模式，可随时更换

```bash
## install docker-compose new verison see: https://github.com/docker/compose/releases/ and https://hub.docker.com/r/linuxserver/docker-compose/tags

# download docker-compose 2.11.2
sudo curl -L --fail https://raw.githubusercontent.com/bridgewwater/docker-exec-tools/main/docker-compose/2.11.2-v2/run.sh -o /usr/local/bin/docker-compose
# download by proxy
sudo curl -L --fail https://mirror.ghproxy.com/https://github.com/bridgewwater/docker-exec-tools/releases/download/v2.17.3/run.sh -o /usr/local/bin/docker-compose

# install
sudo chmod +x /usr/local/bin/docker-compose
```

- 验证 docker-compse 安装

```bash
sudo docker version
sudo docker-compose version
```

- 修复普通用户不能直接使用 docker 的问题

```bash
sudo gpasswd -a ${USER} docker
sudo newgrp docker

# 重新进入用户即可
```

## 验证 docker-compse 安装

### 准备 docker volume 本地目录

- 新建共享文件夹 `container-volume` ，这里真实建立的文件夹是 `/volume1/container-volume/`

在这个目录下建立管理的容器服务

```bash
mkdir -p /volume1/container-volume/utils-service-docker
cd /volume1/container-volume/utils-service-docker
```

- 创建文件 `docker-compose.yml` 内容为

```yml
# more info see https://docs.docker.com/compose/compose-file/
# version: '3.8' # https://docs.docker.com/compose/compose-file/compose-versioning/
services:
  utils-whoami: # https://hub.docker.com/r/containous/whoami/
    container_name: 'utils-whoami'
    image: 'containous/whoami:v1.5.0' # https://hub.docker.com/r/containous/whoami/tags?page=1&ordering=last_updated
    ports:
      - '60010:80'
    restart: always # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: "local"
      options:
        max-size: "2m"
  ## utils-iperf-server start
  utils-iperf-server: # https://hub.docker.com/r/iitgdocker/iperf-server
    container_name: 'utils-iperf-server'
    image: iitgdocker/iperf-server:3.10.1 # https://hub.docker.com/r/iitgdocker/iperf-server/tags
    ports:
      - "59990:5201/tcp" # use as: iperf3 -p 59990 -c [ip]
      - "59990:5201/udp" # use as: iperf3 -p 59990 -c [ip] -u
    volumes:
      - /volume1/container-volume/utils-service-docker/data/utils-iperf-server/data:/data
    restart: always # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: "local"
      options:
        max-size: "2m"
  ## utils-iperf-server end
```

- 验证并启用配置

```bash
# 验证
docker-compose config -q
# 无输出或者报错则可以进行启用
docker-compose up -d --remove-orphans
```

这是一组 容器，可以使用

```bash
## 测试服务器 whoami 信息
curl -v http://<ip>:60010
# 也可以直接网页打开 地址

## 测试点对点网速，测试机 需要安装 iperf3
# 测试机发送数据到 nas
iperf3 -p 59990 -c [ip]
# nas 发送数据到 测试机
iperf3 -p 59990 -c [ip] -R
# 测试机 多线程 8 个(这个根据设备支持来) 发送数据到 nas
iperf3 -p 59990 -c [ip] -P 8
```