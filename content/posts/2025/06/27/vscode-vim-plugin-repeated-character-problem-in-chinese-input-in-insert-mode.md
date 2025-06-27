---
title: "vscode vim 插件 插入模式下中文输入重复字符问题"
date: 2025-06-27T19:24:08+08:00
description: "vscode vim plugin Repeated character problem in Chinese input in insert mode"
draft: false
categories: ['basics']
tags: ['basics', 'vscode']
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

## 问题表现

windows 系统更新后 在插入模式下使用 VSCodeVim 时，中文输入会重复字符

- 跟踪该问题 见[VSCodeVim issues #9668](https://github.com/VSCodeVim/Vim/issues/9668)

### 表现问题环境

```log
Extension (VsCodeVim) version: 1.30.1
VSCode version: 1.101.2
OS: Microsoft Windows 11 专业版 24H2
10.0.26100
26100
```

## 修复方法

[参考 设置 Edit Context](https://code.visualstudio.com/updates/v1_101#_edit-context)

打开设置项 [editor.experimentalEditContextEnabled](vscode://settings/editor.experimentalEditContextEnabled)

或者编辑 配置文件，关闭 `editor.experimentalEditContextEnabled` 临时解决问题

```json
{
	"editor.experimentalEditContextEnabled": false
}
```

虽然按描述 editor.experimentalEditContextEnabled 默认设置为 true。
意味着编辑器的输入现在由 EditContext API 驱动。这修复了许多错误，尤其是与 IME 体验有关的错误，并将为编辑器内更多样、更强大的输入体验铺平道路。

> 实际目前该功能不能打开，影响到 10.0.26100 所有的中文输入法

### 该方法修复可行环境记录

- VSCode version: 1.101.2
- Extension (VsCodeVim) version: 1.30.1

```
OS: Microsoft Windows 11
10.0.26100

# 注意，该环境本身不存在bug， 只在 10.0.26100 存在该问题，修改配置不影响该版本 windows
10.0.22621
```
