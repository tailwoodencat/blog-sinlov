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
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## PipEnv 安装
```bash
$ pip install --user pipenv
# 如果不知道如何将 shell 找不到的命令添加到系统环境变量则这样寻找
$ python -m site --user-base
```
> macOS 可以通过 brew 安装

```bash
$ brew info pipenv
$ brew install pipenv
```
### pipenv 自动补全
添加到 .bashrc 或者 .zshrc 中即可

```bash
eval "$(pipenv --completion)"
```

## pipenv 命令使用
```bash
Usage: pipenv [OPTIONS] COMMAND [ARGS]...

Options:
  --where                         Output project home information.
  --venv                          Output virtualenv information.
  --py                            Output Python interpreter information.
  --envs                          Output Environment Variable options.
  --rm                            Remove the virtualenv.
  --bare                          Minimal output.
  --completion                    Output completion (to be executed by the
                                  shell).

  --man                           Display manpage.
  --support                       Output diagnostic information for use in
                                  GitHub issues.

  --site-packages / --no-site-packages
                                  Enable site-packages for the virtualenv.
                                  [env var: PIPENV_SITE_PACKAGES]

  --python TEXT                   Specify which version of Python virtualenv
                                  should use.

  --three / --two                 Use Python 3/2 when creating virtualenv.
  --clear                         Clears caches (pipenv, pip, and pip-tools).
                                  [env var: PIPENV_CLEAR]

  -v, --verbose                   Verbose mode.
  --pypi-mirror TEXT              Specify a PyPI mirror.
  --version                       Show the version and exit.
  -h, --help                      Show this message and exit.
```

## 已经存在使用 pipenv 管理的项目通过

```bash
# 如果不添加参数 --two 或者 --three ，则通过默认的 python 来安装
$ pipenv install --three
Creating a virtualenv for this project...
# 安装完成后提示
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
```

> pip install 如果目录中没有Pipfile和Pipfile.lock，会自动生成。如果存在，则会自动安装Pipfile中的所有依赖

## 虚拟环境使用

```bash
# 进入环境
$ pipenv shell
# 退出环境, 或者按 ctrl + D
$ exit
```

> tips: 注意：千万不要使用 deactivate 命令退出

### 虚拟环境代理

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

### 虚拟环境常用指令

```bash
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
Command    Script
---------  ---------------------------
main       python main.py
```

那么不进入环境，直接执行则为

```bash
$ pipenv run main
Loading .env environment variables...
......
```

## 官方说明

- [pypi.org/project/pipenv](https://pypi.org/project/pipenv/)