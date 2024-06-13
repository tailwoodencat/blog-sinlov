---
title: "UGOS Pro 系统级优化"
date: 2024-06-13T11:28:31+08:00
description: "UGOS Pro system level optimization"
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

## 优化前申明

本文的优化要求，你必须熟练使用 linux 操作， 并严谨的调整配置，任何错误

- 轻则导致`设备启动异常`
- 重则导致`数据丢失`

NAS (network attached storage) 翻译成中文 `网络附属存储`，那么任何时候都需要一个稳定网络作为基础

- 不要使用无线网络（无线网络本身不稳定易被干扰）
- 保证 点对点 设备的网络本身不存在问题，一般使用 [iperf3](https://github.com/esnet/iperf) 进行验证

NAS 调优前需要准备的

- 务必规划 NAS 设备的使用范围
	- 如果作为 `万兆文件服务器`，那么只能做文件服务，因为成品NAS的CPU 勉强够用
	- 如果作为 `下载服务器`，带有影音仓库功能，网络 2.5G 或者千兆即可，且需要一部分 CPU 冗余给下载服务使用
	- 如果作为 `归档服务器` 比如 素材，照片的服务，那么也只能做文件服务，且需要配置快照 和 jbod 存储池作为冷备，需要对数据本身负责
	- 如果作为 `备份服务器` 一般是多台 NAS 作为冗余备份，那么随便你折腾
- 基础的 NAS 磁盘和存储阵列知识
  - 硬盘的速度，是多方面决定，包括 硬盘本身速度，主板接口速度（比如 PICE 拆分）
  - 拷贝传输速度跟文件类型有关，单个大文件和大量小文件是完全不同的场景，不要混为一谈
  - Raid 理论速度从大到小 Raid 0 > Raid 5/6 > Raid 1 = Basic
  - 机械硬盘的读写速度，肯定没有固态硬盘快，但是数据安全更有保障
  - 不要使用 SSD 缓存加速机械硬盘，这个技术本身存在安全缺陷，且存在性能缺陷（需要额外 CPU 计算 做缓存处理）
- 没有完美的参数，调优需要根据实际使用场景，和设备软硬件配置进行调整
	- `文件传输第一优先原则`，保证最基础功能，才能让其他业务流畅使用
	- 根据不同的使用场景，`灵活调整`
	- `保留冗余`，任何时候不要满载运行，保证突发场景时，系统流畅，需要预留部分 CPU 内存，带宽等，如果设备运行一直运行在 50% 以上负荷，那么就需要迁移服务，或者升级设备

- 内核调优需要 root 权限和 ssh 客户端进行操作
	- root 权限 目前 UGOS Pro 是给的
	- ssh 链接和使用，教程很多，我这里不再说明

## 快速优化

> 警告: 请仔细阅读 `优化前申明`，根据自己的设备网络环境调整后使用，不要无脑使用，不要无脑使用不要无脑使用，重要的事情说三遍

- 文件IO优化

编辑 `/etc/security/limits.conf` 文件，在文件的最后加入，或者修改

```conf
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
* soft core  1048576
```

- 内核 优化 打开 `/etc/sysctl.conf` 文件 新增或者修改

```conf
user.max_inotify_instances = 512
fs.inotify.max_user_watches = 2000000
user.max_inotify_watches = 2000000
vm.min_free_kbytes = 262144
vm.swappiness = 10
vm.dirty_background_ratio = 5

net.ipv4.tcp_max_syn_backlog = 1024
net.core.somaxconn = 65535
net.ipv4.tcp_tw_reuse  = 1

net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
```

执行使内核优化生效

```bash
sudo sysctl -p
```

重启 NAS 服务器，即可完成 内核优化

## 调优思路

UGOS Pro 系统本身是 一个 NAS 服务器系统，那么

- 首先是一个 `服务器`
- 确保网络不是 NAS 的瓶颈，请使用 iperf3 做点对点测试
- 然后本职工作是 NAS `存储`
- 再是可以额外部署一些 `不需要计算的服务`

> tips: 目前需要大量计算的服务有，图片处理，视频渲染处理，Ai推理计算，模型计算等等

我个人是非常反对在 NAS 服务器上部署 视频转码处理，Ai服务这种 计算密集型服务的

NAS 服务器的 CPU 配置较弱，特别是成品NAS 大部分使用 低功耗弱性能 CPU，不能做这类工作，(除非有 GPU 或者 解码芯片加速)，否则会严重影响 NAS 服务器的存储服务

即使是专业的 视频转码 图片处理服务器，也是非常高性能高能耗的 专业 CPU，如果是 Ai 服务，则需要专业的 GPU 或者 NPU 协助，不是 CPU 性能弱跑得慢就可以进行的，因为对 NAS 服务来说，即使是任何一个网络传输，都需要 CPU 参与

开启 计算密集型服务 对 NAS 来说

- 轻则导致 `响应变慢，传输卡顿`
- 重则导致 `传输中断，数据丢失`

### 优化目标

- 通过这套优化，可以充分释放 服务器性能
- 内部文件传输可以稳定使用，保证全部数据传输，且速度足够使用
  - 本优化，对 ssd 固态文件拷贝作为 压力基准，保证当前硬件最高性能可以发挥
- 保证在 smb 模式下
	- smb 是 NAS 服务器目前最普遍的方式，优点是跟使用其他磁盘一样，兼容所有系统，缺点是速度不够极限
	- 目标 SSD 可以跑满 2.5G 网络 定传输生产级别工程文件
	- 目标 Raid1 企业机械硬盘 可以稳定传输生产级别工程文件
- 系统有余量，部署轻应用

### 调优环境和优化效果

设备 DXP8800 plus 32G 4800 内存配置

- 获取系统版本信息 `cat /etc/os-release`

```bash
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
OS_VERSION=1.0.0.0851
BUILD_ID=1.00.0851
```

传输网络为 `2.5G网络` 使用 iperf3 测试`去程回程`结果如下

![13216b7a037735f00c13ada182aab2e8-lXiMAM](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/13216b7a037735f00c13ada182aab2e8-lXiMAM.png)

![096f7ad5ac6cde25993a4c40140a1974-xSt1Qu](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/096f7ad5ac6cde25993a4c40140a1974-xSt1Qu.png)

传输文件为

- 总大小: 257G 左右
- 总文件数量: 115,044个文件，18,503个文件夹
	- 包含 2-10G 单体巨型文件
	- 海量小文件的python C 等工程源码

该工况，足够满足任何 小型团队剪辑，协作开发的需求

> 注意: 该NAS 可以使用万兆网络，不过万兆下，这种成品 NAS 的 CPU 已经是瓶颈，只能做存储使用，不要使用额外功能
>
> 防止数据传输出现问题或者防止数据丢失（消费级设备存在硬件故障且不可自修复），以及有更多人协同工作 （8人以上）， 需要配置 更安全的企业级 CPU + ECC 内存的 专业 NAS 服务器，且只能作为存储使用

#### 优化后传输目标 M.2 硬盘

使用 Basic 存储池 进行 文件传输

![3D39661B564447AF34C11B166314FAC8-T8xD9L](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/3D39661B564447AF34C11B166314FAC8-T8xD9L.png)

![aa5fb8b0f75dc9e37d8c2d921b1143ab-wfVbz4](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/aa5fb8b0f75dc9e37d8c2d921b1143ab-wfVbz4.png)

![41E7539B60F84632CC402E4A69D11964-TQ3rtL](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/41E7539B60F84632CC402E4A69D11964-TQ3rtL.png)

> 备注: 传输目标为 M.2硬盘1

#### 优化后传输目标 企业机械硬盘 Raid1

![08FC6EBBF8A46C16D880DAD9A1E7D614-fYojps](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/08FC6EBBF8A46C16D880DAD9A1E7D614-fYojps.png)

![0396C2431D57F7D5C4E9F99C8DCFDBA1-cB95WK](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/0396C2431D57F7D5C4E9F99C8DCFDBA1-cB95WK.png)

![FB447F9C2341C0B47DAF261779C67C0F-ugNxf5](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/FB447F9C2341C0B47DAF261779C67C0F-ugNxf5.png)

> 备注: 硬盘3 硬盘4 组成 Raid1 阵列

#### 优化后 NAS 内部对拷贝速度

M.2硬盘1 发送文件到 M.2硬盘2

![FAC276D8C022D8A6CA68DEED59852B34-G5b4Ev](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/FAC276D8C022D8A6CA68DEED59852B34-G5b4Ev.png)

## 详细调优

### 已经存在的优化项目

#### UGOS Pro 已有内核非默认值参数

```conf
user.max_inotify_instances = 512
fs.inotify.max_user_watches = 2000000
user.max_inotify_watches = 2000000
vm.min_free_kbytes = 262144
vm.swappiness = 10
vm.dirty_background_ratio = 5
```

文件同步、备份、日志分析的调优

- `user.max_inotify_instances` 每个用户可以创建的 inotify 实例的上限 ，默认 `128`，修改后，可以增加 文件系统变化通知机制 敏感度，特别是有外 ftp webDev 场景需求时
- `fs.inotify.max_user_watches` 为 epol l内核事件表中注册事件的总量，推荐默认值为 `65536` ，这里包含用户打开的所有epoll实例总共能监听的事件数目，被修改为 `2000000`，是针对 `rsync` 同步的调优
- `user.max_inotify_watches` 也是针对同步的调优，指定每个用户可以创建的监控对象的上限，默认 `65536`，修改后，增加文件系统敏感度

内存回收调优

> 其实就是 swap 机制调优，swap 初衷是为了缓解物理内存用尽而选择直接粗暴OOM进程的尴尬 ，但对数据库服务器来说是非常不待见 swap，因为会增加系统的延迟，导致请求阻塞，会让用户感知的卡顿增加

- `vm.min_free_kbytes` 系统所保留空闲内存的最低，一般值 `67584` 或者 `65536`，而绿联的工程师开到 4 倍左右，目的是让系统在 被某些程序导致的 内存耗尽后，保证系统仍然可以动，缺点会增加系统的响应延迟
- `vm.swappiness` 内存回收参数，默认值为 `60`，内核利用一部分物理内存分配出缓冲区，大部分 成品NAS 厂商 的值为 `10`，这个值为 0 则完全用物理内存，如果是 64G 可以尝试设置为 `0`

脏内存调优

- `vm.dirty_background_ratio` 内核脏页回写比例，默认值 `10`,  这个比例值为 系统内存的 10%，百分比越小则更快触发刷新脏数据，调小后IO写峰值削平，特别是 对于内存很大和磁盘性能比较差的服务器来说，被修改为 `5` 是大量基于机械硬盘的存储服务器的选择

> tips: 有需要的，根据自己的需要，调整这些参数，可以优化使用体验，不过这些已有调优，是针对当前产品的设计调整的，不建议再去做修改

### 文件IO调优

- 改优化，可以明显改善 `下载服务器` 场景下的使用体验

#### 文件系统优化

tcp server 连接受到 文件句柄 和 端口限制，这直接限制 tcp 服务器对服务器的连接数量，如果需要使用复杂或者高性能的服务，那么需要对各种用户进程 文件限制 就行修改

编辑 `/etc/security/limits.conf` 文件，在文件的最后加入，或者修改

```conf
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 1048576
* hard nproc 1048576
* soft core  1048576
```

这个调优，在重启设备生效

> tips: 文件句柄限制，每个进程可以单独设置，但是本身受进程孵化影响，子进程 不可超过 父进程，这个机制作为 资源限制的手段，可以进行系统资源分配和限制

### TCP 调优

#### 为什么调优 TCP

- smb 服务基于 445/tcp
- nfs 服务基于 2049/tcp 2049/udp
- webDAV 服务基于 5005/tcp 5006/tcp
- rsync 服务基于 873/tcp 和 22/tcp
- UGOS Pro 的 Web服务基于  9999/tcp, 9443/tcp

这么多服务基于 tcp , 那么非常有必要调优，并且部分调优效果也可以增强 UDP 的表现

#### 内核TCP调优参数

1. 打开 `/etc/sysctl.conf` 配置文件
2. 在文件末尾添加以下参数

```conf
net.ipv4.tcp_max_syn_backlog = 1024
net.core.somaxconn = 65535
net.ipv4.tcp_tw_reuse  = 1

net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
```

TCP 响应调优

- `net.ipv4.tcp_max_syn_backlog` ( 默认 2048 )，所能接受SYN同步包的最大客户端数量，即`半连接上限`，调整为默认的一半，可以增加系统的响应速度
- `net.core.somaxconn` ( 默认 4096)，能accept即处理数据的最大客户端数量，即`完成连接上限`，增大后可以明显增加系统的响应速度
- `net.ipv4.tcp_tw_reuse` 默认 2 `仅启用环回流量`  1 为启用， 0 为关闭，允许重用处于time_wait 的 socket，减少系统资源浪费

TCP 窗口调优

- `net.core.rmem_max` (默认值 212992 ) 和 `net.core.wmem_max` (默认值 212992) 表示系统中每个 socket 接收和发送缓冲区大小的更大值，单位为字节，调整后在千兆以上网络下性能更好
- `net.ipv4.tcp_rmem` ( 默认值 4096	131072	6291456 ) 和 `net.ipv4.tcp_wmem` (默认值   4096	16384	4194304) 表示 TCP 协议中接收和发送缓冲区的默认、最小和更大值，单位为字节

执行命令使配置文件生效

```bash
sudo sysctl -p
```

## UGOS 自身软件设置调优

以下调优，是在`内核调优后执行`

### UGOS 文件服务

NAS 必须保证文件服务正常运作，其他服务必须给 文件服务让步

#### UGOS smb 服务

建议设置

![f98fa481966f3281f3463b30064fb272-9SvJaM](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/f98fa481966f3281f3463b30064fb272-9SvJaM.png)

- `支持SMB协议` 除 smb1 外全部开启，其实就是由客户端决定使用哪个版本的 smb 协议进行传输
- `启用SMB durable handles` 在没有文件锁安全（多人协作安全需求），可以不开启，可以加速传输
- `启用Opportunistic Locking` 这个开启使用部分 CPU 资源，让客户端使用 机会锁，来增加smb 传输效率，减少网络流量并大幅缩短响应时间
	- `启用SMB2 租用`  一并开启，更多使用 smb2 下 Opportunistic Locking 的性能收益

如果是 2.5G 或者 万兆网络

![02db5713ff83086776d917fcfe38f355-uaS65v](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/02db5713ff83086776d917fcfe38f355-uaS65v.png)

- `启用异步读取` 使用更多CPU 资源，提高 4K 随机读取 或 高速网络下文件读取性能
- `当SMB客户端要求立即同步时，将数据同步到硬盘` 使用更多 CPU 和 IO 资源，加快文件传输性能
- `启用SMB3多通道` 提高吞吐量并允许网络容错，但需要网络设备和客户端支持
	- 仅在 x64 平台上受支持
	- 需要 `多个网卡` 或者 `支持 RSS（接收端缩放）的网卡`
	- 启用 SMB3 多通道时，不支持 Link Aggregation (链路聚合)
	- 启用 SMB3 多通道 `可能会降低加密共享文件夹的写入性能`

其他调整项目

- `启用local Master Browser` 如果开启，`会禁用硬盘休眠功能`
- `禁用同一IP地址的多个链接` 如果开启，单一 IP 客户端 下性能非常高，但是多人协作将无法正常使用
- `收集调试日志` 开启后，可以分析 smb 性能，但是日志本身会有性能损耗，不调试不要开启
- `请勿在创建文件时保留硬盘空间`  创建文件时不会预留硬盘空间，不建议开启，开启后会导致某些情况下文件无法正常传输
- `启用通配符搜索缓存` 启用此选项可提高搜索性能，但会消耗一部分资源

##### smb 客户端技巧

- windows 下请开启 `SMB直通`，开启方法 `启用或关闭Windows功能`，顺便 禁用 `SMB 1.0/CIFS 文件共享支持`

![cdff4a78a8afe8764cf313471d240a42-fAXJla](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/cdff4a78a8afe8764cf313471d240a42-fAXJla.png)

### UGOS webDAV 服务

![36f26054bf4005dc6cb3b5d66a58e112-k46eng](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/36f26054bf4005dc6cb3b5d66a58e112-k46eng.png)

- `解除1024个字符路径长度限制` 建议开启，否则某些文件无法传输
- `启用并发送WebDAV日志` 建议关闭，开启有性能损耗，但可以跟踪使用日志

### UGOS 文件管理器

UGOS 文件服务有一个 共享文件链接限制

![742b2850e1adcd38a9f449d290754de9-FwnadT](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/13/742b2850e1adcd38a9f449d290754de9-FwnadT.png)

建议开满，防止忘记