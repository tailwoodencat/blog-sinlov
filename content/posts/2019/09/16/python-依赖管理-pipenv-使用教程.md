---
title: "python 依赖管理 pipenv 使用教程"
date: 2019-09-16T00:04:39+08:00
description: "desc python 依赖管理 pipenv 使用教程"
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

## pipenv 安装

```bash
$ pip install --user pipenv
# 升级 pipenv
$ pip install --user pipenv --upgrade
# 如果不知道如何将 shell 找不到的命令添加到系统环境变量则这样寻找
$ python -m site --user-base
```

### linux 安装

```bash
$ pip install --user pipenv
```

需要配置安装路径 在环境变量

```conf
# python install --user
export PATH=$PATH:$HOME/.local/bin
```

### macOS 安装


```bash
# 可以通过 brew 安装
$ brew info pipenv
$ brew install pipenv
```

- pipenv 自动补全

添加到 .bashrc 或者 .zshrc 中即可

```bash
eval "$(pipenv --completion)"
```

### windows 安装 pipenv

```bash
$ pip install --user pipenv
```

windows 需要设置环境变量到用户目录，方法是添加用户环境变量到 `%AppData%\Python\Python39\Scripts`

> 注意，不同版本可能不同，比如 python 3.8 为 `%AppData%\Python\Python38\Scripts`

## pipenv 会用到 pyenv

- 建议安装依赖 设置 pyenv 的环境[https://github.com/pyenv/pyenv/wiki#suggested-build-environment](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)

### macOS pyenv

```bash
$ brew install pyenv
```

### linux pyenv

```bash
$ git clone --depth 1 https://github.com/pyenv/pyenv.git ~/.pyenv
$ git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

或者新增配置如下

```bash
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init -)"
```


### windows pyenv

- pip安装 [https://github.com/pyenv-win/pyenv-win#get-pyenv-win](https://github.com/pyenv-win/pyenv-win#get-pyenv-win)

```bash
# cmd
$ pip install pyenv-win --target %USERPROFILE%\.pyenv
# Powershell或Git Bash
$ pip install pyenv-win --target $HOME\.pyenv

