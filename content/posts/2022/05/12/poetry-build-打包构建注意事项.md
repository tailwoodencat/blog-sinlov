---
title: "poetry build 打包构建注意事项"
date: 2022-05-12T11:42:57+08:00
description: "poetry build 打包构建 和 工程目录结构注意"
draft: false
categories: ['python']
tags: ['python']
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

## 找不到打包目标

### 失败日志

```bash
$ poetry build
Building playground_1 (0.1.0)

No file/folder found for package playground
```

### 原因

-   `pyproject.toml` 的 name 设定不符合，或者本地目录找不到

### 修复方法

- poetry 设定的 name 和 build 的程序应用程序代码的目录，不可以乱设置
- 可以是对应模块目录，也可以是 `src/` 下的对应模块目录


## poetry 工程目录结构注意

虽然官方有支持 path 本地依赖 [https://python-poetry.org/docs/dependency-specification#path-dependencies](https://python-poetry.org/docs/dependency-specification#path-dependencies)

```
[tool.poetry.dependencies]
# directory
my-package = { path = "../my-package/", develop = false }

# file
my-package = { path = "../my-package/dist/my-package-0.1.0.tar.gz" }
```

实际上，会有依赖管理问题，报错如下

```log
Directory ... does not seem to be a Python package
```

实际这个目录是完整的 python 包代码