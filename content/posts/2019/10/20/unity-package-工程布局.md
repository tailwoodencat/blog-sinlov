---
title: "unity package 工程布局"
date: 2019-10-20T20:01:00+00:00
description: "unity package 工程布局 介绍和 upm 规范介绍"
draft: false
categories: ['unity']
tags: ['unity']
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

> 引用官方文档版本基于 `Unity 2019.4`
> 本说明生效于 `Unity 2019.3 或更高版本` 以后 [database2 资源数据库版本](https://docs.unity.cn/cn/2019.4/Manual/AssetDatabase.html#version)
> `请务必升级 Unity 2019.3 以上`后使用

## 包基础布局

布局继承于官方布局 [2019.4 创建自定义包 > 包布局](https://docs.unity.cn/cn/2019.4/Manual/cus-layout.html)

最新布局见官方文档 [CustomPackages](https://docs.unity3d.com/Manual/CustomPackages.html)

- 例子以命名空间为 `GroupName.Unity.ModuleName` 作为例子

```bash
# unity 定义的 package 等同于 npm 定义的 module, 且 module(模组) 包含更多内容，且不容易跟 package xx(xx包) 之类概念冲突，故使用 module 更贴切
# 命名格式 [GroupName].Unity.[ModuleName] 为包命名空间 后面简称 [PkgNamespace];
.
├── README.md # package 说明文档，将显示在 git 仓库或者 npm 包的首页
├── CHANGELOG.md # 修改日志，可以使用 conventional-changelog 工具读取 git log 和 package.json 自动生成
├── Documentation~ # 包详细说明文档，在发布的包中，路径为 Documentation~ (末尾~自带忽略效果)，故 README.md 中写相对路径无效
├── LICENSE.md # 授权说明 (可选)
├── Makefile # make构建配置文件(可选)，熟悉其他构建脚本工具的可以换成其他配置文件
├── Resources # 资源文件夹 (可选)，当然也可以包括 StreamingAssets Gizmos 之类资源，这里不列举，对外发布必须带有的资源在这个文件夹
├── Plugins # native插件(可选) 会被自动包含进build中去，这里只列举几个平台
│ ├── README.md
│ ├── Android # - Android 平台下的 native 插件
│ ├── iOS # - iOS 平台下的 native 插件
│ └── x86_64 # - x64 平台下的 native 插件
├── Runtime # 运行程序目录 这里面的代码会被打到最终发布包里，并且不要直接在这个目录下写代码
│ ├── [GroupName].Unity.[ModuleName].Runtime.asmdef # - 运行程序集定义 注意：只包含一个定义文件，命名格式 [PkgNamespace].Runtime, 可省略后面的 .Runtime
│ ├── Singleton # -- 运行程序包文件夹
│ │ └── [ModuleName].Runtime.Singleton.cs
│ └── [ModuleName] # -- 运行程序包文件夹
│ ├── Definition.cs
│ ├── [ModuleName].cs
│ ├── [ModuleNameData].cs
│ └── [ModuleNameEnum].cs
├── Editor # 编辑器文件夹(可选) 开发编辑器用到的一些资源或者代码，不会被打到最终发布包里, 并且不要直接在这个目录下写代码
│ ├── [GroupName].Unity.[ModuleName].Editor.asmdef # - 编辑器程序集定义(可选) 注意：建议只包含一个定义文件，命名格式 [PkgNamespace].Editor
│ ├── Default # -- 不分平台，或者默认情况下，请将代码写在这个目录中
│ │ └── [ModuleName].Editor.cs
│ ├── Android # -- 编辑器 android 平台的代码目录
│ │ └── [ModuleName].Editor.Android.cs
│ └── iOS # -- 编辑器 iOS 平台的代码目录
│ └── [ModuleName].Editor.iOS.cs
├── Tests # 测试程序目录，这里面的代码不会被打到最终发布包里，并且不要直接在这个目录下写代码
│ ├── Editor # - 测试编辑器程序文件夹 (可选) ，不要直接在这个目录下写代码
│ │ ├── [GroupName].Unity.[ModuleName].Editor.Tests.asmdef # - 测试编辑器程序集定义(可选) 注意：建议只包含一个定义文件，命名格式 [PkgNamespace].Editor.Tests
│ │ ├── Default # -- 不分平台，或者默认情况下，请将代码写在这个目录中
│ │ │ └── [ModuleName].Editor.Default.Tests.cs
│ │ ├── Android # -- 测试编辑器程序平台 Android 文件夹
│ │ │ └── [ModuleName].Editor.Android.Tests.cs
│ │ └── iOS # -- 测试编辑器程序平台 iOS 文件夹
│ │ └── [ModuleName].Editor.iOS.Tests.cs
│ └── Runtime # - 测试运行程序文件夹 (可选) ，不要直接在这个目录下写代码
│ ├── [GroupName].Unity.[ModuleName].Runtime.Tests.asmdef # - 测试运行程序集定义(可选) 注意：建议只包含一个定义文件，命名格式 [PkgNamespace].Runtime.Tests
│ ├── Base # -- 测试基础代码文件夹
│ │ └── BaseTests.cs
│ └── [ModuleNameTest] # -- 测试运行时代码文件夹，格式为 [ModuleName]Test
│ └── [ModuleNameTest].cs # -- 测试运行代码文件，如果为单元测试，则为对应单元测试的代码文件附加 Test 命名
├── package-lock.json # 不能提交，会导致 源码开发时，编译警告
└── package.json # module 配置，注意: 如果使用源码依赖开发，请不要配置 dependencies 而在发布到 npm 时填充依赖配置
```

编译警告内容
```bash
A meta data file (.meta) exists but its asset 'Packages/xxx/package-lock.json' can't be found. When moving or deleting files outside of Unity, please ensure that the corresponding .meta file is moved or deleted along with it.
```

这个警告是 unity Assets 文件夹下，每个文件必须配置 `.meta` 配置管理文件导致的，可以自己生成一个 `.meta` 或者在 Unity 编辑器下调试插件生成一个解决

- 简化版的工程结构

```bash
# unity 定义的 package 等同于 npm 定义的 module, 且 module(模组) 包含更多内容，且不容易跟 package xx(xx包) 之类概念冲突，故使用 module 更贴切
# 命名格式 [GroupName].Unity.[ModuleName] 为包命名空间 后面简称 [PkgNamespace];
.
├── README.md # package 说明文档，将显示在 git 仓库或者 npm 包的首页
├── CHANGELOG.md # 修改日志，可以使用 conventional-changelog 工具读取 git log 和 package.json 自动生成
├── Documentation~ # 包详细说明文档，在发布的包中，路径为 Documentation~ (末尾~自带忽略效果)，故 README.md 中写相对路径无效
├── Makefile # make构建配置文件(可选)，熟悉其他构建脚本工具的可以换成其他配置文件
├── Plugins # native插件(可选) 会被自动包含进build中去，这里只列举几个平台
│ ├── README.md
│ ├── Android # - Android 平台下的 native 插件
│ ├── iOS # - iOS 平台下的 native 插件
│ └── x86_64 # - x64 平台下的 native 插件
├── Runtime # 运行程序目录 这里面的代码会被打到最终发布包里，并且不要直接在这个目录下写代码
│ ├── [GroupName].Unity.[ModuleName].Runtime.asmdef # - 运行程序集定义 注意：只包含一个定义文件，命名格式 [PkgNamespace].Runtime, 可省略后面的 .Runtime
│ ├── Singleton # -- 运行程序包文件夹
│ │ └── [ModuleName].Runtime.Singleton.cs
│ └── [ModuleName] # -- 运行程序包文件夹
│ ├── Definition.cs
│ ├── [ModuleName].cs
│ ├── [ModuleNameData].cs
│ └── [ModuleNameEnum].cs
├── Editor # 编辑器文件夹(可选) 开发编辑器用到的一些资源或者代码，不会被打到最终发布包里, 并且不要直接在这个目录下写代码
│ ├── [GroupName].Unity.[ModuleName].Editor.asmdef # - 编辑器程序集定义(可选) 注意：建议只包含一个定义文件，命名格式 [PkgNamespace].Editor
│ ├── Default # -- 不分平台，或者默认情况下，请将代码写在这个目录中
│ │ └── [ModuleName].Editor.cs
│ ├── Android # -- 编辑器 android 平台的代码目录
│ │ └── [ModuleName].Editor.Android.cs
│ └── iOS # -- 编辑器 iOS 平台的代码目录
│ └── [ModuleName].Editor.iOS.cs
├── package-lock.json # 依赖版本记录
└── package.json # module 配置，注意: 如果使用源码依赖开发，请不要配置 dependencies 而在发布到 npm 时填充依赖配置
```

