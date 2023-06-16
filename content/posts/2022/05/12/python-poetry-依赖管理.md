---
title: "python poetry 依赖管理"
date: 2022-05-12T10:15:44+08:00
description: "python poetry 依赖管理使用，和进阶使用，包括 black 风格检查"
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

## python 依赖管理工具 poetry

支持 Python 2.7+, 3.7+

- 官方文档 [https://python-poetry.org/docs/](https://python-poetry.org/docs/)
- 依赖工具源码 [https://github.com/python-poetry/poetry](https://github.com/python-poetry/poetry)

poetry 使用 `pyproject.toml` 代替 `setup.py`, `requirements.txt`, `setup.cfg`, `MANIFEST.in` 和新特性`Pipfile`

### pyproject.toml 演示

```toml
[tool.poetry]
name = "my-package"
version = "0.1.0"
description = "The description of the package"

license = "MIT"

authors = [
    "Sébastien Eustace <sebastien@eustace.io>"
]

readme = "README.md"  # Markdown files are supported

repository = "https://github.com/python-poetry/poetry"
homepage = "https://github.com/python-poetry/poetry"

keywords = ["packaging", "poetry"]

[tool.poetry.dependencies]
python = "~2.7 || ^3.7"  # Compatible python versions must be declared here
toml = "^0.9"
# Dependencies with extras
requests = { version = "^2.13", extras = [ "security" ] }
# Python specific dependencies with prereleases allowed
pathlib2 = { version = "^2.2", python = "~2.7", allow-prereleases = true }
# Git dependencies
cleo = { git = "https://github.com/sdispater/cleo.git", branch = "master" }

# Optional dependencies (extras)
pendulum = { version = "^1.4", optional = true }

[tool.poetry.dev-dependencies]
pytest = "^3.0"
pytest-cov = "^2.4"
```

## 安装

```bash
# install by brew
$ brew install poetry

$ pip3 install --user poetry
# 找不到的 poetry 命令，用这个帮助你打印需要配置在环境变量的路径
$ python -m site --user-base
# or
$ curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python3
```

### poetry 使用镜像源

- see [https://python-poetry.org/docs/repositories/#disabling-the-pypi-repository](https://python-poetry.org/docs/repositories/#disabling-the-pypi-repository)
- 在 `pyproject.toml` 文件末尾追加下面的内容来设置自定义镜像源加速

```toml
[[tool.poetry.source]]
name = "tsinghua"
url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple/"
default = true
```

or

```toml
# 设置poetry包管理工具的自定义pypi镜像源配置
[[tool.poetry.source]]
name = "aliyun"
url = "http://mirrors.aliyun.com/pypi/simple"
default = true
```

## 使用

### 首次使用

```bash
# show version
$ poetry --version

# use in project to create file pyproject.toml
$ poetry init

# use poetry to create project
$ poetry new project_name
```

### 依赖管理

```bash
$ poetry install
# --no-dev: Do not install dev dependencies
$ poetry install --no-dev
# --no-root: Do not install the root package (your project)
# --extras (-E): Features to install (multiple values allowed).

# let poetry use target python version will use pyenv, see https://github.com/python-poetry/poetry/issues/655
$ poetry env use python3.7

# search dependencies
$ poetry search [dependencies]
$ poetry search requests

# show dependencies
$ poetry show
# show as tree
$ poetry show --tree
# show outdated dependences
$ poetry show --outdated

# add
$ poetry add flask
# --dev (-D): Add package as development dependency
$ poetry add pytest --dev
# Do not perform install (only update the lockfile).
$ poetry add pytest --lock
# Outputs the operations but will not execute anything (implicitly enables –verbose)
$ poetry add pytest --dry-run
# Add as an optional dependency
$ poetry add pytest --optional
# The path to a dependency
$ poetry add pytest --path

# If you need to checkout a specific branch, tag or revision
$ poetry add git+https://github.com/sdispater/pendulum.git#develop
$ poetry add git+https://github.com/sdispater/pendulum.git#2.0.5
# make them point to a local directory
$ poetry add ./my-package/
$ poetry add ../my-package/dist/my-package-0.1.0.tar.gz
$ poetry add ../my-package/dist/my_package-0.1.0.whl

# update dependences
$ poetry update [dependences]
# update all
$ poetry update
# --dry-run : Outputs the operations but will not execute anything (implicitly enables –verbose).
# --no-dev : Do not install dev dependencies
# --lock : Do not perform install (only update the lockfile).

# remove dependences
$ poetry remove [dependences]

# lock
$ poetry lock
# check
$ poetry check
```

If you want the dependency to be installed in editable mode you can specify it in the `pyproject.toml` file. It means that changes in the local directory will be reflected directly in environment

```toml
[tool.poetry.dependencies]
my-package = {path = "../my/path", develop = true}
```

If the package(s) you want to install provide extras, you can specify them when adding the package

```bash
$ poetry add requests[security,socks]
$ poetry add "requests[security,socks]~=2.22.0"
$ poetry add "git+https://github.com/pallets/flask.git@1.1.1[dotenv,dev]"
```

### to virtualenv

```bash
$ poetry shell
# exit use ctrl+d

# see vituralenv python version
$ poetry run python -V
```

### run execute

```toml
[tool.poetry.scripts]
my-script = "my_module:main"
```

```bash
$ poetry run my-script
```

### build

```bash
# builds the source and wheels archives
$ poetry build
```

### export

```bash
$ poetry export -f requirements.txt --output requirements.txt
```

## Repositories

By default, Poetry is configured to use the [PyPI](https://pypi.org/) repository, for package installation and publishing.

So, when you add dependencies to your project, Poetry will assume they are available on PyPI.

This represents most cases and will likely be enough for most users.

### Using a private repository

```bash
$ poetry config repositories.foo https://foo.bar/simple/
```

Now that you can publish to your private repository, you need to be able to install dependencies from it.

For that, you have to edit your pyproject.toml file, like so

```toml
[[tool.poetry.source]]
name = "foo"
url = "https://foo.bar/simple/"
```

Disabling the PyPI repository

```toml
[[tool.poetry.source]]
name = "foo"
url = "https://foo.bar/simple/"
default = true
```

## 进阶

### black 风格检查

在  `pyproject.toml` 中加入

```toml
[tool.poetry.dev-dependencies]
isort = "==5.10.1"
black = "==22.10.0"

# https://pypi.org/project/black/
[tool.black]
line-length = 100
target-version = ['py36', 'py37', 'py38', 'py39', 'py310']
```

- 支持如下风格检查

```bash
# 首次安装，需要更新依赖
$ poetry update

# 检查代码风格 ${ENV_CHECK_FILES} 为需要检查的目录 ${ENV_BLACK_OPTS} 为检查配置，默认可以不写
$ poetry run black --check ${ENV_BLACK_OPTS} ${ENV_CHECK_FILES}

# 自动修复代码风格
$ poetry run isort -src ${ENV_CHECK_FILES}
$ poetry run black ${ENV_CHECK_FILES}
```