---
title: "golang context 包使用"
date: 2019-12-08T11:35:57+08:00
description: "控制并发有两种经典的方式，一种是WaitGroup，另外一种就是Context, 本文介绍 golang context 包使用 及注意事项"
draft: false
categories: ['golang']
tags: ['golang']
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

go 控制并发有两种经典的方式，一种是 WaitGroup (for select wait chan)，另外一种就是 Context

## 什么是sync.WaitGroup

sync.WaitGroup 是一种控制并发的方式，它的这种方式是控制多个 goroutine 同时完成

```go
func main() {
 var wg sync.WaitGroup
 wg.Add(2)
 go func() {
  time.Sleep(2*time.Second)
  fmt.Println("1号完成")
  wg.Done()
 }()
 go func() {
  time.Sleep(2*time.Second)
  fmt.Println("2号完成")
  wg.Done()
 }()
 wg.Wait()
 fmt.Println("好了，大家都干完了，放工")
 }
```

一定要例子中的 2 个 goroutine 同时做完，才算是完成

先做好的就要等着其他未完成的，`所有的goroutine要都全部完成才可以`

这是一种控制并发的方式，这种尤其适用于，好多个 goroutine 协同做一件事情的时

因为每个 `goroutine` 做的都是这件事情的一部分，只有全部的 goroutine 都完成，这件事情才算是完成

这是等待的方式

## chan 通知

实际的业务中，可能会有这么一种场景：`需要主动的通知某一个goroutine结束`

一个 goroutine 启动后，是无法控制他的，大部分情况是等待它自己结束，那么如果这个 goroutine 是一个不会自己结束的 `后台goroutine` 呢

比如开启一个后台 goroutine 一直做事情，比如监控，现在不需要了，就需要通知这个监控 goroutine 结束，不然它会一直跑，直到内存泄漏

这种情况化，一种傻瓜式的办法是
- `全局变量` 存储状态，其他地方通过修改这个变量`完成结束通知`
- 并且要保证这个变量在`多线程下的安全`
- 然后 后台 goroutine 不停的`检查`这个变量
- `如果判断状态为关闭(被通知关闭)` 就让 gorountine 自我结束

`chan + select` 就是 golang 为了解决这个提供的官方解决方式

例如:

```go
func main() {
 stop := make(chan bool)

 go func() {
  for {
   select {
   case <-stop:
    fmt.Println("监控退出，停止了...")
    return
   default:
    fmt.Println("goroutine监控中...")
    time.Sleep(2 * time.Second)
   }
  }
 }()

 time.Sleep(10 * time.Second)
 fmt.Println("可以了，通知监控停止")
 stop<- true
 //为了检测监控过是否停止，如果没有监控输出，就表示停止了
 time.Sleep(5 * time.Second)

}
```

- 定义一个别名叫 stop 的chan，通知他结束后台 goroutine
- 在后台 goroutine 中，使用select判断stop是否可以接收到值
- 如果可以接收到，就表示可以退出停止了；
- 如果没有接收到，就会执行default里的监控逻辑，继续监控
- 只到收到 stop 的通知

> 当然也可以在其他 goroutine 中，给 stop chan 发送值

- 发送了 `stop<- true` 结束的指令后，使用 time.Sleep(5 * time.Second) 故意停顿5秒来检测结束监控 goroutine 是否成功，模拟异步阻塞

- 如果成功的话，不会再有 goroutine 监控中...的输出了；
- 如果没有成功，监控 goroutine 就会继续打印 goroutine 监控中...输出

不过这种方式也有局限性，如果有很多 goroutine 都需要控制结束怎么办呢？
如果这些 goroutine 又衍生了其他更多的 goroutine 怎么办呢？
如果一层层的无穷尽的 goroutine 呢？

这就非常复杂了，即使定义很多chan也很难解决这个问题，因为 goroutine 的关系链就导致了这种场景非常复杂

## context

比如一个网络请求 Request ，每个 Request 都需要开启一个 goroutine 做一些事情，这些 goroutine 又可能会开启其他的 goroutine

所以需要一种可以 `跟踪 goroutine` 的方案，才可以达到控制他们的目的，这就是 go 语言为提供的 `context` 包

查看文档 go context 包文档

```bash
$ go doc context
```

称之为上下文非常贴切，它就是 `goroutine的上下文`

把上面的示例重新写一遍

