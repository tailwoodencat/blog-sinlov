---
title: "ubuntu gnome-shell 进程占用内存过多的问题"
date: 2023-06-15T09:57:57+08:00
description: "gnome 桌面内存泄露 导致设备假死 "
draft: false
categories: ['basics']
tags: ['basics', 'ubuntu', 'gnome']
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

## 检查内存占用

```bash
# 查看当前 进程占用实际物理内存 最高的 2 个进程信息
$ ps -e -o 'pid,comm,pcpu,rsz,vsz,stime,user,uid,args' | sort -k4nr | head -n 2
4136873 gnome-shell      4.6 13045948 19226972 Jan29 work 1000 /usr/bin/gnome-shell
4137680 gjs              0.9 560220 3539720 Jan29 work   1000 gjs /usr/share/gnome-shell/extensions/ding@rastersoft.com/ding.js -E -P /usr/share/gnome-shell/extensions/ding@rastersoft.com -M 0 -D 0:0:1920:1080:1:27:0:74:0:0

# 查看当前占用
- rsz：进程占用实际物理内存
- vsz：进程占用实际虚拟内存
- res：进程占用的物理内存
- ves：进程占用的虚拟内存

$ ps -e -o 'pid,comm,rsz,vsz,stime,user,uid,args' | grep gnome-shell
```

发现为 gnome 内存回收机制存在 bug 导致内存泄露

一段时间后 gnome-shell 会占用系统中大量的内存，甚至导致设备假死，只能强行断电源解决

## 临时解决方法

通过系统命令重启gdm服务后内存会被释放，问题可以暂时得到解决

> 注意：重启gdm服务就是重启图形界面
> 如果图形界面中有运行任何任务，请不要执行
> 否则图形界面中运行的任何任务都会中断

```bash
$ if [ "$(systemctl get-default)" = "graphical.target" ] ; then echo "now in graphical" && sudo systemctl restart gdm.service ; else echo "now not graphical"; fi

$ if [ "$(systemctl get-default)" = "graphical.target" ] ; \
 then echo "now in graphical" && sudo systemctl restart gdm.service ; \
 else echo "now not graphical"; \
fi
```

### 或者配置定时任务重启

- 创建定时脚本 `/opt/cron-system-task/gdm-auto-restart`

```bash
$ sudo mkdir -p /opt/cron-system-task
$ sudo vim /opt/cron-system-task/gdm-auto-restart
```

- 内容为

```bash
#!/bin/sh

if [ "$(systemctl get-default)" = "graphical.target" ] ; then
  echo "== gdm-auto-restart restart gdm service at: ${date}"
  systemctl restart gdm.service
else
  echo "== gdm-auto-restart not in graphical"
fi
```

- 添加 cron

```bash
$ sudo chmod +x /opt/cron-system-task/gdm-auto-restart
# 查看当前任务
$ sudo crontab -l
$ export EDITOR=vim && sudo crontab -e
```

- 新增一条 每天 05 点 重启图形服务

```bash
0 5 * * * root sh /opt/cron-system-task/gdm-auto-restart 2>&1

# no log
0 5 * * * root sh /opt/cron-system-task/gdm-auto-restart >/dev/null 2>&1
```

- 重启 cron 服务生效

```bash
$ sudo service cron restart
# 查看 cron 状态
$ sudo service cron status
```

开启 cron 日志

```sh
# 修改rsyslog服务，将 /etc/rsyslog.conf 文件中的
# ubuntu 18.04 日志配置在 /etc/rsyslog.d/50-default.conf
#cron.* 前的 # 删掉；用以下命令重启rsyslog cron
$ sudo service rsyslog restart
$ sudo service cron restart
# 位置 /var/log/cron.log 就可以查看定时任务的文件日志文件
$ tail -f /var/log/cron.log
# 查看运行时的日志文件，如果在日志文件中执行一条语句后出现：
　　No MTA installed, discarding output

# 则crontab执行脚本时是不会直接错误的信息输出
# 可以在执行后面加入 >/dev/null 2>&1 即可解决
```

## 切换图形字符服务

### 关闭图形界面服务

如果不需要使用gnome图形界面服务，可以使用以下方法关闭

```bash
$ sudo systemctl status gdm.service
$ sudo systemctl stop gdm.service
$ sudo systemctl disable gdm.service
$ sudo systemctl daemon-reload
# 当前立即进入字符模式
$ sudo systemctl set-default multi-user.target
```

### 打开图形界面服务

```bash
$ sudo systemctl start gdm.service
$ sudo systemctl enable gdm.service
$ sudo systemctl daemon-reload
$ sudo systemctl status gdm.service
# 设置为图形模式
$ sudo systemctl set-default graphical.target
```

## 扩展

### 查找有问题的 gnome-shell-extension

- 安装扩展管理器

```bash
sudo apt install gnome-shell-extensions
```

- 重启后，进入管理器

![gome-shell-extendsions-E49zJL](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/06/15/gome-shell-extendsions-E49zJL.png)

- 管理扩展

- 在线安装新扩展 [https://extensions.gnome.org/?ref=itsfoss.com](https://extensions.gnome.org/?ref=itsfoss.com)

```bash
# 查看已经安装的扩展
$ apt list --installed | grep gnome-shell
# 查看当前扩展运行状态
$ ps -e -o 'pid,comm,rsz,vsz,stime,user,uid,args' | grep gnome-shell
```

###  Ubuntu 22.04 LTS 高内存占用自动清理

> Ubuntu 22.04 LTS 版本带来一项新功能：默认启用 systemd-oomd 作为内存不足时的守护进程，它可以在内存高压的情况下干掉一部分进程

```bash
# 查看状态
$ systemctl status systemd-oomd
```

- 条件 1：当总系统的内存使用量和交换使用量都超过 SwapUsedLimit（在 Ubuntu 上默认为 90%）， cgoups 中超过 5% 的交换就会成为 OOM 的终结对象
- 条件 2：当一个单元的 cgroup 内存压力超过 MemoryPressureLimit ，则监控后代 cgroups 将从具有最多回收率的进程开始执行终止

> 很不幸，gnome-shell 导致的内存泄露，systemd-oomd 也来不及处理，导致系统崩溃
