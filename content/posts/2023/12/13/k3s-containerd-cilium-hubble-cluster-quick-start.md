---
title: "k3s containerd cilium hubble 集群快速上手"
date: 2023-12-13T22:50:14+08:00
description: "使用 cilium 在 k3s 环境下，部署实验环境"
draft: false
categories: ['container']
tags: ['container', 'k3s', 'k8s', 'cilium']
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

##  基础概念

- 使用本文前，必须清楚熟悉  [k8s](https://kubernetes.io/) ，熟练使用 k8s，清楚  CNI (Container Network Interface) 概念和原理
- 本文是针对集群部署，目标是使用 cilium ，用以提升网络工作负载 ，服务的可见性，可维护性的实验，作为 k8s 使用  [eBPF](https://ebpf.io/) 的验证环境使用，不能作为生产环境配置
- 集群中，从网络上是全部等效可见的，因为集群内 cilium-agent  ( 简写 cilium-ag) 可以不需要 管理平面或操作运维平面 Cilium Operator 导致
- 但是在理平面或操作运维平面上还是分 server ( 管理服务节点) 和  agent（工作负载节点）

## 介绍

### k3s 介绍

k3s 是 [rancher](https://github.com/rancher/k3s) 开源的一个 Kubernetes 发行版，并且对宿主的运行要求非常低，非常适合做 k8s 实验环境，和边缘技术服务的基建

> k3s包含了k8s的所有基础功能，而k8s附加功能其实大多数情况也用不到

- k3s v1.24 后，默认容器运行时，使用 [containerd](https://containerd.io/)
- 中文文档 [https://docs.k3s.io/zh/installation](https://docs.k3s.io/zh/installation)
	- [k3s 版本 v1.28.X  更新日志](https://docs.k3s.io/release-notes/v1.28.X)

### cilium 介绍

cilium 采用 linux 最热门的新特性 eBPF 在性能效率和功能，已经成为最受欢迎的 CNI 解决方案

cilium 针对 Service Mesh 的解决方案并没有使用 SideCar，而是通过 eBPF 钩子来实现流量管控、服务发现、负载均衡、链路追踪、灰度发布等常见的 Service Mesh 特性

并且 cilium 最大优势是，Cilium 的网络、安全和可观察性逻辑可以直接编程到内核中，从而使 Cilium 和 Hubble 的功能对应用工作负载完全透明，不只是 k8s 可用，耦合更低通用性更高

使用传统的网络工具(通过五元组)实施可能会非常低效，只能提供粗粒度的可见性和过滤，从而限制了排除故障和保护容器网络安全的能力

Cilium 就是为大规模、高动态的容器化环境而设计的，能原生理解容器和 Kubernetes 身份，解析 HTTP、gRPC 和 Kafka 等 API 协议，提供比传统防火墙更简单、更强大的可视性和安全性。

cilium 主要缺点就在于对[内核的要求高](https://docs.cilium.io/en/stable/operations/system_requirements/)，因为其会用到很多 linux 内核高版本才有的功能

版本要求 ( uname -r 查看内核版本 )

| cilium 版本 | Linux kernel | RHEL kernel |     etcd | clang+LLVM |
|-------------|--------------|-------------|----------|------------|
|       v1.14 |   >= 4.19.57 |     >= 4.18 | >= 3.1.0 |    >= 10.0 |

## 配置

### 配置前准备

- `不感人的网络`，这个做技术都懂
- server 节点需要较高配置 2C 8G 以上，agent 节点要求非常低，树莓派都可以运行
- 多节点 server 至少 3个 以上，满足最低要求，并保证正常运作的数量为奇数，防止脑裂现象
- 提前安装好 `docker` 用于测试镜像拉取（k3s 和 docker 是可以并存的，k3s 采用 containerd 作为默认 COI ），生产环境可用不用
	- 配置 hosts `k3s-master.local` (可选)，非生产环境不做要求
- 下载 [https://github.com/k3s-io/k3s/releases/latest](https://github.com/k3s-io/k3s/releases/latest) (可选，用于离线模式安装)

- 每台设备需要预留的端口
	- k3s 需要 `6443` 端口才能被所有节点访问
 	    - 使用 Flannel VXLAN 时，节点需要能够通过 UDP 端口 `8472` 访问其他节点
 	    - 如果要使用 Metrics Server，所有节点必须可以在端口 `10250` 上相互访问
 	    - 使用 Flannel Wireguard 后端时，节点需要能够通过 UDP 端口 `51820` 和 `51821`（使用 IPv6 时）访问其他节点
		- 嵌入式 etcd 来实现高可用性，则 Server 节点必须可以在端口 `2379` 和 `2380` 上相互访问
	- k3s 监控需要端口 `10250` `10257` `10259`
	- cilium-ag 端口 `4244` 在所有运行 cilium 的节点上打开 TCP 端口，包括 agent

- 安装好 `restorecon` 用于恢复SELinux文件属性，即恢复文件的安全上下文，这个在 k3s 安装时会用到

| OS Distribution  |  Command |
|---|---|
| Debian  | apt install policycoreutils |
| Ubuntu  | apt install policycoreutils  |
| kail  | apt install policycoreutils  |
| CentOS  | yum install policycoreutils  |
| Fedora  | dnf install policycoreutils  |

### 集群外部资源

- 提前配置好 `harbor` 用于快速拉取镜像，这个对部署很重要，并确认获取 harbor 的 `harbor.crt` 证书
	- 本文的私有 harbor 地址为 192.168.50.50
- 有 nas 存储，或者用于实验的数据库可以提前部署准备，这里不多赘述

### k3s with cilium 各节点的入站规则

| 协议 | 端口 | 源 | 目标 | 必需 | 描述 |
|----------|-----------|-----------|-------------|------------|------------
| TCP | 2379-2380 | Servers | Servers | 否 | 只有具有嵌入式 etcd 的 HA 需要 |
| TCP | 4244 | 所有节点 | cilium-ag | 是 | 启用 hubble 需要在所有运行 cilium 的节点上打开 TCP 端口 |
| TCP | 4245 | Servers | Hubble client | 否 | Hubble API Access 监听默认端口 |
| TCP | 6443 | Agents | Servers | 是 | K3s supervisor 和 Kubernetes API Server |
| UDP | 8472 | 所有节点 | 所有节点 | 否 | 只有 Flannel VXLAN 需要 |
| TCP | 10250 | 所有节点 | 所有节点 | 是 | Kubelet 指标 |
| TCP | 10257 | Servers | Servers | 是 | k3s 监控端口 |
| TCP | 10259 | Servers | Servers | 是 | k3s 监控端口 |
| TCP | 12000 | Servers | hubble | 否 | hubble ui 监控端口 |
| TCP/UDP | 20000-39999 | 所有节点 | 所有节点 | 否 | service-node-port-range 对外映射端口 |
| UDP | 51820 | 所有节点 | 所有节点 | 否 | 只有使用 IPv4 的 Flannel Wireguard 才需要 |
| UDP | 51821 | 所有节点 | 所有节点 | 否 | 只有使用 IPv6 的 Flannel Wireguard 才需要 |

### 编排工具 helm

- 安装辅助工具 [helm](https://helm.sh/docs/)，该工具一般安装在 server 节点上
- 中文文档 [https://helm.sh/zh/docs/intro/install/](https://helm.sh/zh/docs/intro/install/)

```bash
# 脚本安装
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Debian/Ubuntu
$ curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
$ sudo apt-get install apt-transport-https --yes
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
$ sudo apt update
$ sudo apt install -y helm

# windows
$ scoop install helm
# macOS
$ brew install helm

# 如果在本机适用，需要设置环境变量（非必需）
# 因为默认读取 $HOME/.kube/config 也可以在安装时设置到 helm 默认路径
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

- 更新安装源 注意不同用户下 helm 的源是不同的

```bash
# 当前源
$ helm repo list
# 海外源
$ helm repo add stable https://charts.helm.sh/stable

# 导入阿里源 国内代理
$ helm repo remove stable
$ helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
$ helm repo update stable

# 导入 云原生应用市场 https://hub.grapps.cn/
$ helm repo add appstore https://charts.grapps.cn
$ helm repo update appstore

# 更新全部
$ helm repo update

# 移除某个 repo
$ helm repo remove [some]
```

- 安装好 helm ，并测试 helm 可用镜像

```bash
# search hub
$ helm search hub postgresql
# search repo
$ helm search repo nginx
```

### 安装 Cilium CLI

CLI 工具能让你轻松上手 Cilium，`每一台涉及 k8s 集群的设备都需要安装`

它直接使用 Kubernetes API 来检查与现有 kubectl 上下文相对应的集群，并为检测到的 Kubernetes 实施选择合适的安装选项

> cilium 高级安装和生产环境 使用 Helm Chart 方式安装，cilium cli 用于确认和维护

`Cilium CLI 安装在 操作机/堡垒机上`

```bash
$ CLI_ARCH=amd64
$ if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

$ CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# 确认 cilium 安装版本
$ echo $CILIUM_CLI_VERSION

$ curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz
$ curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

## use proxy
$ CILIUM_CLI_VERSION=$(curl -s https://mirror.ghproxy.com/https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# 确认 cilium 安装版本
$ echo $CILIUM_CLI_VERSION
$ curl -L --fail --remote-name-all "https://mirror.ghproxy.com/https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz"
$ curl -L --fail --remote-name-all "https://mirror.ghproxy.com/https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz.sha256sum"

# check download
$ sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

# install cilium
$ sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
# remove package
$ rm "cilium-linux-${CLI_ARCH}.tar.gz" "cilium-linux-${CLI_ARCH}.tar.gz.sha256sum"

# check install
$ cilium version
```

#### Cilium Agent  和 Cilium Client

`Cilium Agent` 以 `daemonset` 的形式运行，因此 Kubernetes 集群的每个节点上都有一个 Cilium agent pod 在运行，下面会演示  `Cilium Agent` 的使用

agent 执行与 Cilium 相关的大部分工作：

- 与 Linux kernel 交互，加载 eBPF 程序并更新 eBPF map
- 与 Kubernetes API 服务器交互，同步集群状态
- 通过文件系统 socket 与 Cilium CNI 插件可执行文件交互，以获得新调度工作负载的通知
- 根据要求的网络策略，按需创建 DNS 和 Envoy Proxy 服务器
- 可启用 Hubble 时创建 Hubble gRPC 服务

`Cilium Agent` 守护进程中的每个 pod 都带有一个 `Cilium Client` 可执行文件，可用于检查该节点上安装的 Cilium Agent 和 eBPF map 资源的状态

Client 通过守护进程 pod 与 Cilium Agent 的 REST API 通信

> `Cilium Client` 不是 `Cilium CLI`. 这与安装在操作机/堡垒机上的 Cilium CLI 工具可执行文件不同
> `Cilium Client` 可执行文件包含在`每个 Cilium Agent pod 中`，必要时可用作诊断工具，帮助排除 Cilium Agent 运行故障

## 快速上手 k3s with cilium

### k3s 基本结构

- `k3s server` 控制平面，control plane 和数据存储组件由 K3s 管理
- `k3s agent` 工作节点，不具有任何数据存储或 control plane 组件

所以按照不同 工作节点，安装会不一样

### 部署计划

配置部署后的结构如下

|  主机名 |   类型 |           IP地址 |         系统 |   配置 |      网络 |
|---------|--------|------------------|--------------|--------|-----------|
| server1 | server | 192.168.50.55/24 |  ubuntu 22.4 | 16C32G | inner:NAT |
| server2 | server | 192.168.50.56/24 |  ubuntu 22.4 | 16C32G | inner:NAT |
| server3 | server | 192.168.50.60.24 |  ubuntu 22.4 |  4C32G | inner:NAT |
|  agent1 |  agent | 192.168.50.54/24 | ubuntu 20.04 |   4C8G | inner:NAT |

> 故意使用不同的硬件和宿主系统来检测部署结果，k3s 支持更灵活的部署是巨大优点

### 安装 k3s server with cilium

- 安装官方文档 [https://docs.k3s.io/quick-start](https://docs.k3s.io/quick-start)
- [Installation Using K3s ](https://docs.cilium.io/en/stable/installation/k3s/)

只执行了一个命令即部署了一套 all in one k3s 环境，相对 k8s 无需额外安装如下组件

- kubelet
- containerd
- etcd
- ingress

#### 嵌入式 etcd 的 HA K3s 集群

启动一个带有 cluster-init 标志的 Server 节点来启用集群和一个令牌，该令牌将作为共享 secret，用于将其他 Server 加入集群
这个令牌设置到环境变量 `K3S_TOKEN`

```bash
# 生成 K3S_TOKEN 后面会用到
$ openssl rand -hex 32
```

需要了解的标识，server flag 文档见 [https://docs.k3s.io/cli/server](https://docs.k3s.io/cli/server) 下面的标识在所有 server 节点中是相同的

- 网络相关标志：`--cluster-dns`、`--cluster-domain`、`--cluster-cidr`、`--service- cidr`
- 控制某些组件部署的标志：`--disable-helm-controller`、`--disable-kube-proxy`、`--disable-network-policy` 和任何传递给 `--disable` 的组件
- 功能相关标志：`--secrets-encryption`

- 私有 docker 仓库相关 `--tls-san` 设置 加其他主机名或 IPv4/IPv6 地址作为 Subject Alternative Name
	-  需要预先将 `harbor-domain.crt` 复制到  `/etc/rancher/k3s/` 下 具体见 [private-registry](https://docs.k3s.io/installation/private-registry)

 - 使用 `--flannel-backend=none` 完全禁用 K3s 自带 Flannel，好安装自定义的 CNI
	- 参考文档 [自定义 CNI](https://docs.k3s.io/zh/installation/network-options?_highlight=cilium#%E8%87%AA%E5%AE%9A%E4%B9%89-cni) 因为要使用 cilium 就是自有 CNI 管理
	- 大多数 CNI 插件都有自己的网络策略引擎，因此建议同时设置 `--disable-network-policy` 以避免冲突
	- 附加禁用运行 kube-proxy  `--disable-kube-proxy` [Kubernetes Without kube-proxy](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/#kubeproxy-free)

注意使用内网 ip 或者 公网 ip 搭建，这里以 `192.168.50.56` 为 k3s server  第一个节点

```bash
# 设置主机上的其他非特权用户将能读取它，这个根据实际情况来（非必需）
$ export K3S_KUBECONFIG_MODE=644

# 设置 数据库连接环境变量（非必需）--cluster-init 为内嵌 etcd 模式
$ export K3S_DATASTORE_ENDPOINT=""

# 设置对外服务 ip （非必需）
$ export K3S_INSTALL_ADVERTISE_ADDRESS="192.168.50.56"

## 这些环境变量就是必须设置的

# 这里设置共享密钥用于将 server 或 agent 加入集群的令牌
# 令牌使用 ${ENV_GEN_K3S_TOKEN}
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
# 设置 首个 server 地址，用于其他节点加入
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.56"
# 设置私有 harbor 的域名或者 IP
$ export K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS="192.168.50.50"
# 设置安装版本 https://github.com/k3s-io/k3s/releases 版本
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1

## 设置安装命令
# 这个方式为 使用嵌入式 etcd 初始化新集群，设置 server 对外节点地址，设置配置文件位置
# 使用自定义 CNI 禁用运行 kube-proxy
$ export INSTALL_K3S_EXEC="server --tls-san=${K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS} --cluster-init --flannel-backend=none --disable-network-policy --kube-apiserver-arg service-node-port-range=20000-39999 --write-kubeconfig $HOME/.kube/config --write-kubeconfig-mode 0644"

## 开始安装 k3s
# check env
$ echo $K3S_TOKEN $INSTALL_K3S_EXEC
# then
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s -

# 添加其他参数（非必需）
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s - \
  --tls-san <harbor_domain> \
  --advertise-address=${K3S_INSTALL_ADVERTISE_ADDRESS} \
  --system-default-registry registry.cn-hangzhou.aliyuncs.com

# 或者下载到本地 install-k3s.sh
$ curl -fL -o install-k3s.sh https://get.k3s.io
$ cat install-k3s.sh | INSTALL_K3S_MIRROR=cn sh -s - \
  --system-default-registry registry.cn-hangzhou.aliyuncs.com

## 检查服务运行
$ systemctl status k3s.service

# 配置 KUBECONFIG
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

## 使用 cilium cli 安装 cilium
# get version of cilium https://github.com/cilium/cilium/releases/latest
$ curl https://github.com/cilium/cilium/raw/main/stable.txt
# get version by proxy
$ curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/cilium/cilium/main/stable.txt
# now latest is v1.14.4
# match k3s default podCIDR 10.42.0.0/16
$ cilium install --version 1.14.4 \
  --set=ipam.operator.clusterPoolIPv4PodCIDRList="10.42.0.0/16"
🔮 Auto-detected Kubernetes kind: K3s
ℹ️  Using Cilium version 1.14.4
🔮 Auto-detected cluster name: default

# wait cilium install
$ cilium status --wait

## 安装有错误，卸载安装
$ cilium uninstall
# k3s 下必须手动删除 cilium_host、cilium_net 和 cilium_vxlan 接口
# 如果不这样做，你可能会在 K3s 停止时丢失与主机的网络连接
$ ip link show | grep cilium
$ ip link delete cilium_host
$ ip link delete cilium_net
$ ip link delete cilium_vxlan
# 并且 需要删除 cilium 的 iptables 规则
$ iptables-save | grep -iv cilium | iptables-restore
$ ip6tables-save | grep -iv cilium | ip6tables-restore
# 确认删除
$ sudo iptables-save | grep cilium
$ sudo ip6tables-save | grep cilium
# 确认上面的执行完成后
$ /usr/local/bin/k3s-uninstall.sh
```

- 如果是云端部署，需要确认对外服务的地址（非必需）
	- `--advertise-address=ip`很重要，对于公网来说需要指定，不然默认是内网ip

```bash
$ cat /etc/systemd/system/k3s.service
内容为
–advertise-address=
为 公网或者内网 ip
```

- 基础安装检查

```bash
# 查看 kubectl 配置，这里已经被修改路径 该文件同 /etc/rancher/k3s/k3s.yaml
$ cat $HOME/.kube/config

$ kubectl get nodes
NAME        STATUS   ROLES                       AGE   VERSION
server1     Ready    control-plane,etcd,master   28m   vX.Y.Z

# 或者
$ kubectl get pods -n kube-system -o wide
# 确认基础节点运行正常
$ kubectl get pods -A

# check cilium status
$ cilium status
Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium             Desired: 1, Ready: 1/1, Available: 1/1
Containers:            cilium             Running: 1
                       cilium-operator    Running: 1
Cluster Pods:          5/5 managed by Cilium
Helm chart version:    1.14.4
```

#### 使用共享 secret 其他 k3s server 加入集群

```bash
# 设置主机上的其他非特权用户将能读取它，这个根据实际情况来（非必需）
$ export K3S_KUBECONFIG_MODE=644

# 设置 数据库连接环境变量（非必需）--cluster-init 为内嵌 etcd 模式
$ export K3S_DATASTORE_ENDPOINT=""

## 这些环境变量就是必须设置的

# 这里设置共享密钥用于将 server 或 agent 加入集群的令牌
# 令牌使用首个节点安装时生成的 ${ENV_GEN_K3S_TOKEN}
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
# 设置 首个 server 地址，用于其他节点加入
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.56"
# 设置私有 harbor 的域名或者 IP
$ export K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS="192.168.50.50"
# 设置安装版本 https://github.com/k3s-io/k3s/releases 版本
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1

## 设置安装命令
# 这个方式为 使用嵌入式 etcd 初始化新集群，设置 server 对外节点地址
# 设置 master 对外节点地址，设置配置文件位置
# 使用自定义 CNI 禁用运行 kube-proxy
$ export INSTALL_K3S_EXEC="server --server https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443 --tls-san=${K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS} --flannel-backend=none --disable-network-policy --kube-apiserver-arg service-node-port-range=20000-39999 --write-kubeconfig $HOME/.kube/config --write-kubeconfig-mode 0644"

## 开始安装
# check env
$ echo $K3S_TOKEN $K3S_INSTALL_FIRST_ADVERTISE_ADDRESS $INSTALL_K3S_EXEC
# then
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s -

## 检查服务运行
$ systemctl status k3s.service

# 配置 KUBECONFIG
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

## 使用 cilium cli 安装 cilium
# get version of cilium https://github.com/cilium/cilium/releases/latest
$ curl https://github.com/cilium/cilium/raw/main/stable.txt
# get version by proxy
$ curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/cilium/cilium/main/stable.txt
# now latest is v1.14.4
$ cilium install --version 1.14.4
🔮 Auto-detected Kubernetes kind: K3s
ℹ️  Using Cilium version 1.14.4
🔮 Auto-detected cluster name: default

# wait cilium install
$ cilium status --wait
# 安装成功后效果
Deployment             cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
DaemonSet              cilium             Desired: 2, Ready: 2/2, Available: 2/2
Containers:            cilium             Running: 2
                       cilium-operator    Running: 1
Cluster Pods:          6/6 managed by Cilium

## 安装有错误，卸载安装
$ cilium uninstall
# k3s下必须手动删除 cilium_host、cilium_net 和 cilium_vxlan 接口
# 如果不这样做，你可能会在 K3s 停止时丢失与主机的网络连接
$ ip link show | grep cilium
$ ip link delete cilium_host
$ ip link delete cilium_net
$ ip link delete cilium_vxlan
# 并且 需要删除 cilium 的 iptables 规则
$ iptables-save | grep -iv cilium | iptables-restore
$ ip6tables-save | grep -iv cilium | ip6tables-restore
# 确认删除
$ sudo iptables-save | grep cilium
$ sudo ip6tables-save | grep cilium
# 确认上面的执行完成后
$ /usr/local/bin/k3s-uninstall.sh

```

### 安装 k3s agent

> 使用k3s agent 添加更多的 worker node，只需要添加 `K3S_URL` 和 `K3S_TOKEN` 参数即可

- flag 文档见 [https://docs.k3s.io/cli/agent](https://docs.k3s.io/cli/agent)
- 工作节点配置参数

```bash

## 这些环境变量就是必须设置的

# 这里设置共享密钥用于将 server 或 agent 加入集群的令牌
# 令牌使用首个节点安装时生成的 ${ENV_GEN_K3S_TOKEN}
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
# 设置安装版本 https://github.com/k3s-io/k3s/releases 版本
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1
# 设置集群节点地址
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.56"
$ export K3S_URL=https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443
# 安装配置 agent
$ export INSTALL_K3S_EXEC="agent --server https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443"

## 开始安装
# check env
$ echo $K3S_TOKEN $K3S_URL $INSTALL_K3S_EXEC
# then
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s -

# 或者使用这个命令来，作为已有 server 的工作节点
$ k3s agent --server ${K3S_URL} --token ${K3S_TOKEN}

# 安装有错误，卸载 agent 安装
# k3s下必须手动删除 cilium_host、cilium_net 和 cilium_vxlan 接口
# 如果不这样做，你可能会在 K3s 停止时丢失与主机的网络连接
$ ip link show | grep cilium
$ ip link delete cilium_host
$ ip link delete cilium_net
$ ip link delete cilium_vxlan
# 并且 需要删除 cilium 的 iptables 规则
$ iptables-save | grep -iv cilium | iptables-restore
$ ip6tables-save | grep -iv cilium | ip6tables-restore
# 确认删除
$ sudo iptables-save | grep cilium
$ sudo ip6tables-save | grep cilium
# 确认上面的执行完成后
$ /usr/local/bin/k3s-agent-uninstall.sh
```

### 验证集群安装

```bash
## 验证
# 借助 cilium service list 命令，我们可以验证 Cilium 的 eBPF kube-proxy 替代程序是否创建了新的 NodePort 服务
$ kubectl -n kube-system exec ds/cilium -- cilium service list
# 使用主机名空间中的 iptables 验证是否存在针对该服务的 iptables 规则
$ sudo iptables-save | grep KUBE-SVC
# 因为是使用 cilium cli 安装，iptables 规则不会为空，对于快速上手来说，足够使用

## test
$ cilium connectivity test
# test with args
$ cilium connectivity test --request-timeout 30s --connect-timeout 10s
```

> 在中国安装时，由于网络环境所限，可能部分测试会失败（如访问 1.1.1.1:443 1.0.0.1:443 one.one.one.one:443 ). 测速报告这部分可以忽略
> 连接性测试需要至少两个 worker node 才能在群集中成功部署
> 如果您没有为群集配置两个 worker node，连接性测试命令可能会在等待测试环境部署完成时卡住
> 连接性测试 pod 不会在以控制面角色运行的节点上调度，所以测速过程中，部分 pod 会调度异常

### 查看 cilium 启用的功能

```bash
$ kubectl -n kube-system exec ds/cilium -- cilium status
```

- `datapath mode: tunnel`: 因为兼容性原因，Cilium 会默认启用 tunnel（基于 vxlan) 的 datapatch 模式，也就是 overlay 网络结构
- `KubeProxyReplacement: Disabled` Cilium 是没有完全替换掉 kube-proxy 的，后面我们会出文章介绍如何实现替换
	-  `KubeProxyReplacement:    False`  是换掉了 kube-proxy
- `IPv6 BIG TCP: Disabled` 该功能要求 Linux Kernel >= 5.19
- `BandwidthManager: Disabled` 该功能要求 Linux Kernel >= 5.1
- `Host Routing: Legacy` 性能较弱的 Legacy Host Routing 还是会用到 iptables，但是 BPF-based host routing 需要 Linux Kernel >= 5.10
- `Masquerading:            IPTables [IPv4: Enabled, IPv6: Disabled]` 伪装有几种方式：基于 eBPF 的，和基于 iptables 的。默认使用基于 iptables, 推荐使用 基于 eBPF 的
- `Hubble Relay: disabled` 默认 Hubble 也是禁用的

## hubble

[hubble](https://docs.cilium.io/en/stable/overview/intro/#what-is-hubble) 是 完全分布式的网络和安全可观察性平台，支持

- 服务依赖关系和通信映射
- 网络监控和警报
- 应用监控
- 安全监控

### 开启 hubble in cilium 支持

```bash
# get version of cilium https://github.com/cilium/cilium/releases/latest
$ curl https://github.com/cilium/cilium/raw/main/stable.txt
# get version by proxy
$ curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/cilium/cilium/main/stable.txt
# now latest is v1.14.4

$ helm repo add cilium https://helm.cilium.io/
$ helm upgrade cilium cilium/cilium --version 1.14.4 \
   --namespace kube-system \
   --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true

# or enable by cilium
$ cilium hubble enable

# check
$ cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             OK
 \__/¯¯\__/    Operator:           OK
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       OK
    \__/       ClusterMesh:        disable

# Hubble Relay:       OK
```

### 安装 Hubble Client

```bash
$ HUBBLE_ARCH=amd64
$ if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi

# get version
$ HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/main/stable.txt)
$ echo "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz"
$ curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz
$ curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
## use proxy
$ HUBBLE_VERSION=$(curl -s https://mirror.ghproxy.com/https://raw.githubusercontent.com/cilium/hubble/main/stable.txt)
$ echo "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz"
$ curl -L --fail --remote-name-all "https://mirror.ghproxy.com/https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz"
$ curl -L --fail --remote-name-all "https://mirror.ghproxy.com/https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum"

# check download
$ sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
# pass check then install
$ sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
$ rm "hubble-linux-${HUBBLE_ARCH}.tar.gz" "hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum"

# 默认情况下 hubble 服务绑定在 localhost:4245
# 如果需要，可以修改 hubble 服务配置
$ hubble config set server 0.0.0.0:4245

# 为了访问Hubble API，从本地计算机创建一个转发到Hubble服务的端口。这将允许您将Hubble客户端连接到本地端口4245并访问库伯内特斯集群中的Hubble中继服务。
# This will allow you to connect the Hubble client to the local port 4245 and access the Hubble Relay service in your Kubernetes cluster.
# more doc see https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/
$ cilium hubble port-forward&

# check install
$ hubble status
Healthcheck (via 0.0.0.0:4245): Ok
Current/Max Flows: 16,380/16,380 (100.00%)
Flows/s: 50.64
Connected Nodes: 4/4
```

- 使用 hubble client

```bash
# 您还可以查询流API并查找流
$ hubble observe

# 修改 hubble 服务配置
$ hubble config set server 0.0.0.0:4245

# 检查 hubble 配置
$ hubble config view

# 如果修改配置需要
$ cilium hubble disable
$ cilium hubble enable
```

### 配置  Service Map 和 Hubble UI

```bash
# 启用 hubble UI
$ cilium hubble enable --ui
$ cilium hubble ui --open-browser=false
# 默认情况下 hubble ui 会映射到端口 12000 上

# 检查 正在运行 Hubble UI 的 pod
$ kubectl get pods -n kube-system -l k8s-app=hubble-ui
# 查看详细标签
$ kubectl get pods -n kube-system -l k8s-app=hubble-ui --show-labels
# 查看网络映射
$ kubectl get pods -n kube-system -o wide -l 'k8s-app=hubble-ui'
# 查看 svc 状态
$ kubectl get svc -A | grep hubble-ui
```

> 这种部署模式 hubble ui 只能本地访问，当然你可以自己建立映射修改

## cilium 重要概念

### Cilium Endpoints 接入点

[endpoints](https://docs.cilium.io/en/latest/gettingstarted/terminology/#endpoints) 简单理解就是一个 Pod, 以及 pod 被分配的网络标识，简单理解为基本等价于 Kubernetes 的 endpoints, 但是包含的信息更多，在对象 `ciliumendpoints.cilium.io` 下

```bash
# 查看当前所有的 Cilium Endpoints
$ kubectl get ciliumendpoints.cilium.io -A
```

### Cilium Identity 身份

使 Cilium 能够高效工作的一个关键概念是 Cilium 的 [身份 Identity](https://docs.cilium.io/en/latest/gettingstarted/terminology/#identity) 概念

所有 Cilium Endpoints 都有一个基于标签的标识

Cilium 身份由标签决定，在整个集群中是唯一的

端点会被分配与端点安全相关标签相匹配的身份，也就是说，共享同一组安全相关标签的所有端点将共享相同的身份

与每个身份相关的唯一数字标识符会被 eBPF 程序用于网络数据路径中的快速查找，这也是 Hubble 能够提供 Kubernetes 感知网络可观察性的基础

当网络数据包进入或离开节点时，Cilium 的 eBPF 程序会将源地址和目标 IP 地址映射到相应的数字身份标识符，然后根据引用这些数字身份标识符的策略配置来决定应采取哪些数据路径行动

每个 Cilium Agent 负责通过观察相关 Kubernetes 资源的更新，用与节点上本地运行的端点相关的数字标识符更新与身份相关的 eBPF 映射

```bash
# 查看当前所有的 Cilium Identity
$ kubectl get ciliumidentities.cilium.io -A
```

## 验证部署可行性

### 部署最小demo

创建一个 Nginx 部署，再创建一个新的 NodePort 服务，并验证 Cilium 是否正确安装了该服务

创建 Nginx Deploy
```bash
$ cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
# 观察创建
$ kubectl get pods --watch
```

下一步，为这两个实例创建一个 NodePort 服务

```bash
$ kubectl expose deployment my-nginx --type=NodePort --port=80
service/my-nginx exposed

# 查看 NodePort 服务端口等信息
$ kubectl get svc my-nginx
NAME       TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
my-nginx   NodePort   10.43.209.89   <none>        80:30995/TCP   18s

# 借助 cilium service list 命令
# 可以验证 Cilium 的 eBPF kube-proxy 替代程序是否创建了新的 NodePort 服务
# 在本例中，创建了端口号为 30995 的服务
$ kubectl -n kube-system exec ds/cilium -- cilium service list
...
21   10.43.209.89:80      ClusterIP      1 => 10.42.0.202:80 (active)
                                         2 => 10.42.1.188:80 (active)

# 使用主机名空间中的 iptables 验证是否存在针对该服务的 iptables 规则
$ sudo iptables-save | grep KUBE-SVC
...
-A KUBE-SERVICES -d 10.43.209.89/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-L65ENXXZWWSAPRCR
...
-A KUBE-SVC-L65ENXXZWWSAPRCR ! -s 10.42.0.0/16 -d 10.43.209.89/32 -p tcp -m comment --comment "default/my-nginx cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ

```

### 使用 curl 对 NodePort ClusterIP PodIP 等进行测试

```bash
# 获取 svc my-nginx 端口号
$ node_port=$(kubectl get svc my-nginx -o=jsonpath='{@.spec.ports[0].nodePort}')
# 测试通断
# localhost+NodePort
$ curl 127.0.0.1:$node_port
# eth0+NodePort
$ curl 192.168.50.56:$node_port
# ClusterIP
$ curl 10.43.209.89:80
# 本机 PodIP
$ curl 10.42.0.202:80
# 其他 Node PodIP
$ curl 10.42.1.188:80
```

> 最后 2 条能访问到也是因为之前启用了本地路由(Native Routing)的原因

### 移除验证部署

```bash
$ kubectl delete svc my-nginx
$ cat << EOF | kubectl delete -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
```

## 卸载快速上手环境

- 这里提供完整的卸载上手环境的流程，也可以拆分成不同模块的实验前 清理环境的方法

```bash
## 移除 hubble
# remove cilium hubble
$ cilium hubble disable

## 卸载 cilium
# remove cilium install by cli
$ cilium uninstall

# 如果已经移除 cilium 则不需要在其他节点执行 上面的移除

## 删除 cilium 节点网络配置
# 删除前确认状态
$ cilium status
    /¯¯\
 /¯¯\__/¯¯\    Cilium:             1 errors
 \__/¯¯\__/    Operator:           disabled
 /¯¯\__/¯¯\    Envoy DaemonSet:    disabled (using embedded mode)
 \__/¯¯\__/    Hubble Relay:       disabled
    \__/       ClusterMesh:        disabled
...

# k3s下必须手动删除 cilium_host、cilium_net 和 cilium_vxlan 接口
# 如果不这样做，你可能会在 K3s 停止时丢失与主机的网络连接
$ sudo ip link delete cilium_host
$ sudo ip link delete cilium_net
$ sudo ip link delete cilium_vxlan
# 确认删除 与主机的网络连接
$ ip link show | grep cilium
# 并且 需要删除 cilium 的 iptables 规则
$ sudo iptables-save | grep -iv cilium | sudo iptables-restore
$ sudo ip6tables-save | grep -iv cilium | sudo ip6tables-restore
# 确认删除
$ sudo iptables-save | grep cilium
$ sudo ip6tables-save | grep cilium

## 可选，删除部署的 KUBE 防火墙规则
$ sudo iptables-save | grep -iv 'KUBE-' | sudo iptables-restore
$ sudo ip6tables-save | grep -iv 'KUBE-' | sudo iptables-restore
$ sudo iptables-save | grep 'KUBE-'
$ sudo ip6tables-save | grep 'KUBE-'

## 卸载 k3s 节点
# 确认上面的执行完成后 agent 卸载
$ /usr/local/bin/k3s-agent-uninstall.sh
# 确认上面的执行完成后 server 卸载
$ /usr/local/bin/k3s-uninstall.sh
```

## 写在最后

- 快速上手是更好的理解 cilium 环境，和做各种试验，不是`生产环境使用的部署方式`
- 需要更好的网络性能，需要优化 cilium 部署，在后面的文章告知优化方案
- 卸载 k3s with cilium 一定要注意清理 cilium ip link 和防火墙规则
