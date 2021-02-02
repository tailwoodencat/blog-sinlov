---
title: "golang 获取服务运行信息 服务监控"
date: 2019-05-04T12:59:16+08:00
description: "golang 获取服务器的运行信息 制作服务监控 心跳适配等"
draft: false
categories: ['golang']
tags: ['golang', 'monitor']
toc:
  enable: true
  auto: false
math:
  enable: false
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 服务内存信息获取

### 说明

- golang 自带的包却有一个 runtime 包，可以轻松获取服务运行时候的各种包括内存使用情况的信息
- 本代码 基于 go 1.12

golang 服务可以通过 `runtime.ReadMemStats` 方法获取服务运行期间内存使用情况和垃圾回收等相关信息

比起各种内存监控工具要详细很多，而且是以golang的方式获取内存数据

> 因为在golang中，我们只获取内存使用总量和增长趋势往往可以确定的事情很少，但是由runtime.MemStats获取到的信息确是非常有价值的
在服务后台开发过程中，有一个非常重要的原则就是`无监控，不服务`，这是服务后台开发的基本

无论是架构的演进方向和服务可靠性控制，以及部分性能优化的数据来源都需要以监控数据作为参考

而golang内存信息的监控,必须通过对应时刻runtime.MemStats的为标准

> 即使使用 runtime.ReadMemStats 会短暂的暂停服务中的所有 goroutine，然后收集调用时刻的 MemStats
从源代码来看，暂停所有 goroutine 的时间仅仅是使用 memcopy 拷贝一个 MemStats 的时间

但是在业务高峰时期，不应该将 `runtime.ReadMemStats` 作为性能优化的优化点
因为在在业务高峰时段获取到的服务状态信息往往比程序本身更有用

### 监控参数

- 常用监控参数

| item | desc |
|:------|:------------------------------------|
| Alloc | golang语言框架堆空间分配的字节数 |
| TotalAlloc | 从服务开始运行至今分配器为分配的堆空间总和，只有增加，释放的时候不减少|
| Sys | 服务现在系统使用的内存 |
| Lookups | 被runtime监视的指针数 |
| Mallocs | 服务malloc的次数 |
| Frees | 服务回收的heap objects的字节数 free次数 |
| HeapAlloc | golang语言框架堆空间分配的字节数 |
| HeapSys | 系统分配的堆内存 |
| HeapIdle | 申请但是未分配的堆内存或者回收了的堆内存（空闲）字节数 |
| HeapInuse | 正在使用的堆内存字节数 |
| HeapReleased | 返回给OS的堆内存 |
| HeapObjects | 堆内存块申请的量 |
| StackInuse | 正在使用的栈字节数 |
| StackSys | 系统分配的作为运行栈的内存 |
| MSpanInuse | 用于测试用的结构体使用的字节数 不受GC控制 |
| MSpanSys | 系统为测试用的结构体分配的字节数 |
| MCacheInuse | mcache结构体申请的字节数(不会被视为垃圾回收) |
| MCacheSys | 操作系统申请的堆空间用于mcache的字节数 |
| BuckHashSys | 用于剖析桶散列表的堆空间 |
| GCSys | 垃圾回收标记元信息使用的内存 |
| OtherSys | golang系统架构占用的额外空间 |
| NextGC | 垃圾回收器检视的内存大小 |
| LastGC | 最后一次GC的时间戳 |
| PauseTotalNs | 系统暂停的时间 单位纳秒 |
| NumGC | 垃圾回收调用次数 |
| GCCPUFraction | 调用GC消耗的性能 |

- 完整监控参数

