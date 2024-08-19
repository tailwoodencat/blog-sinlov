---
title: "docker 容器 CPU memory 磁盘 资源限制"
date: 2024-08-20T00:48:51+08:00
description: "Docker container CPU memory disk resource limit"
draft: false
categories: ['container']
tags: ['container', 'docker']
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

## 背景

docker 作为容器的管理者，自然提供了控制容器资源的功能。正如使用内核的 namespace 来做容器之间的隔离，docker 也是通过内核的 cgroups 来做容器的资源限制；包括 CPU、内存、磁盘三大方面，基本覆盖了常见的资源配额和使用量控制。

Docker 内存控制 OOME 在 linxu 系统上，如果内核探测到当前宿主机已经没有可用内存使用，那么会抛出一个 OOME(Out Of Memory Exception: 内存异常)，并且会开启 killing 去杀掉一些进程。

一旦发生 OOME，任何进程都有可能被杀死，包括 docker daemon 在内，为此，docker 特地调整了 docker daemon 的 OOM_Odj 优先级，以免他被杀掉，但容器的优先级并未被调整。经过系统内部复制的计算后，每个系统进程都会有一个 OOM_Score 得分，OOM_Odj 越高，得分越高，（在 docker run 的时候可以调整 OOM_Odj）得分最高的优先被 kill 掉，当然，也可以指定一些特定的重要的容器禁止被 OMM 杀掉，在启动容器时使用 –oom-kill-disable=true 指定

## cgroup 简介

cgroup 是 Control Groups 的缩写，是 Linux 内核提供的一种可以限制、记录、隔离进程组所使用的物理资源 (如 cpu、memory、磁盘 IO 等等) 的机制，被 LXC、docker 等很多项目用于实现进程资源控制。cgroup 将任意进程进行分组化管理的 Linux 内核功能。cgroup 本身是提供将进程进行分组化管理的功能和接口的基础结构，I/O 或内存的分配控制等具体的资源管理功能是通过这个功能来实现的。这些具体的资源管理功能称为 cgroup 子系统，有以下几大子系统实现：

1. blkio：设置限制每个块设备的输入输出控制。例如: 磁盘，光盘以及 usb 等等
2. cpu：使用调度程序为 cgroup 任务提供 cpu 的访问
3. cpuacct：产生 cgroup 任务的 cpu 资源报告。
4. cpuset：如果是多核心的 cpu，这个子系统会为 cgroup 任务分配单独的 cpu 和内存。
5. devices：允许或拒绝 cgroup 任务对设备的访问。
6. freezer：暂停和恢复 cgroup 任务。
7. memory：设置每个 cgroup 的内存限制以及产生内存资源报告。
8. net_cls：标记每个网络包以供 cgroup 方便使用。
9. ns：命名空间子系统。
10. perf_event：增加了对每 group 的监测跟踪的能力，即可以监测属于某个特定的 group 的所有线程以及运行在特定 CPU 上的线程。

```bash
# 检测 cgroup 版本支持
$ grep cgroup /proc/filesystems
nodev	cgroup
nodev	cgroup2
# 显示支持 cgroup v1 v2

# 检测 cgroup 版本
$ mount | grep cgroup
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot)

cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime)
none on /run/cilium/cgroupv2 type cgroup2 (rw,relatime)

# cgroup2 就是 v2 版本
```

目前 docker 只是用了其中一部分子系统，实现对资源配额和使用的控制。

可以使用 stress 工具来测试 CPU 和内存。使用下面的 Dockerfile 来创建一个基于 Ubuntu 的 stress 工具镜像

```Dockerfile
FROM ubuntu:14.04 RUN apt-get update &&apt-get install stress
```

资源监控的关键目录：cat 读出  已使用内存：  /sys/fs/cgroup/memory/docker/应用ID/memory.usage_in_bytes

分配的总内存：  /sys/fs/cgroup/memory/docker/应用ID/memory.limit_in_bytes

已使用的 cpu：单位纳秒  /sys/fs/cgroup/cpuacct/docker/应用ID/cpuacct.usage

