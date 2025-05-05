---
title: "unity openupm 使用"
date: 2021-08-17T19:30:00+00:00
description: "desc unity openupm 使用"
draft: false
categories: ['unity']
tags: ['unity', 'game']
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

## 官方文档

- 官方文档[https://github.com/openupm/openupm-cli](https://github.com/openupm/openupm-cli)
- 中文文档[https://github.com/openupm/openupm-cli/blob/master/README.zh-cn.md](https://github.com/openupm/openupm-cli/blob/master/README.zh-cn.md)

### 使用前注意

版本支持

-  `Unity 2019.3.4f1` 及以上
- node 6+

> 其实 unity editor 本身内置了一套 node 环境

## 基础使用

- 首先请安装好 node 12+

```bash
$ npm install -g openupm-cli
# 或者 yarn
$ yarn global add openupm-cli
```

### 查询包

```bash
# 例子：查看中国区软件包
$ openupm view com.littlebigfun.addressable-importer --cn
# 或
$ openupm-cn view com.littlebigfun.addressable-importer

# 例子：查看美国区软件包
$ openupm view com.littlebigfun.addressable-importer
```

### 工程指令

> 注意：工程指令需要在 unity 工程根目录执行，不是项目根目录

```bash
$ openupm-cn add <pkg> [otherPkgs..]
$ openupm-cn add <pkg>@<version>
$ openupm-cn add <pkg>@git@github.com:...
$ openupm-cn add <pkg>@https://github.com/...
$ openupm-cn add <pkg>@file:...
# 安装软件包时，还可以添加将其添加到testables字段
$ openupm-cn --test <pkg>
# 删除软件包
$ openupm-cn remove <pkg> [otherPkgs...]
# 查看软件包的依赖关系
$ openupm-cn deps <pkg>
# 选项--deep查看深度依赖关系
$ openupm-cn deps <pkg> --deep
```

add指令将软件包添加到manifest.json，并同时维护好作用域（scope）字段

> add指令不会验证或解析Git，HTTPS和文件协议的依赖关系。请参考：[https://docs.unity3d.com/Manual/upm-git.html](https://docs.unity3d.com/Manual/upm-git.html)
> 所以，可用性需要在构建时确认

add指令不会安装检验失败的软件包：

该软件包缺少依赖软件包
该软件包指定了一个不存在的依赖软件包版本
该软件包需要更高的Unity编辑器版本
您应该手动解决这些问题，或者添加选项 `-f` 强制执行

### 身份验证

从 Unity 2019.3.4f1 开始，您可以配置 `.upmconfig.toml`文件以使用私有的软件包仓库

openupm-cn login指令可帮助您通过npm服务器进行身份验证并将信息存储到配置文件中

# open upm

[https://openupm.com/packages/add/](https://openupm.com/packages/add/)