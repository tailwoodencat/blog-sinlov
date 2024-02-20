---
title: "k3s 集群学习环境搭建"
date: 2024-02-20T21:39:43+08:00
description: "k3s 学习环境搭建 k3s 集群部署 基础工具安装"
draft: false
categories: ['container']
tags: ['container', 'kubernetes', 'k3s']
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

[TOC]

## 阅读前说明

- 使用本文前，`必须熟悉 linux 操作系统基础操作`，`知道容器技术`，或者 `熟练使用 docker-ce`，否则很多基础操作问题，本文不会讲解
- 本文是针对 k3s 集群部署，目标是学习使用 k8s，前置条件是 至少 3 台 虚拟机，或者 3台实体机
	- 目前云原生生态上，宿主操作系统 建议使用 [Debian](https://www.debian.org)  或者 `ubuntu 22.04` ，建议使用更新的内核，防止有奇怪的问题产生，下面的操作就是基于 debian 11 来说明
	- 操作运维平面上还是分 server ( 管理服务节点) 和 agent（工作负载节点），所以建议 额外加一台 agent 机器
	- 集群中，每个节点从网络上是全部等效可见的，注意调整网络配置或者防火墙配置

## 介绍

### k3s 介绍

k3s 是 [rancher](https://github.com/rancher/k3s) 开源的一个 Kubernetes 发行版，并且对宿主的运行要求非常低，非常适合做 k8s 实验环境，和边缘技术服务的基建

> k3s包含了k8s的所有基础功能，而k8s附加功能其实大多数情况也用不到

- k3s v1.24 后，默认容器运行时，使用 [containerd](https://containerd.io/)
- 中文文档 [https://docs.k3s.io/zh/installation](https://docs.k3s.io/zh/installation)
	- [k3s 版本 v1.28.X  更新日志](https://docs.k3s.io/release-notes/v1.28.X)

## 安装前准备

- `不感人的网络`，这个做技术都懂
- server 节点需要较高配置 2C 8G 以上
- 多节点 server 至少 3个 以上，满足最低要求，并保证正常运作的数量为奇数，防止脑裂现象
- 提前安装好 `docker-ce` 用于测试镜像，跟 k3s 不会冲突
- 提前配置好 `harbor` 用于快速拉取镜像，并确认获取 harbor 的 `harbor.crt` 证书(可选)
- 配置 hosts `k3s-master.local` (可选)

- 每台设备需要预留的端口
	- k3s 需要 `6443` 端口才能被所有节点访问
 	    - 使用 Flannel VXLAN 时，节点需要能够通过 UDP 端口 `8472` 访问其他节点
 	    - 如果要使用 Metrics Server，所有节点必须可以在端口 `10250` 上相互访问
 	    - 使用 Flannel Wireguard 后端时，节点需要能够通过 UDP 端口 `51820` 和 `51821`（使用 IPv6 时）访问其他节点
		- 嵌入式 etcd 来实现高可用性，则 Server 节点必须可以在端口 `2379` 和 `2380` 上相互访问


### k3s 各节点的入站规则

| 协议 | 端口 | 源 | 目标 | 描述 |
|----------|-----------|-----------|-------------|------------
| TCP | 2379-2380 | Servers | Servers | 只有具有嵌入式 etcd 的 HA 需要 |
| TCP | 6443## k3s 结构

- `k3s server` 控制平面，control plane 和数据存储组件由 K3s 管理
- `k3s agent` 工作节点，不具有任何数据存储或 control plane 组件

所以按照不同 工作节点，安装会不一样

| 协议 | 端口 | 源 | 目标 | 必需 | 描述 |
|----------|-----------|-----------|-------------|------------|------------
| TCP | 2379-2380 | Servers | Servers | 否 | 只有具有嵌入式 etcd 的 HA 需要 |
| TCP | 6443 | Agents | Servers | 是 | K3s supervisor 和 Kubernetes API Server |
| UDP | 8472 | 所有节点 | 所有节点 | 否 | 只有 Flannel VXLAN 需要 |
| TCP | 10250 | 所有节点 | 所有节点 | 是 | Kubelet 指标 |
| TCP | 10257 | Servers | Servers | 是 | k3s 监控端口 |
| TCP | 10259 | Servers | Servers | 是 | k3s 监控端口 |
| TCP/UDP | 20000-39999 | 所有节点 | 所有节点 | 否 | service-node-port-range 对外映射端口 |
| UDP | 51820 | 所有节点 | 所有节点 | 否 | 只有使用 IPv4 的 Flannel Wireguard 才需要 |
| UDP | 51821 | 所有节点 | 所有节点 | 否 | 只有使用 IPv6 的 Flannel Wireguard 才需要 |

## k3s 结构

- `k3s server` 控制平面，control plane 和数据存储组件由 K3s 管理
- `k3s agent` 工作节点，不具有任何数据存储或 control plane 组件

所以按照不同 工作节点，安装会不一样

### 节点数据存储

- `三个或多个 Server` 节点为 Kubernetes API 提供服务并运行其他 control plane 服务
- `外部数据存储` 这里使用 `etcd`
- 下面是 查看每个节点的基础信息所用到的命令

```bash
$ ip addr
$ lscpu
$ lsmem
$ uname -a
$ docker version
```

### 配置部署计划

|  主机名 |   类型 |           IP地址 |         系统 |   配置 |      网络 |
|---------|--------|------------------|--------------|--------|-----------|
| server1 | server | 192.168.50.55/24 |  Debian 11 | 4C16G | inner:NAT |
| server2 | server | 192.168.50.56/24 |  Debian 11 | 4C16G | inner:NAT |
| server3 | server | 192.168.50.60.24 |  Debian 11 | 4C16G | inner:NAT |
|  agent1 |  agent | 192.168.50.54/24 | Debian 11  |  2C8G | inner:NAT |

### 安装 k3s server

- 安装官方文档 [https://docs.k3s.io/quick-start](https://docs.k3s.io/quick-start)

只执行了一个命令即部署了一套 all in one k3s 单节点环境，相对 k8s 无需额外安装如下组件

- kubelet
- kube-proxy
- containerd
- etcd
- ingress

#### 嵌入式 etcd 的 HA K3s 集群

启动一个带有 cluster-init 标志的 Server 节点来启用集群和一个令牌，该令牌将作为共享 secret，用于将其他 Server 加入集群
这个令牌设置到环境变量 `K3S_TOKEN`

```bash
# 生成 K3S_TOKEN 后面会用到
$ ENV_GEN_K3S_TOKEN=$(openssl rand -hex 32)
$ echo "ENV_GEN_K3S_TOKEN=${ENV_GEN_K3S_TOKEN}"
```

有几个配置标志在所有 Server 节点中必须是相同的:

- flag 文档见 [https://docs.k3s.io/cli/server](https://docs.k3s.io/cli/server)
- 网络相关标志：`--cluster-dns`、`--cluster-domain`、`--cluster-cidr`、`--service- cidr`
- 控制某些组件部署的标志：`--disable-helm-controller`、`--disable-kube-proxy`、`--disable-network-policy` 和任何传递给 `--disable` 的组件
- 功能相关标志：`--secrets-encryption`

- 私有 docker 仓库相关 `--tls-san` 设置 加其他主机名或 IPv4/IPv6 地址作为 Subject Alternative Name
	-  需要预先将 `harbor-domain.crt` 复制到  `/etc/rancher/k3s/` 下 具体见 [private-registry](https://docs.k3s.io/installation/private-registry) 如果没有可以去掉这个配置

注意使用内网 ip 或者 公网 ip 这里以 `192.168.50.56` 为 k3s server  第一个节点

```bash
# 设置主机上的其他非特权用户将能读取它，这个根据实际情况来（非必需）
$ export K3S_KUBECONFIG_MODE=644

# 设置 数据库连接环境变量（非必需）--cluster-init 为内嵌 etcd 模式
$ export K3S_DATASTORE_ENDPOINT=""

# 设置对外服务 ip （非必需）
$ export K3S_INSTALL_ADVERTISE_ADDRESS="192.168.50.56"

## 这些环境变量就是必须设置的

# 这里设置共享密钥用于将 server 或 agent 加入集群的令牌
# 生成令牌可以使用 openssl rand -hex 32
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
# 设置 首个 server 地址，用于其他节点加入
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.56"
# 设置私有 harbor 的域名或者 IP
$ export K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS="192.168.50.50"
# 设置安装版本 https://github.com/k3s-io/k3s/releases 版本
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1

## 设置安装命令
# 这个方式为 使用嵌入式 etcd 初始化新集群，设置 server 对外节点地址，设置配置文件位置
$ export INSTALL_K3S_EXEC="server --cluster-init --tls-san=${K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS} --kube-apiserver-arg service-node-port-range=20000-39999 --write-kubeconfig $HOME/.kube/config --write-kubeconfig-mode 0644"

# 例如 限制节点端口段，设置 server 对外节点地址，设置配置文件权限 禁止 traefik 设置 配置文件路径
$ export INSTALL_K3S_EXEC="server --kube-apiserver-arg service-node-port-range=20000-39999 --disable traefik --advertise-address=${K3S_INSTALL_ADVERTISE_ADDRESS} --write-kubeconfig $HOME/.kube/config --write-kubeconfig-mode 0644"

## 开始安装
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s -

# 添加其他参数
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s - \
  --tls-san <harbor_domain> \
  --advertise-address=${K3S_INSTALL_ADVERTISE_ADDRESS} \
  --system-default-registry registry.cn-hangzhou.aliyuncs.com

# 或者下载到本地 install-k3s.sh
$ curl -fL -o install-k3s.sh https://get.k3s.io
$ cat install-k3s.sh | INSTALL_K3S_MIRROR=cn sh -s - \
  --system-default-registry registry.cn-hangzhou.aliyuncs.com

## 安装有错误，卸载安装
$ /usr/local/bin/k3s-uninstall.sh

## 检查服务运行
$ systemctl status k3s.service
```

`--advertise-address=ip`很重要，对于公网来说需要指定，不然默认是内网ip

- 如果是云端部署，需要确认对外服务的地址（非必需）

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
$ kubectl get pods -A
# 确认基础节点运行正常
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   coredns-58c9946f4-5897r                   1/1     Running     0          3h25m
kube-system   helm-install-traefik-4h7xg                0/1     Completed   1          3h25m
kube-system   helm-install-traefik-crd-zlwb8            0/1     Completed   0          3h25m
kube-system   local-path-provisioner-58dc8976d6-vd4k8   1/1     Running     0          3h25m
kube-system   metrics-server-595fb6fd99-ltshj           1/1     Running     0          3h25m
kube-system   svclb-traefik-cb252de0-xbrdt              2/2     Running     0          3h25m
kube-system   traefik-d944fbf67-g8ltm                   1/1     Running     0          3h25m

$ kubectl get pods -n kube-system -o wide
```

#### 使用共享 secret 其他 k3s server 加入集群

- `ENV_GEN_K3S_TOKEN` 手动设置为第一台使用的，别到新设备还生成

```bash
# 设置 数据库连接环境变量 非必需 --cluster-init 为内嵌 etcd 模式
$ export K3S_DATASTORE_ENDPOINT=""

# 设置对外服务 ip 根据当前地址来设置
$ export K3S_INSTALL_ADVERTISE_ADDRESS="192.168.50.55"

# 设置安装版本 https://github.com/k3s-io/k3s/releases 版本 token, 首个 server 地址
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.56"
# 设置私有 harbor 的域名或者 IP
$ export K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS="192.168.50.50"
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1
# 设置主机上的其他非特权用户将能读取它
$ export K3S_KUBECONFIG_MODE=644

# 这个方式为 使用嵌入式 etcd 加入集群控制，限制节点端口段，设置 master 对外节点地址，设置配置文件位置
$ export INSTALL_K3S_EXEC="server --server https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443 --tls-san=${K3S_TLS_SUBJECT_ALTERNATIVE_NAME_HOSTS} --kube-apiserver-arg service-node-port-range=20000-39999 --write-kubeconfig $HOME/.kube/config --write-kubeconfig-mode 0644"

## 开始安装
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s - \
  --system-default-registry registry.cn-hangzhou.aliyuncs.com

## 安装有错误，卸载安装
$ /usr/local/bin/k3s-uninstall.sh

## 检查安装结果
$ systemctl status k3s.service

$ kubectl get pods -n kube-system
```

- 安装加入的控制平面后确认安装

```bash
$ kubectl get nodes
NAME        STATUS   ROLES                       AGE   VERSION
server1     Ready    control-plane,etcd,master   28m   vX.Y.Z
server2     Ready    control-plane,etcd,master   13m   vX.Y.Z
```

### 安装 k3s agent

> 使用k3s agent 添加更多的 worker node，只需要添加 `K3S_URL` 和 `K3S_TOKEN` 参数即可

- flag 文档见 [https://docs.k3s.io/cli/agent](https://docs.k3s.io/cli/agent)
- 工作节点配置参数

```bash
# work 节点安装 需要设置的环境变量
$ export K3S_TOKEN=${ENV_GEN_K3S_TOKEN}
$ export INSTALL_K3S_VERSION=v1.28.1+k3s1
$ export K3S_INSTALL_FIRST_ADVERTISE_ADDRESS="192.168.50.60"
$ export K3S_URL=https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443
# 安装配置，agent
$ export INSTALL_K3S_EXEC="agent --server https://${K3S_INSTALL_FIRST_ADVERTISE_ADDRESS}:6443"

# 开始安装
$ curl -sfL https://get.k3s.io | sh -
# 或者使用国内镜像安装
$ curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | \
  INSTALL_K3S_MIRROR=cn sh -s -

# 或者使用这个命令来，作为已有 master 的工作节点
$ k3s agent --server ${K3S_URL} --token ${K3S_TOKEN}

# 安装有错误，卸载 agent 安装
$ /usr/local/bin/k3s-agent-uninstall.sh
```

- 在管理节点查询节点状态

```bash
$ watch k3s kubectl get nodes -A

# or get
$ k3s kubectl get nodes -A
NAME             STATUS   ROLES                  AGE   VERSION
XXX      Ready    control-plane,etcd,master   17m   vX.Y.Z
XXX      Ready    control-plane,etcd,master   21m   vX.Y.Z
XXX      Ready    <none>                      12m   vX.Y.Z
```

## 配置镜像

k3s 可以使用 docker 的镜像，但是配置是单独的

- [https://docs.k3s.io/installation/private-registry?_highlight=registries.yaml#mirrors](https://docs.k3s.io/installation/private-registry?_highlight=registries.yaml#mirrors)

新建文件 `/etc/rancher/k3s/registries.yaml`

#### 使用 `dockerproxy.com` 镜像

```yml
mirrors:
  xxx.mirror.aliyuncs.com:
    endpoint:
      - "https://xxx.mirror.aliyuncs.com"
config:
  "xxx.mirror.aliyuncs.com":
    tls:
      cert_file:
      key_file:
      ca_file:
```

```bash
sudo mkdir -p /etc/rancher/k3s/
sudo tee /etc/rancher/k3s/registries.yaml <<-'EOF'
mirrors:
  docker.io:
    endpoint:
      - "https://xxx.mirror.aliyuncs.com"
      - "https://registry-1.docker.io"
config:
  "xxx.mirror.aliyuncs.com":
    tls:
      cert_file:
      key_file:
      ca_file:
EOF

# 生效配置
$ sudo systemctl daemon-reload && sudo systemctl restart k3s
# 节点
$ sudo systemctl daemon-reload && sudo systemctl restart k3s-agent
```

## 集群信息查看

### 查看 cluster

```bash
# 查看当前集群
$ kubectl cluster-info
```

### 查看 ingress

```bash
# 查看 ingress 状态
$ kubectl get ingress -o wide
```

### 查看 serviceaccounts

```bash
# 获取
$ k3s kubectl get serviceaccounts
```

## 基础工具 安装

### 配置 kuboard-press 简单 k8s 管理面板

- [https://github.com/eip-work/kuboard-press](https://github.com/eip-work/kuboard-press)
- [官方安装文档 for k8s](https://kuboard.cn/install/v3/install-in-k8s.html#%E5%AE%89%E8%A3%85)

```bash
# online install
$ kubectl apply -f https://addons.kuboard.cn/kuboard/kuboard-v3.yaml
# 等待安装完成
$ watch kubectl get pods -n kuboard
NAME                               READY   STATUS    RESTARTS         AGE
kuboard-etcd-b6hzv                 1/1     Running   1 (7m13s ago)    31m
kuboard-v3-664cc56698-5khvk        1/1     Running   13 (7m56s ago)   31m
kuboard-questdb-645fdcfddf-f7snq   1/1     Running   0                4m35s
kuboard-agent-68d66dcbd5-nvp62     1/1     Running   3 (3m24s ago)    4m35s
kuboard-agent-2-6bd4b646d9-nlv2m   1/1     Running   3 (3m24s ago)    4m35s
```

- 访问地址 [http://192.168.50.56:30080/](http://192.168.50.56:30080/)
- 默认帐户密码
  - admin
  - Kuboard123

#### 升级 kuboard 版本

- 版本来源 [https://hub.docker.com/r/eipwork/kuboard/tags](https://hub.docker.com/r/eipwork/kuboard/tags)

在 `kuboard -> 部署列表 -> kuboard-v3` 选择 `调整镜像版本` 即可

#### Kuboard v3 的卸载

- 执行 Kuboard v3 的卸载

```bash
$ kubectl delete -f https://addons.kuboard.cn/kuboard/kuboard-v3.yaml
```

在 master 节点以及带有 `k8s.kuboard.cn/role=etcd` 标签的节点上执行

```bash
rm -rf /usr/share/kuboard
```

### 本地存储提供程序

在部署需要保留数据的应用时，你需要创建持久存储。持久存储允许你在运行应用的 pod 之外存储应用数据。即使运行应用的 pod 发生故障，这种存储方式也能让你保留应用数据。

持久卷 (PV) 是 Kubernetes 集群中的一块存储，而持久卷声明 (PVC) 是对存储的请求
详细参考 [Kubernetes 存储相关的官方文档](https://kubernetes.io/docs/concepts/storage/volumes/)

#### k3s Local Storage Provider

K3s 自带 Rancher 的 [Local Path Provisioner](https://github.com/rancher/local-path-provisioner/blob/master/README.md#usage)，这使得能够使用各自节点上的本地存储来开箱即用地创建持久卷声明

- 创建一个 在命名空间 `default` 名为 `local-path-pvc` 支持的持久卷声明 `pvc.yaml`

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi
```

- 使用 命名空间 `default` 名为 `local-path-pvc` 作为存储 `pod.yaml`

```yml
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
  namespace: default
spec:
  containers:
  - name: volume-test
    image: nginx:stable-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: volv
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: volv
    persistentVolumeClaim:
      claimName: local-path-pvc
```

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

#### helm 警告 WARNING: Kubernetes configuration file

```
WARNING: Kubernetes configuration file is group-readable.
WARNING: Kubernetes configuration file is world-readable.
```

更改文件的权限为 `group-unreadable`，以提高安全性，但可能导致很多 非 root 用户使用集群功能出现问题，参考 [https://github.com/helm/helm/issues/9115](https://github.com/helm/helm/issues/9115)