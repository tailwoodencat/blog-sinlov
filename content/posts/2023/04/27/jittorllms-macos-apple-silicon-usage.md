---
title: "JittorLLMs macOS Apple Silicon 使用"
date: 2023-04-27T19:04:44+08:00
description: "JittorLLMs macOS Apple Silicon 安装和使用"
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

> 本文已经跑起来了

## 运行要求

内存要求：至少2G，推荐32G
磁盘空间：至少 40GB 空闲磁盘空间，用于下载参数和存储交换文件

Python版本要求至少3.8

### 安装 conda

本文使用的 conda 为 arm64 架构的  [miniforge3](https://github.com/conda-forge/miniforge)，使用的为 `Miniforge3-MacOSX-arm64`

```bash
# 卸载 Anaconda，安装 arm64
$ brew uninstall miniconda
$ cd ~/Downloads
$ wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh -O Miniforge3-MacOSX-arm64.sh
Miniforge3 will now be installed into this location:
/Users/${USER}/miniforge3

  - Press ENTER to confirm the location
  - Press CTRL-C to abort the installation
  - Or specify a different location below

==> For changes to take effect, close and re-open your current shell. <==

If you'd prefer that conda's base environment not be activated on startup,
   set the auto_activate_base parameter to false:

conda config --set auto_activate_base false

Thank you for installing Miniforge3!

# will add ~/.zshrc to source
# check
$ conda --version
conda 23.1.0
```

## 运行方法

- 需要单独隔离 conda 来执行

```bash
cd github.com/Jittor
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
```

- 日常使用

```bash
$ conda activate JittorLLMs

# run with cli_demo
$ python cli_demo.py [chatglm|pangualpha|llama|chatrwkv]
```

## 运行错误

### No CUDA found

```bash
$ python cli_demo.py chatrwkv

Check failed: value==0  No CUDA found.
Caught SIGCHLD. Maybe out of memory, please reduce your worker size. si_errno: 0 si_code: 0 si_status: 0 , quick exit
```

> 在 macOS 上跑会炸内存

```bash
$ export JT_SAVE_MEM=1
$ export cpu_mem_limit=16000000000
```

### ModuleNotFoundError: No module named 'prompt_toolkit'

```bash
# 没有安装此模型需要的依赖，请尝试运行 'python -m pip install -r models/chatrwkv/requirements.txt -i https://pypi.jittor.org/simple'
$ python -m pip install -r models/chatrwkv/requirements.txt -i https://pypi.jittor.org/simple
```

### api 例子

JittorLLM 在api.py文件之中，提供了一个架设后端服务的示例

```bash
# install depends
$ python -m pip install fastapi uvicorn

$ export JT_SAVE_MEM=1 && export cpu_mem_limit=16000000000
$ python api.py chatglm
```

- curl

```bash
$ curl -X POST http://0.0.0.0:8000 -d '{"prompt":"你好，解5x=13"}'

# 请求例子
$ curl -X POST http://192.168.50.55:8000 -d '{"prompt":"你好，解2x=512"}' | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1036  100  1005    0    31      1      0  0:16:45  0:14:27  0:02:18   230
{
  "response": "你好！如果你有一个方程 $2x=512$，你可以使用消元法或代入法来解它。\n\n使用消元法，可以将方程两边同时除以 $2$，得到 $x=256$。这个答案是正确的，因为 $2x=512$ 可以被简化为 $x=256$。\n\n如果你使用代入法，可以将 $256$ 直接代入原方程，得到 $256=512$。这个答案也是正确的，因为 $512$ 等于 $256\\times2$。\n\n因此，你的方程 $2x=512$ 的解是 $x=256$。",
  "history": [
    [
      "你好，解2x=512",
      "你好！如果你有一个方程 $2x=512$，你可以使用消元法或代入法来解它。\n\n使用消元法，可以将方程两边同时除以 $2$，得到 $x=256$。这个答案是正确的，因为 $2x=512$ 可以被简化为 $x=256$。\n\n如果你使用代入法，可以将 $256$ 直接代入原方程，得到 $256=512$。这个答案也是正确的，因为 $512$ 等于 $256\\times2$。\n\n因此，你的方程 $2x=512$ 的解是 $x=256$。"
    ]
  ],
  "status": 200,
  "time": "2023-04-27 17:03:24"
}
```

### web GUI 例子

```bash
# install depends
$ python -m pip install gradio

$ export JT_SAVE_MEM=1 && export cpu_mem_limit=16000000000
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