系统当前 cpu：

```bash
$ cat /proc/stat | grep 'cpu '（周期/时间片/jiffies）
#得到的数字相加/HZ（cat /boot/config-`uname -r` | grep '^CONFIG_HZ='
ubuntu 14.04为250）就是系统时间（秒）
#再乘以10*9就是系统时间（纳秒）
```

例子

```bash
$ cat /proc/stat
cpu 432661 13295 86656 422145968 171474 233 5346
cpu0 123075 2462 23494 105543694 16586 0 4615
cpu1 111917 4124 23858 105503820 69697 123 371
cpu2 103164 3554 21530 105521167 64032 106 334
cpu3 94504 3153 17772 105577285 21158 4 24
intr 1065711094 1057275779 92 0 6 6 0 4 0 3527 0 0 0 70 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
ctxt 19067887
btime 1139187531
processes 270014
procs_running 1
procs_blocked 0


输出解释
CPU 以及CPU0、CPU1、CPU2、CPU3每行的每个参数意思（以第一行为例）为：
参数 解释
user (432661) 从系统启动开始累计到当前时刻，用户态的CPU时间（单位：jiffies） ，不包含 nice值为负进程。
nice (13295) 从系统启动开始累计到当前时刻，nice值为负的进程所占用的CPU时间（单位：jiffies）
system (86656) 从系统启动开始累计到当前时刻，核心时间（单位：jiffies）
idle (422145968) 从系统启动开始累计到当前时刻，除硬盘IO等待时间以外其它等待时间（单位：jiffies）
iowait (171474) 从系统启动开始累计到当前时刻，硬盘IO等待时间（单位：jiffies） ，
irq (233) 从系统启动开始累计到当前时刻，硬中断时间（单位：jiffies）
softirq (5346) 从系统启动开始累计到当前时刻，软中断时间（单位：jiffies）
```

cpu 使用率：  （已使用 2 - 已使用 1）/（系统当前 2 - 系统当前 1）*100%

## 内存限制

Docker 提供的内存限制功能有以下几点：

- 容器能使用的内存和交换分区大小
- 容器的核心内存大小
- 容器虚拟内存的交换行为
- 容器内存的软性限制
- 是否杀死占用过多内存的容器
- 容器被杀死的优先级

一般情况下，达到内存限制的容器过段时间后就会被系统杀死

### 内存限制相关的参数

执行 `docker run` 命令时能使用的和内存限制相关的所有选项如下

| 参数 | 说明  |
|---|---|
| `-m,--memory`  | 内存限制，格式是数字加单位，单位可以为 b,k,m,g。最小为 4M |
| `--memory-swap`  |  内存 + 交换分区大小总限制。格式同上。必须比 `-m` 设置的大 |
| `--memory-reservation`  |  内存的软性限制。格式同上 |
| `--oom-kill-disable` | 是否阻止 OOM killer 杀死容器，默认未开启  |
| `--oom-score-adj`  | 容器被 OOM killer 杀死的优先级，范围是 `[-1000, 1000]`，默认为 0 |
| `--memory-swappiness` | 用于设置容器的虚拟内存控制行为。值为 0~100 之间的整数  |
| `--kernel-memory`  |  核心内存限制。格式同上，最小为 4M |

### 用户内存限制

用户内存限制就是对容器能使用的内存和交换分区的大小作出限制。
使用时要遵循两条直观的规则：

- `-m，--memory` 选项的参数最小为 4 M
- `--memory-swap` 不是交换分区，而是内存加交换分区的总大小，所以 `--memory-swap` 必须比 `-m,--memory` 大

在这两条规则下，一般有四种设置方式

> 你可能在进行内存限制的实验时发现docker run命令报错：
> WARNING: Your kernel does not support swap limit capabilities, memory limited without swap.
>
> 这是因为宿主机内核的相关功能没有打开。按照下面的设置就行。
>
>   step 1：编辑 /etc/default/grub 文件，将 GRUB_CMDLINE_LINUX 一行改为
>
>   GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
>
>   step 2：更新 GRUB，即执行  `sudo update-grub`
>
>   step 3: 重启系统