| item | type | desc |
|:------|:-------|:----------------------------|
| Alloc | uint64 | golang语言框架堆空间分配的字节数 |
| TotalAlloc | uint64 | 从服务开始运行至今分配器为分配的堆空间总 和，只有增加，释放的时候不减少 |
| Sys | uint64 | 服务现在系统使用的内存 换算成 MB 需要 `/1024/1024` |
| Lookups | uint64 | 被runtime监视的指针数 |
| Mallocs | uint64 | 服务malloc的次数 |
| Frees | uint64 | 服务回收的heap objects的字节数 |
| HeapAlloc | uint64 | 服务分配的堆内存字节数 |
| HeapSys | uint64 | 系统分配的作为运行栈的内存 |
| HeapIdle | uint64 | 申请但是未分配的堆内存或者回收了的堆内存（空闲）字节数 |
| HeapInuse | uint64 | 正在使用的堆内存字节数 |
| HeapReleased | uint64 | 返回给OS的堆内存，类似C/C++中的free。 |
| HeapObjects | uint64 | 堆内存块申请的量 |
| StackInuse | uint64 | 正在使用的栈字节数 |
| StackSys | uint64 | 系统分配的作为运行栈的内存 |
| MSpanInuse | uint64 | 用于测试用的结构体使用的字节数 |
| MSpanSys | uint64 | 系统为测试用的结构体分配的字节数 |
| MCacheInuse | uint64 | mcache结构体申请的字节数(不会被视为垃圾回收) |
| MCacheSys | uint64 | 操作系统申请的堆空间用于mcache的字节数 |
| BuckHashSys | uint64 | 用于剖析桶散列表的堆空间 |
| GCSys | uint64 | 垃圾回收标记元信息使用的内存 |
| OtherSys | uint64 | golang系统架构占用的额外空间 |
| NextGC | uint64 | 垃圾回收器检视的内存大小 |
| LastGC | uint64 | 垃圾回收器最后一次执行时间。 |
| PauseTotalNs | uint64 | 垃圾回收或者其他信息收集导致服务暂停的次数。 |
| PauseNs | [256]int64 | 一个循环队列，记录最近垃圾回收系统中断的时间 |
| PauseEnd | [256]int64 | 一个循环队列，记录最近垃圾回收系统中断的时间开始点。 |
| NumForcedGC | uint32 | 服务调用runtime.GC()强制使用垃圾回收的次数。 |
| GCCPUFraction | float64 | 垃圾回收占用服务CPU工作的时间总和。如果有100个goroutine，垃圾回收的时间为1S,那么久占用了100S。 |
| BySize | [{}] | 内存分配器使用情况 |

### 内存信息定义源码

- runtime中和内存使用情况相关的结构体为runtime.MemStats

这个结构定义了golang运行过程中所有内存相关的信息

