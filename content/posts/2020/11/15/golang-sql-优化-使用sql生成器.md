---
title: "golang SQL 优化 使用SQL生成器"
date: 2020-11-15T12:55:46+08:00
description: "golang 如何进行SQL优化"
draft: false
categories: ['golang']
tags: ['golang', 'optimization']
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

## 为啥不用ORM？

使用ORM的好处显而易见，能够自动帮我们处理好面向对象和数据库之间的映射

但是目前的ORM有个明显问题，要么使用复杂，要么导致服务器崩溃(内存占用高或者频繁 GC)

## 使用sqlx + squirrel

- sqlx 用法入门 [https://github.com/jmoiron/sqlx/blob/master/sqlx_test.go]
- squirrel 用法参见库里面的测试用例 [https://github.com/Masterminds/squirrel](https://github.com/Masterminds/squirrel)

### 快速例子插入数据

```go
var db *sqlx.DB

// InsertPost 插入帖子
func InsertPost(p Post) (int64, error) {
    now := time.Now()

    sql, args, err := squirrel.Insert("post").Columns(
        "created_at", "updated_at", "app", "user_id", "tag", "content", "comment_count",
    ).Values(now, now, p.App, p.UserID, p.Tag, p.Content, p.CommentCount).ToSql()
    if err != nil {
        return 0, err
    }

    return db.MustExec(sql, args...).LastInsertId()
}
```
从写简单语句的复杂度上来看，上述代码比ORM还是要复杂一些，却又比裸写SQL好一些
squirrel的写法基本上与SQL一致，通过 `ToSql()` 调用，会返回3个参数：sql, args, err
- sql是一条sql 语句
- args是给sql用的参数
- err 表明是否出错

其他例子
```go
import sq "github.com/Masterminds/squirrel"

users := sq.Select("*").From("users").Join("emails USING (email_id)")

active := users.Where(sq.Eq{"deleted_at": nil})

sql, args, err := active.ToSql()

sql == "SELECT * FROM users JOIN emails USING (email_id) WHERE deleted_at IS NULL"
sql, args, err := sq.
    Insert("users").Columns("name", "age").
    Values("moe", 13).Values("larry", sq.Expr("? + 5", 12)).
    ToSql()
```

### squirrel 源码分析

- 首先调用源码
```go
sql, args, err := squirrel.Insert("post").Columns(
    "created_at", "updated_at", "app", "user_id", "tag", "content", "comment_count",
).Values(now, now, p.App, p.UserID, p.Tag, p.Content, p.CommentCount).ToSql()
```

对于 Insert 语句生成

```go
// Insert returns a new InsertBuilder with the given table name.
//
// See InsertBuilder.Into.
func Insert(into string) InsertBuilder {
    return StatementBuilder.Insert(into)
}
```

- 跟进 StatementBuilder.Insert(into)

```go
// Insert returns a InsertBuilder for this StatementBuilderType.
func (b StatementBuilderType) Insert(into string) InsertBuilder {
    return InsertBuilder(b).Into(into)
}
```

- 跟进 InsertBuilder(b).Into(into)

```go
// Into sets the INTO clause of the query.
func (b InsertBuilder) Into(from string) InsertBuilder {
    return builder.Set(b, "Into", from).(InsertBuilder)
}
```

继续 InsertBuilder

```go
type InsertBuilder builder.Builder
type Builder struct {
    builderMap ps.Map
}
// ps.Map 来自 https://godoc.org/github.com/lann/ps，看其描述是 Fully persistent data structures. A persistent data
// structure is a data structure that always preserves the previous version of itself when it is modified. Such data
// structures are effectively immutable, as their operations do not update the structure in-place, but instead always
// yield a new structure.
```

也就是说ps这个库里提供的数据结构，总是会保持其历史内容，而不是直接覆盖。不过不知道目前引入这个库的作用，先按下不表。
后面的 `.Columns` 和 `.Values` ，发现都是差不多的逻辑

- 接下来来看看最重要的 `.ToSql()`

```go
// ToSql builds the query into a SQL string and bound args.
func (b InsertBuilder) ToSql() (string, []interface{}, error) {
    data := builder.GetStruct(b).(insertData)
    return data.ToSql()
}
```

- 先看 builder.GetStruct

```go
// GetStruct builds a new struct from the given registered builder.
// It will return nil if the given builder's type has not been registered with
// Register or RegisterValue.
//
// All values set on the builder with names that start with an uppercase letter
// (i.e. which would be exported if they were identifiers) are assigned to the
// corresponding exported fields of the struct.
//
// GetStruct will panic if any of these "exported" values are not assignable to
// their corresponding struct fields.
func GetStruct(builder interface{}) interface{} {
    structVal := newBuilderStruct(reflect.TypeOf(builder))
    if structVal == nil {
        return nil
    }
    return scanStruct(builder, structVal)
}
```

所以是这样的，通过传入 InsertBuilder 这个类型
```go
structVal := newBuilderStruct(reflect.TypeOf(builder))
```
输出一个 `insertData 的struct实例`
再通过 `scanStruct(builder, structVal)` 把之前存储的值放到struct里
这里就要使用到 `Go的反射` 而之所以能通过 InsertBuilder 找到 insertData

是因为 `insert.go` 里有这样几行代码：
```go
func init() {
    builder.Register(InsertBuilder{}, insertData{})
}
```

因此在这里我们就拿到了一个 `insertData` 的实例，我们之前链式调用的值都保存在里面了，我们来看看这个struct长啥样：

```go
type insertData struct {
    PlaceholderFormat PlaceholderFormat
    RunWith           BaseRunner
    Prefixes          exprs
    Options           []string
    Into              string
    Columns           []string
    Values            [][]interface{}
    Suffixes          exprs
    Select            *SelectBuilder
}
```

然后看看 `ToSql` 函数的实现：

```go
func (d *insertData) ToSql() (sqlStr string, args []interface{}, err error) {
if len(d.Into) == 0 {
    err = errors.New("insert statements must specify a table")
    return
}
if len(d.Values) == 0 && d.Select == nil {
    err = errors.New("insert statements must have at least one set of values or select clause")
    return
}

sql := &bytes.Buffer{}

if len(d.Prefixes) > 0 {
    args, _ = d.Prefixes.AppendToSql(sql, " ", args)
    sql.WriteString(" ")
}

sql.WriteString("INSERT ")

if len(d.Options) > 0 {
    sql.WriteString(strings.Join(d.Options, " "))
    sql.WriteString(" ")
}

sql.WriteString("INTO ")
sql.WriteString(d.Into)
sql.WriteString(" ")

if len(d.Columns) > 0 {
    sql.WriteString("(")
    sql.WriteString(strings.Join(d.Columns, ","))
    sql.WriteString(") ")
}

if d.Select != nil {
    args, err = d.appendSelectToSQL(sql, args)
} else {
    args, err = d.appendValuesToSQL(sql, args)
}
if err != nil {
    return
}

if len(d.Suffixes) > 0 {
    sql.WriteString(" ")
    args, _ = d.Suffixes.AppendToSql(sql, " ", args)
}

sqlStr, err = d.PlaceholderFormat.ReplacePlaceholders(sql.String())
return
}
```

很明显，就是各种根据所输入的条件，进行SQL拼接
