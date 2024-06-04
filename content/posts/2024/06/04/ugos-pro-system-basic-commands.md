---
title: "UGOS Pro 系统基础命令"
date: 2024-06-04T11:51:41+08:00
description: "讲解 UGOS Pro 系统基础命令"
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


## 查看系统信息

```bash
# 系统信息
cat /etc/os-release

# 更多信息
cat /etc/os-release && \
  cat /etc/issue && \
  echo "" && \
  uname -asrm
```

## 内核版本和系统

```bash
# Linux是多少位的
getconf LONG_BIT
# 快速输出
lsb_release -a
# 输出系统信息
uname -a
# Linux内核版本
uname -srm

# 查看 linux 系统版本信息 通用方法
# 查询配置描述文件
cat /proc/version
```

## 网络发现

- 按照设定，网络发现根据 hostname 那么就是 `hostname.local`，可以直接 ping 通，不过如果修改网络连接，或者更换网口，会导致 mDNS 变更，重启 `avahi-daemon` 服务即可恢复正常

```bash
# 如果 ping 不通，检查 avahi 服务，也就是 mDNS 服务工作是否开启并且工作正常
sudo systemctl enable avahi-daemon
sudo systemctl daemon-reload
sudo systemctl restart avahi-daemon
# 查看 服务状态
systemctl status avahi-daemon
```

## 系统监控

使用 htop 或者 btop 都能方便的监控系统状态

```bash
sudo apt install -y htop btop
```

### 温度信息

[btop](https://github.com/aristocratos/btop) 对温度的监控已经给了，直接使用即可

## 硬件信息

### CPU信息

```bash
# CPU 和处理单元的信息
lscpu

# 查看CPU详情
cat /proc/cpuinfo
# 查看cpu核心数量
cat /proc/cpuinfo | grep 'cpu cores' | uniq
# 查看cpu型号
cat /proc/cpuinfo | grep 'model name' | uniq

# 查看cpu数量
lscpu |grep "Socket" |awk '{print $NF}'
# 或者
lscpu |grep "CPU socket" |awk '{print $NF}'
# 每个CPU的核数
lscpu |grep "Core(s) per socket" |awk '{print $NF}'

# 查看每个 cpu
grep "model name" /proc/cpuinfo |awk -F ':' '{print $NF}'
```

### 硬盘信息

```bash
# 各种分区及其挂载点
df -h
# 硬盘详情
sudo fdisk -l

## RAID分为软RAID和硬RAID
# 软RAID查看
cat /proc/mdstat
```

### PCI 总线信息

```bash
lspci
# 过滤出特定的设备信息
lspci -v | grep -A 10 'SATA'
```

#### 查询网卡信息

```bash
# 查看网卡芯片信息
lspci -v | grep Ethernet -A 10
# 查看无线网卡芯片信息
lspci -v | grep "Network" -A 10
```

### 连接到此计算机 USB 控制器

```bash
lsusb
```


