---
title: "python 打包输出执行程序"
date: 2018-09-05T23:47:00+00:00
description: "python 打包 exe 或者 可执行包, 讲解 PyInstaller 或者 cpython 的使用"
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

## PyInstaller

- 把Python应用程序及其所有依赖项捆绑到一个包中，用户可以在不安装Python解释器或任何模块的情况下运行打包的应用程序
- PyInstaller支持Python 2.7和Python 3.3+
- 支持诸如numpy，PyQt，Django，wxPython等主要Python软件包
- 它不是一个交叉编译器：要制作一个Windows应用程序，你需要在Windows中运行PyInstaller；在Linux中运行Linux应用程序
- [官方文档 pyinstaller](https://pyinstaller.readthedocs.io/en/stable/)

### PyInstaller 常用参数

```sh
-d #debug模式，可以得到运行时的跟踪
-p DIR #可以增加pyinstaller搜索模块的路径，多个路径以:分隔。默认site-packages目录下都是可以被识别的
--add-data <SRC;DEST or SRC:DEST> #增加非二进制文件到目录下，windows以;分隔而且得用双引号包含，而*NIX以:分隔
--add-binary <SRC;DEST or SRC:DEST> #增加二进制文件到目录下
-i <FILE.ico or FILE.exe,ID or FILE.icns> #给打包的文件添加图标
--version-file FILE #windows里可把版本信息注入到exe里
```

- `--version-file` 需要的版本信息文件是需要格式

切换到 `python安装目录下的 `\Lib\site-packages\PyInstaller\utils\cliutils`下，有一个 `grab_version.py`

```sh
# 会生成一个 file_version_info.txt，这个文件就可以作为版本参考
python grab_version.py C:\Windows\System32\cmd.exe
```

### macOS 使用

```sh
pip install --user PyInstaller
```

- 打包程序

```sh
pyinstaller --help
# 后缀支持 .py .pyw
# 使用 -F 在当前目录下的dist文件夹,生成一个独立的执行文件
pyinstaller -F main.py
# 使用 -D 在当前目录下的dist文件夹生成一个文件夹存放exe以及所有依赖文件
pyinstaller -D --clean main.py
# # 使用 -w 在当前目录下的dist文件夹,生成一个 macOS 版的 app
pyinstaller -F -w main.py
```

### windows 使用

- 安装

```sh
pip install PyInstaller
# or
pip install --user PyInstaller
# will install at path: python -m site --user-base
```

- 打包程序

```sh
pyinstaller --help
# 后缀支持 .py .pyw
# 使用 -F 在当前目录下的dist文件夹,生成一个独立的exe文件
pyinstaller -F main.py
# 生成一个带窗口的应用包
pyinstaller -F -w main.py
# 使用 -D 在当前目录下的dist文件夹生成一个文件夹存放exe以及所有依赖文件
pyinstaller -D -w main.py
```

> 当 py 文件使用了窗体时，加入参数 -w，在windows下不会显示控制台，-w 在 UNIX系统里会被忽略

### 使用 spec 模式

如果不使用 `--specpath` 指定路径，会在当前目录下生成一个 spec文件，pyinstaller 是根据 spec 文件来创建 exe 文件
spec文件也是可以先生成

```sh
pyi-makespec [options] pcat.spec
# 生成spec文件后，你可以对其进行修改后
pyinstaller [options] pcat.spec
```

## cpython

- 输出平台二进制文件，可以保护代码
- 注意：它不是一个交叉编译器
- [官方文档 http://docs.cython.org/en/latest](http://docs.cython.org/en/latest/)

### 使用

安装

```bash
pip install Cython
```

> 安装失败见 http://docs.cython.org/en/latest/src/quickstart/install.html

例如，对文件 `test.py`创建出包配置 `setup.py`

```python
from distutils.core import setup
from Cython.Build import cythonize
setup(
    name = "test",
    ext_modules = cythonize("test.py")
)
```

运行命令

```sh
 python setup.py build_ext --inplace
```

输出的文件，`test.so` 可以直接当成模块，通过python调用

注意

- 编译的时候，如果执行命令的目录是 python 包（里面有 `__init__.py`），则编译的路径会改变
- 当文件改变，或者so文件被删除掉了，重复运行编译命令会重新编译，如果原py文件大小没有改变，so依旧存在，则重新编译不会编译

下面是一个编译 二进制文件的帮助脚本

```python
import platform

def py2binary(root_dir=str, file_path=str):
    u"""
    @root_dir 应用的上级
    @file_path文件的路径
    把指定的py文件编译成so 或者 dll文件, 如果文件存在，原py文件没有改变大小，则不编译
    """
    COMPILE_S = u"""
from distutils.core import setup
from Cython.Build import cythonize
setup(
    name = "temp",
    ext_modules = cythonize("{path}")
)"""
    if not os.path.exists(file_path):
        return False
    setup_file = COMPILE_S.format(path=file_path)
    so_file = ''
    if platform.system() == 'windows':
        so_file = file_path.replace(".py",".dll")
    else:
        so_file = file_path.replace(".py",".so")
    t = tempfile.NamedTemporaryFile(suffix='.py',delete = False)
    path = t.name
    t.write(setup_file)
    t.close()
    command = "python {path} build_ext --inplace".format(path=path)
    logger.info("command='%s'"%command)
    os.chdir(root_dir) #编译的时候，会在这个目录下面生成按照文件路径的so
    os.system(command)
    os.remove(path) #删除临时文件
    if os.path.exists(so_file):#编译好了so之后，删除py文件
        os.remove(file_path)

```