#### 不设置

容器默认可以用完宿舍机的所有内存和 swap 分区。不过注意，如果容器占用宿主机的所有内存和 swap 分区超过一段时间后，会被宿主机系统杀死 （如果没有设置 `--oom-kill-disable=true` 的话）

#### 设置-m,--memory，不设置--memory-swap

这种情况下，容器能使用的内存大小为 a，能使用的交换分区大小也为 a。因为 Docker 默认容器交换分区的大小和内存相同

> 如果在容器中运行一个一直不停申请内存的程序，你会观察到该程序最终能占用的内存大小为 2a

比如  `docker run -m 1G ubuntu:22.04`

该容器能使用的内存大小为 1G，能使用的 swap 分区大小也为 1G。容器内的进程能申请到的总内存大小为 2G

#### 设置- m,--memory=a，--memory-swap=b，且 b > a

a 时容器能使用的内存大小，b 是容器能使用的 内存大小 + swap 分区大小。

所以 b 必须大于 a。b -a 即为容器能使用的 swap 分区大小

比如$ `docker run -m 1G --memory-swap 3G ubuntu:22.04`

该容器能使用的内存大小为 1G，能使用的 swap 分区大小为 2G。容器内的进程能申请到的总内存大小为 3G

#### 设置-m,--memory=a，--memory-swap=-1

这种情况表示限制容器能使用的内存大小为 a，而不限制容器能使用的 swap 分区大小

这时候，容器内进程能申请到的内存大小为 a + 宿主机的 swap 大小

### Memory reservation

Memory reservation 是一种软性限制，用于节制容器内存使用。
给 `--memory-reservation` 设置一个比 `-m` 小的值后，虽然容器最多可以使用 `-m` 使用的内存大小，但在宿主机内存资源紧张时，在系统的下次内存回收时，系统会回收容器的部分内存页，强迫容器的内存占用回到 `--memory-reservation` 设置的值大小。

没有设置时（默认情况下）`--memory-reservation` 的值和 `-m` 的限定的值相同。将它设置为 0 会设置的比-m的参数大 等同于没有设置

Memory reservation 是一种软性机制，它不保证任何时刻容器使用的内存不会超过 `--memory-reservation` 限定的值，它只是确保容器不会长时间占用超过 `--memory-reservation` 限制的内存大小

例如：

```bash
$ docker run -it -m 500M --memory-reservation 200M ubuntu:22.04 /bin/bash
```

如果容器使用了大于 200M 但小于 500M 内存时，下次系统的内存回收会尝试将容器的内存锁紧到 200M 以下

而改为

```bash
$ docker run -it --memory-reservation 1G ubuntu:22.04 /bin/bash
```

容器可以使用尽可能多的内存。`--memory-reservation` 确保容器不会长时间占用太多内存

### OOM killer

默认情况下，在出现 `out-of-memory(OOM)` 错误时，系统会杀死容器内的进程来获取更多空闲内存。这个杀死进程来节省内存的进程，我们姑且叫它 OOM killer

我们可以通过设置 `--oom-kill-disable` 选项来禁止 OOM killer 杀死容器内进程。

但请确保只有在使用了 `-m/--memory` 选项时才使用 `--oom-kill-disable` 禁用 OOM killer

> 如果没有设置 `-m` 选项，却禁用了 OOM-killer，可能会造成出现 out-of-memory 错误时，系统通过杀死宿主机进程或获取更改内存。

例子

```bash
# 限制了容器的内存为 100M 并禁止了 OOM killer
$ docker run -it -m 100M --oom-kill-disable ubuntu:22.04 /bin/bash
```

一般一个容器只有一个进程，这个唯一进程被杀死，容器也就被杀死

我们可以通过 `--oom-score-adj` 选项来设置在系统内存不够时，容器被杀死的优先级

负值不可能被杀死，而正值更有可能被杀死

### 核心内存

核心内存和用户内存不同的地方在于核心内存不能被交换出

