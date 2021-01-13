---
title: "golang 浮点型 小数精度及舍入规则"
date: 2018-04-27T18:35:07+08:00
description: "desc golang 浮点型 小数精度及舍入规则"
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

## 精度问题

```go
x := 74.96
y := 20.48
b := x - y
fmt.Println(b) //output: 54.47999999999999

var a = 0.6
fmt.Println(a + 0.7) //output: 1.2999999999999998
```

> 出现浮点数不精确的原因是，浮点数储存至内存中时，2的-1、-2……-n次方不能精确的表示小数部分，所以再把这个数从地址中取出来进行计算就出现了偏差
>> 不是所有的float相加减乘除都一定出现偏差，具体要根据golang实现IEEE 754的情况定

表现为

- float32和float64直接互转会精度丢失, 四舍五入后错误
- int64转float64在数值很大的时候出现偏差
- 两位小数乘100强转int, 比期望值少了1

```go
// case: float32==>float64
// 从数据库中取出80.45, 历史代码用float32接收
var a float32 = 80.45
var b float64
// 有些函数只能接收float64, 只能强转
b = float64(a)
// 打印出值, 强转后出现偏差
fmt.Println(a) //output:80.45
fmt.Println(b) //output:80.44999694824219
// ... 四舍五入保留小数点后1位, 期望80.5, 结果是80.4

// case: int64==>float64
var c int64 = 987654321098765432
fmt.Printf("%.f\n", float64(c)) //output:987654321098765440

// case: int(float64(xx.xx*100))
var d float64 = 1129.6
var e int64 = int64(d * 100)
fmt.Println(e) //output:112959
```

### 解决精度问题

> 思路都是 利用取近似值的方法


#### fmt.Sprintf()

```go
func Round2(f float64, n int) float64 {
    floatStr := fmt.Sprintf("%."+strconv.Itoa(n)+"f", f)
    inst, _ := strconv.ParseFloat(floatStr, 64)
    return inst
}
```

#### math.Trunc()

```go
func Round(f float64, n int) float64 {
    n10 := math.Pow10(n)
    return math.Trunc((f+0.5/n10)*n10) / n10
}
```

## 舍入规则

### 舍入规则说明

`ROUND_HALF_EVEN` 也就是 四舍六入五成双

这是一种比较精确比较科学的计数保留法，是一种数字修约规则，又名银行家舍入法。它比通常用的四舍五入法更加精确

简单规则描述

1. 被修约的数字小于5时，该数字舍去；
1. 被修约的数字大于5时，则进位；
1. 被修约的数字等于5时，要看5前面的数字，若是奇数则进位，若是偶数则将5舍掉，即修约后末尾数字都成为偶数；若5的后面还有不为“0”的任何数，则此时无论5的前面是奇数还是偶数，均应进位。

`四舍六入五考虑，五后非零就进一，五后为零看奇偶，五前为偶应舍去，五前为奇要进一`

> 注意：Golang中浮点数精确到超过14位小数后，该舍入规则将不准确，原因是golang的浮点型最大精确到小数点后15位

相信规则见 [wiki/IEEE_754](https://en.wikipedia.org/wiki/IEEE_754)

#### 验证

Golang中浮点型默认使用银行家舍入法，如下使用代码验证

```go
import (
    "fmt"
)

func main() {
    fmt.Printf("9.8249    =>    %0.2f(四舍)\n", 9.8249)
    fmt.Printf("9.82671    =>    %0.2f(六入)\n", 9.82671)
    fmt.Printf("9.8351    =>    %0.2f(五后非零就进一)\n", 9.8351)
    fmt.Printf("9.82501    =>    %0.2f(五后非零就进一)\n", 9.82501)
    fmt.Printf("9.8250    =>    %0.2f(五后为零看奇偶，五前为偶应舍去)\n", 9.8250)
    fmt.Printf("9.8350    =>    %0.2f(五后为零看奇偶，五前为奇要进一)\n", 9.8350)
}
```

输出

```bash
  9.8249  =>  9.82(四舍)
  9.82671 =>  9.83(六入)
  9.8351  =>  9.84(五后非零就进一)
  9.82501 =>  9.83(五后非零就进一)
  9.8250  =>  9.82(五后为零看奇偶，五前为偶应舍去)
  9.8350  =>  9.84(五后为零看奇偶，五前为奇要进一)
```

## 舍入技巧

可以方便得使用fmt的方法对浮点型进行银行家取舍，取得其近似数

```go
import (
    "fmt"
    "strconv"
)

func main() {
    s := fmt.Sprintf("%0.6f", 17.82671567890123456789987654324567898765432)
    f, _ := strconv.ParseFloat(s, 64)
    fmt.Println(s, f)
}
```

输出

```sh
17.826716 17.826716
```

### golang 四舍五入

```go
import (
    "math"
)

func roundHalfUp(val float64)float64{
    return math.Floor(val +0.5)
}

func roundHalfUp(val float64, places int) float64 {
    var t float64
    f := math.Pow10(places)
    x := val * f
    if math.IsInf(x, 0) || math.IsNaN(x) {
        return val
    }
    if x >= 0.0 {
        t = math.Ceil(x)
        if (t - x) > 0.50000000001 {
            t -= 1.0
        }
    } else {
        t = math.Ceil(-x)
        if (t + x) > 0.50000000001 {
            t -= 1.0
        }
        t = -t
    }
    x = t / f
    if !math.IsInf(x, 0) {
        return x
    }
    return t
}
```
