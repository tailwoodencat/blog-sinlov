---
title: "unreal engine 工程构建辅助工具 ue4cli"
date: 2024-05-16T21:57:58+08:00
description: "介绍 UE 构建辅助工具 ue4cli 的使用 和技巧"
draft: false
categories: ['unreal']
tags: ['unreal']
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

## 介绍

Ue4cli Python软件包实现了一个名为 `ue4` 的命令行工具，为 Epic Games的 虚幻引擎 的构建系统的各种功能提供了简化的界面。该工具的主要目标如下：

- 抽象分散在引擎源树中的各种批处理文件和 shell 脚本的平台特定细节
- 提供在 Linux 下轻松生成 IDE项目文件的能力，目前不存在从编辑器外部执行此任务的 shell 集成。
- 确定构建在引擎模块中使用的第三方库所需的编译器标志。这在 macOS 和 Linux 下尤为重要，符号插入可能导致外部库与引擎源代码树的第三方目录中捆绑库之间的冲突，在 Linux 下，库需要针对引擎的捆绑版 libc++ 构建

> ue4cli需要Python 3.5或更新版本，并作为虚幻引擎4.19.0或更新版本的接口，实际上 UE 5 也支持

- 官方文档 [https://docs.adamrehn.com/ue4cli/overview/introduction-to-ue4cli](https://docs.adamrehn.com/ue4cli/overview/introduction-to-ue4cli)
- 源码地址 [https://github.com/adamrehn/ue4cli](https://github.com/adamrehn/ue4cli)

## 使用前知识

- [Installed Build Reference Guide](https://dev.epicgames.com/documentation/en-us/unreal-engine/installed-build-reference-guide-for-unreal-engine)
- [创建引擎的已安装构建](https://dev.epicgames.com/documentation/en-us/unreal-engine/create-an-installed-build-of-unreal-engine)

## 安装

```bash
pip install ue4cli
# 检查安装
ue4 --help
```

### ue4cli 插件支持

官方插件：

[conan-ue4cli](https://github.com/adamrehn/conan-ue4cli)：提供生成和使用 [conan](https://conan.io/) 软件包的功能，这些软件包包装了捆绑在 Unreal Engine 的 `Engine/Source/ThirdParty` 子目录中的第三方库

社区维护的插件：

[ctags-ue4cli](https://github.com/drichardson/ctags-ue4cli/): provides functionality for building ctags for Unreal Engine projects and plugins using [Universal Ctags](https://github.com/universal-ctags/ctags).

## 使用方法

使用前，需要设置 UE 安装路径，这个路径得指定到具体的版本上

> 比如 `UE_5.4`安装在 `D:\games\EpicGames\UE_5.4`

### 构建环境设置 windows

- 构建前设置

```bash
## 设置 UE 引擎目录
ue4 setroot <ROOTDIR>
# ue5.4
ue4 setroot D:\games\EpicGames\UE_5.4

## 显示 UE 引擎设置
ue4 root
## 显示 当前使用的 UE 版本
ue4 version
```

### 构建环境设置 macOS

```bash
## 设置 UE 引擎目录
ue4 setroot <ROOTDIR>
# ue5.4
ue4 setroot '/Users/Shared/Epic Games/UE_5.4'

## 显示 UE 引擎设置
ue4 root
## 显示 当前使用的 UE 版本
ue4 version
```

### 根据工程自动切换 UE 版本

在工程下创建文件 `ue4cli/config.json` 内容为

```json
{"rootDirOverride": "/Users/Shared/Epic Games/UE_5.3"}
```
然后在当前工程，执行设置环境变量

```bash
# bash zsh
export UE4CLI_CONFIG_DIR="$PWD/ue4cli"

# powershell
$env:UE4CLI_CONFIG_DIR="$PWD/ue4cli"
```

然后在改变过的 环境变量下执行检查

```bash
ue4 version
```

### 项目辅助(最常用)

```bash
## 清理构建缓存
# 这个功能很常用，ue 的构建缓存是出名的烂
# 如果在当前目录中找不到.uproject或.uplugin文件，那么ue4cli将发出错误并停止执行
# 默认清理 Binaries Intermediate 目录
ue4 clean

## 在没有虚幻项目的情况下运行编辑器（用于创建新项目）
ue4 editor [EXTRA ARGS]

## 为虚幻项目生成IDE项目文件
# Linux和macOS下的源构建和已安装构建将调用 GenerateProjectFiles.sh ，它支持命令行参数。指定的任何其他参数将直接传递给脚本
# Windows下的源构建将调用 GenerateProjectFiles.bat ，它支持命令行参数。指定的任何其他参数都将直接传递给脚本
ue4 gen [EXTRA ARGS]

## 运行虚幻项目的编辑器
# 这个命令可以用于 UE 编辑器插件的开发，或者查找工程构建问题
# 如果在当前目录中找不到 .uproject 或 .uplugin 文件，那么ue4cli将发出错误并停止执行
# 默认情况下，编辑器将与当前目录中虚幻项目的 .uproject文件路径一起调用，以及确保在Windows下打印日志输出的 -stdout 和 -FullStdOutLogOutput 标志。指定的任何其他参数都将附加到这些标志中
# --debug标志是Editor的-debug参数的别名，纯粹是为了方便而提供的
ue4 run [--debug] [EXTRA ARGS]

## 清理 root
# 删除路径为 `ue4 setroot` 设定的任何 previously-specified 内容
# 修改引擎的时候会用到这个工具
ue4 clearroot
```

### 构建项目 ue4 build

为虚幻项目 或 插件构建 模块

- 如果在当前目录中找不到 `.uproject` 或 `.uplugin` 文件，那么 ue4cli 将发出错误并停止执行

```bash
ue4 build [CONFIGURATION] [TARGET] [EXTRA UBT ARGS]
```

第一个可选参数用于指定要构建的构建配置，可以是任何支持构建编辑器目标的有效[虚幻引擎构建配置状态 Unreal Engine build configuration states](https://docs.unrealengine.com/en-us/Programming/Development/BuildConfigurations)（如果为项目构建非编辑器目标，则为任何有效的配置）：

- Debug
- DebugGame
- Development

如果没有明确指定构建配置，则默认情况下将构建 `Development`

在构建虚幻项目时，可以使用第二个可选参数来指定要构建的自定义目标，该目标可以是任何有效的[Unreal Engine build configuration targets](https://docs.unrealengine.com/en-us/Programming/Development/BuildConfigurations)：

- Editor
- Client
- Server

如果未明确指定目标，则默认构建 `Editor` 目标。构建Unreal插件时忽略此参数

Examples:

```bash
# Build the Editor modules for a project or plugin using the default Development configuration
ue4 build

# Build the Editor modules for a project or plugin, explicitly using the Development configuration
ue4 build Development

# Build the Editor modules for a project or plugin using the Shipping configuration
ue4 build Shipping

# Build the Editor modules for a project using the Development configuration
ue4 build Development Editor

# Build the Editor modules for a project using the Shipping configuration
ue4 build Shipping Editor

# Build the Client target for a project using the Development configuration
# (This only works if you've defined a Client target .Build.cs file)
ue4 build Development Client

# Build the Server target for a project using the Development configuration
# (This only works if you've defined a Server target .Build.cs file)
ue4 build Development Server
```

### 工程打包 ue4 package

在当前目录中打包虚幻项目或插件的构建

- 如果在当前目录中找不到 `.uproject` 或 `.uplugin` 文件，那么 ue4cli 将发出错误并停止执行
- 打包的构建将放置在当前工作目录（`distribution`的缩写）中一个名为`dist`的子目录中

Usage syntax for projects:

```bash
ue4 package [CONFIGURATION] [EXTRA UAT ARGS]
```

Usage syntax for plugins:

```bash
ue4 package [EXTRA UAT ARGS]
```

打包项目时，第一个可选参数用于指定要构建和打包的构建配置，可以是任何有效的[虚幻引擎构建配置](https://docs.unrealengine.com/en-us/Programming/Development/BuildConfigurations)：

- Debug
- DebugGame
- Development
- Shipping
- Test

如果没有明确指定构建配置，则默认情况下将构建和打包 `Shipping`

> 请注意，插件始终打包在开发和发布配置中。打包插件时不要指定构建配置参数，因为这会混淆UAT！

指定的任何附加参数将直接传递给RunUAT，以及正在打包的描述符类型（项目或插件）的适当默认参数。请注意，在打包项目并将附加参数传递给RunUAT时，必须指定构建配置

打包项目的默认参数是：

```
BuildCookRun
  -platform=<PLATFORM>
  -project=<PROJECT_FILE>
  -clientconfig=<BUILD_CONFIGURATION>
  -serverconfig=<BUILD_CONFIGURATION>
  -noP4
  -cook
  -allmaps
  -build
  -stage
  -prereqs
  -pak
  -archive
  -archivedirectory=<PROJECT_DIR>/dist
```

这些默认值将自动适应任何用户指定的参数：

- `-platform=<PLATFORM>` 参数可以用用户指定的值重写
- 如果指定了 `-server` 标志，那么平台值也将用于生成适当的 `-serverplatform=<PLATFORM>` 参数
- 仅当 `-noclient` 标志不存在时，才会包含 `-allmaps` 标志

打包插件的默认参数是：

```
BuildPlugin
  -Plugin=<PLUGIN_FILE>
  -Package=<PROJECT_DIR>/dist
```

### 测试构建 ue4 test

此命令为位于当前工作目录中的[虚幻项目运行自动化测试](https://docs.unrealengine.com/en-us/Programming/Automation)

- 如果在当前目录中找不到 `.uproject` 或 `.uplugin` 文件，那么 ue4cli 将发出错误并停止执行
- 默认情况下，自动化测试将在禁用渲染的情况下运行，这允许它们在无法访问GPU加速的环境中运行。如果您需要启用渲染，那么您可以通过指定 `--withrhi` 标志来做到这一点

```bash
ue4 test [--withrhi] [--list] [--all] [--filter FILTER] TEST1 TEST2 TESTN
```

> 请注意，由于自动化测试输出在测试运行时由ue4cli缓冲在内存中，因此在所有测试完成之前不会看到任何输出。

此命令的行为取决于指定的参数：

- 如果指定了 `--list` 标志，那么ue4cli将简单地打印虚幻项目的可用自动化测试列表并停止执行
- 如果指定了 `--all` 标志，那么ue4cli将为虚幻项目运行所有可用的自动化测试。请注意，这包括全引擎自动化测试，可能需要相当长的时间才能完成
- 如果指定了 `--filter` 标志，那么ue4cli将为与指定过滤器匹配的虚幻项目运行所有自动化测试。有效的过滤器是
	- Engine
	- Smoke
	- Stress
	- Perf
	- Product (这是您最有可能用于运行特定于您的项目及其包含的任何插件的自动化测试的过滤器)
- 如果没有指定上述标志，那么ue4cli将运行名称已明确指定的自动化测试

### Library Commands

#### ue4 libs

列出与虚幻引擎安装捆绑的第三方库

```bash
ue4 libs
```

此命令将打印与ue4cli当前用作接口的虚幻引擎安装捆绑的所有可用第三方库的名称列表。然后，这些名称可以用作其他库相关命令的参数，以检索有关任何给定库的进一步信息

#### ue4 defines

打印指定库的预处理器定义

```bash
ue4 defines [--nodefaults] [LIBS]
```

此命令打印指定库列表的预处理器定义。（要确定可用的库名称，请运行ue4 libs命令。）

- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用。

#### ue4 includedirs

打印标题包括指定库的目录

```bash
ue4 includedirs [--nodefaults] [LIBS]
```

此命令打印到标头的路径，包括指定库列表的目录。（要确定可用的库名称，请运行ue4 libs命令。）

- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用。

#### ue4 libfiles

打印指定库的库文件

```bash
ue4 libfiles [--nodefaults] [LIBS]
```

此命令打印指定库列表的库文件的路径。（要确定可用的库名称，请运行ue4 libs命令。）

- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用。

#### ue4 cmakeflags

此命令打印根据指定的库列表构建所需的CMake标志。（要确定可用的库名称，请运行 `ue4 libs` 命令。）生成的标志包括CMAKE_PREFIX_PATH、CMAKE_INCLUDE_PATH和CMAKE_LIBRARY_PATH

```bash
ue4 cmakeflags [--multiline] [--nodefaults] [LIBS]
```

- 如果指定了 `--multiline` 标志，那么每个标志将打印在单独的行上。默认是将所有标志打印在一行上，以空格分隔
- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用。

#### ue4 cxxflags

打印编译器标志，以便针对指定的库进行构建

此命令打印针对指定的库列表构建所需的编译器标志。（要确定可用的库名称，请运行ue4 libs命令。）

```bash
ue4 cxxflags [--multiline] [--nodefaults] [LIBS]
```

- 如果指定了 `--multiline` 标志，那么每个标志将打印在单独的行上。默认是将所有标志打印在一行上，以空格分隔
- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用。

#### ue4 ldflags

打印链接器标志，以针对指定的库进行构建

```bash
ue4 ldflags [--multiline] [--flagsonly] [--nodefaults] [LIBS]
```

此命令打印链接到指定库列表所需的链接器标志。（要确定可用的库名称，请运行ue4 libs命令。）

- 如果指定了 `--multiline` 标志，那么每个标志将打印在单独的行上。默认是将所有标志打印在一行上，以空格分隔
- 如果指定了 `--flagsonly` 标志，那么只有链接器标志本身（例如指定库目录）将打印，末尾没有实际的库名称。默认也是打印库名称，因为这些是您与库链接时将运行的实际链接器命令的一部分
- 如果在Linux下运行时指定了 `--nodefaults` 标志，则针对libc++构建的详细信息将不包含在输出中。这个标志在macOS和Windows下没有任何作用

### ue4 uat

使用指定的参数调用RunUAT

```bash
ue4 uat [ARGS]
```

> 可以由RunUAT执行的大多数常见用例已经具有由其他ue4cli命令（例如 ue4 build 、ue4 test 和 ue4 package ）提供的更简单的接口。直接调用RunUAT仅用于高级使用。

此命令在

- Linux和macOS下调用 `RunUAT.sh` shell脚本
- 在Windows下调用 `RunUAT.bat` 批处理文件

此脚本是虚幻自动化工具的命令行界面，可用于执行各种任务。常见用途包括：

- 建筑和包装项目
- 运行自动化测试
- 运行 [BuildGraph](https://dev.epicgames.com/documentation/en-us/unreal-engine/buildgraph-for-unreal-engine) 脚本（例如 [创建引擎的已安装构建](https://dev.epicgames.com/documentation/en-us/unreal-engine/create-an-installed-build-of-unreal-engine) ）

指定的任何参数都将直接传递给RunUAT脚本，并添加以下内容：

- 如果没有指定 `-platform=<PLATFORM>` 参数，则该参数将注入当前系统平台的值（例如`Linux`、`Mac`、`Win64` 等）
- 如果没有指定 `-project=<PROJECT>` 参数，ue4cli 将在当前工作目录中查找 `.uproject` 文件，并将以项目文件的路径作为其值注入此参数。
