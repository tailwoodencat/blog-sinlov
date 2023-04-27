---
title: "cuda cudnn 安装配置"
date: 2022-08-21T17:40:54+00:00
description: "cuda cudnn 安装配置"
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

## cuda 安装前检查

- 各个版本 cuda 兼容列表[https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)

- 需要安装NV驱动版本查询  [LINUX X64 (AMD64/EM64T) DISPLAY DRIVER](https://www.nvidia.com/Download/driverResults.aspx/191961/en-us/)
[https://www.nvidia.cn/geforce/drivers/](https://www.nvidia.cn/geforce/drivers/)

- 去站点 [https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads) 查找 cuda 的下载
- 根据上面的系统选择 [https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=runfile_local](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=runfile_local)

### CUDA Toolkit 历史版本收集

- [cuda-toolkit-archive 发布地址](https://developer.nvidia.com/cuda-toolkit-archive)

| version | link | desc |
|-----|------|----|
| 11.8.0 | [cuda-11.8.0](https://developer.nvidia.com/cuda-11-8-0-download-archive) | |
| 11.7.1 | [cuda-11-7.1](https://developer.nvidia.com/cuda-11-7-1-download-archive) | |
| 11.6.0 | [cuda-11-6.0](https://developer.nvidia.com/cuda-11-6-0-download-archive) | |


### 测试安装结果

```bash
# 显示当前状态
$ nvidia-smi

# cuda toolkit 版本
$ nvcc --version
```

## cudnn 安装

[安装指导](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html)

各个版本地址 [https://developer.nvidia.com/rdp/cudnn-archive](https://developer.nvidia.com/rdp/cudnn-archive)