```golang
// A MemStats records statistics about the memory allocator. 记录内存分配器的信息
type MemStats struct {
    // General statistics.
    // Alloc is bytes of allocated heap objects.
    // 堆空间分配的字节数
    // This is the same as HeapAlloc (see below).
    Alloc uint64
    // TotalAlloc is cumulative bytes allocated for heap objects.
    //
    // TotalAlloc increases as heap objects are allocated, but
    // unlike Alloc and HeapAlloc, it does not decrease when
    // objects are freed. 从服务开始运行至今分配器为分配的堆空间总和
    TotalAlloc uint64
    // Sys is the total bytes of memory obtained from the OS.
    //
    // Sys is the sum of the XSys fields below. Sys measures the
    // virtual address space reserved by the Go runtime for the
    // heap, stacks, and other internal data structures. It's
    // likely that not all of the virtual address space is backed
    // by physical memory at any given moment, though in general
    // it all was at some point. 服务现在使用的内存
    Sys uint64
    // Lookups is the number of pointer lookups performed by the
    // runtime.
    //
    // This is primarily useful for debugging runtime internals. 被runtime监视的指针数
    Lookups uint64
    // Mallocs is the cumulative count of heap objects allocated. 服务malloc的次数
    // The number of live objects is Mallocs - Frees.
    Mallocs uint64
    // Frees is the cumulative count of heap objects freed. 服务回收的heap objects
    Frees uint64
    // Heap memory statistics.
    //
    // Interpreting the heap statistics requires some knowledge of
    // how Go organizes memory. Go divides the virtual address
    // space of the heap into "spans", which are contiguous
    // regions of memory 8K or larger. A span may be in one of
    // three states:
    //
    // An "idle" span contains no objects or other data. The
    // physical memory backing an idle span can be released back
    // to the OS (but the virtual address space never is), or it
    // can be converted into an "in use" or "stack" span.
    //
    // An "in use" span contains at least one heap object and may
    // have free space available to allocate more heap objects.
    //
    // A "stack" span is used for goroutine stacks. Stack spans
    // are not considered part of the heap. A span can change
    // between heap and stack memory; it is never used for both
    // simultaneously.
    // HeapAlloc is bytes of allocated heap objects.
    //
    // "Allocated" heap objects include all reachable objects, as
    // well as unreachable objects that the garbage collector has
    // not yet freed. Specifically, HeapAlloc increases as heap
    // objects are allocated and decreases as the heap is swept
    // and unreachable objects are freed. Sweeping occurs
    // incrementally between GC cycles, so these two processes
    // occur simultaneously, and as a result HeapAlloc tends to
    // change smoothly (in contrast with the sawtooth that is
    // typical of stop-the-world garbage collectors).
    //服务分配的堆内存
    HeapAlloc uint64
    // HeapSys is bytes of heap memory obtained from the OS.
    //
    // HeapSys measures the amount of virtual address space
    // reserved for the heap. This includes virtual address space
    // that has been reserved but not yet used, which consumes no
    // physical memory, but tends to be small, as well as virtual
    // address space for which the physical memory has been
    // returned to the OS after it became unused (see HeapReleased
    // for a measure of the latter).
    //
    // HeapSys estimates the largest size the heap has had.
    //系统分配的堆内存
    HeapSys uint64
    // HeapIdle is bytes in idle (unused) spans.
    //
    // Idle spans have no objects in them. These spans could be
    // (and may already have been) returned to the OS, or they can
    // be reused for heap allocations, or they can be reused as
    // stack memory.
    //
    // HeapIdle minus HeapReleased estimates the amount of memory
    // that could be returned to the OS, but is being retained by
    // the runtime so it can grow the heap without requesting more
    // memory from the OS. If this difference is significantly
    // larger than the heap size, it indicates there was a recent
    // transient spike in live heap size.
    //申请但是为分配的堆内存，（或者回收了的堆内存）
    HeapIdle uint64
    // HeapInuse is bytes in in-use spans.
    //
    // In-use spans have at least one object in them. These spans
    // can only be used for other objects of roughly the same
    // size.
    //
    // HeapInuse minus HeapAlloc esimates the amount of memory
    // that has been dedicated to particular size classes, but is
    // not currently being used. This is an upper bound on
    // fragmentation, but in general this memory can be reused
    // efficiently.
    //正在使用的堆内存
    HeapInuse uint64
    // HeapReleased is bytes of physical memory returned to the OS.
    //
    // This counts heap memory from idle spans that was returned
    // to the OS and has not yet been reacquired for the heap.
    //返回给OS的堆内存，类似C/C++中的free。
    HeapReleased uint64
    // HeapObjects is the number of allocated heap objects.
    //
    // Like HeapAlloc, this increases as objects are allocated and
    // decreases as the heap is swept and unreachable objects are
    // freed.
    //堆内存块申请的量
    HeapObjects uint64
    // Stack memory statistics.
    //
    // Stacks are not considered part of the heap, but the runtime
    // can reuse a span of heap memory for stack memory, and
    // vice-versa.
    // StackInuse is bytes in stack spans.
    //
    // In-use stack spans have at least one stack in them. These
    // spans can only be used for other stacks of the same size.
    //
    // There is no StackIdle because unused stack spans are
    // returned to the heap (and hence counted toward HeapIdle).
    //正在使用的栈
    StackInuse uint64
    // StackSys is bytes of stack memory obtained from the OS.
    //
    // StackSys is StackInuse, plus any memory obtained directly
    // from the OS for OS thread stacks (which should be minimal).
    //系统分配的作为运行栈的内存
    StackSys uint64
    // Off-heap memory statistics.
    //
    // The following statistics measure runtime-internal
    // structures that are not allocated from heap memory (usually
    // because they are part of implementing the heap). Unlike
    // heap or stack memory, any memory allocated to these
    // structures is dedicated to these structures.
    //
    // These are primarily useful for debugging runtime memory
    // overheads.
    // MSpanInuse is bytes of allocated mspan structures. 用于测试用的结构体使用的字节数
    MSpanInuse uint64
    // MSpanSys is bytes of memory obtained from the OS for mspan
    // structures. 系统为测试用的结构体分配的字节数
    MSpanSys uint64
    // MCacheInuse is bytes of allocated mcache structures. mcache结构体申请的字节数
    MCacheInuse uint64
    // MCacheSys is bytes of memory obtained from the OS for
    // mcache structures. 操作系统申请的堆空间用于mcache的量
    MCacheSys uint64
    // BuckHashSys is bytes of memory in profiling bucket hash tables.用于剖析桶散列表的堆空间
    BuckHashSys uint64
    // GCSys is bytes of memory in garbage collection metadata. 垃圾回收标记元信息使用的内存
    GCSys uint64
    // OtherSys is bytes of memory in miscellaneous off-heap
    // runtime allocations. golang系统架构占用的额外空间
    OtherSys uint64
    // Garbage collector statistics.
    // NextGC is the target heap size of the next GC cycle.
    //
    // The garbage collector's goal is to keep HeapAlloc ≤ NextGC.
    // At the end of each GC cycle, the target for the next cycle
    // is computed based on the amount of reachable data and the
    // value of GOGC. 垃圾回收器检视的内存大小
    NextGC uint64
    // LastGC is the time the last garbage collection finished, as
    // nanoseconds since 1970 (the UNIX epoch).
    // 垃圾回收器最后一次执行时间。
    LastGC uint64
    // PauseTotalNs is the cumulative nanoseconds in GC
    // stop-the-world pauses since the program started.
    //
    // During a stop-the-world pause, all goroutines are paused
    // and only the garbage collector can run.
    // 垃圾回收或者其他信息收集导致服务暂停的次数。
    PauseTotalNs uint64
    // PauseNs is a circular buffer of recent GC stop-the-world
    // pause times in nanoseconds.
    //
    // The most recent pause is at PauseNs[(NumGC+255)%256]. In
    // general, PauseNs[N%256] records the time paused in the most
    // recent N%256th GC cycle. There may be multiple pauses per
    // GC cycle; this is the sum of all pauses during a cycle. 一个循环队列，记录最近垃圾回收系统中断的时间
    PauseNs [256]uint64
    // PauseEnd is a circular buffer of recent GC pause end times,
    // as nanoseconds since 1970 (the UNIX epoch).
    //
    // This buffer is filled the same way as PauseNs. There may be
    // multiple pauses per GC cycle; this records the end of the
    // last pause in a cycle. 一个循环队列，记录最近垃圾回收系统中断的时间开始点。
    PauseEnd [256]uint64
    // NumGC is the number of completed GC cycles.
    //垃圾回收的内存大小
    NumGC uint32
    // NumForcedGC is the number of GC cycles that were forced by
    // the application calling the GC function.
    //服务调用runtime.GC()强制使用垃圾回收的次数。
    NumForcedGC uint32
    // GCCPUFraction is the fraction of this program's available
    // CPU time used by the GC since the program started.
    //
    // GCCPUFraction is expressed as a number between 0 and 1,
    // where 0 means GC has consumed none of this program's CPU. A
    // program's available CPU time is defined as the integral of
    // GOMAXPROCS since the program started. That is, if
    // GOMAXPROCS is 2 and a program has been running for 10
    // seconds, its "available CPU" is 20 seconds. GCCPUFraction
    // does not include CPU time used for write barrier activity.
    //
    // This is the same as the fraction of CPU reported by
    // GODEBUG=gctrace=1.
    //垃圾回收占用服务CPU工作的时间总和。如果有100个goroutine，垃圾回收的时间为1S,那么久占用了100S
    GCCPUFraction float64
    // EnableGC indicates that GC is enabled. It is always true,
    // even if GOGC=off.
    //是否启用GC
    EnableGC bool
    // DebugGC is currently unused.
    DebugGC bool
    // BySize reports per-size class allocation statistics.
    //
    // BySize[N] gives statistics for allocations of size S where
    // BySize[N-1].Size < S ≤ BySize[N].Size.
    //
    // This does not report allocations larger than BySize[60].Size.
    //内存分配器使用情况
    BySize [61]struct {
        // Size is the maximum byte size of an object in this
        // size class.
        Size uint32
        // Mallocs is the cumulative count of heap objects
        // allocated in this size class. The cumulative bytes
        // of allocation is Size*Mallocs. The number of live
        // objects in this size class is Mallocs - Frees.
        Mallocs uint64
        // Frees is the cumulative count of heap objects freed
        // in this size class.
        Frees uint64
    }
}
```