# use choco
$ choco install pyenv-win
```

- 将pyenv安装到环境变量

```bash
# PowerShell或Windows Terminal 运行
$ [System.Environment]::SetEnvironmentVariable('PYENV',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
$ [System.Environment]::SetEnvironmentVariable('path', $HOME + "\.pyenv\pyenv-win\bin;" + $HOME + "\.pyenv\pyenv-win\shims;" + $env:Path,"User")
```


### 查看pyenv是否安装成功

```bash
$ pyenv --version

# windows 限定
$ pyenv update

# 常用版本安装
$ pyenv install 2.7.18
$ pyenv install 3.10.7
$ pyenv install 3.9.7

$ pyenv install -v 3.8.7
# macOS m1 will use
$ pyenv install 3.8.12

$ pyenv install 3.7.7
# macOS m1 will use
$ pyenv install 3.7.14
```

### pyenv 镜像加速

- 淘宝镜像 python 列表 [https://registry.npmmirror.com/binary.html?path=python/](https://registry.npmmirror.com/binary.html?path=python/)

```bash
# 比如安装 python 3.10.7 使用淘宝镜像加速
$ v=3.10.7;wget https://npmmirror.com/mirrors/python/$v/Python-$v.tar.xz -P ~/.pyenv/cache/;pyenv install $v

# in powershell
> $v="3.10.7";wget https://npmmirror.com/mirrors/python/$v/python-$v-amd64.exe -OutFile $HOME\.pyenv\pyenv-win\install_cache\python-$v-amd64.exe;pyenv install $v
```

- 安装错误常识安装依赖

```bash
$ sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

### pyenv 安装错误

#### ld: symbol(s) not found for architecture x86_64

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

#### configure: error: Unexpected output of 'arch' on OSX

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

#### checking for the platform triplet based on compiler characteristics... darwin

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

#### Undefined symbols for architecture x86_64

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
 "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" -cc1 -triple arm64-apple-macosx12.0.0 -Wundef-prefix=TARGET_OS_ -Wdeprecated-objc-isa-usage -Werror=deprecated-objc-isa-usage -Werror=implicit-function-declaration -E -disable-free -disable-llvm-verifier -discard-value-names -main-file-name - -mrelocation-model pic -pic-level 2 -mframe-pointer=non-leaf -fno-strict-return -fno-rounding-math -munwind-tables -target-sdk-version=12.3 -fvisibility-inlines-hidden-static-local-var -target-cpu apple-m1 -target-feature +v8.5a -target-feature +fp-armv8 -target-feature +neon -target-feature +crc -target-feature +crypto -target-feature +dotprod -target-feature +fp16fml -target-feature +ras -target-feature +lse -target-feature +rdm -target-feature +rcpc -target-feature +zcm -target-feature +zcz -target-feature +fullfp16 -target-feature +sm4 -target-feature +sha3 -target-feature +sha2 -target-feature +aes -target-abi darwinpcs -fallow-half-arguments-and-returns -debugger-tuning=lldb -target-linker-version 762 -v -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/13.1.6 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -I/usr/local/include -internal-isystem /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/local/include -internal-isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/13.1.6/include -internal-externc-isystem /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include -internal-externc-isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -Wno-reorder-init-list -Wno-implicit-int-float-conversion -Wno-c99-designator -Wno-final-dtor-non-final-class -Wno-extra-semi-stmt -Wno-misleading-indentation -Wno-quoted-include-in-framework-header -Wno-implicit-fallthrough -Wno-enum-enum-conversion -Wno-enum-float-conversion -Wno-elaborated-enum-base -Wno-reserved-identifier -Wno-gnu-folding-constant -Wno-objc-load-method -fdebug-compilation-dir=/Users/sinlov/Downloads -ferror-limit 19 -stack-protector 1 -fstack-check -mdarwin-stkchk-strong-link -fblocks -fencode-extended-block-signature -fregister-global-dtors-with-atexit -fgnuc-version=4.2.1 -fmax-type-align=16 -fcommon -fcolor-diagnostics -clang-vendor-feature=+messageToSelfInClassMethodIdReturnType -clang-vendor-feature=+disableInferNewAvailabilityFromInit -clang-vendor-feature=+disableNonDependentMemberExprInCurrentInstantiation -fno-odr-hash-protocols -clang-vendor-feature=+enableAggressiveVLAFolding -clang-vendor-feature=+revert09abecef7bbf -clang-vendor-feature=+thisNoAlignAttr -clang-vendor-feature=+thisNoNullAttr -mllvm -disable-aligned-alloc-awareness=1 -D__GCC_HAVE_DWARF2_CFI_ASM=1 -o - -x c -
clang -cc1 version 13.1.6 (clang-1316.0.21.2.3) default target x86_64-apple-darwin21.4.0
ignoring nonexistent directory "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/local/include"
ignoring nonexistent directory "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/Library/Frameworks"
#include "..." search starts here:
#include <...> search starts here:
 /usr/local/include
 /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/13.1.6/include
 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
 /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks (framework directory)
End of search list.

$ which -a pyenv brew
```

## pipenv 命令使用

```bash
Usage: pipenv [OPTIONS] COMMAND [ARGS]...

Options:
--where Output project home information.
--venv Output virtualenv information.
--py Output Python interpreter information.
--envs Output Environment Variable options.
--rm Remove the virtualenv.
--bare Minimal output.
--completion Output completion (to be executed by the
shell).

--man Display manpage.
--support Output diagnostic information for use in
GitHub issues.

--site-packages / --no-site-packages
Enable site-packages for the virtualenv.
[env var: PIPENV_SITE_PACKAGES]

--python TEXT Specify which version of Python virtualenv
should use.

--three / --two Use Python 3/2 when creating virtualenv.
--clear Clears caches (pipenv, pip, and pip-tools).
[env var: PIPENV_CLEAR]

-v, --verbose Verbose mode.
--pypi-mirror TEXT Specify a PyPI mirror.
--version Show the version and exit.
-h, --help Show this message and exit.
```

## 已经存在使用 pipenv 管理的项目通过

```bash
# 如果不添加参数 --two 或者 --three ，则通过默认的 python 来安装
$ pipenv install --three
Creating a virtualenv for this project...
# 安装完成后提示
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
# 如果安装报错，可以尝试
$ pipenv install --three --skip-lock
# 如果使用了 requirements.txt 管理依赖可以这样初始化
$ pipenv install --three -r requirements.txt
# 使用代理
$ pipenv install --skip-lock --pypi-mirror https://mirrors.aliyun.com/pypi/simple/
```

> pip install 如果目录中没有Pipfile和Pipfile.lock，会自动生成。如果存在，则会自动检查 Pipfile 中的所有依赖

## 虚拟环境使用

- 注意，使用 pipenv 的一切操作都在工程目录执行 `pipenv shell` 进入
- 不要在非 pipenv shell 环境下执行操作

```bash
# 进入环境
$ pipenv shell
# 退出环境, 或者按 ctrl + D
$ exit
```

> tips: 注意：千万不要使用 deactivate 命令退出

### 虚拟环境代理

[https://pipenv.pypa.io/en/latest/advanced/#using-a-pypi-mirror](https://pipenv.pypa.io/en/latest/advanced/#using-a-pypi-mirror)

工程目录新建文件  `.env`  内容为

```env
PIPENV_PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/
PIP_DEFAULT_TIMEOUT=300
PIPENV_IGNORE_VIRTUALENVS=-1
```

在虚拟环境目录种执行

```bash
echo PIPENV_PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/ >.env
```

也可以制作一个快速脚本放在 ~/.zshrc 中，方便生成本地环境来做隔离化的代理管理

```bash
# for new local pipenv mirror
function pipenv-mirror-tsinghua() {
	echo PIPENV_PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/ > .env
	cat .env
}
```


- 设置永久代理 到环境变量

```bash
export PIPENV_DEFAULT_PYTHON_VERSION=3.7
export PIPENV_PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
```


### 虚拟环境常用指令

```bash
# 锁定依赖
$ pipenv lock
# 导出生成requirements.txt文件
$ pipenv lock -r
# 安装依赖
$ pipenv sync
# 安装 开发工具依赖
$ pipenv sync --dev

# 如果依赖使用了 带有 dev 或者非发布依赖需要这么安装 否则报错
$ pipenv lock --pre
$ pipenv sync --pre
$ pipenv sync --dev --pre

# 检查当前工程，建议任何时候先使用这个命令防止错误
$ pipenv check

# 显示项目文件所在地
$ pipenv --where
# 显示虚拟环境实际文件路径
$ pipenv --venv
# 显示虚拟环境 python 解释器路径
$ pipenv --py
```

### 删除虚拟环境

```bash
$ pipenv --rm
```

## 依赖管理

**注意：需要先进入虚拟环境后使用依赖管理**

### 安装依赖
```bash
# Pipfile文件目录下
$ pipenv install requests
```
这里执行了两步操作：
1. 安装到虚拟环境中，更新 `Pipfile` 里面的依赖版本
1. 使用sha256算法更新 `Pipfile.lock` 文件

> tips: 默认情况下会加锁，速度很慢，可以增加参数 --skip-lock 来加快安装，但是会出现版本可能对不上的问题

- 安装开发依赖

```bash
$ pipenv install httpie --dev
```

这种依赖不会出现在最终运行库，可以方便隔离发布和测试代码

### 更新依赖

```bash
# 更新某个依赖
$ pipenv update requests
# 更新全部依赖
$ pipenv update
```

> tips: 如果不写具体依赖更新，会删除全部软件包重新安装到最新

### 卸载依赖

```bash
# Pipfile文件目录下
$ pipenv uninstall requests
```

### 查看当前所有依赖

```bash
$ pipenv graph
httpie==2.3.0
- Pygments [required: >=2.5.2, installed: 2.7.3]
- requests [required: >=2.22.0, installed: 2.25.1]
- certifi [required: >=2017.4.17, installed: 2020.12.5]
- chardet [required: >=3.0.2,<5, installed: 4.0.0]
- idna [required: >=2.5,<3, installed: 2.10]
- urllib3 [required: >=1.21.1,<1.27, installed: 1.26.2]
- requests-toolbelt [required: >=0.9.1, installed: 0.9.1]
- requests [required: >=2.0.1,<3.0.0, installed: 2.25.1]
- certifi [required: >=2017.4.17, installed: 2020.12.5]
- chardet [required: >=3.0.2,<5, installed: 4.0.0]
- idna [required: >=2.5,<3, installed: 2.10]
- urllib3 [required: >=1.21.1,<1.27, installed: 1.26.2]
PySocks==1.7.1
```

pip list 也行，不过没 graph 清楚

```basj
$ pip list
```

### 锁定依赖

```bash
$ pipenv lock
```

生成 Pipfile.lock 文件

> tips: Pipfile.lock 本质是一个 json 文件，用于锁定依赖的，建议上传文件对照依赖

### 依赖环境管理

pipenv shell 运行时会读取默认工程目录下的 `.env` 文件作为环境变量文件

例如：

```env
ENV_HTTP_PORT=2880
```

那么
```py
print('env: ENV_HTTP_PORT=%s' % os.getenv('ENV_HTTP_PORT'))
```

就会输出对应的环境变量

## 执行脚本

在 Pipfile 中编写脚本

```toml
[scripts]
main = "python main.py"
```

那么就可以看到可以执行的脚本代理

```bash
$ pipenv scripts
Command Script
--------- ---------------------------
main python main.py
```

那么不进入环境，直接执行则为

```bash
$ pipenv run main
Loading .env environment variables...
......
```

## 官方说明

- [pypi.org/project/pipenv](https://pypi.org/project/pipenv/)