---
title: "MacOS 安装 oh-my-zsh autojump"
date: 2020-04-11T12:50:11+12:13
description: "Install oh my zsh and autojump on macOS"
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

## oh-my-zsh 介绍

[oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) 是基于zsh的功能做了一个扩展，方便的插件管理、主题自定义，以及漂亮的自动完成效果

## 安装 zsh

> macOS 系统 10.15 开始，默认就是 zsh 不需要重复安装

### 查看zsh版本

```bash
zsh --version
```

### 手动安装 zsh

```bash
brew info zsh
brew install zsh
```

###  确认当前默认bash

```bash
echo $SHELL
```

### 确保zsh在/etc/shells列表中，修改默认shell

检查当前的shell有那些

```sh
cat /etc/shells
```

```bash
chsh -s /bin/zsh
```
`注销用户，重新登录用户`，确认已经是zsh，就可以了

### 提示 chsh:no changes made解决办法

```sh
chsh -s /bin/zsh
dscl . -read /Users/$USER/ UserShell
exec su - $USER
```

## 安装 oh-my-zsh

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 使用国内代理安装
sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh \
    | sed 's|^REPO=.*|REPO=${REPO:-mirrors/oh-my-zsh}|g' \
    | sed 's|^REMOTE=.*|REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}|g')"
git clone https://gitee.com/mirrors/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://gitee.com/mirrors/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### oh-my-zsh 设置代理

```bash
# https://gitee.com/mirrors/oh-my-zsh
git -C "${HOME}/.oh-my-zsh" remote set-url origin https://gitee.com/mirrors/oh-my-zsh.git

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" remote set-url origin https://gitee.com/mirrors/zsh-autosuggestions.git

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" remote set-url origin https://gitee.com/mirrors/zsh-syntax-highlighting.git

# 恢复官方地址
git -C "${HOME}/.oh-my-zsh" remote set-url origin https://github.com/robbyrussell/oh-my-zsh.git

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" remote set-url origin https://github.com/zsh-users/zsh-autosuggestions.git

git -C "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" remote set-url origin https://github.com/zsh-users/zsh-syntax-highlighting.git
```


## zsh兼容bash_profile

zsh 不会读取用户目录下的 `.bash_profile` 和 `.bashrc 文件`，把你要在 `~/.bash_profile` 里做的事写在 `~/.zshrc` 里。

或者，手工在 `~/.zshrc` 里使用 `source` 命令执行 `~/.bash_profile` 也可以
方法是在 `~/.zshrc` 中加入一行 `source ~/.bash_profile`

## 常用alias配置

```sh
# alias base
alias free='top -l 1 | head -n 10 | grep PhysMem'
alias ls='ls -hG'
alias ll='ls -l'
alias la='ls -a'
alias l='ls -CF'
alias cls='clear'
alias gs='git status'
alias gc='git commit'
alias gqa='git add .'

# alias docker
alias dkst="docker stats"
alias dkps="docker ps"
alias dkpsa="docker ps -a"
alias dkimgs="docker images"
alias dkex="docker exec"
alias dkext="docker exec -it"
alias dkcpup="docker-compose up -d"
alias dkcpdown="docker-compose down"
alias dkcpstart="docker-compose start"
alias dkcpstop="docker-compose stop"

```

## zsh插件设置

修改 `~/.zshrc` 文件中`plugins=(git)` 这个部分

建议开启

```bash
plugins=(
  macos
  xcode
  brew
  git
  sudo
  ruby
  python
)
```

这个是本人的插件，根据需要开启，部分插件需要安装后开启

```bash
plugins=(
  macos
  xcode
  brew
  git
  zoxide
  autojump
  colored-man-pages
  sudo
  zsh-safe-rm
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  docker-compose
  ruby
  rust
  python
  pip
  poetry
  pipenv
  node
  npm
  golang
)
```

查看插件列表

```sh
# 搜索具体插件
ls ~/.oh-my-zsh/plugins | grep [pluginsName]

# 自定义插件
ls $HOME/.oh-my-zsh/custom/plugins
```

> 可以再插件在最前面加 `!` 表示禁用插件

