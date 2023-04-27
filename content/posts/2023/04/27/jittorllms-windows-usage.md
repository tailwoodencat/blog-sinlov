---
title: "JittorLLMs windows 使用"
date: 2023-04-27T19:05:54+08:00
description: "JittorLLMs windows 下的安装和使用"
draft: false
categories: ['AI']
tags: ['AI']
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

[JittorLLL](https://github.com/Jittor/JittorLLMs) 计图大模型推理库

1.  成本低：相比同类框架，本库可大幅降低硬件配置要求（减少80%），没有显卡，2G内存就能跑大模型，人人皆可在普通机器上，实现大模型本地部署；是目前已知的部署成本最低的大模型库；
2.  支持广：目前支持了4种大模型：[ChatGLM大模型](https://github.com/THUDM/ChatGLM-6B)；鹏程[盘古大模型](https://openi.org.cn/pangu/)；BlinkDL的[ChatRWKV](https://github.com/BlinkDL/ChatRWKV)；国外Meta的[LLaMA大模型](https://github.com/facebookresearch/llama)

[Jittor 官方文档](https://cg.cs.tsinghua.edu.cn/jittor/assets/docs/index.html)

> 建议使用 CUDA 运行，比 CPU 模式快 10倍，使用 1070 8G 显存，开启交换
> api 回答根据问题答案会等很久（实现原因导致，会完全等问题结束才返回），如果是 命令行模式，则有交互效果

## 运行要求

内存要求：至少2G，推荐32G
磁盘空间：至少 40GB 空闲磁盘空间，用于下载参数和存储交换文件
Python版本要求至少3.8
CUDA: 1.11 以上

- [https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/](https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/)
- [Miniconda3-py39_4.10.3-Windows-x86_64.exe](https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_4.10.3-Windows-x86_64.exe)

- 安装后 通过 `Anaconda Powershell Promot` 使用

> 建议通过 `Anaconda Powershell Promot` 管理员模式运行，见 [https://github.com/Jittor/JittorLLMs/issues/27](https://github.com/Jittor/JittorLLMs/issues/27)

> 建议配置镜像加速，因为后面安装会用到

```bash
# check CUDA
$ nvidia-smi
$ nvcc -V
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2022 NVIDIA Corporation
Built on Wed_Jun__8_16:59:34_Pacific_Daylight_Time_2022
Cuda compilation tools, release 11.7, V11.7.99
Build cuda_11.7.r11.7/compiler.31442593_0
```

## 运行方法

- 需要单独隔离 conda 来执行

```bash
$ cd github.com/Jittor
# 国内使用 gitlink clone
$ git clone https://gitlink.org.cn/jittor/JittorLLMs.git --depth 1
$ git clone https://github.com/Jittor/JittorLLMs.git --depth 1

$ cd JittorLLMs
# create new env
$ conda create -n JittorLLMs python=3.8
$ conda activate JittorLLMs
# isntall
# -i 指定用jittor的源， -I 强制重装Jittor版torch
$ pip install -r requirements.txt -i https://pypi.jittor.org/simple -I

# run with cli_demo
$ python cli_demo.py [chatglm|pangualpha|llama|chatrwkv]
# 运行后会自动从服务器上下载模型文件到本地，会占用根目录下一定的硬盘空间

## 首次运行需要安装依赖
# chatglm
$ python -m pip install -r models/chatglm/requirements.txt -i https://pypi.jittor.org/simple
# chatrwkv
$ python -m pip install -r models/chatrwkv/requirements.txt -i https://pypi.jittor.org/simple
```

> 注意：如果你的显存不够 16G，请一定要设置 `device_mem_limit`
> 比如 8G 显存，设置为 device_mem_limit=7000000000 ，否则会爆内存

- 日常使用

```bash
$ conda activate JittorLLMs

# run with cli_demo
$ python cli_demo.py [chatglm|pangualpha|llama|chatrwkv]
```

#### chatglm

```ps1
> $env:JT_SAVE_MEM="1"
> $env:cpu_mem_limit="16000000000"
> $env:device_mem_limit="7000000000"
> python cli_demo.py chatglm
```

#### chatrwkv

```ps1
> $env:JT_SAVE_MEM="1"
> $env:cpu_mem_limit="16000000000"
> $env:device_mem_limit="7000000000"
> $env:RWKV_CUDA_ON="1"
> python cli_demo.py chatrwkv
```

### api 例子

JittorLLM 在api.py文件之中，提供了一个架设后端服务的示例

```ps1
# install depends
> python -m pip install fastapi uvicorn

> $env:JT_SAVE_MEM="1" ; $env:cpu_mem_limit="16000000000" ; $env:device_mem_limit="7000000000"
> python api.py chatglm
```

- curl

```bash
$ curl -X POST http://0.0.0.0:8000 -d '{"prompt":"你好，解5x=13"}'

# 例子
$ curl -X POST http://192.168.110.153:8000 -d '{"prompt":"你好，解2x=1024"}'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   334  100   302    0    32      2      0  0:02:31  0:02:14  0:00:17    76
{
  "response": "2x = 1024\n\n将等式两边同时除以2，得到：\n\nx = 512\n\n因此，方程的解为 x = 512。",
  "history": [
    [
      "你好，解2x=1024",
      "2x = 1024\n\n将等式两边同时除以2，得到：\n\nx = 512\n\n因此，方程的解为 x = 512。"
    ]
  ],
  "status": 200,
  "time": "2023-04-27 17:57:26"
}
```

### web GUI 例子

```bash
# install depends
$ python -m pip install gradio

$ python web_demo.py chatglm
```

## 节省内存方法

请安装Jittor版本大于1.3.7.8，并添加如下环境变量

```
export JT_SAVE_MEM=1
# 限制cpu最多使用16G
export cpu_mem_limit=16000000000
# 限制device内存（如gpu、tpu等）最多使用8G
export device_mem_limit=8000000000
# windows 用户，请使用powershell
# $env:JT_SAVE_MEM="1"
# $env:cpu_mem_limit="16000000000"
# $env:device_mem_limit="8000000000"
```

用户可以自由设定cpu和设备内存的使用量，如果不希望对内存进行限制，可以设置为 `-1`

```
# 限制cpu最多使用16G
export cpu_mem_limit=-1
# 限制device内存（如gpu、tpu等）最多使用8G
export device_mem_limit=-1
# windows 用户，请使用powershell
# $env:JT_SAVE_MEM="1"
# $env:cpu_mem_limit="-1"
# $env:device_mem_limit="-1"
```

如果想要清理磁盘交换文件，可以运行如下命令

```bash
python -m jittor_utils.clean_cache swap
```