## 监控服务运行各项指标

go标准库还有一个更好用的可以监控服务运行各项指标和状态的包 `expvar`

expvar包为监控变量提供了一个标准化的接口
它以 JSON 格式通过 `/debug/vars` 接口以 HTTP 的方式公开这些监控变量以及我自定义的变量

- 如果url不是/debug/vars，则用metricBeat去获取会出问题
- 当然还可以使用，ES和Kibana，可以很轻松的对服务进行监控

## gin 服务监控

如果你的 web 服务是 gin 编写的，那么这里有一个非侵入型，支持配置的 gin 服务监控工具

[https://github.com/bar-counter/monitor](https://github.com/bar-counter/monitor)

```go
import (
	"github.com/bar-counter/monitor"
)

	r := gin.Default()
	monitorCfg := &monitor.Cfg{
		Status: true,
		//StatusPrefix: "/status",
		StatusHardware: true,
		//StatusHardwarePrefix: "/hardware",
	}
	err := monitor.Register(r, monitorCfg)
	if err != nil {
		fmt.Printf("monitor register err %v\n", err)
		return
	}
	r.Run(":38000")
```

设置好了后可以

```bash
# 心跳接口
curl 'http://127.0.0.1:38000/status/health' \
  -X GET

# 磁盘状态
curl 'http://127.0.0.1:38000/status/hardware/disk' \
  -X GET

# 内存状态
curl 'http://127.0.0.1:38000/status/hardware/ram' \
  -X GET

# cpu 状态
curl 'http://127.0.0.1:38000/status/hardware/cpu' \
  -X GET
```

> StatusPrefix default is `/status` you can change by your self
> StatusHardwarePrefix default is `/hardware`

还可以
- 支持调试
- 设置访问密码

如果需要参数配置，结合 [github.com/spf13/viper](https://github.com/spf13/viper)

```yml
monitor: # monitor
  status: true             # api status use {monitor.health}
  health: /status/health   # api health
  retryCount: 10           # ping api health retry count at start
  hardware: true           # hardware true or false
  status_hardware:
    disk: /status/hardware/disk     # hardware api disk
    cpu: /status/hardware/cpu       # hardware api cpu
    ram: /status/hardware/ram       # hardware api ram
  debug: true                       # debug true or false
  pprof: true                       # security true or false
  security: false                    # debug and security security true or false
  securityUser:
    admin: xxx
```

具体代码见 [https://github.com/bridgewwater/gin-api-swagger-temple/blob/main/router/monitor.go#L30](https://github.com/bridgewwater/gin-api-swagger-temple/blob/main/router/monitor.go#L30)
