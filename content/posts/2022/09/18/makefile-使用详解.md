---
title: "Makefile 使用详解"
date: 2022-09-18T22:28:36+08:00
description: "Makefile make 常见使用，及例子"
draft: false
categories: ['basics']
tags: ['basics']
toc:
  enable: true
  auto: false
math:
  enable: false
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## makefile介绍

在 Unix 下的软件工程，会不会编写 makefile，从一个侧面说明了开发者是否具备完成大型工程的能力

因为，makefile关系到了整个工程的编译规则

- 一个工程中的源文件不计数，其按类型、功能、模块分别放在若干个目录中
- makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译
- 甚至于进行更复杂的功能操作，因为 makefile 就像一个树状 shell 脚本一样，不但可以执行依赖的任务，也可以执行操作系统的命令

makefile带来的好处就是—— `自动化编译`
一旦写好，只需要一个make命令，整个工程完全自动编译，极大的提高了软件开发的效率

> 这里介绍的是 GNU 对 makefile 的描述和支持

参考

- [https://en.wikipedia.org/wiki/Make_(software)#Makefile](https://en.wikipedia.org/wiki/Make_(software)#Makefile)
- [https://www.gnu.org/software/make/manual/html_node/Introduction.html#index-makefile](https://www.gnu.org/software/make/manual/html_node/Introduction.html#index-makefile)

参考练习网站

- [https://makefiletutorial.com/](https://makefiletutorial.com/)

## makefile 组成

- [https://www.gnu.org/software/make/manual/html_node/Rule-Introduction.html#Rule-Introduction](https://www.gnu.org/software/make/manual/html_node/Rule-Introduction.html#Rule-Introduction)

### Makefile 基本格式

```
target … : prerequisites …
        recipe
        …
        …
```

- `target` 目标文件, 可以是 Object File, 也可以是可执行文件
- `prerequisites` 生成 target 所需要的文件或者目标，比如生成某个文件的前置任务是另外个目标
- `command` 需要执行的命令，可以是任意的 shell 命令,  Makefile中的命令必须以 `tab` 开头

### 对应规则

- `显示规则` 说明如何生成一个或多个目标文件(包括 生成的文件, 文件的依赖文件, 生成的命令)
- `隐晦规则` make的自动推导功能所执行的规则
- `定义变量` Makefile中定义的变量
- `文件指示` Makefile中引用其他Makefile; 指定Makefile中有效部分; 定义一个多行命令
- `注释 ` Makefile 只有行注释，以 `#` 开头，如果要使用或者输出 `#` 字符, 需要进行转义, `\#`

## make 命令基础

### make 的工作过程

- [https://www.gnu.org/software/make/manual/html_node/How-Make-Works.html#How-Make-Works](https://www.gnu.org/software/make/manual/html_node/How-Make-Works.html#How-Make-Works)

1. 读入主Makefile (主Makefile中可以引用其他Makefile)
1. 读入被include的其他Makefile
1. 初始化文件中的变量
1. 推导隐晦规则, 并分析所有规则
1. 为所有的目标文件创建依赖关系链
1. 根据依赖关系, 决定哪些目标要重新生成
1. 执行生成命令

### 运行 make 和指定 Makefile 目标

默认执行 make 命令时,

- GNU make 在 `当前目录`下依次搜索下面3个文件 `GNUmakefile` , `makefile`, `Makefile`
- 找到对应文件之后, 就开始执行此文件中从上到下的第一个目标(target)
- 如果找不到这3个文件就报错
- 如果指定了参数 `-f` 和一个存在的文件，可以使用默认文件
- 目标可以被指定，切换到其他目标
- 目标不存在，也会报错

e.g. [https://github.com/sinlov/makefile-playground/blob/main/00-basic](https://github.com/sinlov/makefile-playground/blob/main/00-basic)

```
.
├── 00-GNUMakefile
│   └── GNUmakefile
├── 01-more-makefile
│   ├── GNUmakefile
│   └── Makefile
└── 02-no-default
    └── make-file
$ cd 00-GNUMakefile
$ make
targetGNU1 [1]  begin
targetGNU1 [1]  end

$ cd ../01-more-makefile
$ make
targetGNU1 [1]  begin
targetGNU1 [1]  end

$ cd ../02-no-default
make: *** No targets specified and no makefile found.  Stop.

$ make -f make-file
targetMakefile1 [1]  begin
targetMakefile1 [1]  end

$ make -f make-file targetMakefile2
targetMakefile2 [2]  begin
targetMakefile2 [2]  end

$ make -f make-file targetMakefile3
make: *** No rule to make target `targetMakefile3'.  Stop.
```

#### make 常用命令参数

全部参数查看 `man make`  or `make -h`

常用参数见下表

| 参数 | 描述 |
|:---|:---|
| `-f` | 指定运行文件 |
| `-q` | 找目标的意思，也就是说，如果目标存在，那么其什么也不会输出，当然也不会执行编译，如果目标不存在，其会打印出一条出错信息 |
| `-B --always-make` | 假设所有目标都有更新, 即强制重编译 |
| `--debug[=<options>]` | 输出make的调试信息, options 可以是 a, b, v |
| `-j --jobs` | 同时运行的命令的线程个数, 也就是多线程执行 Makefile |
| `-r --no-builtin-rules` | 禁止使用任何隐含规则 |
| `-R --no-builtin-variabes` | 禁止使用任何作用于变量上的隐含规则 |

#### 静态模式

静态模式可以更加容易地定义多目标的规则，可以让我们的规则变得更加的有弹性和灵活，语法

```
<targets...>: <target-pattern>: <prereq-patterns ...>
	<commands>
```

- targets定义了一系列的目标文件，可以有通配符。是目标的一个集合
- target-parrtern是指明了targets的模式，也就是的目标集模式
- prereq-parrterns是目标的依赖模式，它对target-parrtern形成的模式再进行一次依赖目标的定义

例如

```mk
objects = foo.o bar.o

all: $(objects)

$(objects): %.o: %.c

$(CC) -c $(CFLAGS) $< -o $@
```

展开后等价于下面的规则

```mk
foo.o : foo.c

$(CC) -c $(CFLAGS) foo.c -o foo.o

bar.o : bar.c

$(CC) -c $(CFLAGS) bar.c -o bar.o
```

如果我们的“%.o”有几百个，那种我们只要用这种很简单的 `静态模式规则` 就可以写完一堆规则

### make 退出码

make 的退出码有以下3种

- `0` 表示成功执行
- `1` make命令出现了错误，或者使用了参数 `-q` 选项
- `2` make命令出现了错误，并且使用了 `-q` 选项, 并且make使得一些目标不需要更新

e.g. [https://github.com/sinlov/makefile-playground/01-command/00-args](https://github.com/sinlov/makefile-playground/01-command/00-args)

```mk
all:
	@echo "target all [1]  begin"
	@echo "target all [1]  end"
```

执行测试

```bash
$ make all && echo $?
target all [1]  begin
target all [1]  end
0

$ make all -q ||  echo $?
1

$ make allTag -q ||  echo $?
make: *** No rule to make target `allTag'.  Stop.
2
```

## Makefile 语法

### 语法规则

语法有以下2种

```
target ... : prerequisites ...
	command
	...
```

或者

```
target ... : prerequisites ; command
	command
	...
```

> tips: command太长, 可以用 `\` 作为换行符

####  通配符

- `*`	表示任意一个或多个字符
- `?` 表示任意一个字符
- `[...]`	ex.  `[abcd]` 表示a,b,c,d中任意一个字符,  `[^abcd]` 表示除 a,b,c,d 以外的字符,  `[0-9]` 表示 0~9中任意一个数字
- `~`	表示用户的 home目录

#### 路径搜索

Makefile 中涉及到大量源文件时，源文件和 Makefile 极有可能不在同一个目录中，那么最好将源文件的路径明确在Makefile中, 便于编译时查找

Makefile 中有个特殊的变量 `VPATH` 就是解决这个问题的

> 指定了 VPATH 之后, 如果当前目录中没有找到相应文件或依赖的文件, Makefile 回到 VPATH 指定的路径中再去查找

VPATH 使用方法

```
vpath <directories>            :: 当前目录中找不到文件时, 就从<directories>中搜索
vpath <pattern> <directories>  :: 符合<pattern>格式的文件, 就从<directories>中搜索
vpath <pattern>                :: 清除符合<pattern>格式的文件搜索路径
vpath                          :: 清除所有已经设置好的文件路径
```

例子

```mk
# 示例1 - 当前目录中找不到文件时, 按顺序从 src目录 ../parent-dir目录中查找文件
VPATH src:../parent-dir

# 示例2 - .h结尾的文件都从 ./header 目录中查找
VPATH %.h ./header

# 示例3 - 清除示例2中设置的规则
VPATH %.h

# 示例4 - 清除所有VPATH的设置
VPATH
```

### 定义命令包

出现一些相同命令序列，那么我们可以为这些相同的命令序列定义一个变量，语法

```mk
define <comm-pkg>
endef
```

e.g. [https://github.com/sinlov/makefile-playground/blob/main/05-method/00-custom-define-pkg/Makefile](https://github.com/sinlov/makefile-playground/blob/main/05-method/00-custom-define-pkg/Makefile)

```mk
define show-basic-variable
@echo "Hello\n"
@echo RM -> $(RM)
@echo AR -> $(AR)
@echo CC -> $(CC)
@echo CXX -> $(CXX)
@echo CPP -> $(CPP)
endef

all:
	$(show-basic-variable)
```

执行效果为

```bash
$ make
Hello

RM rm -f
AR ar
CC cc
CXX c++
CPP cc -E
```

### Makefile 中的变量

####  变量定义

使用 `=` `:=` `?=` 定义变量

- 使用 `=` 号或者 `:=`

左侧是变量，右侧是变量的值，右侧变量的值可以定义在文件的任何一处

> 其中 `=` 和 `:=` 的区别在于,  `:=` 只能使用前面定义好的变量, `=` 可以使用后面定义的变量

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/01-variate-define/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/01-variate-define/Makefile)

```mk
OBJS2 = $(OBJS1) programC.o
OBJS1 = programA.o programB.o

all:
	@echo $(OBJS2)
```

bash中执行 make, 可以看出虽然 OBJS1 是在 OBJS2 之后定义的, 但在 OBJS2中可以提前使用

```bash
$ make
programA.o programB.o programC.o
```

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/02-variate-define-after/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/02-variate-define-after/Makefile)

```mk
OBJS2 := $(OBJS1) programC.o
OBJS1 := programA.o programB.o

all:
	@echo $(OBJS2)
```

bash中执行 make, 可以看出 OBJS2 中的 $(OBJS1) 为空

```bash
$ make
programC.o
```

- 使用 `?=`

如果变量没有被定义过，那么变量的值就是当前定义的值，如果变量先前被定义过，那么这条语将什么也不做


#### 变量替换

- 替换方法为 `$(VAR:[form]=[to])`

> 注意:替换表达式中不能有空格

- 使用 `%` 保留`变量值中的指定字符串`，其他部分替换为新字符，格式 `$(var:a%b=x%y)` 意思为 a换成x b 换成y

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/03-variable-substitution/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/03-variable-substitution/Makefile)

```mk
SRCS := programA.c programB.c programC.c
OBJS := $(SRCS:%.c=%.o)

all:
	@echo "SRCS: " $(SRCS)
	@echo "OBJS: " $(OBJS)
```

bash中运行make

```bash
$ make
SRCS:  programA.c programB.c programC.c
OBJS:  programA.o programB.o programC.o
```

####  变量追加

- 使用 `+=` 对已经存在的变量进行追加

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/04-variate-append/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/04-variate-append/Makefile)

```mk
SRCS := programA.c programB.c programC.c
SRCS += programD.c

all:
	@echo "SRCS: " $(SRCS)
```

bash中运行make

```bash
$ make
SRCS:  programA.c programB.c programC.c programD.c
```

### 变量覆盖

能让 Makefile 中定义的变量能够覆盖 `make 命令参数` 中指定的变量

参考 [https://makefiletutorial.com/#command-line-arguments-and-override](https://makefiletutorial.com/#command-line-arguments-and-override)

```
override <variable> = <value>
override <variable> := <value>
override <variable> += <value>
```

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/05-variate-override/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/05-variate-override/Makefile)

```mk
SRCS := programA.c programB.c programC.c

notOverride:
	@echo "SRCS: " $(SRCS)

override OSRCS := programA.c programB.c programC.c

override:
	@echo "OSRCS: " $(OSRCS)
```

- 执行的时候分别测试覆盖和布覆盖的效果

```bash
$ make notOverride SRCS=nothing
SRCS:  nothing

$ make override OSRCS=nothing
OSRCS:  programA.c programB.c programC.c
```

#### 目标变量

使变量的作用域仅限于这个 taget(目标)，区分于其他 target
语法

```
<target ...> :: <variable-assignment>

<target ...> :: override <variable-assignment>
```

> override 的使用方法同 变量覆盖

e.g. [https://github.com/sinlov/makefile-playground/blob/main/02-variate/06-variate-target/Makefile](https://github.com/sinlov/makefile-playground/blob/main/02-variate/06-variate-target/Makefile)

```mk
SRCS := programA.c programB.c programC.c

target1:
	@echo "SRCS: " $(SRCS)
	@echo "TARGET1-SRCS: " $(TARGET1-SRCS)
	@echo "TARGET2-SRCS: " $(TARGET2-SRCS)
	@echo "TARGET3-SRCS: " $(TARGET3-SRCS)

target2: TARGET2-SRCS := program2.c
target2:
	@echo "SRCS: " $(SRCS)
	@echo "TARGET1-SRCS: " $(TARGET1-SRCS)
	@echo "TARGET2-SRCS: " $(TARGET2-SRCS)
	@echo "TARGET3-SRCS: " $(TARGET3-SRCS)

target3: override TARGET3-SRCS := program3.c
target3:
	@echo "SRCS: " $(SRCS)
	@echo "TARGET1-SRCS: " $(TARGET1-SRCS)
	@echo "TARGET2-SRCS: " $(TARGET2-SRCS)
	@echo "TARGET3-SRCS: " $(TARGET3-SRCS)
```

执行效果

```bash
$ make target1
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:
TARGET2-SRCS:
TARGET3-SRCS:
$ make target1 TARGET1-SRCS=TARGET1-SRCS
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:  TARGET1-SRCS
TARGET2-SRCS:
TARGET3-SRCS:

$ make target2
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:
TARGET2-SRCS:  program2.c
TARGET3-SRCS:
$ make target2 TARGET2-SRCS=TARGET2-SRCS
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:
TARGET2-SRCS:  TARGET2-SRCS
TARGET3-SRCS:

$ make target3
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:
TARGET2-SRCS:
TARGET3-SRCS:  program3.c
$ make target3 TARGET3-SRCS=TARGET3-SRCS
SRCS:  programA.c programB.c programC.c
TARGET1-SRCS:
TARGET2-SRCS:
TARGET3-SRCS:  program3.c
```

### Makefile 命令前缀

书写shell命令时可以加 2 种前缀 `@` 或者 `-`，区别为

- `不用前缀` 输出执行的命令以及命令执行的结果, `出错的话停止执行`
- `@` 只输出命令执行的结果, `出错的话停止执行`
- `-` 命令执行有错的话, 忽略错误, 继续执行

e.g. [https://github.com/sinlov/makefile-playground/blob/main/03-comand-prefix/Makefile](https://github.com/sinlov/makefile-playground/blob/main/03-comand-prefix/Makefile)

```mk
prefixEmpty:
	echo "empty prefix: "
	cat this_file_not_exist
	echo "error not show"

prefixAt:
	@echo "prefix at: "
	@cat this_file_not_exist
	@echo "error not show"

prefixMinus:
	-echo "prefix minus: "
	-cat this_file_not_exist
	-@echo "this after error show"
```

执行效果如下

```bash
$ make prefixEmpty
echo "empty prefix: "
empty prefix:
cat this_file_not_exist
cat: this_file_not_exist: No such file or directory
make: *** [prefixEmpty] Error 1

$ make prefixAt
prefix at:
cat: this_file_not_exist: No such file or directory
make: *** [prefixAt] Error 1

$ make prefixMinus
echo "prefix minus: "
prefix minus:
cat this_file_not_exist
cat: this_file_not_exist: No such file or directory
make: [prefixMinus] Error 1 (ignored)
this after error show
```

### 伪目标

伪目标并不是一个 `目标(target)`, 不像真正的目标那样会生成一个目标文件

> 典型的伪目标是 Makefile 中用来清理编译过程中中间文件的 clean 伪目标

```mk
.PHONY: clean   # 这句没有也行, 但是最好加上
clean:
    $(RM) *.o
```

> `$(RM)` 为隐含变量，默认值为 rm -f



### 引用其他的 Makefile

语法:

```
include <filename>  (filename 可以包含通配符和路径)
```

e.g. [https://github.com/sinlov/makefile-playground/blob/main/04-mutli-makefile/00-inculde-other](https://github.com/sinlov/makefile-playground/blob/main/04-mutli-makefile/00-inculde-other)

```mk
# Makefile

all:
	@echo "main Makefile begin"
	@make one-all
	@echo "main Makefile end"

include ./one.mk

# one.mk
one-all:
	@echo "one makefile one-all begin"
	@echo "one makefile one-all end"
```

执行测试

```bash
$ make
main Makefile begin
one makefile one-all begin
one makefile one-all end
main Makefile end
```

> 注意: 为了避免混乱 make 不允许把整个条件语句分成两部分放在不同的文件中

#### MAKEFILES 环境变量介绍

如果你的当前环境中定义了 环境变量 `MAKEFILES` make会把这个变量中的值做一个类似于include的动作
和include不同的是

- 从这个环境变中引入的Makefile的 `target(目标)` 不会起作用
- 如果环境变量中定义的文件发现错误，make也会不理

> 建议不要使用这个环境变量，因为只要这个变量一被定义，那么当你使用make时，所有的Makefile都会受到它的影响，这绝不是你想看到的。在这里提这个事，只是为了告诉大家，也许有时候你的Makefile出现了怪事，那么你可以看看当前环境中有没有定义这个变量

#### 查看 c文件 的依赖关系

Makefile 的时候, 需要确定每个目标的依赖关系

GNU提供一个机制可以查看C代码文件依赖那些文件, 这样在写 Makefile 目标的时候就不用打开C源码来看其依赖那些文件

e.g. [https://github.com/sinlov/makefile-playground/blob/main/04-mutli-makefile/01-c-dependencies](https://github.com/sinlov/makefile-playground/blob/main/04-mutli-makefile/01-c-dependencies)

```
.
├── Makefile
├── dmain.c
└── include
    ├── dmain.h
    └── dtype.h
```

> 这个目录下的 Makefile 比较复杂，后面会讲为啥会写这么复杂

```bash
$ gcc -MM dmain.c
dmain.o: dmain.c include/dmain.h include/dtype.h

$ make all
gcc -std=gnu11 -Wall -Werror -Wno-unused-function -Wno-nonnull -I include dmain.c -c -o build/dmain.o
gcc -std=gnu11 -Wall -Werror -Wno-unused-function -Wno-nonnull -I include build/dmain.o -o bin/d_example
$ ./bin/d_example
d_main_version 1.0.0
get_d_status() 3
$ make clean
rm -f -r build bin
```


### 条件判断

- 参考 [https://makefiletutorial.com/#conditional-part-of-makefiles](https://makefiletutorial.com/#conditional-part-of-makefiles)

使用条件判断，可以让make根据运行时的不同情况选择不同的执行分支，语法为

```
<conditional-directive>
<text-if-true>
endif
```

或者

```
<conditional-directive>
<text-if-true>
else
<text-if-false>
endif
```

 `conditional-directive` 关键字有四个

 #### `ifeq` 比较参数值是否相同

 常见写法

```
ifeq (<arg1>, <arg2> )
ifeq '<arg1>' '<arg2>'
ifeq "<arg1>" "<arg2>"
ifeq "<arg1>" '<arg2>'
ifeq '<arg1>' "<arg2>"
```

技巧，函数的返回值是空可以这么写

```mk
ifeq ($(strip $(foo)),)
<text-if-empty>
endif
```

#### `ifneq` 比较参数值是否不同

```
ifneq (<arg1>, <arg2> )
ifneq '<arg1>' '<arg2>'
ifneq "<arg1>" "<arg2>"
ifneq "<arg1>" '<arg2>'
ifneq '<arg1>' "<arg2>"
```

#### `ifdef` 值非空为真, `ifndef` 值空为真

```
ifdef <variable-name>

ifndef <variable-name>
```

ifdef 只是测试一个变量是否有值，其并不会把变量扩展到当前位置

e.g. [https://github.com/sinlov/makefile-playground/blob/main/05-method/01-conditional-ifdef](https://github.com/sinlov/makefile-playground/blob/main/05-method/01-conditional-ifdef)

```mk
# extension.mk
bar =
foo = $(bar)
ifdef foo
frobozz = yes
else
frobozz = no
endif

all:
	@echo frobozz $(frobozz)

# not-extension.mk
foo =
ifdef foo
frobozz = yes
else
frobozz = no
endif

all:
	@echo frobozz $(frobozz)
```

2个文件执行效果为

```bash
$ make -f extension.mk
frobozz yes
$ make -f not-extension.mk
frobozz no
```

### 使用函数

make所支持的函数也不算很多，不过已经足够的操作

函数调用后，函数的返回值可以当做变量来使用

#### 使用函数的语法

函数调用，很像变量的使用，也是以 `$` 来标识的

```
$(<function> <arguments>)

${<function> <arguments>}
```

- function 函数名
- arguments 参数间以逗号 `,` 分隔，而函数名和参数之间以 `空格` 分隔
- 圆括号或花括号都可以用，为了风格的统一，函数和变量的括号最好一样

### 字符串处理函数

#### 字符串替换函数 subst

```
$(subst <from>,<to>,<text>)
```

功能: 把字串 `<text>` 中的 `<from>` 字符串替换成  `to`

返回: 函数返回被替换过后的字符串

```mk
bar := ${subst not, totally, "I am not superman"}
all:
	@echo $(bar)
```

结果为 `I am totally superman`

如果想替换 空格 ， 可以先定义变量再替换

e.g. [https://github.com/sinlov/makefile-playground/blob/main/06-string-function/01-subst/replace-spaces.mk](https://github.com/sinlov/makefile-playground/blob/main/06-string-function/01-subst/replace-spaces.mk)

```mk
comma := ,
empty:=
space := $(empty) $(empty)
foo := a b c
bar := $(subst $(space),$(comma),$(foo))

all:
	@echo $(bar)
```

执行结果为

```bash
$ make -f replace-spaces.mk
a,b,c
```

#### 模式字符串替换函数 patsubst

```
$(patsubst <pattern>,<replacement>,<text>)
```

功能: 查找 `<text>` 中的单词(单词以 `空格`、`Tab` 或 `回车` `换行` 分隔) 是否符合模式 `<pattern>` ，如果匹配的话，则以 `<replacement>` 替换

返回: 函数返回被替换过后的字符串

- pattern 可以包括通配符 `%``，表示任意长度的字串
- pattern replacement 都包含 `%` ，那么，`<replacement>` 中的这个 `%` 将是 `<pattern>` 中的那个 `%` 所代表的字串

```mk
$(patsubst %.c,%.o,x.c.c bar.c)
```

结果为

```bash
x.c.o bar.o
```

也可以查看示例 [https://github.com/sinlov/makefile-playground/blob/main/06-string-function/02-patsubst/Makefile](https://github.com/sinlov/makefile-playground/blob/main/06-string-function/02-patsubst/Makefile)

#### 去空格函数 strip

```
$(strip <string>)
```

功能: 去掉 `<string>` 字串中开头和结尾的空字符

返回: 返回被去掉空格的字符串值

e.g.

```mk
$(strip a b c )
```

返回为 `a b c`，只去到开头和结尾的空格

#### 查找字符串函数 findstring

```
$(findstring <find>,<in>)
```

功能: 在字串 `<in>` 中查找 `<find>` 字串

返回: 如果找到，那么返回 `<find>` ，否则返回 `空字符串`

```mk
$(findstring a,a b c)
# 返回 字符串 a

$(findstring a,b c)
# 返回 空字符串
```

#### 过滤函数 filter

```
$(filter <pattern...>,<text>)
```

功能: 以 `<pattern>` 模式过滤 `<text>` 字符串中的单词，保留符合模式 `<pattern>` 的单词

返回: 返回符合模式 `<pattern>` 的字串

e.g.

```mk
sources := foo.c bar.c baz.s ugh.h

foo:
	cc $(filter %.c %.s,$(sources)) -o foo
```

`$(filter %.c %.s,$(sources))` 返回的值是 `foo.c bar.c baz.s`

- 其他例子见 [https://makefiletutorial.com/#static-pattern-rules-and-filter](https://makefiletutorial.com/#static-pattern-rules-and-filter)

#### 排序函数 sort

```
$(sort <list>)
```

功能: 给字符串 `<list>` 中的单词排序（升序），会去掉 `<list>` 中相同的单词

返回: 返回排序后的字符串

e.g.

```mk
$(sort foo bar lose)
# 返回为: bar foo lose
```

#### 取单词函数 word

```
$(word <n>,<text>)
```

功能: 从开始，取字符串 `<text>` 中第 `<n>` 个单词，`注意，第一个单词是 1`

返回: 返回字符串 `<text>` 中第 `<n>` 个单词，如果 `<n>` 比 `<text>` 中的单词数要大，那么返回空 `字符串`

e.g.

```mk
$(word 2, foo bar baz)
# 返回为 bar
```


#### 取单词串函数 wordlist

```
$(wordlist <s>,<e>,<text>)
```

功能: 从字符串 `<text>` 中取从 `<s>` 开始到 `<e>` 的单词串，`<s>`和 `<e>`是一个数字

返回: 返回字符串 `<text>` 中从 `<s>` 到 `<e>` 的单词字串；如果 `<s>` 比 `<text>` 中的单词数要大，那 么返回空字符串；如果 `<e>` 大于 `<text>` 的单词数，那么返回从 `<s>` 开始，到 `<text>` 结束的单 词串

e.g.

```mk
foo := $(wordlist 2, 3, foo bar baz)
bar := $(wordlist 3, 4, foo bar baz)
baz := $(wordlist 5, 6, foo bar baz)

all:
	@echo foo [${foo}]
	@echo bar [${bar}]
	@echo baz [${baz}]
```

执行结果为

```bash
$ make
foo [bar baz]
bar [baz]
baz []
```

#### 单词个数统计函数 words

> 该函数失效

```
$(words <text>)
```

功能: 统计 `<text>` 中字符串中的单词个数

返回: 返回 `<text>` 中的单词数

e.g.

```mk
sources := foo bar baz

foo := $(words, $(sources))
last := $(word $(words $(sources) ),$(sources))

all:
	@echo foo [${foo}]
	@echo last [${last}]
```

#### 首单词函数 firstword

```
$(firstword <text>)
```

功能: 取字符串 `<text>` 中的第一个单词

返回: 返回字符串 `<text>` 的第一个单词

e.g.

```mk
foo := $(firstword foo bar)

all:
	@echo foo [${foo}]
```

输出

```
foo [foo]
```

### 文件名操作函数

函数的参数字符串都会被当做一个或是一系列的文件名来对待

#### 取目录函数 dir

```
$(dir <names...>)
```

功能:  从文件名序列 `<names>` 中取出目录部分

返回: 返回文件名序列 `<names>` 的目录部分

e.g.[https://github.com/sinlov/makefile-playground/blob/main/07-path-function/01-dir/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/01-dir/Makefile)

```mk
source_path := $(dir src/foo.c hacks)

all:
	@echo source_path [${source_path}]
```

- 输出为

```bash
$ make
source_path [src/ ./]
```

#### 取文件函数 notdir

```
$(notdir <names...>)
```

功能: 从文件名序列 `<names>` 中取出非目录部分

返回: 返回文件名序列 `<names>` 的非目录部分

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/02-notdir/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/02-notdir/Makefile)

```mk
source_path := $(notdir src/foo.c hacks)

all:
	@echo source_path [${source_path}]
```

- 执行结果为

```
$ make
source_path [foo.c hacks]
```

#### 取后缀函数 suffix

```
$(suffix <names...>)
```

功能: 从文件名序列 `<names>` 中取出各个文件名的后缀

返回: 文件名序列 `<names>` 的后缀序列，如果文件没有后缀，则返回 `空字串`

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/03-suffix/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/03-suffix/Makefile)

```mk
foo := $(suffix src/foo.c src-1.0/bar.c hacks)

all:
	@echo foo [${foo}]
```

执行输出为

```bash
$ make
foo [.c .c]
```

#### 取前缀函数 basename

```
$(basename <names...>)
```

功能: 从文件名序列 `<names>` 中取出各个文件名的前缀部分

返回: 返回文件名序列 `<names>` 的前缀序列，如果文件没有前缀，则返回`空字串`

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/04-basename/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/04-basename/Makefile)

```mk
foo := $(basename src/foo.c src-1.0/bar.c hacks)

all:
	@echo foo [${foo}]
```

- 执行结果

```bash
$ make
foo [src/foo src-1.0/bar hacks]
```

#### 加后缀函数 addsuffix

```
$(addsuffix <suffix>,<names...>)
```

功能: 把后缀 `<suffix>` 加到 `<names>` 中的每个单词后面

返回: 返回加过后缀的文件名序列

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/05-addsuffix/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/05-addsuffix/Makefile)

```mk
foo := $(addsuffix .c,foo bar)

all:
	@echo foo [${foo}]
```

执行结果

```bash
$ make
foo [foo.c bar.c]
```

#### 加前缀函数 addprefix

```
$(addprefix <prefix>,<names...>)
```

功能: 把前缀 `<prefix>` 加到 `<names>` 中的每个单词后面

返回: 返回加过前缀的文件名序列

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/06-addprefix/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/06-addprefix/Makefile)

```mk
foo := $(addprefix src/,foo bar)

all:
	@echo foo [${foo}]
```

执行结果

```bash
$ make
foo [src/foo src/bar]
```

#### 连接函数  join

```
$(join <list1>,<list2>)
```

功能: 把 `<list2>` 中的单词对应地加到 `<list1>` 的单词后面。如果 `<list1>` 的单词个数要比 `<list2>` 的多，那么，`<list1>`中的多出来的单词将保持原样。如果`<list2>`的单词个数要比 `<list1>` 多，那么，`<list2>` 多出来的单词将被复制到 `<list2>` 中

返回: 返回连接过后的字符串

e.g. [https://github.com/sinlov/makefile-playground/blob/main/07-path-function/07-join/Makefile](https://github.com/sinlov/makefile-playground/blob/main/07-path-function/07-join/Makefile)

```mk
foo := $(join aaa bbb , 111 222 333)

all:
	@echo foo [${foo}]
```

执行结果

```bash
$ make
foo [aaa111 bbb222 333]
```

### foreach 函数

foreach 函数和别的函数非常的不一样。因为这个函数是用来做循环用的

Makefile 中的 foreach 函数几乎是仿照于 Unix 标准 Shell `/bin/sh` 中的 for 语句
或是 C-Shell `/bin/csh` 中的 foreach 语句而构建的

```
$(foreach <var>,<list>,<text>)
```

函数的意思是，把参数`<list>`中的单词逐一取出放到参数`<var>`所指定的变量中，然后再执行`<text>`所包含的表达式
每一次`<text>`会返回一个字符串，循环过程中，`<text>`的所返回的每个字符串会以空格分隔，最后当整个循环结束时，`<text>`所返回的每个字符串所组成的整个字符串(以空格分隔) 将会是foreach函数的返回值

- `<var>`最好是一个变量名，并且 `<var>` 是一个临时的局部变量，foreach函数执行完后，参数 `<var>` 的变量将不在作用，其作用域只在 foreach 函数当中
- `<list>` 可以是一个表达式
- 而 `<text>` 中一般会使用 `<var>` 这个参数来依次枚举`<list>`中的单词

e.g. [https://github.com/sinlov/makefile-playground/blob/main/08-foreach/Makefile](https://github.com/sinlov/makefile-playground/blob/main/08-foreach/Makefile)

```mk
names := a b c d
files := $(foreach n,$(names),$(n).o)

all:
	@echo files [${files}]
```

执行结果为

```bash
$ make
files [a.o b.o c.o d.o]
```

### if 函数

很像GNU的make所支持的 ifeq 条件语句

```
$(if <condition>,<then-part>)

$(if <condition>,<then-part>,<else-part>)
```

- if 函数 可以包含 `else` 部分，或是不含。即if函数的参数可以是两个，也可以是三个
- `<condition>` 参数是 if 的表达式，如果其返回的为非空字符串，那么这个表达式就相当于返回真
- `<then-part>`和`<else-part>`只会有一个被计算

if 函数的返回值

- 如果`<condition>`为真（非空字符串），那个`<then- part>`会是整个函数的返回值
- 如果`<condition>`为假（空字符串），那么`<else-part>`会是整个函数的返回值，此时如果`<else-part>`没有被定义，那么，整个函数返回空字串

### call 函数

call 函数是 `唯一一个可以用来创建新的参数化的函数`

你可以写一个非常复杂的表达式，这个表达式中，你可以定义许多参数，然后你可以用call函数来向这个表达式传递参数

```
$(call <expression>,<parm1>,<parm2>,<parm3>...)
```

当 make执行这个函数时，`<expression>`参数中的变量，如`$(1)`，`$(2)`，`$(3)`等，会被参数`<parm1>`，`<parm2>`，`<parm3>`依次取代

`<expression>`的返回值就是 call函数的返回值

e.g. [https://github.com/sinlov/makefile-playground/blob/main/09-call/Makefile](https://github.com/sinlov/makefile-playground/blob/main/09-call/Makefile)

```mk
reverse = $(1) $(2)
foo = $(call reverse,a,b)

all:
	@echo foo [${foo}]
```

- 执行结果为

```bash
$ make
foo [a b]
```

### origin 函数

origin函数不像其它的函数，他并不操作变量的值，他`只是告诉你你的这个变量是哪里来的`

```
$(origin <variable>)
```

注意，`<variable>` 是变量的名字，不应该是引用。所以你最好不要在`<variable>`中使用`$`字符
origin函数会以其返回值来告诉你这个变量的

- origin 函数的返回值 默认为 `undefined`
- 如果为隐式规则的变量，返回为 `default`
- 如果变量为环境变量，返回为 `environment`
- 如果被定义在 Makefile，返回为 `file`
- 如果是在命令行定义的，返回为 `command line`
- 如果为命令运行中的自动化变量，返回为 `automatic`

假设我们有一个Makefile其包了一个定义文件 `Make.def`
在Make.def中定义了一个变量`bletch`，而我们的环境中也有一 个环境变量`bletch`, 那么就需要判断到底是哪来的

例如如果变量来源于环境，那么我们就把之重定义了，如果来源于Make.def或是命令行等非环境的，那么我们就不重新定义它

```mk
ifdef bletch
ifeq "$(origin bletch)" "environment"
bletch = barf, gag, etc.
endif
endif
```

详细例子 [https://github.com/sinlov/makefile-playground/blob/main/10-origin/Makefile](https://github.com/sinlov/makefile-playground/blob/main/10-origin/Makefile)

```mk
ifdef bletch
ifeq "$(origin bletch)" "environment"
bletch = barf, gag, etc.
endif
endif

foo := foo

all:
	@echo "origin -> undefined [$(origin notfound)]"
	@echo "origin -> default : CC [$(origin CC)]"
	@echo "origin -> environment : PATH [$(origin PATH)]"
	@echo "origin -> file : foo [$(origin foo)]"
	@echo "origin -> command line : C_FLAG [$(origin C_FLAG)]"
	@echo "origin -> change : bletch [$(origin bletch)]"
```

- 执行结果

```bash
$ make C_FLAG=1
origin -> undefined [undefined]
origin -> default : CC [default]
origin -> environment : PATH [environment]
origin -> file : foo [file]
origin -> command line : C_FLAG [command line]
origin -> change : bletch [undefined]

$ bletch=ONE make C_FLAG=1
origin -> undefined [undefined]
origin -> default : CC [default]
origin -> environment : PATH [environment]
origin -> file : foo [file]
origin -> command line : C_FLAG [command line]
origin -> change : bletch [file]
```

### shell 函数

shell 函数也不像其它的函数。顾名思义，它的参数应该就是操作系统Shell的命令
shell 函数把执行操作系统命令后的输出作为函数 返回

```mk
files := $(shell echo *.c)
```

> 注意，这个函数会新生成一个Shell程序来执行命令，所以你要注意其运行性能
> 如果你的Makefile中有一些比较复杂的规则，并大量使用了这个函数，那么对于你的系统性能是有害的
> 特别是Makefile的隐晦的规则可能会让你的shell函数执行的次数比你想像的多得多

### 控制 make 执行函数

通常，你需要检测一些运行Makefile时的运行时信息，并且根据这些信息来决定，你是让make继续执行，还是停止


#### error 函数

产生一个致命的错误

> 注意，error函数不会在一被使用就会产生错误信息，所以如果你把其定义在某个变量中，并在后续的脚本中使用这个变量，那么也是可以的

```
$(error <text ...>)
```

- `<text ...>`是错误信息

有两种常见用法 [https://github.com/sinlov/makefile-playground/tree/main/11-ctrl/00-error](https://github.com/sinlov/makefile-playground/tree/main/11-ctrl/00-error)

- 在变量ERROR_001定义了后执行时产生error调用

```mk
ifdef ERROR_001

$(error error is $(ERROR_001))

endif

all:
	@echo ERROR_001 [${ERROR_001}]
```

- 执行效果

```bash
$ make
ERROR_001 []
$ make ERROR_001=1
error-def.mk:3: *** error is 1.  Stop.
```

- 在 err 被执行时才发生 error 调用

```mk
ERR = $(error found an error!)

.PHONY: err

right:
	@echo right

err:
	@echo err $(ERR)
```

执行效果

```bash
$ make
right
$ make err
Makefile:9: *** found an error!.  Stop.
```

#### warning 函数

很像 error 函数，只是它并不会让make退出，只是输出一段警告信息，而make继续执行

## Makefile 隐含规则和自动变量

如果要使用隐含规则生成你需要的目标，你所需要做的就是不要写出这个目标的规则
那么，make 会试图去自动推导产生这个目标的规则和命令

> 可以使用 make 的参数 `-r` 或 `--no-builtin-rules` 选项来取消所有的预设置的隐含规则

### 自动变量

Makefile 中很多时候通过自动变量来简化书写, 各个自动变量的含义

| 自动变量 | 含义 |
|:------|:------|
| `$@` | 目标集合 |
| `$%` | 当目标是函数库文件时, 表示其中的目标文件名 |
| `$<` | 第一个依赖目标. 如果依赖目标是多个, 逐个表示依赖目标 |
| `$?` | 比目标新的依赖目标的集合 |
| `$^` | 所有依赖目标的集合, 会去除重复的依赖目标 |
| `$+` | 所有依赖目标的集合, 不会去除重复的依赖目标 |
| `$*` | 这个是GNU make特有的, 其它的make不一定支持 |

### 隐含命令变量和命令参数变量

#### 隐含命令变量

Makefile可以直接写 shell 时用这些变量

常见的命令变量

| 变量名 | 默认值 | 用途 |
|:----|:----|:----|
| RM | `rm -f` | 删除文件
| AR | `ar` | AS 汇编语言编译程序 |
| CC | `cc` | C语言编译程序 |
| CXX | `g++` | C++语言编译程序, 会被覆盖为 `c++` |
| CO | `co` | 从 RCS 文件中扩展文件程序 |
| CPP | `$(CC) -E` | C程序的预处理器（输出是标准输出设备）|
| CTANGLE | `ctangle` | 转换C Web 到 C |
| FC | `f77` | Fortran 和 Ratfor 的编译器和预处理程序 |
| GET | `get` | Fortran 从 SCCS 文件中扩展文件的程序 |
| LEX | `lex` | Lex方法分析器程序（针对于C或Ratfor）|
| PC | `pc` | Pascal语言编译程序 |
| TANGLE | `tangle` | 转换Web到Pascal语言的程序 |
| YACC | `yacc` | Yacc文法分析器（针对于C程序）|
| YACCR | `yacc -r` | Yacc文法分析器（针对于Ratfor程序） |
| MAKEINFO | `makeinfo` | 转换Texinfo源文件（.texi）到Info文件程序 |
| TEX | `tex` | TeX 源文件创建 TeX DVI 文件的程序 |
| TEXI2DVI | `texi2dvi` | 从Texinfo源文件创建军 TeX DVI 文件的程序 |
| WEAVE | `weave` | 转换Web到TeX的程序 |
| CWEAVE | `cweave` | 转换 C Web 到 TeX 的程序 |

#### 隐含命令参数的变量

没有指明其默认值，那么其默认值都是  空 ` `

Makefile可以直接写 shell 时用这些命令参数

| 参数变量名 | 默认值 | 用途 |
|:----|:----|:----|
| ARFLAGS | `rv` | 函数库打包程序AR命令的参数 |
| ASFLAGS |  | 汇编语言编译器参数 |
| CFLAGS | | C语言编译器参数 |
| CPPFLAGS | | C预处理器参数（C 和 Fortran 编译器 也会读取）|
| CXXFLAGS | | C++语言编译器参数 |
| LDFLAGS | | 链接器参数,比如 ld |
| FFLAGS | | Fortran语言编译器参数 |
| RFLAGS | | Ratfor 程序的Fortran 编译器参数 |
| GFLAGS | | SCCS `get` 程序参数 |
| LFLAGS | | Lex文法分析器参数 |
| PFLAGS | | Pascal语言编译器参数 |
| YFLAGS | | Yacc文法分析器参数 |
| COFLAGS | | RCS命令参数 |

### 不同编程语言目标的隐含规则

#### 编译C程序的隐含规则

`<n>.o` 的目标的依赖目标会自动推导为 `<n>.c`

并且其生成命令是 `$(CC) –c $(CPPFLAGS) $(CFLAGS)`

#### 编译C++程序的隐含规则

 `<n>.o` 的目标的依赖目标会自动推导为 `<n>.cc` 或是 `<n>.C`

 生成命令是 `$(CXX) –c $(CPPFLAGS) $(CFLAGS)`

 > 建议使用 `.cc`  作为C++源文件的后缀，而 不是 `.C`

#### 链接 Object 文件的隐含规则

`<n>` 目标依赖于 `<n>.o` 通过运行C的编译器来运行链接程序生成(一般 ld)

生成命令是 `$(CC) $(LDFLAGS) <n>.o $(LOADLIBES) $(LDLIBS)`

> 这个规则对 于只有一个源文件的工程有效，同时也对多个Object文件（由不同的源文件生成）的也有效

e.g.

如下规则：

```mk
x : y.o z.o
```

并且 `x.c` , `y.c` 和 `z.c` 都存在时，隐含规则将执行如下命令

```bash
cc -c x.c -o x.o cc -c y.c -o y.o cc -c z.c -o z.o cc x.o y.o z.o -o x rm -f x.o rm -f y.o rm -f z.o
```

如果没有一个源文件( 如上面的 x.c ) 和 你的目标名字 ( 如上面的x ) 相关联，那么，最好写出自己的生成规则，不然，隐含规则会报错的

#### 汇编和汇编预处理的隐含规则

`<n>.o` 的目标的依赖目标会自动推导为 `<n>.s`

默认使用编译工具 as

生成命令是 `$(AS) $(ASFLAGS)`

`<n>.s` 的目标的依赖目标会自动推导为 `<n>.S`

默认使用C预编译 cpp

生成命令是 `$(AS) $(ASFLAGS)`

#### 编译Pascal程序的隐含规则

`<n>.o` 的目标的依赖目标会自动推导为 `<n>.p`

 生成命令是 `$(PC) –c $(PFLAGS)`

 #### 编译Fortran/Ratfor程序的隐含规则

 `<n>.o` 的目标的依赖目标会自动推导为 `<n>.r` 或者  `<n>.F`  `<n>.f`

 生成命令是 `".f" "$(FC) –c $(FFLAGS)" ".F" "$(FC) –c $(FFLAGS) $(CPPFLAGS)" ".f" "$(FC) –c $(FFLAGS) $(RFLAGS)"`

 #### 预处理Fortran/Ratfor程序的隐含规则

 `<n>.f` 的目标的依赖目标会自动推导为 `<n>.r` 或者 `<n>.F`

 > 只是转换Ratfor或有预处理的Fortran程序到一个标准的Fortran程序

预处理命令 `".F” "$(FC) –F $(CPPFLAGS) $(FFLAGS)” ".r” "$(FC) –F $(FFLAGS) $(RFLAGS)"`

#### 编译 Modula-2 程序的隐含规则

`<n>.sym` 的目标的依赖目标会自动推导为 `<n>.def`

生成命令是 `$(M2C) $(M2FLAGS) $(DEFFLAGS)`

`<n.o>` 的目标的依赖目标会自动推导为 `<n>.mod`

生成命令 `$(M2C) $(M2FLAGS) $(MODFLAGS)`

#### Yacc C 程序时的隐含规则

Yacc生成的文件 `<n>.c` 的依赖文件被自动推导为 `<n>.y`

生成命令是 `$(YACC) $(YFALGS)`

> Yacc 是一个语法分析器

#### Lex C 程序时的隐含规则

`<n>.c` 的目标的依赖目标会自动推导为 `<n>.l` (Lex生成的文件)

生成命令是 `$(LEX) $(LFALGS)`

#### Lex Ratfor程序时的隐含规则

`<n>.r` 的目标的依赖目标会自动推导为 `<n>.l` Lex生成的文件

生成命令是 `$(LEX ) $(LFALGS)`

#### C程序、Yacc文件或Lex文件创建Lint库的隐含规则

`<n>.ln` 的目标的依赖目标会自动推导为 `<n>.c`

生成命令是： `$(LINT) $(LINTFALGS) $(CPPFLAGS) -i`

`<n>.y` 的目标的依赖目标会自动推导为 `<n>.l`

### 隐含规则链

make会努力自动推导生成目标的一切方法，不管中间目标有多少，其都会执着地把所有的隐含规则和你书写的规则全部合起来分析，努力达到目标

在默认情况下，对于中间目标，它和一般的目标有两个地方所不同

- 第一个不同是除非中间的目标不存在，才会引发中间规则
- 第二个不同的是，只要目标成功产生，那么，产生最终目标过程中，所产生的中间目标文件会被以 `$(RM)` 删除

> warning: 禁止同一个目标出现两次或两次以上，这样一来，就可防止在make自动推导时出现无限递归的情况

通常，一个被 makefile 指定成目标或是依赖目标的文件不能被当作中介

明显地说明一个文件或是目标是中介目标，你可以使用 `伪目标` `.INTERMEDIATE` 来强制声明

```mk
.INTERMEDIATE mid
```

可以阻止make自动删除中间目标，通过 伪目标 `.SECONDARY` 来强制声明

```mks
.SECONDARY sec
```

可以把你的目标，以模式 `.PRECIOUS` 方式来指定，来保存被隐含规则所生成的中间文件

```mk
.PRECIOUS %.o
```

#### 隐含规则自动优化

make 会优化一些特殊的隐含规则，而不生成中间文件

例如，从文件 `foo.c` 生成目标程序 `foo`, 本来需要先编译为中间文件 `foo.o`  然后链接为 `foo`，在实际运行 make 生成时，可以被 `cc` 命令直接解决 `cc –o foo foo.c` ，那么优化规则也不会生成中间文件
