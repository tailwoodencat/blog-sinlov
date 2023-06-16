---
title: "golang 内存池sync.pool使用及如何降低IO密集应用的GC频率"
date: 2020-03-03T12:39:26+08:00
description: "讲述 golang 使用 sync.pool 内存池的使用，以及 go sdk 更新, 以及降低IO密集应用下 GC 频率"
draft: false
categories: ['golang']
tags: ['golang', 'performance']
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

在go语言的世界里，内存池有两种

- 一种是官方的 sync.pool 临时对象池
- 另一种是利用 channel实现的自定义内存池

下面将首先介绍这两种内存池的特点

## 标准库sync.pool

用法很简单，如下所示：

```go
package main

import(
    "fmt"
    "sync"
)

func main() {
    p := &sync.Pool{
        New: func() interface{} {
            return 0
        },
    }

    a := p.Get().(int)
    p.Put(1)
    b := p.Get().(int)
    fmt.Println(a, b)
}
```

```
// 这种写法是将Interface{}强转成int
p.Get().(int)
```

使用 `Get/Put` 方法取出和放回 Interface对象

如果Get时池中`没有对象，则调用New，新建对象并返回`

1. 这个标准库的实现，内部也是使用`锁来保证线程（协程）安全`，但是使用了更`细粒度的锁`，类似 java 的 ConcurrentHashMap，这样就能减少竞争
2. sync.pool 中空闲的对象会在，下一次GC时被清空

以上两点，就是 sync.pool 最重要的两个特征：`细粒度锁`、`pool中空闲对象在GC时仍然会被清空`

Go gc 发生的三种情况：

1. 自动GC：分配大于32k的内存时如果探测到堆上存活对象>memstats.gc_trigger（激发阈值）。这个32K是怎么来的？
2. 主动GC：调用runtime.GC()
3. 定时GC：如果两分钟没有进行GC，则进行一次

细粒度锁是很好的，但是GC时仍然会被回收会导致没必要的浪费

> 优化方向，比如提供一个可以自定义的回收策略，比如定时5分钟这样，下一次GC还是太频繁了

从下面的代码来看，用户也没有办法自己去覆写 poolCleanup 函数：`runtime_registerPoolCleanup` 由 `runtime` 实现，并且是私有防范

```go
func init() {
 runtime_registerPoolCleanup(poolCleanup)
}

func indexLocal(l unsafe.Pointer, i int) *poolLocal {
 lp := unsafe.Pointer(uintptr(l) + uintptr(i)*unsafe.Sizeof(poolLocal{}))
 return (*poolLocal)(lp)
}

// Implemented in runtime.
func runtime_registerPoolCleanup(cleanup func())
```


在 `src/sync/pool.go` 的代码的开头，一大段注释中写道，查看方法 `go doc sync pool`

```
    On the other hand, a free list maintained as part of a short-lived object is
    not a suitable use for a Pool, since the overhead does not amortize well in
    that scenario. It is more efficient to have such objects implement their own
    free list.

    A Pool must not be copied after first use.
```

意思应该是，持有 sync.pool 的对象不能是短命的对象

