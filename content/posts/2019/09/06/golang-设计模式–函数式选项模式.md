---
title: "golang 设计模式–函数式选项模式"
date: 2019-09-06T18:38:01+08:00
description: "desc golang 设计模式–函数式选项模式"
draft: false
categories: ['golang']
tags: ['golang']
toc:
  enable: true
  auto: false
code:
  copy: true
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 为什么需要函数式选项模式

- 为 struct 结构体可能存在的字段设置默认值
- struct 的成员可以改变

范例源码

[https://github.com/micro/go-micro/blob/master/options.go](https://github.com/micro/go-micro/blob/master/options.go)

## 函数选项模式

我们先定义一个 结构体`Option` 和对应的 `OptionFunc` 的函数类型

```go
type Option struct {
    A string
    B string
    C int
}
type OptionFunc func(*Option)
```

然后利用闭包为每个字段编写一个设置值的 With 函数

```go
func WithA(a string) OptionFunc {
    return func(o *Option) {
        o.A = a
    }
}

func WithB(b string) OptionFunc {
    return func(o *Option) {
        o.B = b
    }
}

func WithC(c int) OptionFunc {
    return func(o *Option) {
        o.C = c
    }
}
```

然后，我们定义一个 `默认的Option 函数` 如下

```go
var (
    defaultOption = setDefaultOption()
)

func setDefaultOption() *Option {
    return &Option{
        A: "A",
        B: "B",
        C: 100,
    }
}
```

最后编写,我们new 构造函数如下

```go
func NewOption(opts ...OptionFunc) (opt *Option) {
    opt = defaultOption
    for _, o := range opts {
        o(opt)
    }
    defaultOption = setDefaultOption()
    return
}
```

> 这里需要注意，`defaultOption = setDefaultOption()` 一定别忘记。不然会相互影响

### 测试选项模式

```go
func TestNewOption(t *testing.T) {
    absOptions := newOptionABS("A", "B", 100)
    optionFast := NewOption()
    changeOption := NewOption(
        WithA("B"),
        WithB("A"),
    )
    // do
    t.Logf("absOptions %v", absOptions)
    t.Logf("optionFast %v", optionFast)
    t.Logf("changeOption %v", changeOption)
}
```

详细代码见

- [https://github.com/sinlov/GoLang-PlayGround/blob/master/DesignPatterns/OptionMode/OptionFunc_test.go#L8](https://github.com/sinlov/GoLang-PlayGround/blob/master/DesignPatterns/OptionMode/OptionFunc_test.go#L8)
