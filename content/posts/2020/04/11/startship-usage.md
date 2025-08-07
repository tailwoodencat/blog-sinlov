---
title: "startship 命令行皮肤插件使用"
date: 2020-04-11T12:56:11+03:10
description: "Startship command line skin plug-in use"
draft: false
categories: ['basics']
tags: ['basics', 'dev-kits']
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

- [https://github.com/starship/starship](https://github.com/starship/starship)

Starship 是由 rust 编写的命令行主题，跨平台，简单高效、容易配置

## 安装

### 字体问题

使用主题可以提升使用的体验，但是需要额外的字体支持，不配置字体会出现乱码显示

- 下载字体 [https://www.nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads) 选择字体在分辨 `|1lLiIoO08A` 这种易混淆的情况下好区分的

- 推荐 字体 `Source Code Pro`[download link v3.0.2](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/SourceCodePro.zip)
- 喜欢尝试的 推荐字体 `mononoki Nerd Font` ，非等宽字体，同屏内容会更多 [download link v3.0.2](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Mononoki.zip)

- windows 打开 `C:\Windows\Fonts`，拖拽字体即可安装
- macOS 下载字体文件后，打开 `字体册`，拖拽字体即可安装

需要调整控制台字体配置

- 比如打开 powershell 菜单，选择 `默认值`，选择 `字体`，在 `字体` 中选择 `mononoki Nerd Font`

### windows

```ps1
> scoop install starship

# 或者
> choco install starship -y
```

编辑 PowerShell 配置文件命令为

```ps1
> notepad $profile
# 有 vscode 则使用
> code $profile
```

将以下内容添加到 PowerShell 配置文件的末尾

```ps1
# theme starship init
Invoke-Expression (&starship init powershell)
```

### macOS 安装

```bash
$ brew install starship
$ echo -e '\n\n# for starship\neval "$(starship init zsh)"' >> ~/.zshrc
```

## startship 配置模版

- windows 使用 powershell 创建自定义配置

```ps1
> mkdir -Force -p $Env:USERPROFILE\.config ; code $Env:USERPROFILE\.config\starship.toml
```

- 类 UNIX 系统 使用创建自定义配置

```bash
$ mkidr -p  ~/.config

$ vim ~/.config/starship.toml
# or
$ code ~/.config/starship.toml
```

###  简单模版

```toml
# Get editor completions based on the config schema
"$schema" = 'https://starship.rs/config-schema.json'

# Inserts a blank line between shell prompts
add_newline = true
# fix command timeout
command_timeout = 60000

# Replace the "❯" symbol in the prompt with "➜"
[character] # The name of the module we are configuring is "character"
success_symbol = '[➜](bold green)' # The "success_symbol" segment is being set to "➜" with the color "bold green"
error_symbol = '[➜](bold red) ' # The "error_symbol" segment is being set to "➜" with the color "bold green"
vimcmd_symbol = '[←](bold green)'
vimcmd_replace_one_symbol = '[←](bold purple)'
vimcmd_replace_symbol = '[←](bold purple)'
vimcmd_visual_symbol = '[←](bold yellow)'

[directory]
truncation_length = 9
truncation_symbol = '…/'
truncate_to_repo = false
use_os_path_sep = true

[sudo]
style = 'bold green'
symbol = '🚧 '
disabled = false

# Disable the package module, hiding it from the prompt completely
[package]
disabled = false

[conda]
format = '[$symbol$environment](dimmed green) '
```