> 博客 [七分钟读懂 Go 的临时对象池pool及其应用场景](https://segmentfault.com/a/1190000016987629)有不一样的理解

我们的内存池是一个全局的资源池，`全局`这个东西的生命周期就是一个进程的开始到消亡，应该是最长生命周期对象


### go 1.13 sync.Pool 的优化

- 对STW暂停时间做了优化, 避免大的 sync.Pool 严重影响STW时间
- GC时对 sync.Pool 进行回收，不会一次将池化对象全部回收，这就避免了 sync.Pool 释放对象和重建对象导致的性能尖刺
- 对调用性能的优化

具体见如何优化的 查看文章 [Go 1.13中 sync.Pool 是如何优化的?](https://colobu.com/2019/10/08/how-is-sync-Pool-improved-in-Go-1-13/)

反正 go 1.13 以后，基本可以放心使用 sync.Pool ，除非已经严重影响到业务了再想办法自己写内存池

## 使用channel机制实现的pool

好几个使用 channel 实现的pool，大体如下

```go
package bpool

// BytePool implements a leaky pool of []byte in the form of a bounded
// channel.
type BytePool struct {
 c chan []byte
 w int
}

// NewBytePool creates a new BytePool bounded to the given maxSize, with new
// byte arrays sized based on width.
func NewBytePool(maxSize int, width int) (bp *BytePool) {
 return &BytePool{
  c: make(chan []byte, maxSize),
  w: width,
 }
}

// Get gets a []byte from the BytePool, or creates a new one if none are
// available in the pool.
func (bp *BytePool) Get() (b []byte) {
 select {
 case b = <-bp.c:
 // reuse existing buffer
 default:
  // create new buffer
  b = make([]byte, bp.w)
 }
 return
}

// Put returns the given Buffer to the BytePool.
func (bp *BytePool) Put(b []byte) {
 if cap(b) < bp.w {
  // someone tried to put back a too small buffer, discard it
  return
 }

 select {
 case bp.c <- b[:bp.w]:
  // buffer went back into pool
 default:
  // buffer didn't go back into pool, just discard
 }
}

// Width returns the width of the byte arrays in this pool.
func (bp *BytePool) Width() (n int) {
 return bp.w
}
```

这段代码定义的pool的特点有：

1. pool的大小固定，put多余的buf将会被丢弃（leaky）
2. 只接受固定宽度的buf

这段代码用的还是挺多的

shadowsocks-go 的 [leakbuf.go](https://github.com/shadowsocks/shadowsocks-go/blob/master/shadowsocks/leakybuf.go) 会漏水的池子 -> 多余的、宽度不对的buff都会被丢弃

其实也是这样，也有这两个特点

- 唯一的不同是，shadowsocks-go 的 Put 会检查`[]byte`的长度是否正确
- 不正确则panic（这应该是他的实现决定的）

使用 sync.pool 会在 GC 时回收 pool 空闲的buff（pool中buf数量可能为0），使用这个 leakypool 则会回收过多（丢弃）的buff（pool中数量基本不会为0）

前面是回收到剩余0空闲，后面是回收到空闲数量 <=channel 的容量

- sync.pool 可能会面临 pool 中无空闲可用的情况，需要重新 make 而 leakypool 则不会有这个问题
- sync.pool 不要求`[]byte`固定容量，更加自由，leakpool 则只能复用固定长度的`[]byte`（当然，改下源码就不再有这个问题）
- sync.pool 有更细粒度的锁

以上就是这两个方案的区别

### slice内部实现

slice 建立在 array 的基础上，首先讲 go 的 array

```
var a [4]int
a[0] = 1
i := a[0]
// i == 1
```

和很多语言一样，array 包括类型和长度；包裹相同类型的对象，但长度不同的数组是不同的类型，比如`[3]int`和`[4]int`是不一样的类型，没错，go的数组的`[]`放在前面。`var a [4]int `会将数组的所有元素初始化为0

与c语言不同，array变量代表整个数组，而非是指向数组第一个元素的指针。所以，赋值或者作为参数传递数组，都会copy整个数组（形参、实参的区别）；为了避免copy，可以传递数组的指针

在这里提一下：`b := [2]byte{ 0x01, 0x02}`这时初始化了一个长度为2的字节数组，而非byte的slice。没错,`[]byte`是slice,`[n]byte`是数组！ `b := []byte{ 0x01, 0x02}`就是初始化了一个byte的slice

下面开始讲 slice

 slice 的底层有一个 array ，所以可以从 array 转成 slice ；把一个 slice 赋值给另一个 slice ，两个 slice 共享同一个底层的 array ，修改 array 的值，对两个 slice 都有效。如下所示：

```
func main() {
 array:=[5]int{0,1,2,3,4}
 a:=array[:]
 b:=array[1:]//同：b=a[1:]
 array[4]=-1
 fmt.Println(a)
 fmt.Println(b)
 //[0 1 2 3 -1]
 //[1 2 3 -1]
}
```

## 内存池优化思路

好了，看 slice 的实现，其实只是为了弄清一句话：

>append 的结果是一个包含原 slice 所有元素加上新添加的元素的 slice

>如果 s 的底层数组太小，而不能容纳所有值时，会分配一个更大的数组。 返回的 slice 会指向这个新分配的数组

目前的问题，socket编程处理数据省不了要 append 两个 slice ，旧 slice 和新 slice 是不是都要放回池中？

好好看看 slice 之后，有了这样的认识：

slice 其实只是指针，我们的pool其实要保留的就是 slice 所指向的数组

- 如果 slice 的底层数组太小，而不能容纳所有值时，会分配一个更大的数组
- 如果旧 slice 的底层数组不够大，那么 append 操作会让这个旧的底层数组失去引用，面临GC回收

所以需要为了避免旧的底层数组被回收，让旧的 slice 的 cap 大一点吗？

```go
b=append(a,c...)
```

这样我们有三个slice，执行完毕会有两个或者三个底层数组参与（取决于a的底层数组够不够大）

为了尽可能地复用（将所有出现过的数组都放进pool）

那么就不要丢弃a的底层数组，最终只有两个底层数组参与

从试图将所有的数组放入pool的角度看，a的cap要大一点

但是将所有数组都放进pool真的好吗？

对于 leakypool ，不是太好，因为 leakypool 限定了 pool 中可以有的数量，多了的最后都被GC

举一个例子：

```
某一时刻有2000个socket连接，共使用4000个底层数组，pool中缓存0个（4000个底层数组都被socket连接相关的处理持有）
下一时刻，只有1950个socket连接，供使用3900个底层数组，pool中缓存100个底层数组
这时新来10个socket连接，从pool中去除20个底层数组
然后，GC发生，pool中的80个底层数组被回收
这整个过程反应的是，pool随着需求增减缓冲的情形。唯一的不可控点是何时GC
只要gc不频繁，就是好的
```

结论就是，还是得根据实际需要，去复用 底层数组 或者跟换 锁策略 来优化 内存池