不能交换出去的特性使得容器可以通过消耗太多内存来堵塞一些系统服务

核心内存包括：

- stack pages（栈页面）
- slab pages
- socket memory pressure
- tcp memory pressure

可以通过设置核心内存限制来约束这些内存

> 例如，每个进程都要消耗一些栈页面，通过限制核心内存，可以在核心内存使用过多时阻止新进程被创建。

核心内存和用户内存并不是独立的，必须在用户内存限制的上下文中限制核心内存

假设用户内存的限制值为 U，核心内存的限制值为 K。有三种可能地限制核心内存的方式：

1. `U != 0`，不限制核心内存。这是默认的标准设置方式
2. `K < U`，核心内存时用户内存的子集。这种设置在部署时，每个 cgroup 的内存总量被过度使用。过度使用核心内存限制是绝不推荐的，因为系统还是会用完不能回收的内存。在这种情况下，你可以设置 K，这样 groups 的总数就不会超过总内存了。然后，根据系统服务的质量自有地设置 U
3. `K > U`，因为核心内存的变化也会导致用户计数器的变化，容器核心内存和用户内存都会触发回收行为。这种配置可以让管理员以一种统一的视图看待内存。对想跟踪核心内存使用情况的用户也是有用的。

例如：

```bash
# 容器中的进程最多能使用 500M 内存，在这 500M 中，最多只有 50M 核心内存
$ docker run -it -m 500M --kernel-memory 50M ubuntu:22.04 /bin/bash

# 未设置用户内存限制，所以容器中的进程可以使用尽可能多的内存，但是最多能使用 50M 核心内存
$ docker run -it --kernel-memory 50M ubuntu:22.04 /bin/bash
```

### Swappiness

默认情况下，容器的内核可以交换出一定比例的匿名页

`--memory-swappiness` 就是用来设置这个比例的

`--memory-swappiness` 可以设置为从 0 到 100

0 表示关闭匿名页面交换。100 表示所有的匿名页都可以交换。

默认情况下，如果不使用 `--memory-swappiness` ，则该值从父进程继承而来。

例如:

```bash
# 将 --memory-swappiness 设置为 0 可以保持容器的工作集，避免交换代理的性能损失
$ docker run --rm -it --memory-swappiness=0 ubuntu:22.04 /bin/bash

# 验证
$ docker run --rm -tid —name mem1 —memory 128m ubuntu:22.04 /bin/bash
$ cat /sys/fs/cgroup/memory/docker/<容器的完整ID>/memory.limit_in_bytes
$ cat /sys/fs/cgroup/memory/docker/<容器的完整ID>/memory.memsw.limit_in_bytes
```

## CPU 限制

Docker 的资源限制和隔离完全基于 Linux cgroups

对 CPU 资源的限制方式也和 cgroups 相同

Docker 提供的 CPU 资源限制选项可以在多核系统上限制容器能利用哪些 vCPU

而对容器最多能使用的 CPU 时间有两种限制方式：

1. 有多个 CPU 密集型的容器竞争 CPU 时，设置各个容器能使用的 CPU 时间`相对比例`
2. 绝对的方式设置容器在每个调度周期内`最多`能使用的 CPU 时间

### CPU 限制相关参数

docker run 命令和 CPU 限制相关的所有选项