```go
func main() {
 ctx, cancel := context.WithCancel(context.Background())
 go func(ctx context.Context) {
  for {
   select {
   case <-ctx.Done():
    fmt.Println("gorountine exit and stop...")
    return
   default:
    fmt.Println("goroutine running...")
    time.Sleep(2 * time.Second)
   }
  }
 }(ctx)

 time.Sleep(10 * time.Second)
 fmt.Println("fine, and can stop routine")
 cancel()
 //为了检测过 协程 是否停止，如果 协程 没有输出，就表示停止了
 time.Sleep(5 * time.Second)

}
```

把原来的 chan stop 换成 Context，使用 Context 跟踪 goroutine，以便进行控制，比如结束

- context.Background() 返回一个空的 Context，这个`空的 Context 一般用于整个 Context 树的根节点`
- context.WithCancel(parent) 函数，创建一个可取消的 `子 Context` ，然后当作参数传给 goroutine 使用，这样就可以使用这个 子Context 跟踪这个 goroutine
- 在 goroutine 中，使用 select 调用 `<-ctx.Done()` 判断是否要结束，如果接受到值的话，就可以返回结束 goroutine
- 如果`接收不到，就会继续进行`
- 发送结束指令，调用 context.WithCancel(parent) 函数生成 `子 Context` 的时候返回的`第二个返回值`就是作为取消函数
- 调用这个取消函数就可以发出`取消指令`，然后的 `监控 goroutine 就会收到信号`，然后`返回结束`

### context控制多个goroutine

例子

```go
func main() {
 ctx, cancel := context.WithCancel(context.Background())
 go watch(ctx,"goroutine 1")
 go watch(ctx,"goroutine 2")
 go watch(ctx,"goroutine 3")

 time.Sleep(10 * time.Second)
 fmt.Println("fine, and can stop routine")
 cancel()
 //为了检测 协程 过是否停止，如果没有 协程 输出，就表示停止了
 time.Sleep(5 * time.Second)
}

func watch(ctx context.Context, name string) {
 for {
  select {
  case <-ctx.Done():
   fmt.Println(name,"gorountine exit and stop...")
   return
  default:
   fmt.Println(name,"goroutine running...")
   time.Sleep(2 * time.Second)
  }
 }
}
```

- 启动了3个 goroutine 进行不断的监控
- 每一个都使用了 Context 进行跟踪
- 当使用 `cancel()` 函数通知取消时，这3个goroutine都会被结束

这就是 Context 的控制能力，所有`基于这个 Context` 或者`衍生的 子Context` 都会收到通知

通知收到后，这时就可以进行清理操作，最终释放 goroutine

这就优雅的解决了 goroutine 启动后不可控的问题

## Context接口使用

Context的接口定义

```go
type Context interface {
 Deadline() (deadline time.Time, ok bool)

 Done() <-chan struct{}

 Err() error

 Value(key interface{}) interface{}
}
```

### Context接口详解

#### Deadline

`Deadline()` 方法是获取设置的死期（截止时间的意思）

- 第一个返回式是截止时间，到了这个时间点，Context会自动发起取消请求；
- 第二个返回值 ok==false 时表示没有设置截止时间，如果需要取消的话，需要调用取消函数进行取消

#### Done

`Done()` 方法返回一个只读的 chan，类型为struct{}

- 在goroutine中，如果该方法返回的chan可以读取，则意味着parent context已经发起了取消请求
- 通过Done方法收到这个信号后，就应该做清理操作
- 然后退出goroutine，释放资源

#### Err

`Err()` 返回取消的错误原因，为什么Context被取消

#### Value

`Value()` 方法获取该Context上绑定的值，是一个键值对

- 所以要通过一个Key才可以获取对应的值
- 这个值`一般是线程安全的`

#### Done

`Done()` 方法 在Context取消的时候，就可以得到一个关闭的chan

- 这个`关闭的chan是可以读取的`，所以只要可以读取的时候，就意味着已经收到Context取消的信号

例如

```go
func Stream(ctx context.Context, out chan<- Value) error {
 for {
  v, err := DoSomething(ctx)
  if err != nil {
   return err
  }
  select {
  case <-ctx.Done():
   return ctx.Err()
  case out <- v:
  }
 }
}
```

#### Context 实现

`Context接口并不需要实现`，Go内置已经帮实现了2个

```go
var (
 background = new(emptyCtx)
 todo = new(emptyCtx)
)

func Background() Context {
 return background
}

func TODO() Context {
 return todo
}
```

代码中最开始都是以这两个内置的作为最顶层的 partent context ，`衍生出更多的 子 Context`

