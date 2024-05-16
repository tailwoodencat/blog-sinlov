---
title: "python pyenv 使用"
date: 2020-02-12T10:41:39+08:00
description: "python pyenv 使用 和 各种问题修复"
draft: false
categories: ['python']
tags: ['python']
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

## 安装前检查

- 建议安装依赖 设置 pyenv 的环境[https://github.com/pyenv/pyenv/wiki#suggested-build-environment](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)

- 安装前需要安装依赖

```bash
## ubuntu
$ sudo apt update; sudo apt install -y \
 build-essential libssl-dev zlib1g-dev \
 libbz2-dev libreadline-dev libsqlite3-dev curl \
 libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# ubuntu old
$ sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

### macOS pyenv

```bash
$ brew install pyenv
```

### linux pyenv

```bash
$ git clone --depth 1 https://github.com/pyenv/pyenv.git ~/.pyenv
$ git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
```

-  proxy version

```bash
$ git clone https://mirror.ghproxy.com/https://github.com/pyenv/pyenv.git ~/.pyenv
$ git clone https://mirror.ghproxy.com/https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
```

或者新增配置如下

```bash

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# python bin
export PATH=$PATH:$HOME/.local/bin


# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init -)"
```

#### linux update pyenv

- 设置代理

```bash
# https://gitee.com/mirrors/pyenv
git -C "${PYENV_ROOT}" remote set-url origin https://gitee.com/mirrors/pyenv.git

git -C "${PYENV_ROOT}" remote set-url origin https://mirror.ghproxy.com/https://github.com/pyenv/pyenv.git
l

# 恢复官方地址
git -C "${PYENV_ROOT}" remote set-url origin https://github.com/pyenv/pyenv.git
git -C "${PYENV_ROOT}/plugins/pyenv-virtualenv" remote set-url origin https://github.com/pyenv/pyenv-virtualenv.git
```

- 执行更新

```bash
cd ${PYENV_ROOT} && git pull && cd ${PYENV_ROOT}/plugins/pyenv-virtualenv && git pull
```

### windows pyenv

- pip安装 [https://github.com/pyenv-win/pyenv-win#get-pyenv-win](https://github.com/pyenv-win/pyenv-win#get-pyenv-win)

```bash
# windows
# use scoop
$ scoop install main/pyenv

# for https://github.com/ScoopInstaller/Main/issues/4143
$ scoop install pyenv@2.64.11
$ scoop hold pyenv
# or
> Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"

# cmd 不推荐
$ pip install pyenv-win --target %USERPROFILE%\.pyenv
# Powershell或Git Bash
$ pip install pyenv-win --target $HOME\.pyenv

# use choco 不推荐
$ choco install pyenv-win
```

- 将pyenv安装到环境变量 如果是 scoop 安装则不需要这个步骤

```bash
# PowerShell或Windows Terminal 运行
$ [System.Environment]::SetEnvironmentVariable('PYENV',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
$ [System.Environment]::SetEnvironmentVariable('path', $HOME + "\.pyenv\pyenv-win\bin;" + $HOME + "\.pyenv\pyenv-win\shims;" + $env:Path,"User")
```

## pyenv 使用

### 查看pyenv是否安装成功

```bash
## 帮助
$ pyenv commands
# pyenv version
$ pyenv --version

# windows 限定
$ pyenv update

## 版本安装
# 查看安装支持列表
$ pyenv install -l
# 常用版本安装
$ pyenv install 2.7.18
$ v=2.7.18; wget https://npmmirror.com/mirrors/python/$v/Python-$v.tar.xz -P ~/.pyenv/cache/; pyenv install $v

$ pyenv install 3.10.7
$ pyenv install 3.9.7
$ v=3.11.7; wget https://npmmirror.com/mirrors/python/$v/Python-$v.tar.xz -P ~/.pyenv/cache/; pyenv install $v

$ pyenv install -v 3.8.7
# macOS m1 will use
$ pyenv install 3.8.12

$ pyenv install 3.7.7
# macOS m1 will use
$ pyenv install 3.7.14

## 版本管理
# 查看 可以切换的 版本
$ pyenv versions
# 在这个目录下，自动使用某个 Python 版本
$ pyenv local <version>
# 查看 全局 版本
$ pyenv global
# 设置全局版本
$ pyenv global <version>
# 进入某个版本
$ pyenv shell 3.10.7
# 使用系统版本
$ pyenv shell system
```

### pyenv 镜像加速

- 淘宝镜像 python 列表 [https://registry.npmmirror.com/binary.html?path=python/](https://registry.npmmirror.com/binary.html?path=python/)

```bash
# 比如安装 python 3.10.7 使用淘宝镜像加速
$ v=3.10.7;wget https://npmmirror.com/mirrors/python/$v/Python-$v.tar.xz -P ~/.pyenv/cache/;pyenv install $v

# in powershell install with scoop
> $v="3.10.7"; echo "download path: $HOME\scoop\apps\pyenv\current\pyenv-win\install_cache\python-$v-amd64.exe"
> $v="3.10.7"; Invoke-WebRequest -Uri "https://npmmirror.com/mirrors/python/$v/python-$v-amd64.exe" -OutFile "$HOME\scoop\apps\pyenv\current\pyenv-win\install_cache\python-$v-amd64.exe" ; pyenv install $v

# in powershell install with cmd
> $v="3.10.7"; Invoke-WebRequest -Uri "https://npmmirror.com/mirrors/python/$v/python-$v-amd64.exe" -OutFile "$env:USERPROFILE\.pyenv\pyenv-win\install_cache\python-$v-amd64.exe" ; pyenv install $v
```

- 安装 对应 python 版本 错误尝试 安装 python 对应的依赖

```bash
# debian or ubuntu
$ sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

## pyenv 安装错误

### shell integration not enabled

```log
pyenv: shell integration not enabled. Run `pyenv init' for instructions
```


### ld: symbol(s) not found for architecture x86_64

```
  "__Py_Dealloc", referenced from:
      _test_open_code_hook in _testembed.o
      _test_unicode_id_init in _testembed.o
      __audit_hook_run in _testembed.o
  "__Py_InitializeMain", referenced from:
      _test_init_main in _testembed.o
      _test_init_set_config in _testembed.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [Programs/_testembed] Error 1
```

- fix

```
# https://github.com/pyenv/pyenv/issues/2283#issuecomment-1075923205
$ brew uninstall binutils
# then install
```

### configure: error: Unexpected output of 'arch' on OSX

```bash
Last 10 log lines:
checking size of _Bool... 1
checking size of off_t... 8
checking whether to enable large file support... no
checking size of time_t... 8
checking for pthread_t... yes
checking size of pthread_t... 8
checking size of pthread_key_t... 8
checking whether pthread_key_t is compatible with int... no
configure: error: Unexpected output of 'arch' on OSX
make: *** No targets specified and no makefile found.  Stop.
```

- fix from [https://github.com/pyenv/pyenv/issues/1768#issuecomment-770445006](https://github.com/pyenv/pyenv/issues/1768#issuecomment-770445006)

```
pyenv install --patch 3.8.7 <<(curl -sSL https://raw.githubusercontent.com/Homebrew/formula-patches/9811be33170a8f31a684fae6955542e31eb4e61e/python/3.8.7.patch)
```

### checking for the platform triplet based on compiler characteristics... darwin

```bash
$ pyenv install 3.7.7
Last 10 log lines:
checking for --with-cxx-main=<compiler>... no
checking for clang++... no
configure:

  By default, distutils will build C++ extension modules with "clang++".
  If this is not intended, then set CXX on the configure command line.

checking for the platform triplet based on compiler characteristics... darwin
configure: error: internal configure error for the platform triplet, please file a bug report
make: *** No targets specified and no makefile found.  Stop.
```

- trf fix or not support

```
# https://github.com/pyenv/pyenv#python-versions-with-extended-support
# 3.7.8-3.7.15, 3.8.4-3.8.12, 3.9.0-3.9.7 : XCode 13.3

# install gcc-11
$ brew install gcc@11

# try
$ CFLAGS="-I$(brew --prefix readline)/include -I$(brew --prefix openssl)/include -I$(xcrun --show-sdk-path)/usr/include" \
LDFLAGS="-L$(brew --prefix readline)/lib -L$(brew --prefix openssl)/lib" \
PYTHON_CONFIGURE_OPTS=--enable-unicode=ucs2 \
pyenv install -v 3.7.7

# intel
$ CC=/usr/local/bin/gcc-11 pyenv install 3.7.7
# m1
$ CC=/opt/homebrew/bin/gcc-11 pyenv install 3.7.7
```

### Undefined symbols for architecture x86_64

```bash
ld: warning: ignoring file libpython2.7.a, building for macOS-x86_64 but attempting to link with file built for unknown-unsupported file format ( 0x21 0x3C 0x61 0x72 0x63 0x68 0x3E 0x0A 0x2F 0x20 0x20 0x20 0x20 0x20 0x20 0x20 )
Undefined symbols for architecture x86_64:
  "_PyMac_Error", referenced from:
     -u command line option
  "_Py_Main", referenced from:
      _main in python.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [python.exe] Error 1
```

- 检查依赖

```bash
$ clang -arch arm64 -E -x c - -v < /dev/null | pbcopy
Apple clang version 13.1.6 (clang-1316.0.21.2.3)
Target: arm64-apple-darwin21.4.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

确认 目标版本和运行的 macOS 版本不支持，放弃这个版本安装