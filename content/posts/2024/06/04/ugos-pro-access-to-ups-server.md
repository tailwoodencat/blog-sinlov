---
title: "UGOS Pro 接入 UPS server"
date: 2024-06-04T11:52:04+08:00
description: "UGOS Pro access to UPS server"
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

## 场景说明

多个NAS 或者实体服务器，在单个UPS的情况下是正确的 nas 正确使用方法，这样保证数据不会 `all in bomb` （除了异地数据备份这点没满足，至少鸡蛋没在一个篮子里面）

那么多个NAS在同一局域网下，连接图如下

```mermaid
---
title: 简易网络连接图
---
graph TD;
    上游路由器---SWITCH(交换机);
    SWITCH---MainNAS(主NAS);
    MainNAS---|USB 连接|UPS;
    SWITCH---WebSer(Web服务器);
    SWITCH---DowloadSer(下载服务器);
    SWITCH---AppleTV;
    SWITCH---NAS-BAK(NAS 备份);
```

- 使用 [nut](https://networkupstools.org/) 是 C/S 架构的软件，来作为集群 UPS 管理
- 这个时候，`Nas-Main` 主 nas ，就作为 `网络UPS服务器` 来使用
- 其他设备，连接上`网络UPS服务器` 来接收 `断电安全关机操作`，作为 `受控设备`

**优点**

- 在于省成本，不用买很贵的带网络管理卡的 UPS，只需要一个 main 节点能 和 UPS 各种客户端通信就足够
- 可以覆盖绝大多数消费级设备

> 注意: 要 UPS 生效，`链路经过的路由器或者交换机` 电源也得接入 UPS

- 断电时候 `网络UPS服务器` 节点可以通过网络通知 `受控设备` 节点关机

```mermaid
---
title: UPS C/S 通知图
---
graph TD;
    SWITCH(交换机)---MainNAS(主NAS);
	MainNAS---|USB 连接|UPS;
	MainNAS---|部署|NUTServer(网络NUT服务器);
    SWITCH---DowloadSer(下载服务器);
	DowloadSer---|配置|NutClient(NUT客户端)
    SWITCH---NAS-BAK(NAS 备份);
	NAS-BAK---|配置|NutClient(NUT客户端)
	SWITCH---AppleTV(AppleTV【不接入】);

	NUTServer-.通知.-NutClient
```

> tips: `网络UPS服务器` 占用端口 `3493` 也就是 [nut](https://networkupstools.org/) 服务端端口

**缺点**

- 来电后，所有节点启动时，要先等 `网络UPS服务器` 节点启动 ，然后再在 `网络UPS服务器` 节点上

> 使用 `wake-on-lan` 唤醒其他节点，这个后面通过 docker 配置一套开机服务即可解决

## 已知问题

### UGOS Pro 系统存在问题

系统版本: 1.0.0.0760 下

UPS 使用 `SNMP不断电系统` 支持的 SNMP 版本为 `v1` 或者 `v2c` 不安全，不建议使用这方式

## 配置 网络UPS服务器

### nut  服务端

apcupsd 停止支持，请迁移到 nut

- [http://www.apcupsd.com/](http://www.apcupsd.com/)
	- [https://sourceforge.net/projects/apcupsd/](https://sourceforge.net/projects/apcupsd/)
	- 用户手册 已废弃 [http://www.apcupsd.org/manual/manual.html#basic-user-s-guide](http://www.apcupsd.org/manual/manual.html#basic-user-s-guide)

如果是 apcupsd 执行下面的命令，返回的 UPS 信息正常，打开 apcupsd 服务，端口为 3551

```bash
apcaccess status
```

主要是配置 nut 服务端

```bash
# 先查看是否已经安装 nut
systemctl status nut-driver.service
systemctl status NUTServerver.service

# 安装 nut 服务，非必要不需要安装
sudo apt install -y nut
```

修改 `/etc/nut/nut.conf`，设置 MODE 值为 netserver

```conf
MODE=netserver
```

修改 `/etc/nut/upsd.conf`，去掉注释或写入以下内容以绑定本地 IP 和端口，默认 `0.0.0.0 3493`

```conf
LISTEN 0.0.0.0 3493
```

打开 `/etc/nut/ups.conf`，写入以下内容以将 apcupsd 作为 UPS 源

```conf
[ups]
 driver = apcupsd-ups
 port = 127.0.0.1:3551
 desc = "SANTAK TG-BOX"
```

> `port = 127.0.0.1:3551` 这里 需要改为你的 apcupsd 主机配置
> `desc = ` 为描述

修改  `/etc/nut/upsd.use`r，写入以下内容以为 NAS 创建一个用户， 如果有多个用户 增加即可

```
[synologyNAS]
 password = synology
 actions = SET
 instcmds = ALL
 upsmon slave
```

> 如果需要给 群晖作为受控机，按照上面的设置 password 和 upsmon 即可

UPS电源检查

```bash
# 查看 UPS 电源 全部状态
$ upsc ups@localhost
# 查看 UPS 电源当前状态
$ upsc ups@localhost ups.status
Init SSL without certificate database
OL
# 这些状态可能同时出现，例如当市电断电时，状态可能是 OB 和 DISCHRG，如果同时电池电量低，可能还会有 LB
# 因此，ups.status的值可能是多个状态组合，用空格分隔
# 可能状态有
# OL：在线（On Line），表示UPS正在市电供电下正常工作，电池充满或正在充电
# OFF：UPS处于关闭状态
# ALARM：UPS有报警状态，可能有多种原因，需要进一步检查
# RB：需要更换电池（Replace Battery），电池可能老化需要更换
# OB：在电池上（On Battery），市电断电，UPS正在使用电池供电
# FSD：强制关机（Forced Shutdown），UPS即将关闭，通常由低电池触发
# OVER：过载（Overload），连接的负载超过UPS的容量，UPS可能无法维持供电
# LB：低电池（Low Battery），电池电量低，可能即将耗尽
# HB：高电池（High Battery），电池电量充足，可能正在充电或已充满
# CHRG：充电中（Charging），电池正在充电
# DISCHRG：放电中（Discharging），电池正在放电，为负载供电
# BYPASS：旁路模式，UPS处于旁路状态，可能因为内部故障或维护
# CAL：校准模式，UPS正在进行自我校准
# TRIM：市电电压调整模式，UPS正在调整输入电压（升压）
# BOOST：与TRIM类似，可能指电压调整

# 查看服务状态
$ sudo systemctl status nut-driver.service
$ sudo systemctl status NUTServerver.service

# 查看 nut 服务主机网络可达性
$ nc -zv 0.0.0.0 3493
Connection to 0.0.0.0 3493 port [tcp/nut] succeeded!
```

### 群晖作为 网络UPS服务器

在`控制面板`的 `不断电系统`中
  - 勾选`启用 UPS 支持`
  - 选好 `UPS 类型` 演示为 USB 连接
  - 勾选 `启用网络 UPS 服务器`

![ugos-pro-access-to-ups-server-qunhui-SqUaGM](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/06/04/ugos-pro-access-to-ups-server-qunhui-SqUaGM.png)

在 `允许的 Synology NAS 设备` 中，点击后添加 `受控设备` 的 ip，保存即可，注意群晖支持的 客户端数量很少

如果没添加到 `允许的 Synology NAS 设备` 并`保存设置`，后面验证时，会报错

```
Init SSL without certificate database
Error: Access denied
```

## 配置 UPS服务 受控端

> `UGOS Pro` 系统为 debian ，支持安装 nut 作为受控端

### 检查服务端配置

在配置 受控端前，需要在 `网络UPS服务器` 中配置好受控端信息，否则连接失败

### nut client 作为受控端

```bash
sudo apt install -y nut
```

- 修改配置文件，路径为 `/etc/nut/nut.conf`  模式改为客户端 `MODE=netclient`

```conf
MODE=netclient
```

- 修改服务指向配置文件，路径为 `/etc/nut/upsmon.conf` ，修改以下参数，UPS 服务指向 `MONITOR ups@host`，这里以 192.168.50.50 这个 IP 作为 `网络UPS服务器` 来 演示

```conf
MONITOR ups@192.168.50.50 1 monuser secret slave
```

- 配置生效

```bash
$ sudo systemctl restart nut-client
# 查看状态
$ sudo systemctl status nut-client
```

- 线路测试

不想通过拔电源来测试上面设置是否生效

```bash
$ upsc ups@192.168.50.50
Init SSL without certificate database
battery.charge: 5
battery.charge.low: 20
battery.runtime: 126
battery.type: PbAc
device.mfr: EATON
device.model: SANTAK TG-BOX 850
device.serial: Blank
device.type: ups
...
```

获取到 UPS 服务的信息，则为成功，测试通过设置 nut-client 为开机启动

```bash
$ sudo systemctl enable nut-client
$ sudo systemctl restart nut-client
```

### 群晖NAS 作为 受控端

- 打开你的群晖 DSM 控制面板
- 选择 `硬件和电源` 中的 `不断电系统`
  - 勾选 `启用 UPS 支持`
  - 网络不断电系统类型选择为 `Synology 不断电系统服务器`
  - 在网络不断电系统服务器 IP 地址中 输入你的 `网络UPS服务器` 主机的 IP 地址
- 点击应用，稍等一会即可看到保存成功的提示，并出现一个按钮 `设备信息`
- 点开之前没有出现的 `设备信息` 你将可以看到 UPS 的当前状态

### windows 作为 受控端

支持 UPS 的软件不少

- [nutdotnet/WinNUT-Client](https://github.com/nutdotnet/WinNUT-Client)
- [gawindx/WinNUT-Client](https://github.com/gawindx/WinNUT-Client)
- [apcupsd](http://www.apcupsd.org/)
- [PowerChute 个人版](https://www.apc.com/cn/zh/product-range/61934-powerchute-%E4%B8%AA%E4%BA%BA%E7%89%88/)

这里选择 [nutdotnet/WinNUT-Client](https://github.com/nutdotnet/WinNUT-Client) 版本 `Release v2.2.8719`，注意该软件需要自己设置开机启动

> 如果作为 windows nut 服务端 需要安装 `NUT-for-Windows-2.6.5-6` form [https://networkupstools.org/download.html](https://networkupstools.org/download.html)

- 如果您的 NUT 服务器托管在Synology NAS 上，请务必提供以下连接信息（默认）

```
UPS Name: ups
Login: upsmon
Password: secret
```

- 如果您的 NUT 服务器托管在 QNAP NAS 上，请务必提供以下连接信息（默认）

```
UPS Name: ups
Login: 留空不需要
Password: 留空不需要
```

## 网络UPS服务器 配置来电唤醒其他设备

- 配置前需要找到 受控端支持 网络唤醒的网卡 mac 地址，获取方式为

```bash
## linux mac
$ ifconfig <具体网卡>
# ether 后面跟着就是

## windows
$ ipconfig /All
# 物理地址 就是
# 使用需要 去掉 - 改为.
# 比如 48-21-0B-12-34-56 改为 48.21.0b.12.34.56
```

- 在主控 `网络NUT服务器` (一般是主NAS兼职做这个) 配置唤醒其他设备，需要 主NAS 支持 docker 和 docker-compose

- docker-compse 配置例子

```yml
# more info see https://docs.docker.com/compose/compose-file/
services:
  wakeonlan-foo-server:
    container_name: wakeonlan-foo-server
    image: fopina/wakeonlan:v1.1.2-1 # https://hub.docker.com/r/fopina/wakeonlan/tags
    network_mode: "host"
    environment:
      - TZ=Asia/Shanghai
    command: wake <foo mac addr>
    restart: on-failure # https://docs.docker.com/compose/compose-file/#restart

  wakeonlan-bar-server:
    container_name: wakeonlan-bar-server
    image: fopina/wakeonlan:v1.1.2-1 # https://hub.docker.com/r/fopina/wakeonlan/tags
    network_mode: "host"
    environment:
      - TZ=Asia/Shanghai
    command: wake <bar mac addr>
    restart: on-failure # https://docs.docker.com/compose/compose-file/#restart
```

- `<mac addr>` 换为受控机的 mac 地址
- 有多台设备需要唤醒，直接配置多个 service 即可

应用容器编排

```bash
docker-compose up -d --remove-orphans
```

> 这个容器编排，会在 下一次重启的时候，因为 `restart: on-failure` 而做到开机启用