- `Background()`，主要用于 main 函数、初始化以及测试代码中，作为 Context 这个树结构的最顶层的 Context，也就是`根Context`
- `TODO()`，不知道具体的使用场景，如果不知道该使用什么 Context 的时候，可以使用这个

> 这两个实现，本质上都是 emptyCtx 结构体类型，是`一个不可取消，没有设置截止时间，没有携带任何值的Context`

```go
type emptyCtx int

func (*emptyCtx) Deadline() (deadline time.Time, ok bool) {
 return
}

func (*emptyCtx) Done() <-chan struct{} {
 return nil
}

func (*emptyCtx) Err() error {
 return nil
}

func (*emptyCtx) Value(key interface{}) interface{} {
 return nil
}
```

这里实现 Context 接口的方法 emptyCtx，这些方法什么都没做，返回的都是 `nil` 或者 `零值`

## Context衍生使用

context包为提供的 With 系列的函数，可以衍生出很多不同类型的 Context

```go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)
func WithDeadline(parent Context, deadline time.Time) (Context, CancelFunc)
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
func WithValue(parent Context, key, val interface{}) Context
```

- 这四个With函数，接收的都有一个partent参数，就是`根 Context`
- 基于这个 `父Context` 创建出 `子Context`, 使用这种方式可以理解为 `子Context` 对 `父Context的继承`，也可以理解为`基于 父Context 的衍生`
- 前三个函数都返回一个 `取消函数CancelFunc`，这就是取消函数的类型
- `该函数可以取消一个Context，以及这个节点Context下所有的所有的Context，不管有多少层级`

通过这些函数，就`创建了一颗Context树`

树的每个节点都可以有任意多个子节点，节点层级可以有`任意多个`

- WithCancel 函数，传递一个 `父Context` 作为参数，返回 `子Context`，以及一个`取消函数`用来取消 Context
- WithDeadline 函数，和WithCancel差不多，它会`多传递一个截止时间参数`，意味着到了这个时间点，会自动取消 Context，当然也可以不等到这个时候，可以提前通过取消函数进行取消
- WithTimeout 和 WithDeadline 基本上一样，这个表示是`超时自动取消`，多少时间后自动取消Context的意思
- WithValue 函数和 取消 Context 无关，是`为了生成一个绑定了一个键值对数据的Context`
  - 这个绑定的数据可以通过 Context.Value 方法访问到，`用于树状层级控制上下文`

### WithValue传递元数据

通过 Context 也可以传递一些必须的`元数据`，这些数据会附加在 Context 上以供使用

```go
var key string="name"

func main() {
 ctx, cancel := context.WithCancel(context.Background())
 // extra value
 valueCtx:=context.WithValue(ctx,key,"goroutine 1")
 go watch(valueCtx)
 time.Sleep(10 * time.Second)
 fmt.Println("fine, and goroutine stop")
 cancel()
 //为了检测 协程 过是否停止，如果没有 协程 输出，就表示停止了
 time.Sleep(5 * time.Second)
}

func watch(ctx context.Context) {
 for {
  select {
  case <-ctx.Done():
   // get value
   fmt.Println(ctx.Value(key),"goroutine stop and exit ...")
   return
  default:
   // get value
   fmt.Println(ctx.Value(key),"goroutine running...")
   time.Sleep(2 * time.Second)
  }
 }
}
```

使用 `context.WithValue` 方法附加一对K-V的键值对需要注意

- 这里`Key必须是等价性的，也就是具有可比性`，也就是可以被 select
- `Value值要是线程安全`，因为 golang 协程模型，本身不保证线程安全

通过 context.WithVaule 就生成了一个新的 Context，这个新的 Context 带有这个键值对

在使用的时候，可以通过 `Value` 方法读取 `ctx.Value(key)`

> 记住，使用WithValue传值，一般是必须的值，不要什么值都传递

## Context 使用原则

- `不要把 Context 放在结构体中`，要以参数的方式传递
- 以 Context 作为参数的函数方法，应该`把 Context 作为第一个参数，放在第一位`
- 对一个函数方法传递 Context 的时候，`不要传递nil`，如果`不知道传递什么，就使用 context.TODO`
- Context的 `Value 相关方法应该传递必须的数据`，不要什么数据都使用这个传递
- `Context是线程安全的`，可以放心的在多个goroutine中传递
- `Value值要是线程安全`，golang 协程模型不保证线程安全
