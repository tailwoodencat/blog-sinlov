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

- support poetry 1.7.1+

```bash
poetry source add --default aliyun https://mirrors.aliyun.com/pypi/simple
poetry source add --default tuna https://pypi.tuna.tsinghua.edu.cn/simple/
# 设置私有源
poetry source add --priority=PRIORITY [name] [url]
```

- 在 `pyproject.toml` 文件末尾追加下面的内容来设置自定义镜像源加速

```toml
## 设置poetry包管理工具的自定义pypi镜像源配置
[[tool.poetry.source]]
name = "aliyun"
url = "https://mirrors.aliyun.com/pypi/simple"
priority = "default"
```

- 老版本配置

```toml
[[tool.poetry.source]]
name = "tsinghua"
url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple/"
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

poetry 导出 requirements.txt

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

### 从 requirements.txt 生成 pyproject.toml

- [https://stackoverflow.com/questions/62764148/how-to-import-requirements-txt-from-an-existing-project-using-poetry](https://stackoverflow.com/questions/62764148/how-to-import-requirements-txt-from-an-existing-project-using-poetry)

```bash
poetry init --no-interaction

cat requirements.txt | xargs poetry add
poetry add -D "$(cat requirements.txt)"
```

第一条命令会初始化一个新的 poetry 项目

第二条命令会从requirements.txt文件中读取依赖项，并添加到 poetry 的项目依赖中

### ruff 风格检查

- [https://github.com/astral-sh/ruff](https://github.com/astral-sh/ruff)

用Rust编写极快的 Python linter和代码格式化工具

在  `pyproject.toml` 中加入

```toml
[tool.poetry.dev-dependencies]
# https://github.com/astral-sh/ruff
ruff = "^0.3.4"
```

> 不要把 ruff 安装到全局，不同版本的 ruff 规则不一样，应该把 ruff 安装到 工程隔离的 虚拟环境中
> 推荐不要把 ruff 写到 pyproject.toml 中，会导致维护麻烦，全部写到 ruff.toml 中隔离 工程管理 和 工程辅助的职责

配置 ruff 风格检查文件 `ruff.toml` 具体配置文档见 [https://docs.astral.sh/ruff/configuration/](https://docs.astral.sh/ruff/configuration/)

```toml
# Exclude a variety of commonly ignored directories.
exclude = [
    ".bzr",
    ".direnv",
    ".eggs",
    ".git",
    ".git-rewrite",
    ".hg",
    ".ipynb_checkpoints",
    ".mypy_cache",
    ".nox",
    ".pants.d",
    ".pyenv",
    ".pytest_cache",
    ".pytype",
    ".ruff_cache",
    ".svn",
    ".tox",
    ".venv",
    ".vscode",
    "__pypackages__",
    "_build",
    "buck-out",
    "build",
    "dist",
    "node_modules",
    "site-packages",
    "venv",
]

# Same as Black.
line-length = 88
indent-width = 4

# Assume Python 3.8
target-version = "py38"

[lint]
# Enable Pyflakes (`F`) and a subset of the pycodestyle (`E`)  codes by default.
select = ["E4", "E7", "E9", "F"]
ignore = []

# Allow fix for all enabled rules (when `--fix`) is provided.
fixable = ["ALL"]
unfixable = []

# Allow unused variables when underscore-prefixed.
dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$"

[format]
# Like Black, use double quotes for strings.
quote-style = "single"

# Like Black, indent with spaces, rather than tabs.
indent-style = "space"

# Like Black, respect magic trailing commas.
skip-magic-trailing-comma = false

# Like Black, automatically detect the appropriate line ending.
line-ending = "auto"
```

- 支持风格检查命令为

```bash
# 格式化
poetry run ruff format [dirs]

# 检查风格
poetry run ruff check [dirs]

# 对 poetry 目录下的 工程文件全部进行检查
poetry run ruff format src/ tests/
poetry run ruff check src/ tests/
```

### black 风格检查

> 如果已经使用了 ruff 风格检查，就不需要配置这个

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


## error

### Poetry was unable to find a compatible version

```
The currently activated Python version 3.9.7 is not supported by the project (3.10.7).
Trying to find and use a compatible version.

Poetry was unable to find a compatible version. If you have one, you can explicitly use it via the "env use" command
```

- 修复方法

```bash
pyenv shell 3.10.7
```

### Failed to unlock the collection!

```bash
  • Updating pip (23.2.1 -> 23.3.2): Failed

  KeyringLocked

  Failed to unlock the collection!

  at ~/.local/share/pypoetry/venv/lib/python3.10/site-packages/keyring/backends/SecretService.py:67 in get_preferred_collection
       63│             raise InitError("Failed to create the collection: %s." % e)
       64│         if collection.is_locked():
       65│             collection.unlock()
       66│             if collection.is_locked():  # User dismissed the prompt
    →  67│                 raise KeyringLocked("Failed to unlock the collection!")
       68│         return collection
       69│
       70│     def unlock(self, item):
       71│         if hasattr(item, 'unlock'):
```

当您没有运行初始化的密钥环/密钥服务时会导致这种情况，本来是为了给应用程序提供了一个安全的地方来存储凭据等。

This issue typically occurs when connecting over SSH as it may not even be spawning it.

修复方法是简单地禁用密钥环，以便 poetry 不会尝试使用使用

```bash
keyring --disable
```

### Failed to create the collection: Prompt dismissed

```
$ poetry lock --no-update
Failed to create the collection: Prompt dismissed..
```

same as `Failed to unlock the collection!`

### Configuration file exists

```log
Configuration file exists at ~/Library/Application Support/pypoetry,
reusing this directory.

Consider moving configuration to ~/Library/Preferences/pypoetry,
as support for the legacy directory will be removed in an upcoming release.
```

- doc [https://python-poetry.org/docs/configuration/](https://python-poetry.org/docs/configuration/)

- check

```bash
$ poetry config --list
# fix
$ mv ~/Library/Preferences/pypoetry ~/Library/Preferences/pypoetry_bak
```
