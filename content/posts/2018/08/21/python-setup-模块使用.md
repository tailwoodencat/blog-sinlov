---
title: "python setup 模块使用"
date: 2018-08-21T15:46:00+00:00
description: "python setup 模块的使用 参数解释等"
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

## 介绍

python setup 模块，在工程的根目录中含有文件 `setup.py`, 这个文件执行函数 `setup()`
用于 python 工程的 初始化，依赖安装，编译，构建等

## setup.py 常用命令

```sh
# 安装 依赖
python setup.py install
# 编译
python setup.py build
#制作分发包
python setup.py sdist
# 制作windows下的分发包
python setup.py bdist_wininst
# 制作 Linux 下的 rpm 分发包
python setup.py bdist_rpm
```

## setup.py 文件编写

一个的 setup.py 文件是这样的

```python
from setuptools import setup, find_packages
setup(
  name = "test",
  version = "1.0",
  keywords = ("test", "xxx"),
  description = "eds sdk",
  long_description = "eds sdk for python",
  license = "MIT Licence",
  url = "http://test.com",
  author = "test",
  author_email = "test@gmail.com",
  packages = find_packages(),
  include_package_data = True,
  platforms = "any",
  install_requires = [],
  scripts = [],
  entry_points = {
    'console_scripts': [
    'test = test.help:main'
    ]
  }
)
```

参数介绍

- --name 包名称
- --version (-V) 包版本
- --author 程序的作者
- --author_email 程序的作者的邮箱地址
- --maintainer 维护者
- --maintainer_email 维护者的邮箱地址
- --url 程序的官网地址
- --license 程序的授权信息
- --description 程序的简单描述
- --long_description 程序的详细描述
- --platforms 程序适用的软件平台列表
- --classifiers 程序的所属分类列表
- --keywords 程序的关键字列表
- --packages 需要处理的包目录（包含__init__.py的文件夹）
- --py_modules 需要打包的python文件列表
- --download_url 程序的下载地址
- --cmdclass 执行命令行的类
- --data_files 打包时需要打包的数据文件，如图片，配置文件等
- --scripts 安装时需要执行的脚步列表
- --package_dir 告诉setuptools哪些目录下的文件被映射到哪个源码包。
一个例子：package_dir = {'': 'lib'}，表示“root package”中的模块都在lib 目录中
- --requires 定义依赖哪些模块
- --provides定义可以为哪些模块提供依赖
- --find_packages() 对于简单工程来说，手动增加packages参数很容易

它默认在和setup.py同一目录下搜索各个含有 __init__.py的包
其实我们可以将包统一放在一个src目录中，另外，这个包内可能还有aaa.txt文件和data数据文件夹。另外，也可以排除一些特定的包

```python
find_packages(exclude=["*.tests", "*.tests.*", "tests.*", "tests"])
```

- --install_requires = ["requests"] 需要安装的依赖包
- --entry_points 动态发现服务和插件

```python
entry_points={
    'console_scripts': [
        'redis_run = RedisRun.redis_run:main',
    ]
}
```

console_scripts 指明了命令行工具的名称；在“redis_run = RedisRun.redis_run:main”中
等号前面指明了工具包的名称，等号后面的内容指明了程序的入口地址

> 可以有多条记录，这样一个项目就可以制作多个命令行工具

## setup.py 代码模板

```python
# -*- coding: utf-8 -*-
from setuptools import setup
setup(
    name='name',
    version='0.0.1',
    description='desc',
    # long_description=read('README.md'),
    license='MIT',
    # dependences
    install_requires=[
        'mock>=2.0.0',
        'requests>=2.18.4',
    ],
    # if use console scripts must open below
    # zip_safe=False
)
```

### pycharm python setup 模板

```python
from setuptools import setup

requires = [
    # 'requests>=2.18.4',
]

test_requirements = [
    'mock>=2.0.0',
    'pytest>=2.8.0',
    # 'pytest-cov',
    # 'pytest-mock',
    # 'pytest-xdist',
]

setup(
    name='$NAME$',
    version='$VERSION$',
    description='$DESC$',
    # long_description=read('README.md'),
    license='$LICENSE$',

    # dependences
    install_requires=requires,
    tests_require=test_requirements,
    extras_require={
    },

    # if use console scripts must open below
    zip_safe=False,
)
```
