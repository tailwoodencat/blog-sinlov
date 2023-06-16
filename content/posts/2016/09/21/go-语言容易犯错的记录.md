---
title: "go 语言容易犯错的记录"
date: 2016-09-21T10:36:22+08:00
description: "收集 go 语言容易被坑的陷阱"
draft: false
categories: ['golang']
tags: ['golang']
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

## 字符串不能为"nil"

`(mismatched types string and nil)`

```golang
package main
func main() {
    var x string = nil //error
    if x == nil { //error
        x = "default"
    }
}

./hello.go:4: cannot use nil as type string in assignment
./hello.go:6: invalid operation: x == nil (mismatched types string and nil)
```

正确的为

```golang
func main() {
    var x string //defaults to "" (zero value)
    if x == "" {
        x = "default"
    }
}
```

## nil 并不能进行比较操作

```bash
invalid operation: nil == nil (operator == not defined on nil)
```

## time.Duration 时间常量定义

报错

```bash
time.Second * connectTimeout (mismatched types time.Duration and int)
```

产生原因

> int and time.Duration are different types. You need to convert the int to a time.Duration

Golang 的和时间相关的可以直接用数字，但不能是 float 浮点型，也不能直接是数值型变量.

```bash
time.Sleep(10* time.Second)  //可以
time.Sleep(time.Duration(yourTime) * time.Second) //可以


time.Sleep(1.1*time.Second) //不可以
time.Sleep(paramsTime*time.Second) //不可以
```

解决方法

```golang
connectTimeout := 10
time.Sleep(time.Duration(connectTimeout) * time.Second)
```

## 时区设置问题
```go
loc, err := time.LoadLocation(locationName)
 if err != nil {
  return err
 }
time.Now().In(loc)
```
在 windows 没用安装 go 开发环境下，是无法工作的
```go
// CST 需要增加 8 个 offerset
loc := time.FixedZone("CST", 8*3600)
time.Now().In(loc)
```

## make 初始化容量

- slice

```golang
make([]int, 2) //创建一个初始元素个数为2的整型数组切片，元素初始值为0
make([]int, 4, 8) //创建一个初始元素个数为4的整型数组切片，元素初始值为0,并预留8个元素的存储空间
```

在 uber 的代码指南里面

- 对应 map 的 make 有要求，一定要限制大小

