---
title: "golang json 使用详解"
date: 2018-04-27T10:45:05+08:00
description: "golang json 使用，以及各种奇技淫巧"
draft: false
categories: ['golang']
tags: ['golang', 'json']
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

# json 在 golong 中定义

| 数据类型 | JSON  | 默认值 json | Golang| 默认值 go |
| :------- | :----- | :------ |:----- | :------ |
| 空值 | null | null | nil | nil |
| 布尔 | bool | false |  bool | false |
| 字串 | string | `""` | string | `""` |
| 整数 | number | 0  | int64 | 0 |
| 浮点数 | number | 0 | float64 | 0 |
| 数组 | arrary |  `[]` | slice | 初始化 `[]` ，未初始化为 nil |
| 对象 | object | null | struct | 初始化 则为 struct 自己的默认值，未初始化为 nil |

# json序列化使用 encoding/json

golang提供了 encoding/json 的标准库用于编码json

> go 1.12 以后，`encoding/json` 的性能问题已经很不明显了，当然特殊需求的时候，还是需要三方库来解决

## 编码流程
- 定义json结构体

```go
type Account struct {
    Email string
    password string
    Money float64
}
```

> 定义结构体的时候，只有字段名是大写的，才会被编码到json当中

- 使用 Marshal方法序列化

```go
    ccount := Account{
        Email: "mine@gmail.com",
        password: "123456",
        Money: 100.0,
    }
    rs, err := json.Marshal(account)
```
## 复合结构编码

相比字串，数字等基本数据结构，slice(切片)，map(图)则是复合结构

> 定义能让 encode/json 识别 map 的key必须是字串，而 value 必须是同一类型的数据

```go
type User struct {
    Name string
    Roles []string
    Skill map[string]float64
}
func main() {
    skill := make(map[string]float64)
    skill["python"] = 99.5
    skill["elixir"] = 90
    skill["ruby"] = 80.0
    user := User{
        Name:"mine",
        Roles: []string{"Owner", "Master"},
        Skill: skill,
    }
    rs, err := json.Marshal(user)
}
```

## 嵌套编码

slice和map可以匹配json的数组和对象，当前提是对象的value是同类型的情况
更通用的做法，对象的key可以是string，但是其值可以是多种结构。
golang可以通过定义结构体实现这种构造

```go
type User struct {
    Name string
    Roles []string
    Skill map[string]float64
    Account Account
}
func main() {
    user := User{
        Name:"abc",
        Roles: []string{"Owner", "Master"},
        Skill: skill,
        Account:account,
    }
}
```
- golang的数组或切片，其类型也是一样的，如果遇到不同数据类型的数组，则需要借助空结构来实现

```go
type User struct {
    ...
    Extra []interface{}
}
extra := []interface{}{12345, "hello world"}
user := User{
    ...

    Extra: extra,
}
```

使用空接口，也可以定义像结构体实现那种不同value类型的字典结构。
当空接口没有初始化其值的时候，零值是 nil, 编码成json就是 null

```go
type User struct {
    Name string
    Roles []string
    Skill map[string]float64
    Account Account
    Extra []interface{}
    Level map[string]interface{}
}
func main() {
    level := make(map[string]interface{})
    level["web"] = "Good"
    level["server"] = 90
    level["tool"] = nil
    user := User{
        Name: "mine",
        Roles: []string{"Owner", "Master"},
        Skill: skill,
        Account: account,
        Level: level,
    }
}
```
输出的 json 就会为

```json
{
    ...
    "Extra":null,
    "Level":{
        "server":90,
        "tool":null,
        "web":"Good"
    }
}
```

## StructTag 字段重名

通常json世界中，更盛行小写字母的方式
golang提供了struct tag的方式可以重命名结构字段的输出形式

```go
type Account struct {
    Email string `json:"email"`
    Password string `json:"pass_word"`
    Money float64 `json:"money"`
}
```
### StructTag `-`忽略字段

通常使用marshal的时候，会把结构体的所有除了私有字段都编码到json
而实际开发中，我们定义的结构可能更通用，我们需要某个字段可以导出，但是又不能编码到json中

```go
type Account struct {
    Email string `json:"email"`
    Password string `json:"password,-"`
    Money float64 `json:"money"`
}
```

### StructTag 可选字段 omitempty

当其有值的时候就输出，而`没有值或者零值` 的时候就不输出

```go
type Account struct {
    Email string `json:"email"`
    Password string `json:"password,-"`
    Money float64 `json:"money,omitempty"`
}
```

### StructTag string 选项

在json处理当中，struct tag的string可以起到部分动态类型的效果
有时候输出的json希望是数字的字符串，而定义的字段是数字类型，那么就可以使用string选项

```go
type Account struct {
    Email string `json:"email"`
    Password string `json:"password,omitempty"`
    Money float64 `json:"money,string"`
}
account := Account{
    Password: "123",
    Money: 100.50,
}
```

# golang json 技巧

## 临时忽略struct字段

```go
type User struct {
    Email string        `json:"email"`
    Password string `json:"password"`
}
```
如果想临时忽略 Password 字段，可以这么写

```go
json.Marshal(struct {
    *User
    Password bool `json:"password,omitempty"`
}{
    User: user,
})
```

## 临时添加额外字段

```go
json.Marshal(struct {
    *User
    Token string `json:"token"`
    Password bool `json:"password,omitempty"`
}{
    User: user,
    Token: token,
})
```
> 添加token字段，并且临时忽略掉Password字段

## 临时合并两个struct

