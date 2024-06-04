---
title: "UGOS Pro ssh 密钥登陆"
date: 2024-06-04T11:50:23+08:00
description: "UGOS Pro ssh 密钥登陆 及 注意事项"
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

## 系列文章规约

注意：新手第一次使用 linux 命令，有几个约定

- 约定1: `$` 开头 表示需要执行的命令，`$` 空格后的内容复制到终端执行即可，不需要包括开头的 `$`

- 约定2: 终端的文本编辑，默认使用 vi 或者 vim ，不会的请自行学习，这里不讲解使用方法

## 环境

```bash
$ cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
OS_VERSION=1.0.0.0760
BUILD_ID=1.00.0760
```

## 准备

### 开启 ssh 支持

- 在 UGOS 系统的 WebUI 中，打开
- `控制面板` -> `终端机`
- `ssh`下
  - 勾选 `启动`
  - 端口可不用修改保持 `22`
  - `高级设置`
    - `SSH加密算法` 选择 `中`
    - `访问限制` 勾选 `仅允许本地网络内SSH访问`
    - `SFTP服务` 勾选 `启动`

应用设置即可

### 启用用户文件夹

- 在 UGOS 系统的 WebUI 中，打开
- `控制面板` -> `用户管理`
- 选择一个用户，右侧 `操作` 三个点，点击展开菜单中，点击 `编辑`
- 选项卡 `基础信息`，下拉
	- 勾选 `启用TA的个人文件夹`

### 尝试登陆NAS

```bash
# <user> 更换为你的用户
# <nas-ip> 更换你的NAS IP 地址
$ ssh <user>@<nas-ip>
# 输入密码进入NAS服务器
```

#### 修改 ssh 服务配置

>  tips: 非必需，如果是第一次使用，请不要修改

```bash
$ sudo vi /etc/ssh/sshd_config
#PubkeyAuthentication yes

# 修改为
PubkeyAuthentication yes

## 不建议修改这个
# 效果为禁止用户密码登陆
PasswordAuthentication no

# 重启ssh服务生效
$ sudo service ssh reload
```

## 配置 ssh 公钥

- 在客户端生成公钥私钥对
	- `dxp8800plus-xxx` 修改为 你自己的公钥别名

```bash
# 进入客户端 ~/.ssh 目录
$ cd ~/.ssh

## 生成的密钥对在 ~/.ssh 目录
$ ssh-keygen -m PEM -t rsa -b 4096 -C "dxp8800plus-xxx"
# 再次输入 dxp8800plus-xxx
# 如果需要密钥密码，再次输出2次密码即可
# 完成后，会生成 2个文件
# dxp8800plus-xxx     这个为 私钥
# dxp8800plus-xxx.pub 这个为 公钥

# 检查私钥信息
$ ssh-keygen -lf dxp8800plus-xxx
# 查看公钥信息
$ cat dxp8800plus-xxx.pub
```

- 在 nas 服务器配置公钥

```bash
mkdir ~/.ssh
vi ~/.ssh/authorized_keys
# 输入公钥内容，一行为一个公钥配置
chmod 644 ~/.ssh/authorized_keys
```

- 在 ssh 客户端 配置连接，在客户端目录 `~/.ssh` 下，修改或者创建文件 `config` 内容为
	- `Host` 为别名
	- `HostName` 为网络连接地址
	- `Port` 为 ssh 端口
	- `User` 中 `<user>` 改为你的用户名
	- `IdentityFile` ，路径使用 私钥的路径，这里配置为 客户端的 `$HOME/.ssh/` 下成对的私钥路径

```conf
Host dxp8800plus-xxx
  HostName 192.168.50.100
  Port 22
  User <user>
  IdentityFile ~/.ssh/dxp8800plus-xxx
```

有多个配置例子为

```conf
Host dxp4800plus-01
  HostName 192.168.50.101
  Port 22
  User <user>
  IdentityFile ~/.ssh/dxp4800plus-01
Host dxp4800plus-02
  HostName 192.168.50.102
  Port 22
  User <user>
  IdentityFile ~/.ssh/dxp4800plus-02
```

### 修复用户 home 目录权限

- 在 nas 服务端，需要修复 用户 home 目录权限才能访问
- 先验证修改权限效果

```bash
# 检查当前 HOME 目录
$ ls ~

# 逐条 修改 home 权限
$ chmod go-w ~
$ chmod 700 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```

#### 每次开机生效

- 需要修复 home 权限脚本
- 执行 `sudo vi /usr/local/bin/fix-git-ownership-for-user-home.sh`
- 添加脚本 内容为

```bash
#!/bin/bash

want_fix_home_root_path=$1

if [ -z "${want_fix_home_root_path}" ]; then
    echo "want_fix_home_root_path is empty"
    exit 1
fi

while [ ! -d ${want_fix_home_root_path} ] ; do
    sleep 10
done

chmod go-w ${want_fix_home_root_path}
chmod 700 ${want_fix_home_root_path}/.ssh
chmod 600 ${want_fix_home_root_path}/.ssh/authorized_keys

echo "fix done at path: ${want_fix_home_root_path}"
```

- 测试修复脚本效果

```bash
# 替换 /home/sinlov 为你的用户根目录，注意不要加最后的 /
bash /usr/local/bin/fix-git-ownership-for-user-home.sh /home/sinlov
# 输出为这个为正常
fix done at path: /home/sinlov
```

- 在用户的 crontab  中添加开机任务

```bash
# 这里给当前用户开启一个开机任务
sudo crontab -e -u $USER
```

- 新增内容为

```rc
## change user folder ownership for ssh connect，when reboot by this user
@reboot bash /usr/local/bin/fix-git-ownership-for-user-home.sh /home/sinlov
```

- 验证当前用户是否添加了一个任务

```bash
crontab -l
```

- 确认添加好了，生效

```bash
sudo systemctl restart cron
# 查看 cron 日志
sudo journalctl -u cron
```

### 验证 ssh 登陆

- 客户机 配置好 `~/.ssh/config` 文件后执行
  - `<Host>` 替换为 config 文件对应的 host 配置即可

```bash
$ ssh -vT <host>
# 连接正常有显示
debug1: Entering interactive session
```

> tips: 如果登陆有问题，去服务器查看 ssh 登陆日志
> 日志查看命令 `sudo tail -f /var/log/auth.log`