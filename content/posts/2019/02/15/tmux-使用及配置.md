---
title: "tmux 使用及配置"
date: 2019-02-15T21:38:00+00:00
description: "tmux 使用 https://github.com/gpakosz/.tmux 及快捷键介绍"
draft: false
categories: ['basics']
tags: ['basics']
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

# 配置

- [https://github.com/gpakosz/.tmux](https://github.com/gpakosz/.tmux)

```bash
$ cd ~
$ git clone https://github.com/gpakosz/.tmux.git
$ ln -s -f .tmux/.tmux.conf
$ cp .tmux/.tmux.conf.local .
# mouse mode just use ctrl+b; m
```

- 使用 gpakosz/.tmux 配置的 不用再次配置
- 如果需要修改可以查看下方配置 config file at `~/.tmux.conf`

```conf
set -g default-command /bin/zsh # can change bash
set -g default-shell /bin/zsh   # can change bash

# mouse
setw -g mouse-resize-pane on
setw -g mouse-select-pane on
setw -g mouse-select-window on
setw -g mode-mouse on

set-option -g display-time 5000 # 提示信息的持续时间；设置足够的时间以避免看不清提示，单位为毫秒
set-option -g repeat-time 1000 # 控制台激活后的持续时间；设置合适的时间以避免每次操作都要先激活控制台，单位为毫秒

set-option -g base-index 1                        # 窗口的初始序号；默认为0，这里设置为1
set-option -g display-time 5000                   # 提示信息的持续时间；设置足够的时间以避免看不清提示，单位为毫秒
set-option -g repeat-time 1000                    # 控制台激活后的持续时间；设置合适的时间以避免每次操作都要先激活控制台，单位为毫秒
set-option -g status-keys vi                      # 操作状态栏时的默认键盘布局；可以设置为vi或emacs
set-option -g status-utf8 on                      # 开启状态栏的UTF-8支持

---
set-option -g status-bg blue
set-option -g status-fg '#bbbbbb'
set-option -g status-left-fg green
set-option -g status-left-bg blue
set-option -g status-right-fg green
set-option -g status-right-bg blue
set-option -g status-left-length 10               # 状态栏左方的内容长度；
set-option -g status-right-length 15              # 状态栏右方的内容长度；建议把更多的空间留给状态栏左方（用于列出当前窗口）
set-option -g status-left '[#(whoami)]'           # 状态栏左方的内容
set-option -g status-right '[#(date +" %m-%d %H:%M ")]'     # 状态栏右方的内容；这里的设置将得到类似23:59的显示
set-option -g status-justify "centre"             # 窗口列表居中显示
set-option -g default-terminal "screen-256color"  # 支持256色显示
分割窗口边界的颜色
set-option -g pane-active-border-fg '#55ff55'
set-option -g pane-border-fg '#555555'
​
---
此类设置可以在命令行模式中输入show-window-options -g查询
set-window-option -g mode-keys vi    # 复制模式中的默认键盘布局；可以设置为vi或emacs
set-window-option -g utf8 on         # 开启窗口的UTF-8支持
set-window-option -g mode-mouse on   # 窗口切换后让人可以用鼠标上下滑动显示历史输出
​
---
窗口切分快捷键(没设置成功)
bind \ split-window -h                      # 使用 \ 将窗口竖切
bind - split-window -v                      # 使用 - 将窗口横切
bind K confirm-before -p "kill-window #W? (y/n)" kill-window    # 使用大写 K 来关闭窗口
bind '"' choose-window                      # 双引号选择窗口
​
---
Pane之间切换的快捷键
bind h select-pane -L                       # 定位到左边窗口的快捷键
bind j select-pane -D                       # 定位到上边窗口的快捷键
bind k select-pane -U                       # 定位到下方窗口的快捷键
bind l select-pane -R                       # 定位到右边窗口的快捷键
```

# 使用

## tmux 外操作

```bash
# 列出 session
$ tmux list-sessions
$ tmux ls

# 进入下标 0 的会话
$ tmux attach -t 0

# 创建名为 docker 的 session
$ tmux new -s docker
# 创建名为 docker 的 session 窗口名为 docker
$ tmux new -s docker -n docker
# 进入名为 docker 的 session
$ tmux attach -t docker
# 简写为
$ tmux at -t docker
## old verison
$ tmux attach -s docker

# 快速进入 at = attach
$ tmux at -t docker
## old verison
$ tmux at -s docker

# kill名为 docker 的 session
$ tmux kill-session -t docker
```

## tmux 内操作

### session操作

```
ctrl+b s      // 列出所有会话
ctrl+b d      // detach当前session(可以认为后台运行)
ctrl+d        // 关闭会话 = exit
```

### window操作

```
ctrl+b c      // 创建一个新窗口
ctrl+b &      // 关闭当前窗口
ctrl+b p      // 切换到上一个窗口
ctrl+b n      // 切换到下一个窗口
ctrl+b w      // 从列表中选择窗口
ctrl+b 窗口号  // 使用窗口号切换窗口(例如窗口号为1的, 则C-b 1)
ctrl+b ,      // 重命名当前窗口，便于识别各个窗口
```

- 窗口操作

```
ctrl + b %             // 分成左右两个窗格
ctrl + b "             // 分成上下两个窗格
ctrl + b z             // 当前窗格全屏显示，再按一次恢复
ctrl + b q             // 显示窗格编号
ctrl + b t             // 在当前窗格显示时间
ctrl + b <arrow key>   // 光标切换到其他窗格
ctrl + b o             // 光标切换到下一个窗格
ctrl + b {             // 左移当前窗格
ctrl + b }             // 右移当前窗格
ctrl + b Ctrl+o        // 上移当前窗格
ctrl + b Alt+o         // 下移当前窗格
ctrl + b space         // 切换窗格布局
```

### panel 操作

```
ctrl+b %      //横向分Terminal(左右)
ctrl+b "      //纵向分Terminal
ctrl+b 方向键  //则会在自由选择各面板
ctrl+b x      //关闭当前pane
ctrl+b q      //显示面板编号
```

### tmux中的复制粘贴

- 进行鼠标滚轮操作

```
鼠标滚轮模式 ctrl + b 后松开，再按 m
按下 ctrl + b 后松开，再按 [
用鼠标选中文本，被选中的文本会被自动复制到tmux的剪贴板
按下 ctrl + b 后松开，再按 ]，会将剪贴板的内容粘贴到光标处
```

### 命令模式

```bash
先按 ctrl+b ，然后输入: ，进入命令行模式

输入
set -g mouse on
不行的话换成
set-option-g mouse on

按住shift再操作即可，复制粘贴都要按住
```