```go
type Link struct {
    URL string `json:"url"`
    Title string `json:"title"`
}
type Statistics {
    PageViews int `json:"page_views"`
    UserVisitors int `json:"user_visitors"`
}
json.Marshal(struct{
    *Link
    *Statistics
}{link, statistics})
```
## json 解析切分成两个struct
- 这里使用上面的 Link 和 Statistics 结构体
```go
json.Unmarshal([]byte(`{
  "url": "mine@admin.com",
  "title": "Home",
  "user_visitors": 6,
  "page_views": 14
}`), &struct {
  *Link
  *Statistics
}{&link, &statistics})
```
## 临时改名struct的字段
```go
type CacheItem struct {
    Key string `json:"key"`
    MaxAge int `json:"cacheAge"`
    Value Value `json:"cacheValue"`
}
json.Marshal(struct{
    *CacheItem
    // Omit bad keys
    OmitMaxAge omit `json:"cacheAge,omitempty"`
    OmitValue omit `json:"cacheValue,omitempty"`
    // Add nice keys
    MaxAge int `json:"max_age"`
    Value *Value `json:"value"`
}{
    CacheItem: item,
    // Set the int by value:
    MaxAge: item.MaxAge,
    // Set the nested struct by reference, avoid making a copy:
    Value: &item.Value,
})
```
> 注意改名可以，但注意类型匹配上

## 用字符串传递数字

同 StructTag string 选项
```go
type TestIntString struct {
    FieldInt int `json:",string"`
}
```
> 注意，这个写法后，json必须为 `{"FieldInt": "100"}` 如果为 {"FieldInt": 100} 不能转换

## 使用 json.Number 处理精度问题

默认情况下，如果是 interface{} 对应数字的情况会是 float64 类型的
如果输入的数字比较大，会有损精度
可以启用 json.Number 来用字符串表示数字

```go
decoder1 := json.NewDecoder(bytes.NewBufferString(`123`))
decoder1.UseNumber()
var obj1 interface{}
decoder1.Decode(&obj1)
should.Equal(json.Number("123"), obj1)
```

> jsoniter 支持标准库的这个用法。同时，扩展了行为使得 Unmarshal 也可以支持 UseNumber
参见 [json-iterator config_test](https://github.com/json-iterator/go/blob/master/api_tests/config_test.go#L40)

## 使用 MarshalJSON 支持 time.Time

golang 默认会把 time.Time 用字符串方式序列化
如果我们想用其他方式表示 time.Time，需要自定义类型并定义 MarshalJSON

```sh
type timeImplementedMarshaler time.Time

func (obj timeImplementedMarshaler) MarshalJSON() ([]byte, error) {
    seconds := time.Time(obj).Unix()
    return []byte(strconv.FormatInt(seconds, 10)), nil
}
// 序列化的时候调用 MarshalJSON
type TestObject struct {
    Field timeImplementedMarshaler
}
should := require.New(t)
val := timeImplementedMarshaler(time.Unix(123, 0))
obj := TestObject{val}
bytes, err := jsoniter.Marshal(obj)
should.Nil(err)
should.Equal(`{"Field":123}`, string(bytes))
```

## 使用 MarshalText 支持非字符串作为key的map

虽然 JSON 标准里只支持 string 作为 key 的 map
golang 通过 MarshalText() 接口，使得其他类型也可以作为 map 的 key

```go
f, _, _ := big.ParseFloat("1", 10, 64, big.ToZero)
val := map[*big.Float]string{f: "2"}
str, err := MarshalToString(val)
should.Equal(`{"1":"2"}`, str)
```
>  big.Float 就实现了 MarshalText()

## 使用 json.RawMessage 处理json格式问题

如果对方发过来的json格式有问题，可以序列到 field 中

```go
type TestObject struct {
    Field1 string
    Field2 json.RawMessage
}
var data TestObject
json.Unmarshal([]byte(`{"field1": "hello", "field2": [1,2,3]}`), &data)
should.Equal(` [1,2,3]`, string(data.Field2))
```

## 容忍字符串和数字互转

PHP一个令人崩溃的地方是，`value 值在 数字和字符串之间飘忽不定`
使用 [http://github.com/json-iterator](http://github.com/json-iterator) ，可以启动模糊模式来支持 PHP 传递过来的 JSON

```go
import "github.com/json-iterator/go/extra"
extra.RegisterFuzzyDecoders()

func main() {
    var val string
    jsoniter.UnmarshalFromString(`100`, &val)
    var valF float32
    jsoniter.UnmarshalFromString(`"1.23"`, &valF)
}
```
## 容忍空数组作为对象

PHP另外一个令人崩溃的地方是
如果 PHP array是空的时候，序列化出来是 `[]`
但是 array 不为空的时候，序列化出来的是 `{"key":"value"}`
所以需要把 [] 当成 {} 处理
解决方法
```go
import "github.com/json-iterator/go/extra"
extra.RegisterFuzzyDecoders()

var val map[string]interface{}
jsoniter.UnmarshalFromString(`[]`, &val)
```

## 使用 RegisterTypeEncoder支持time.Time

json-iterator 能够对不是你定义的type自定义JSON编解码方式
比如对于 time.Time 可以用 epoch int64 来序列化

```go
import "github.com/json-iterator/go/extra"

extra.RegisterTimeAsInt64Codec(time.Microsecond)
output, err := jsoniter.Marshal(time.Unix(1, 1002))
should.Equal("1000001", string(output))
```

## jsoniter 使用私有的字段

Go 的标准库只支持 public 的 field。jsoniter 额外支持了 private 的 field
使用 `SupportPrivateFields()` 来开启开关

```go
import "github.com/json-iterator/go/extra"
extra.SupportPrivateFields()
type TestObject struct {
    field1 string
}
obj := TestObject{}
jsoniter.UnmarshalFromString(`{"field1":"Hello"}`, &obj)
should.Equal("Hello", obj.field1)
```
