---
title: "Android Multiple substitutions specified in non positional format"
date: 2018-09-07T23:53:05+08:00
description: "desc Android Multiple substitutions specified in non positional format"
draft: false
categories: ['Android']
tags: ['Android']
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

# 错误日志

```bash
Multiple substitutions specified in non-positional format; did you mean to add the formatted=”false” attribute?
```

# 原因

错误的设置 string xml 的内容

```xml
<string name="cpu_cur_freq">code -> %d message: %s</string>
```

# 修复

- 按下标填充

`% 改为 %1$s，其中1表示填充下标`

```xml
<string name="cpu_cur_freq">code -> %1$d message: %2$s</string>
```

- 如果不需要填充，可以加入配置

```xml
<string name="cpu_cur_freq" formatted="false">code -> %d message: %s</string>
```
