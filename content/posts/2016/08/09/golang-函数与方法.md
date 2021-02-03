---
title: "golang 函数与方法"
date: 2016-08-09T10:43:05+08:00
description: "解释 golang 函数与方法"
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

## go lang的函数

```
func 方法名(参数列表) 返回值 {
    定义
}
```

### 函数的值（闭包）

在Go中，`函数被看作第一类值（first-class values）`
函数像其他值一样，拥有类型，可以被赋值给其他变量，传递给函数，从函数返回

> 函数类型的零值是nil。调用值为nil的函数值会引起panic错误

比如
```go
var f func(int) int
f(1) // 此处f的值为nil, 会引起panic错误
```
`函数值不仅仅是一串代码，还记录了状态`
Go使用闭包（closures）技术实现函数值，Go程序员也把 `函数值叫做闭包`

```go
func f1(limit int) (func(v int) bool) {
    // 这里编译器发现limit逃逸了，自动在堆上分配
    return func (limit int) bool { return v>limit}
}
func main() {
    closure := f1(5)
    fmt.Printf("%v\n", closure(1)) //false
    fmt.Printf("%v\n", closure(5)) //false
    fmt.Printf("%v\n", closure(10)) //true
}
```

> f1函数传入limit参数，返回一个闭包，闭包接受一个参数v，判断v是否大于之前设置进去的limit

### 可变参数列表

可变参数，定义
```
func 函数名(变量名...类型) 返回值
```

即参数不是固定的，例如 fmt.Printf("", arg...) 函数那样，注意`只有最后一个参数才可以是声明为可变参数`

### 函数的延迟执行 defer

包含defer语句的函数执行完毕后，例如return(编译后的 return 都带有 defer)、panic
释放堆栈前会调用被声明 defer 的语句，常用于释放资源、记录函数执行耗时

- 当defer被声明时，其`参数就会被实时解析`，也就是当时的值
- `执行顺序和声明顺序相反`
- defer可以读取有名返回值，当然匿名就没法读取

例子

```go
//演示defer的函数可以访问返回值
func f2() (v int) {
    defer func (){ v++}()
    return 1 //执行这个时,把v置为1
}
//演示defer声明即解释
func f3(i int) (v int) {
    defer func(j int) { v += j} (i) //此时函数i已被解析为10,后面修改i的值无影响
    v = i
    i = i*2
    return
}
//演示defer的执行顺序,与声明顺序相反
func f4() {
    defer func() {fmt.Printf("first\n")} ()
    defer func() {fmt.Printf("second\n")} ()
}
func main() {
    fmt.Printf("%d\n", f2()) // 13
    fmt.Printf("%d\n", f3(10)) // 20
    f4() //second\nfirst\n
}
```

- 典型的使用场景，函数执行完毕关闭资源

```go
func do() error {
    f, err := os.Open("book.txt")
    if err != nil {
        return err
    }
    defer func(f io.Closer) {
        if err := f.Close(); err != nil {
            // log etc
        }
    }(f)
    // ..code...
    f, err = os.Open("another-book.txt")
    if err != nil {
        return err
    }
    defer func(f io.Closer) {
        if err := f.Close(); err != nil {
            // log etc
        }
    }(f)
    return nil
}
```

判断了Close()是否成功
因为在一些文件系统中，尤其是NFS，写文件出错往往被延迟到Close的时候才反馈，所以必须检查Close的状态

### 恐慌panic

golang 有别于那些将函数运行失败看作是异常的语言，直接用恐慌来描述
> 虽然 golang 有各种错误处理机制，但这些机制`仅仅用于严重的错误，而不是在那些看似在健壮程序中应该被避免的程序错误`

也能使用panic关键字让程序陷入恐慌，panic 定义如下

```
panic(恐慌的值) //啥值都行
```

出现恐慌之后，默认情况就是程序退出并打印堆栈

```go
func fn_dive_zero() {
    func () {
        func () int {
            x := 0
            y := 1/x
            return y
        }()
    }()
}
func main() {
     fn_dive_zero()
}
```
输出为
```bash
panic: runtime error: integer divide by zero
goroutine 1 [running]:
```