| 参数  | 说明 |
|---|---|
| `--cpuset-cpus=""` | 允许使用的 CPU 集，值可以为 0-3,0,1 |
| `-c,--cpu-shares=0` | CPU 共享权值（相对权重）  |
| `cpu-period=0`  |  限制 CPU CFS 的周期，范围从 100ms~1s，即 `[1000, 1000000]` |
| `--cpu-quota=0` | 限制 CPU CFS 配额，必须不小于 1ms，即 >= 1000  |
| `--cpuset-mems=""`  | 允许在上执行的内存节点（MEMs），只对 [NUMA 系统](https://en.wikipedia.org/wiki/Non-uniform_memory_access)有效  |

其中

- `--cpuset-cpus` 用于设置容器可以使用的 vCPU 核
- `-c,--cpu-shares` 用于设置多个容器竞争 CPU 时，各个容器相对能分配到的 CPU 时间比例
- `--cpu-period` 和 `--cpu-quata` 用于绝对设置容器能使用 CPU 时间

### CPU 集

设置容器可以在哪些 CPU 核上运行

例如

```bash
# 容器中的进程可以在 cpu 1 和 cpu 3 上执行
$ docker run --rm -it --cpuset-cpus="1,3" ubuntu:22.04 /bin/bash

# 容器中的进程可以在 cpu 0、cpu 1 及 cpu 3 上执行
$ docker run --rm -it --cpuset-cpus="0-2" ubuntu:22.04 /bin/bash
$ cat /sys/fs/cgroup/cpuset/docker/<容器的完整长ID>/cpuset.cpus

## 在 NUMA 系统上，我们可以设置容器可以使用的内存节点
# 容器中的进程只能使用内存节点 1 和 3 上的内存
$ docker run --rm -it --cpuset-mems="1,3" ubuntu:22.04 /bin/bash
# 容器中的进程只能使用内存节点 0、1、2 上的内存
$ docker run --rm -it --cpuset-mems="0-2" ubuntu:22.04 /bin/bash
```

### CPU 资源的相对限制

默认情况下，所有的容器得到同等比例的 CPU 周期。在有多个容器竞争 CPU 时我们可以设置每个容器能使用的 CPU 时间比例

这个比例叫作`共享权值`，通过 `-c` 或 `--cpu-shares` 设置

Docker 默认每个容器的权值为 `1024`，不设置或将其设置为 0，都将使用这个默认值

系统会根据每个容器的共享权值和所有容器共享权值和比例来给容器分配 CPU 时间

> 假设有三个正在运行的容器，这三个容器中的任务都是 CPU 密集型的
>
> 第一个容器的 cpu 共享权值是 1024，其它两个容器的 cpu 共享权值是 512
>
> 第一个容器将得到 50% 的 CPU 时间，而其它两个容器就只能各得到 25% 的 CPU 时间了
>
> 如果再添加第四个 cpu 共享值为 1024 的容器，每个容器得到的 CPU 时间将重新计算
>
> 第一个容器的 CPU 时间变为 33%，其它容器分得的 CPU 时间分别为 16.5%、16.5%、33%


**必须注意的是，这个比例只有在 CPU 密集型的任务执行时才有用**

> 在四核的系统上，假设有四个单进程的容器，它们都能各自使用一个核的 100% CPU 时间，不管它们的 cpu 共享权值是多少

在多核系统上，CPU 时间权值是在所有 CPU 核上计算的

即使某个容器的 CPU 时间限制少于 100%，它也能使用各个 CPU 核的 100% 时间

例如

假设有一个不止三核的系统。用 `-c=512` 的选项启动容器 {C0}，并且该容器只有一个进程，用 `-c=1024` 的启动选项为启动容器C2，并且该容器有两个进程

CPU 权值的分布可能是这样的：

```
# 容器中的进程 CPU 份额值为 100

PID    container    CPU CPU share
100    {C0}     0   100
101    {C1}     1   100
102    {C1}     2   100
```

### CPU 资源的绝对限制

Linux 通过 CFS（Completely Fair Scheduler，完全公平调度器）来调度各个进程对 CPU 的使用。CFS 默认的调度周期是 100ms

> 关于 CFS 的更多信息，参考 [CFS documentation on bandwidth limiting](https://www.kernel.org/doc/Documentation/scheduler/sched-bwc.txt)

我们可以设置每个容器进程的调度周期，以及在这个周期内各个容器最多能使用多少 CPU 时间

- 使用 `--cpu-period` 即可设置调度周期
- 使用 `--cpu-quota` 即可设置在每个周期内容器能使用的 CPU 时间

两者一般配合使用

例如

```bash
# 将 CFS 调度的周期设为 50000，将容器在每个周期内的 CPU 配额设置为 25000，表示该容器每 50ms 可以得到 50% 的 CPU 运行时间
$ docker run --rm -it --cpu-period=50000 --cpu-quota=25000 ubuntu:22.04 /bin/bash

# 调整后验证
$ docker run --rm -it --cpu-period=10000 --cpu-quota=20000 ubuntu:22.04 /bin/bash
$ cat /sys/fs/cgroup/cpu/docker/<容器的完整长ID>/cpu.cfs_period_us
$ cat /sys/fs/cgroup/cpu/docker/<容器的完整长ID>/cpu.cfs_quota_us
```

将容器的 CPU 配额设置为 CFS 周期的两倍，CPU 使用时间怎么会比周期大呢？

其实很好解释，给容器分配两个 vCPU 就可以了

该配置表示容器可以在每个周期内使用两个 vCPU 的 100% 时间

CFS 周期的有效范围是 `1ms~1s`，对应的 `--cpu-period` 的数值范围是 `1000~1000000`

而容器的 CPU 配额必须不小于 `1ms`，即 `--cpu-quota` 的值必须  `>= 1000`

可以看出这两个选项的单位都是 us

### 正确的理解 绝对

注意前面我们用 `--cpu-quota` 设置容器在一个调度周期内能使用的 CPU 时间时实际上设置的是一个上限

并不是说容器一定会使用这么长的 CPU 时间

比如，我们先启动一个容器，将其绑定到 cpu 1 上执行。给其 --cpu-quota 和 --cpu-period 都设置为 50000

```bash
$ docker run --rm --name test01 --cpu-cpus 1 --cpu-quota=50000 --cpu-period=50000 deadloop99/hello-world
```

调度周期为 50000，容器在每个周期内最多能使用 50000 cpu 时间

再用 `docker stats test01` 可以观察到该容器对 CPU 的使用率在 100% 左右

然后，我们再以同样的参数启动另一个容器

```bash
$ docker run --rm --name test02 --cpu-cpus 1 --cpu-quota=50000 --cpu-period=50000 deadloop99/hello-world
```

再用 `docker stats test01 test02` 可以观察到这两个容器

每个容器对 cpu 的使用率在 50% 左右。说明容器并没有在每个周期内使用 50000 的 cpu 时间

使用 `docker stop test02` 命令结束第二个容器，再加一个参数 `-c 2048` 启动它

```bash
$ docker run --rm --name test02 --cpu-cpus 1 --cpu-quota=50000 --cpu-period=50000 -c 2048 deadloop99/hello-world
```

再用 `docker stats test01` 命令可以观察到第一个容器的 CPU 使用率在 33% 左右
第二个容器的 CPU 使用率在 66% 左右

因为第二个容器的共享值是 2048，第一个容器的默认共享值是 1024，所以第二个容器在每个周期内能使用的 CPU 时间是第一个容器的两倍

## 磁盘 IO 配额控制

该控制依赖 blkio 子系统，相对于 CPU 和内存的配额控制，docker 对磁盘 IO 的控制相对实现不成熟，大多数都必须在有宿主机支持的情况下使用

衡量磁盘读写的常见指标

- IOPS(Input/Output Operations per Second): 每秒读写磁盘的次数
- Throughput(吞吐量): 每秒读写磁盘的数据量，也称为带宽(BandWidth)

`Throughput = 数据块大小 * IOPS`

> 在 IOPS 固定的情况下，读写的数据块越大，吞吐量也越大

### blkio 子系统说明

限制写入需要 linux Cgroup（Control Groups）支持 blkio，并且分为 2个版本

- [Block IO Controller v1](https://www.kernel.org/doc/Documentation/cgroup-v1/blkio-controller.txt)
	- cgroup v1 blkio独立与memory子系统，它无法统计由Page cache刷入磁盘的I/O，不能限制 Buffered I/O
- [Control Group v2](https://www.kernel.org/doc/Documentation/cgroup-v2.txt)
	-  在 cgroup v2 中，内核将Page cache flush到磁盘产生的I/O也会被计算到进程的 I/O 中， 对磁盘限速时，可以同时限制Directed I/O和Buffered I/O

目前主流还是 cgroup v1，查询 cgroup 支持 `cat /boot/config-$(uname -r) | grep CONFIG_BLK` ，关键支持需要开启

```cfg
CONFIG_BLK_CGROUP=y
CONFIG_BLK_DEV_THROTTLING=y
```

存储配额控制的相关参数，可以参考 [Red Hat 文档中 blkio 这一章](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/resource_management_guide/ch-subsystems_and_tunable_parameters#sec-blkio)

blkio cgroup 的虚拟文件系统挂载点 `/sys/fs/cgroup/blkio/` 包含以下参数

- blkio.throttle.read_iops_device：读IOPS限制
- blkio.throttle.read_bps_device：读吞吐量限制
- blkio.throttle.write_iops.device：写IOPS限制
- blkio.throttle.write_bps_device：写吞吐量限制

### docker 磁盘资源配额参数

主要包括以下参数：

- `--device-read-bps`：限制此设备上的读速度（bytes per second），单位可以是 kb、mb 或者 gb
- `--device-read-iops`：通过每秒读 IO 次数来限制指定设备的读速度
- `--device-write-bps` ：限制此设备上的写速度（bytes per second），单位可以是 kb、mb 或者 gb
- `--device-write-iops`：通过每秒写 IO 次数来限制指定设备的写速度
- `--blkio-weight`：容器默认磁盘 IO 的加权值，有效值范围为 `10-100`
- `--blkio-weight-device`： 针对特定设备的 IO 加权控制。其格式为 `DEVICE_NAME:WEIGHT`

### docker-compose 磁盘配额配置

- 参考 [https://docs.docker.com/compose/compose-file/05-services/#blkio_config](https://docs.docker.com/compose/compose-file/05-services/#blkio_config)

```yml
services:
  foo:
    image: busybox
    blkio_config:
       weight: 300
       weight_device:
         - path: /dev/sda
           weight: 400
       device_read_bps:
         - path: /dev/sdb
           rate: 12582912 # 12582912 byte '12mb'
       device_read_iops:
         - path: /dev/sdb
           rate: 120
       device_write_bps:
         - path: /dev/sdb
           rate: 524288 # 524288 byte = 512k
       device_write_iops:
         - path: /dev/sdb
           rate: 30
```

### 磁盘 IO 配额控制示例

#### device-write-bps

使用下面的命令创建容器，并执行命令验证写速度的限制

```bash
# 拿到 /dev/sda 的主次设备号
$ ls -l /dev/sda -l
brw-rw---- 1 root disk 8, 0  Aug 18 19:28 /dev/sda
# 其中 8:0 是/dev/vdb的主次设备号

$ docker run -tid --rm –name disk1 --device-write-bps /dev/sda:1mb ubuntu:stress

# 通过 dd 来验证写速度
dd if=/dev/zero of=test.out bs=1M count=100 oflag=direct
104857600 bytes (105 MB) copied, 100.53 s 1.0MB/s
```

#### blkio-weight

要使 `--blkio-weight `生效，需要保证 IO 的调度算法为 CFQ，可以使用下面的方式查看

```bash
$ cat /sys/block/sda/queue/scheduler
noop [deadline] cfq
```

使用下面的命令创建两个 `--blkio-weight` 值不同的容器

```bash
$ docker run -ti –rm --blkio-weight 100 ubuntu:stress
$ docker run -ti –rm --blkio-weight 1000 ubuntu:stress
```

在容器中同时执行下面的 dd 命令，进行测试

```bash
time dd if=/dev/zero of=test.out bs=1M count=1024 oflag=direct
```

#### 容器空间大小限制

在 docker 使用 `devicemapper` 作为存储驱动时，默认每个容器和镜像的最大大小为 10G

如果需要调整，可以在 daemon 启动参数中，使用 dm.basesize 来指定

> 警告: 修改这个值，不仅仅**需要重启 docker daemon 服务，还会导致宿主机上的所有本地镜像和容器都被清理掉**

使用 aufs 或者 overlay 等其他存储驱动时，没有这个限制