[https://github.com/uber-go/guide/blob/master/style.md#prefer-specifying-map-capacity-hints](https://github.com/uber-go/guide/blob/master/style.md#prefer-specifying-map-capacity-hints)

- 让 nil 作为有效 slice ，节省空间， 不得用 make

[https://github.com/uber-go/guide/blob/master/style.md#nil-is-a-valid-slice](https://github.com/uber-go/guide/blob/master/style.md#nil-is-a-valid-slice)

- 在 Channel make 的时候，注意，这个值控制了缓冲策略

[https://github.com/uber-go/guide/blob/master/style.md#channel-size-is-one-or-none](https://github.com/uber-go/guide/blob/master/style.md#channel-size-is-one-or-none)

## nil map nil slice 添加数据

```go
package main

func main() {
  var m map[string]string
  m["name"] = "hello"
}
```

这段代码将导致一个 panic

```bash
panic: assignment to entry in nil map
```

> 这是因为代码中只是声明了 map 的类型，却没有为 map 创建底层数组，此时的 map 实际上在内存中还不存在，即 nil map
> nil map 不能直接赋值

```go
func main() {
  var m map[string]string
  m := make(map[string]string)
  m["name"] = "hello"
}
```

同样的，直接对 nil slice 添加数据也是不允许的，因为 slice 的底层也是数组，没有经过 make 函数初始化时，只是声明了 slice 类型，而底层数组是不存在的

```go
func main() {
 var s []int
 s[0] = 1
}
```

产生一个 panic

```bash
runtime error:index out of range
```

正确做法应该是使用 make 函数或者字面量

```go
func main() {
 s := make([]int, 1)
 s[0] = 1
}
```

对 `nil slice使用append函数而不经过make也是有效的`

```go
import "fmt"

func main() {
 var s []int
 s = append(s, 1)
 fmt.Println(s) // s => [1]
}
```

那是因为 slice 本身其实类似一个 struct，它有一个 len 属性，是当前长度，还有个 cap 属性，是底层数组的长度

- append 函数会判断传入的 slice 的 len 和 cap，如果 len 即将大于 cap
- 会调用 make 函数生成一个更大的新数组并将原底层数组的数据复制过来

## `误用:=赋值`导致变量覆盖

这段代码输出是?

```go
import (
 "errors"
 "fmt"
)

func main() {
 i := 2
 if i > 1 {
  i, err := doDivision(i, 2)
  if err != nil {
   panic(err)
  }
  fmt.Println(i)
 }
 fmt.Println(i)
}

func doDivision(x, y int) (int, error) {
 if y == 0 {
  return 0, errors.New("input is invalid")
 }
 return x / y, nil
}
```

输出结果不是设想的

```bash
1
1
```

真实输出是

```bash
1
2
```

这是因为 golang 中变量的作用域范围小到每个词法块，都是一个`单独的作用域`
作用域的内部声明会屏蔽外部同名的声明，而`每个 if 语句都是一个词法块`
也就是会出现

- 如果`在某个 if 语句中`，不小心`用 := 而不是 = 对某个 if 语句外的变量进行赋值`
- 那么`将产生一个新的局部变量`，并`仅在 if 语句中的这个赋值语句后有效`
- `同名的外部变量会被屏蔽`，并且`不会因为这个赋值语句之后的逻辑产生任何变化`

> 实际工作中如果误用，那么产生的 bug 会很隐秘

## 将值传递当成引用传递

在 golang 中， `array` 和 `struct` 都是`值类型`
而 `slice` `map` `chan` 是`引用类型`

写代码的时候，基本都是:

- `引用类型` 的 `slice` 代替 array
- 对于 `struct` 则尽量使用指针

> 这样避免传递变量时复制数据的时间和空间消耗，也避免了无法修改原数据的情况，建议养成这个好习惯

错误的演示

```go
import "fmt"

type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p1 := person{name: "zzy", age: 100}
 p2 := person{name: "dj", age: 99}
 p3 := person{name: "px", age: 20}
 people := []person{p1, p2, p3}
 whoIsDead(people)
 for _, p := range people {
  if p.isDead {
   fmt.Println("who is dead?", p.name)
  }
 }
}

func whoIsDead(people []person) {
 for _, p := range people {
  if p.age < 50 {
   p.isDead = true
  }
 }
}
```

错误如下

- struct 是值类型，所以在赋值给 `p` 的过程中，实际上需要重新生成一份 person 数据，便于 for range 内部使用
- 所以 `p.isDead = true` 这个操作实际上`更改的是新生成的 p 数据，而非 people 中原本的 person`

故 `需要修改数据时，则最好传递 struct 指针`

```go
import "fmt"

type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p1 := &person{name: "zzy", age: 100}
 p2 := &person{name: "dj", age: 99}
 p3 := &person{name: "px", age: 20}
 people := []*person{p1, p2, p3}
 whoIsDead(people)
 for _, p := range people {
  if p.isDead {
   fmt.Println("who is dead?", p.name)
  }
 }
}

func whoIsDead(people []*person) {
 for _, p := range people {
  if p.age < 50 {
   p.isDead = true
  }
 }
}
```

当然，还有另外的方法，使用`索引访问 people 中的 person` ，改动一下 whoIsDead 函数

```go
func whoIsDead(people []person) {
 for i := 0; i < len(people); i++ {
  if people[i].age < 50 {
   people[i].isDead = true
  }
 }
}
```

### map 直接遍历修改的错误

将之前的 `people []person` 改成了 map 结构

```go
import "fmt"

type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p1 := person{name: "aaa", age: 100}
 p2 := person{name: "bbb", age: 99}
 p3 := person{name: "ccc", age: 20}
 people := map[string]person{
  p1.name: p1,
  p2.name: p2,
  p3.name: p3,
 }
 whoIsDead(people)
 if p3.isDead {
  fmt.Println("who is dead?", p3.name)
 }
}

func whoIsDead(people map[string]person) {
 for name, _ := range people {
  if people[name].age < 50 {
   people[name].isDead = true
  }
 }
}
```

运行则会报错

```bash
cannot assign to struct field people[name].isDead in map
```

- map `底层使用了 array 存储数据，并且没有容量限制`
- 随着 map `元素的增多`，需要`创建更大的 array 来存储数据`
- 那么`之前的地址就无效`了，因为数据被复制到了新的更大的 array 中
- 所以 map 中元素是不可取址的，也是不可修改的

报错的意思其实就是不允许修改 map 中的元素

怎么改才能正确呢?

```go
type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p1 := &person{name: "aaa", age: 100}
 p2 := &person{name: "bbb", age: 99}
 p3 := &person{name: "ccc", age: 20}
 people := map[string]*person{
  p1.name: p1,
  p2.name: p2,
  p3.name: p3,
 }
 whoIsDead(people)
 if p3.isDead {
  fmt.Println("who is dead?", p3.name)
 }
}

func whoIsDead(people map[string]*person) {
 for name, _ := range people {
  if people[name].age < 50 {
   people[name].isDead = true
  }
 }
}
```

老套路，依然是使用指针

### 在 interface{} 断言里试图直接修改 struct 属性的错误

```go
type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p := person{name: "zzy", age: 100}
 isDead(p)
}

func isDead(p interface{}) {
 if p.(person).age < 101 {
  p.(person).isDead = true
 }
}
```

报一个编译错误

```bash
cannot assign to p.(person).isDead
```

即使编译通过，代码也是错误的 ，始终要记住 struct 是值类型的数据，请使用指针去操作它

正确做法

```go
import "fmt"

type person struct {
 name string
 age byte
 isDead bool
}

func main() {
 p := &person{name: "zzy", age: 100}
 isDead(p)
 fmt.Println(p)
}

func isDead(p interface{}) {
 if p.(*person).age < 101 {
  p.(*person).isDead = true
 }
}
```

## golang 正则表达式风格RE2

go 为了正则表达式效率，不不符合 RCPE 规则 [Perl Compatible Regular Expressions](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions)

使用[RE2](https://github.com/google/re2/wiki/Syntax) 规则 [wiki https://en.wikipedia.org/wiki/RE2_(software)](https://en.wikipedia.org/wiki/RE2_(software))


规则详情见 [https://code.google.com/p/re2/wiki/Syntax](https://code.google.com/p/re2/wiki/Syntax)
官方文档 [http://golang.org/pkg/regexp/](http://golang.org/pkg/regexp/)

某些表达式无法生效，比如

- `^(?![0-9]+$)(?![a-z]+$)(?![A-Z]+$)[\w]{6,20}$`

## go 1.15 更新后 不能直接 string(uint16)

遇到这个按位转换 uint16 即可，例如

```go
        var context = ""
        var additional = ""
        if len(v) < 1 {
            continue
        }
        if len(v) > 4 {
            rs := []rune(v)
            v = string(rs[:4])
            additional = string(rs[4:])
        }
        temp, err := strconv.ParseInt(v, 16, 32)
        if err != nil {
            context += v
        }
        context += fmt.Sprintf("%c", temp)
        context += additional
```