如果不想程序退出的话，`使用recover捕捉恐慌，然后返回 error`
- 没发生 panic 的情况下，调用 recover 会返回 nil
- 发生了panic，那么就是 panic 的值

例子

```go
type shouldRecover struct{}
type emptyStruct struct{}
func fn_must_panic() (err error) {
    defer func () {
        switch p := recover(); p {
            case nil:
                //donoting
            case shouldRecover{}:
      err = fmt.Errorf("occur panic but had recovered")
        default:
            panic(p)
        }
    } ()
    func () {
        func () int {
            panic(shouldRecover{})
            //panic(emptyStruct{})
            x := 0
            y := 5/x
            return y
        }()
    }()
    return
}
```

例子中，我们手动抛出一个panic，值是shouldRecover
然后外层使用 `defer + 匿名函数 + recover` 去恢复程序，去除恐慌
发现 panic 的值是 shouldRecover 那么就不退出程序，而是返回error，告诉恐慌原因

## golang的方法

### 方法定义

```
func (type类型参数) 方法名(参数列表) 返回值 {
    定义
}
```
例子
```go
func (t *TestType) testFunc() int {
    // ….do what you want
}
```

t称为接收器，可以是该类型本身，或该类型的指针
> 由于是值传递，所以是接收器是该类型时，会复制值，类型比较大时开销大，可以选择使用指针降低开销
> 如果一个类型低层实际是一个指针，那么不允许在使用该类型的指针作为接收器

当`使用指针作为接收器时，记得检查是否是nil`

例子

```go
type myInt struct {
    owner string
    value int
}
func (a myInt) Owner(suffix string) string { //golang不支持默认参数
    return a.owner + suffix
}
func (a *myInt) SetOwner(owner string) {
    if a == nil {
        fmt.Println("set owner to nil point is invalid")
        return
    }
    a.owner = owner
}
func (a myInt) SetOwner2(owner string) { //golang函数参数按值传递,所以这个方法实际只是修改临时变量的owner
    a.owner = owner
}
func SetOwner3(a *myInt, owner string) {
    if a == nil {
        fmt.Println("set owner to nil point is invalid")
        return
    }
    a.owner = owner
}
func main() {
    var k = myInt{"kitman", 3}
    fmt.Print(k.value, " ", k.Owner("aa"), "\n") //输出3 kitmanaa
    k.SetOwner("ak") //相当于SetOwner(&k, "ak")
    fmt.Print(k.value, " ", k.Owner("bb"), "\n") //输出3 akbb
    k.SetOwner2("sss") //相当于SetOwner(k, "sss")
    fmt.Print(k.value, " ", k.Owner("bb"), "\n") //输出3 akbb
    SetOwner3(&k, "sss")
    fmt.Print(k.value, " ", k.Owner("bb"), "\n") //输出3 sssbb
    var k2 *myInt = nil
    k2.SetOwner("aa") //输出set owner to nil point is invalid
}
```

### 方法和函数的区别

- 本质上和普通函数一样，就是语法上的差别而已
- 就算给type类型定义方法，函数参数也是按值传递的，所以 `type参数使用指针才能修改变量`
- nil指针也能调用方法，但是如果方法里面没判断指针是否是nil，那么就会 panic
- 方法的值也是第一类变量，能赋值给别的变量，`golang无论是对象方法，还是类型的方法，都能赋值给别的变量`

### 方法妙用

#### golang 面向对象继承语义

可以通过使用匿名成员 + 定义方法，实现部分继承

```go
type Base struct {
    y int
    Y int
}
func (b *Base) FuncByPoint() int {
    if (b == nil) {
        return 0;
    }
    return b.y*b.Y
}
func (b Base) FuncByValue() int {
    return b.y*b.Y
}
type Child struct {
    Base
    x int
    X int
}
func (c *Child) FuncByPoint() int {
    if (c == nil) {
        return 0
    }
    return c.x*c.X
}
```
