---
title: "Kubernetes 技巧"
date: 2024-02-20T21:43:02+08:00
description: "k8s 常用命令 常用技巧"
draft: false
categories: ['container']
tags: ['container', 'kubernetes', 'kubectl']
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

## 获取帮助详细信息

```bash
# 查看帮助信息和help类似，尤其是资源清单的结构字段信息
$ kubectl explain po

# 查看帮助信息，资源下的 cpu 和 memory 等，每个配置项都有详细的网页手册地址
$ kubectl explain Deployment.spec.template.spec.containers.resources
```

可以安装 [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 开启插件

- `docker`
- `docker-compose`
- `kubectl`
- `helm`

获取更舒服的日常操作体验

## Kubernetes 常用命令行缩写

| 名称         | 缩写   | Kind        |
| ------------ | ------ | ----------- |
| namespace    | ns     | Namespace   |
| nodes        | no     | Node        |
| pods         | po     | Pod         |
| services     | svc    | Service     |
| deployment   | deploy | Deployment  |
| replicasets  | rs     | ReplicaSet  |
| statefulsets | sts    | StatefulSet |

## Pod 日志技巧

```bash
# 需要找出 Pod 的名称或与 Pod 关联的标签
$ kubectl get pods --show-labels

# 获取所有在 ns default 下的 Pod 的 IP 信息
$ kubectl get pods -o=custom-columns=NAME:.metadata.name,Node-IP:.status.hostIP,Pod-IP:.status.podIP -n default

#获取整个k8s node和podip关联信息，命令如下
$ kubectl get pods --all-namespaces -o=custom-columns=NAME:.metadata.name,Node-IP:.status.hostIP,Pod-IP:.status.podIP

# 从 Pod 获取日志
$ kubectl logs <podName>

# 如果 Pod 之前发生过崩溃，您可以通过以下方式访问上一个 Pod 的日志
$ kubectl logs --previous <podName>

# 如果一个 Pod 有多个副本，并且具有关联的标签（例如 app=my-app）
# 可以使用它来查看来自具有该标签的所有 Pod 的日志
$ kubectl logs -l app=my-app
```

获取最近日志

```bash
# 只获取 Pod 的最近 100 行日志
$ kubectl logs --tail=100 <podName>

# 显示最近一小时写入的 Pod 日志
$ kubectl logs --since=1h <podName>

# 在最近 15 分钟内
$ kubectl logs --since=15m <podName>
```

实时跟踪日志

```bash
# 实时跟踪来自 Pod 的日志
$ kubectl logs -f <podName>

# 实时跟踪 Pod 的最近 100 行日志
$ kubectl logs --tail=100 -f <podName>
```

## 资源类

### 常用获取资源方式

```bash
# 查看pod信息
kubectl get pods
# 已监控方式查看pod信息，有新的创建和销毁会立刻打印出来
kubectl get pods -wide
# 查看pod详细信息
kubectl get pods -o wide
# 查看node详细信息
kubectl get nodes -o wide
# 列出所有的namespace
kubectl get namespaces
# 查看rc和service列表
kubectl get rc,service
# 获取指定控制器pod信息
kubectl get deployment

# 查看kube-system命名空间中pod信息
kubectl get pods -n kube-system
# 查看pod的yaml信息
kubectl get pods/podName -o yaml
```

### 描述资源

```bash
# 获取详细资源清单信息（包括CPU和Memory）
kubectl describe node nodeName
# 获取详细资源清单信息（包括错误信息和实时状态）
kubectl describe po podName
```

### 进入容器

```bash
# 进入pod容器，但是对权限要求也较多
kubectl exec -it podName sh
# 通过bash获得Pod中某个容器的TTY，相当于登录容器
kubectl exec -it podName -c containerName bash
# 获取实时的logs信息
kubectl attach podName
```

### 创建资源

```bash
# 根据yaml文件创建
kubectl create/apply -f yamls/sonar.yaml
# 多个yaml文件创建
kubectl create/apply -f yamls/
# 根据yaml配置文件一次性创建service和rc
kubectl create/apply -f my-service.yaml -f my-rc.yaml
```

### 删除资源

```bash
# 删除指定pod
kubectl delete -f yamls/sonar.yaml
# 删除多个pod 通过目录下的配置文件
kubectl delete -f yamls/

# 删除指定pod
kubectl delete pods podName
# 强制删除pod
kubectl delete pod podName --force --grace-period=0
# 有控制器的pod不能直接删除，需先删除其控制器
kubectl delete deployment ControllerName
# 删除所有包含某个label的Pod和service
kubectl delete pods,services -l name=labelName

# 删除所有Pod
kubectl delete pods --all
```

### 标签匹配和设置

```bash
kubectl get pods --show-labels
# 多个标签同时满足条件
kubectl get pods --show-labels -l env=dev,tie=front
# [in,notin]
kubectl get pods --show-labels -l 'env in (dev,test)'

# 设置标签 env=test
kubectl label pods podName env=test
# 若env标签存在，强制设置标签 env=test
kubectl label pods podName env=test --overwrite
# 删除podname中env标签
kubectl lable pods podName env-
```

## service相关

### 创建service

```bash
kubectl expose pod podName [--port=80 --target-port=8000]
kubectl expose deployment deployName [--port=80 --target-port=8000]
```

## 维护相关

### 扩缩容

```bash
# 执行扩缩容Pod的操作
kubectl scale deployment deployName --replicas=3
# 设置pod数量在2到10之间
kubectl autoscale deployment deployName --min=2 --max=10
# pod数量在1到5之间，目标CPU利用率为80%
kubectl autoscale deployment deployName --max=5 --cpu-percent=80
```

### 在线设置镜像版本

```bash
# 设置 nginx 镜像为 1.23 版本
kubectl set image deployment/nginx nginx=nginx:1.23
# 编辑yaml文件修改
kubectl edit deployment/nginx
# 执行滚动升级操作
kubectl rolling-update deployment deployName -f redis-rc.update.yaml
```

![](https://kubernetes.io/images/docs/kubectl_rollingupdate.svg)

### 升级和回滚操作

```bash
# 显示deployment的详情
kubectl rollout history deployment deployName
# 显示版本3 deployment的详情
kubectl rollout history deployment deployName --revision=3
# 回滚到上一个版本
kubectl rollout undo eployment/deployName
# 回滚到第3个版本
kubectl rollout undo eployment/deployName --to-revision=3
# 回滚到上一个版本，dry-run 模式，实际不执行回滚
kubectl rollout undo --dry-run=true eployment/deployName
```

## 多集群相关

```bash
# 获取k8s集群信息
kubectl cluster-info
# 获取k8s集群管理配置信息，也就是 .kube/config 文件内容
kubectl config view
# 查看集群名称的context
kubectl config get-contexts
# 设置上下文
kubectl config set-context 上下文名称 --user=minikube --cluster=minikube --namespace=demo
# 切换到名称为 minikube 的集群中
kubectl config set current-context minikube
# 切换到名称为 minikube 的集群中
kubectl config use-context minikube
```

### 设置集群角色

```bash
# 设置 test1 为 master 角色
kubectl label nodes test1 node-role.kubernetes.io/master=
# 设置 test2 为 node 角色
kubectl label nodes 192.168.0.92 node-role.kubernetes.io/node=
# 设置 master 一般情况下不接受负载
kubectl taint nodes test1 node-role.kubernetes.io/master=true:NoSchedule
# master运行pod
kubectl taint nodes test1 node-role.kubernetes.io/master-
# master不运行pod
kubectl taint nodes test1 node-role.kubernetes.io/master=:NoSchedule
```

## 查看集群和版本相关信息

```bash
# 显示客户端和服务器侧版本信息
kubectl version
# 列出当前版本的kubernetes的服务器端所支持的api版本信息
kubectl api-versions
# 获取k8s集群信息
kubectl cluster-info
# 获取k8s集群管理配置信息，也就是 .kube/config 文件内容
kubectl config view
```

## 设置kubectl shell命令自动补全

- REHL

```bash
kubectl completion -h
sudo yum -y install bash-completion

source /usr/share/bash-completion/bash_completion
type _init_completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```

 嫌麻烦的，安装 [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 开启插件即可
