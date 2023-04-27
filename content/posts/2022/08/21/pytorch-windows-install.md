---
title: "Pytorch windows 配置"
date: 2022-08-21T18:06:54+00:00
description: "Pytorch windows 配置"
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

## 配置前检查环境

环境有GPU和CPU版本之分，通过 `dxdiag` 查看是否有GPU

> 注意: 请选择 `正确的 CUDA 版本`，防止安装完成后，项目无法运行

## cuda 安装

- 各个版本 cuda 兼容列表[https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)

- 需要安装NV驱动版本查询  [LINUX X64 (AMD64/EM64T) DISPLAY DRIVER](https://www.nvidia.com/Download/driverResults.aspx/191961/en-us/)
[https://www.nvidia.cn/geforce/drivers/](https://www.nvidia.cn/geforce/drivers/)

- 去站点 [https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads) 查找 cuda 的下载
- 根据上面的系统选择 比如 [https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=runfile_local](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=runfile_local)

> 配置 [Anaconda 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)，因为后面安装会用到
> 配置 [PyPI 镜像加速](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/)

### CUDA Toolkit 历史版本收集

- [cuda-toolkit-archive 发布地址](https://developer.nvidia.com/cuda-toolkit-archive)

| version | link | desc |
|-----|------|----|
| 11.8.0 | [cuda-11.8.0](https://developer.nvidia.com/cuda-11-8-0-download-archive) | |
| 11.7.1 | [cuda-11-7.1](https://developer.nvidia.com/cuda-11-7-1-download-archive) | |
| 11.6.0 | [cuda-11-6.0](https://developer.nvidia.com/cuda-11-6-0-download-archive) | |

### CUDA安装完成后检查

```bash
# 显示当前状态
$ nvidia-smi

# cuda toolkit 版本
$ nvcc --version
```

### anaconda

- anaconda 的下载 [https://www.continuum.io/downloads](https://www.continuum.io/downloads)
- [清华镜像帮助](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)
	- [https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/](https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/)
	-  [https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/](https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/)

- 安装后 通过 `Anaconda Powershell Promot` or `Anaconda Promot` 使用

> 建议配置镜像加速，因为后面安装会用到

## 安装 pytorch

### 下载 pytorch

- [https://pytorch.org/get-started/locally/](https://pytorch.org/get-started/locally/)

> 注意: pytorch 需要先确定平台支持，安装对应的版本，否则安装会报错

### python 安装方式

打开anaconda的终端，输入命令进行环境安装

```bash
# version 2.0.0 cuda 11.7
$ pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117
$ conda install pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia
```

## 安装环境测试

打开 anaconda终端 安装依赖包 d2l

```bash
# 会安装一大堆依赖包，一次失败后多试几次即可
$ pip install jupyter d2l
```

之后就可运行 jupyter notebook

```bash
$ jupyter notebook
```