- macos 希望在 macos 中 插件生效，请一定加入这个配置。非这个系统请写成 `!macos`
- brew 这两个是给OS X 的brew增加补全的。非这个系统请写成 `!brew`
- git 是 git 各种补全插件，并且含有日常用到的各种 git 命令别名
- zoxide 配合 [zoxide](https://github.com/ajeetdsouza/zoxide) 使用 `z` 命令直接快速进入某个目录
- autojump 配合 [autojump](https://github.com/wting/autojump) 使用 `j` 命令直接快速进入某个目录
- colored-man-pages 顾名思义，彩色的man很赞
- sudo 当你输入一个命令发现需要root权限，通常只能按方向上键，然后光标移到头部，加入sudo，但是有了这个插件，不用再移动光标到头部了，直接两下 ESC， sudo就会自动加入到最前面，再按两下 ESC，取消加在头部的 sudo
- zsh-safe-rm 安全删除插件，防止 `rm -rf` 错误使用导致的悲剧
- zsh-syntax-highlighting 这个是当你正在输入一个命令的时候，显示绿色，表示这个命令是有效的存在的，显示红色表示这个命令在系统中不存在，当然不止这些。
- zsh-autosuggestions 自动提示命令，自动提示各种命令
- zsh_reload  已经废弃，Use `omz reload` or `exec zsh` instead. 原理是增加了一个src的alias，可以重新reload zsh，尤其是当一个新的程序安装，zsh并不能像bash那样立马可以识别新的命令

### 安全删除 zsh-safe-rm

- [https://github.com/mattmc3/zsh-safe-rm](https://github.com/mattmc3/zsh-safe-rm)
- the files or directories you choose to remove will move to `~/.local/share/Trash` or `$HOME/.Trash`

with oh-my-zsh install

```bash
$ echo $ZSH_CUSTOM
# will print $HOME/.oh-my-zsh/custom

$ git clone --recursive --depth 1 https://github.com/mattmc3/zsh-safe-rm $ZSH_CUSTOM/plugins/zsh-safe-rm
# please do not use proxy clone url, which this project used git submodule
```

### 语法高亮 zsh-syntax-highlighting

zsh-syntax-highlighting 安装分源码和管理工具安装

```
# if use brew install
brew install zsh-syntax-highlighting
echo "source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# use git install
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
echo "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```


### 自动提示命令 zsh-autosuggestions

输入命令时，终端会自动提示你接下来可能要输入的命令

它建议您根据历史记录和完成情况键入时的命令，可以做到任意提示

- 克隆仓库到本地 `~/.oh-my-zsh/custom/plugins` 路径

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# or
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

在`~/.zshrc` 中添加

```
plugins=(
	zsh-autosuggestions
)
```

> 可能看不到变化，可能你的字体颜色太淡


```sh
vim ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
```

修改 `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'`

### autojump 配置

只在 `zsh` 中配置了插件

```sh
plugins=(
	autojump
)
```

没有安装autojump是不能使用的

```sh
brew install autojump
```

安装完成后会有提示，因为是使用了`zsh`，将下面的配置添加到 `~/.bash_profile` 后

```sh
# env of autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
```

设置完成后，加载配置`source ~/.bash_profile`，然后就可以使用 `j [路径短写]`来跳转

> autojump 是基于cd去过的路径，没用去过的路径无法短写跳转
>> 路径跳转错误可以使用 `autojump --purge ` 来清理错误路径

### 自动补全 zsh-autocomplete

这个补全可能和其他补全冲突，建议自己测试一下冲突再使用

- install as github

```bash
$ git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
```

- add config at `·zshrc`

```rc
plugins=(
  zsh-autocomplete
)
```

```bash
# fix error
$ sudo mkdir -p .local/state/zsh-autocomplete
$ sudo chmod 777 .local/state/zsh-autocomplete
```

### 插件推荐

- rsync 增加了几个rsync的alias，简化操作

## zsh 美化

主题预览

https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

其中主题 `robbyrussell` `dst` `agnoster` `duellj` 可以尝试一下

## error fix

### fix oh-my-zsh plugin autocomplete feature

```bash
rm ~/.zcompdump*
```

## 安装可能错误Error

### .zshrc:3: command not found: ^M

The temporary solution to that is changing your core.autocrlf git config setting to use input, given that you are on OSX. See [#4402 (comment)](https://github.com/robbyrussell/oh-my-zsh/issues/4402#issuecomment-143976458).

```sh
cd $ZSH
git config core.autocrlf input
git rm --cached -r .
git reset --hard
```

### oh-my-zsh.sh: : parse error near `||` after Upgrade

```sh
vi the ~/.gitconfig file and set the autocrlf = false. then it works
```

[Git clone errors if .gitconfig specifies autocrlf = true #4069](https://github.com/robbyrussell/oh-my-zsh/issues/4069)

### PATH set to RVM ruby but GEM_HOME and/or GEM_PATH not set

[PATH set to RVM ruby but GEM_HOME and/or GEM_PATH not set](https://github.com/rvm/rvm/issues/3212)

Add RVM set at `~/.zshrc`

```sh
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
```
