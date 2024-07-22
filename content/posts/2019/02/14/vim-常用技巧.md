---
title: "vim 常用技巧"
date: 2019-02-14T20:01:00+00:00
description: "vim 在各种模式下的技巧, vim 学习游戏介绍"
draft: false
categories: ['basics']
tags: ['basics', 'vim']
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

# 使用前需要知道的

**vim 是对vi的扩展，文中的很多操作是vi通用的**

- vi是**区分大小写**的命令的，也就是说 `g`与`G` 是不同的命令

在不同模式下，快捷键是不一样的 模式

- `一般模式` 用于文件内部操作
- `编辑模式` 用于输入编写等
- `指令模式` 用于对文本文件进行操作

vim 帮助文档 [https://vim.fandom.com/wiki/Vim_Tips_Wiki](https://vim.fandom.com/wiki/Vim_Tips_Wiki)

## 光标移动训练

vim 光标不是上下左右而是 `hjkl` 那么有款 [pacvim](https://github.com/jmoon018/PacVim) 游戏可以帮助你

[玩游戏前看一定点击这里看说明书](https://github.com/jmoon018/PacVim#how-to-play)

```bash
# play with docker
$ docker run -it freedomben/pacvim
# install at macOS
$ brew install pacvim
```

# 常用操作

> 进入一般模式为开始编辑，或者按 `esc` 后进入 当然更建议使用 `Ctrl+[` 进入一般模式

|按键|效果|
|---|---|
|a,i,c,r,o,A,I,C,R,O|进入编辑模式 当然进入的是不同的编辑位置，非常常用|
|`n+`|数字+命令表示多次重复执行|
|h,backspace|左移动|
|l,space|右移动|
|j|下移动|
|k|上移动|
|0, \||移动到行首|
|`$`|移动到行末，`1$`表示当前行的行尾，`2$`表示当前行的下一行的行尾|
|b|按照单词向前移动 `<- 字首` |
|e|按照单词向后移动 `字 -> 尾` |
|w|按照单词向后移至次一个字首，一般是光标在单词中间，直接到单词首位 |
|H|移动到屏幕最上 非空白字 记忆方法 `H`igh |
|M|移动到屏幕中央 非空白字 记忆方法 `M`iddle |
|L|移动到屏幕最下 非空白字 记忆方法 `L`ow |
|zz|普通模式，把当前行置为屏幕中间|
|G|移动到文档最后一行 |
|gg|移动到文档第一行 |
|ngg |移动到文档的第 n 行的行首 |
|gi | 普通模式,快速回到上一次编辑位置，并进入编辑模式 |
|Ctrl+o | 普通模式，返回 |
|Ctrl+i | 普通模式，前进 |
|v|进入光标模式，配合移动键选中多个文字 |
|V|进入光标模式，配合移动键，选中多行|
|Ctrl+f|向下翻页|
|Ctrl+b|向上翻页|
|Ctrl+d|向下翻半页|
|Ctrl+u|向上翻半页|
|u| 撤销上一次操作 |
|Ctrl+r |再次执行上次的动作|
|\`\`|回到上次编辑的位置|
|~|更换当前光标位置的大小写，并光标移动到本行右一个位置，直到无法移动|
|x|快速删除一个字符`4x`快速删除4个字符|
|dw|删除一个单词（包含空格删除）3dw：快速删除3个单词|
|diw|保留空格删除|
|dt)|删除到右括号的内容，右括号被保留|
|dd|删除光标当前行|
|dG|删除光标后的全部文字|
|d$|删除本行光标后面的内容|
|d0|删除本行光标前面的内容|
|cw|删除这个单词后面的内容，并进入插入模式|
|ecw|删除这个单词并进入插入模式|
|cc|删除光标当前行，并进入插入模式|
|cG|删除光标后的全部文字，并进入插入模式|
|c$|删除本行光标后面的内容，并进入插入模式|
|c0|删除本行光标前面的内容，并进入插入模式|
|y|复制当前行，会复制换行符|
|yy|复制当前行的内容|
|yyp|复制当前行到下一行，此复制不会放到剪切板中|
|nyy|复制当前开始的n行|
|xp|交换字符后面的交换到前面|
|p,P,.|粘贴，不同的粘贴方式不一样|
|ddp|当前行和下一行互换位置|
|J|合并行|
|Ctrl+z|暂停并退出|
|ZZ|保存离开|

## 常用移动操作

辅助移动记忆图

![](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/02/06/vim-mnemonic-keys-GWOGs0.png)

|按键|速记|效果|
|:---|:---|:---|
| w | word | 下一个单词的开头，注意这个单词为非 a-zA-z0-9 组成 |
| e | end| 下一个单词的末尾，注意这个单词为非 a-zA-z0-9 组成 |
| b | back | 上一个单词的开头，注意这个单词为非 a-zA-z0-9 组成 |
| W | Word | 下一个单词的开头，注意这个单词为空格为分割 |
| E | End | 下一个单词的末尾，注意这个单词为空格为分割 |
| B | Back | 上一个单词的开头，注意这个单词为空格为分割 |
| I | Insert begin line | 移动到当前行开头并进行编辑 |
| A | Append end line | 移动到当前行末尾并进行编辑 |
| ^D | begin and delete or then editor | 删除当前内容行并进入编辑模式 |
| gi | goto insert | beam 技巧，快速定位到上次插入的位置，并进入编辑模式 |
| Ctrl+d | move down | 向文件尾翻半屏幕 |
| Ctrl+u | move up | 向文件头翻半屏幕 |
| zz | center cursor line in window | 当前光标调整居中 |
| tab + hjkl | editor mode | 在编辑模式下可以移动光标 |
| f{char} | find character | 移动到当前行右侧目标字符 |
| F{char} | find character | 移动到当前行左侧侧目标字符 |
| t{chat} | till character | 移动到当前行右侧目标字符的前一个 |
| T{chat} | till character | 移动到当前行左侧目标字符的前一个 |
| {} | code block | 段落进行移动, { 为向上 } 为向下 |
| % | goto match | 跳转到对于括号处 |
| g* | goto search for the word under the cursor | 向后到一样的 |
| g# | goto search for the word under the cursor backward direction | 向前到一样的 |
| gd | [goto define local](https://vim.fandom.com/wiki/Go_to_definition_using_g) | 跳转到函数定义位置(常常无法准确定位到变量和函数被声明),不搜索注释行 |
| gD | [goto define global](https://vim.fandom.com/wiki/Go_to_definition_using_g) | 跳转到函数定义位置 其实有全局 |

## 常用光标操作

|按键|速记|效果|
|:---|:---|:---|
| ggVG | select all | 全选整个 |
| viw | select word | 选中整个字符 |
| va{chat} | select all {chat} | 选中在 {chat} 中的全部字符 |

## mark 标记和快速查找

- 在 Normal 模式中可用
- `m` mark 标记键，`'` 为跳转键
- 标记方法为 `m+{mark}` mark 比如 a s d f 都可以作为标记
- 跳转则是按 \`{mark} 或者  '{mark} 则跳转到对应的标记
- mark 标记是可以跨文件的，但必须为大写跳转，如果想无视这个需要配置额外配置

`~/.vimrc`  如果是 idea 则需要配置在 `~/.ideavimrc`

```conf
" mark or goto mark ignore lower case
nnoremap ma mA
nnoremap 'a 'A
nnoremap ms mS
nnoremap 's 'S
nnoremap md mD
nnoremap 'd 'D
nnoremap mf mF
nnoremap 'f 'F
```

vscode 需要放到 `settings.json` 中的配置 `vim.normalModeKeyBindings`

```json
{
    "vim.normalModeKeyBindings": [
        {
            "before": ["m", "a"],
            "after": ["m", "A"]
    		},
    		{
            "before": ["'", "a"],
             "after": ["'", "A"]
    		},
    		{
            "before": ["m", "s"],
             "after": ["m", "S"]
    		},
    		{
            "before": ["'", "s"],
             "after": ["'", "S"]
    		},
    		{
            "before": ["m", "d"],
             "after": ["m", "D"]
    		},
    		{
            "before": ["'", "d"],
             "after": ["'", "D"]
    		},
    		{
            "before": ["'", "f"],
             "after": ["'", "F"]
    		},
    		{
            "before": ["'", "f"],
             "after": ["'", "F"]
    		}
    ]
}
```

## 快速编辑技巧

|按键|速记|效果|
|:---|:---|:---|
| Ctrl+a | fast add | 对数字快速增加，normal模式 |
| Ctrl+x | fast subtraction | 对数字快速减少，normal模式 |
| U/u | visule mode | 可视模式下的U或u：把选中的文本变为大写或小写 |
| ~ | toggle case | normal 模式快速对调字母大小写，并进入下一个字符 |
| gUw | extra Upper word | 对当前单词往后改为大写|
| guw | extra lower word | 对当前单词往后改为小写|
| z= | extra spell | 拼写检查列表 |

## 快速短语

:iab 通过这个设置比如

```conf
:iab author author:sinlov sinlovgmppt@gmail.com
```

- 输入 author 按 space 就会自动补全
- 如果不需要自动补全，就需要按 `Ctrl+v` 输入空格并且不需要补全

# 查找命令

|指令|效果|
|---|---|
|\*|向下查找同样光标的字符|
|#|向上查找同样光标的字符|
|/code|查找 code 一样的内容，向后|
|?code|查找 code 一样的内容，向前|
|n|查找下一处|
|N|查找上一处|
|ma|在光标处做一个名叫a的标记 可用26个标记 (a~z)|
|\`a|移动到一个标记a|
|d\`a|删除当前位置到标记a之间的内容|
|:marks|查看所有标记|

# 可视模式

|指令|效果|
|---|---|
|Ctrl+g | 可视模式和选择模式切换 |
| v V Ctrl+v | 分别激活面向字符、行、列的可视模式 |
| gv | 重选上次的高亮度选区 |
| o | 切换高亮度选区活动端 |

> vim 多行注释使用 `Ctrl+g  Ctrl+v` 选择行数 在执行 `I` 插入注释符号，然后 `Ctrl+[` `Ctrl+[` 即可

# 插入模式

|指令|效果|
|---|---|
| esc / Ctrl+\[ | 切换至普通模式 |
| Ctrl+o | 切换到插入-普通模式 |
| Ctrl+h | 同 backspace |
| Ctrl+w | 回删一个单词 |
| Ctrl+u | 删至行首 |
| R | 切换替换模式 |
| gR | 切换到虚拟替换模式 |
| r | 单次替换模式 |
| gr | 单次虚拟替换模式 |
| Ctrl+r{register} | 插入寄存器的内容，h i_Ctrl+R |
| Ctrl+r Ctrl+p | 按原语义插入寄存器的内容，防止不必要的缩进 |
| Ctrl+r={expression} | 插入表达式的结果 |
| Ctrl+v{3位code}或Ctrl+vu{4位code} | 插入 code 所代表的字符 |
| Ctrl+k{char1}{char2} | 插入以二合字母表示的字符 h digraph-table h digraps-default |

# 指令模式

|指令|效果|
|---|---|
|:q|一般退出|
|:q!|退出不保存|
|:wq|保存退出|
|:!| 切换到 vim 外，再次按 enter 进入 vim |
|:w filename|另存为 filename|
|:jumps|历史编辑文档记录|
|:set nu|设置行号显示|
|:set nonu|取消行号显示|
|:set|显示设置参数|
|:set autoindent|自动缩排，回车与第一个非空格符对齐|
|:syntax on/off|根据程序语法高亮显示|
|:set highlight|高亮设置查看|
|:set hlsearch|查找代码高亮显示|
|:nohlsearch|暂时关闭高亮显示|
|:set nohlsearch|永久关闭高亮显示|
|:set bg=dark|设置暗色调|
|:set bg=light|设置亮色调|

## 光标详细操作

|按键|效果|
|---|---|
|Ctrl+e|向下滚动|
|Ctrl+y|向上滚动|
|Ctrl+d|向文件尾翻半屏幕|
|Ctrl+u|向文件首翻半屏幕|
|b|按照单词向前移动 字首|
|B|按照单词向前移动 字首 忽略一些标点符号|
|e|按照单词向后移动 字尾|
|E|按照单词向后移动 忽略一些标点符号|
|w|按照单词向后移至次一个字首|
|W|按照单词向后移至次一个字首 忽略一些标点符号|
|H|移动到屏幕最上 非空白字|
|M|移动到屏幕中央 非空白字|
|L|移动到屏幕最下 非空白字|
|G|移动到文档最后一行|
|gg|移动到文档第一行|
|(|光标到句尾|
|)|光标到局首|
|{|光标到段落开头|
|}|光标到段落结尾|
|nG|光标下移动到n行的首位|
|n$|光标移动到n行尾部|
|n+|光标下移动n行|
|n-|光标上移动n行|

## 插入/修改

|按键|效果|
|---|---|
|i| insert 在光标前|
|I|在当前行首|
|a| append 在光标后|
|A|在当前行尾部|
|o|在当前行下新开一行|
|O|在当前行上新开一行|
|r|替换当前字符|
|R|替换当前行及后面的字符，直到按esc为止|
|s|从当前行开始，以输入的文本替代指定数目的字符|
|S|删除指定数目的行，并以输入的文本替代|
|ncw,nCW|修改指定数目n的字符|
|nCC|修改指定数目n的行|
| c{n}w: | 改写光标后1(n)个词 |
| c{n}l: | 改写光标后n个字母 |
| c{n}h: | 改写光标前n个字母 |
| {n}cc: | 修改当前{n}行 |
| {n}s: | 以输入的文本替代光标之后1(n)个字符，相当于c{n}l |
| {n}S: | 删除指定数目的行，并以所输入文本代替之 |
| c{n}w: | 改写光标后1(n)个词 |
| c{n}l: | 改写光标后n个字母 |
| c{n}h: | 改写光标前n个字母 |
| {n}cc: | 修改当前{n}行 |
| {n}s: | 以输入的文本替代光标之后1(n)个字符，相当于c{n}l |
| {n}S: | 删除指定数目的行，并以所输入文本代替之 |
|bcw| 删除当前字符，并进入编辑模式 |
|:r !date | 在光标处插入当前日期与时间 |
|:r !{command} | 可以将其它shell命令的输出插入当前文档 |
|:r filename| 在当前位置插入另一个文件 filename 的内容 |
|:{n}r filename | 在第n行插入另一个文件 filename 的内容|

## 删除命令

|按键|效果|
|---|---|
|ndw,nDW|删除光标开始及其后 n-1 个字符|
|dw|删除这个单词后面的内容|
|dG|删除光标后的全部文字|
|d$|删除本行光标后面的内容|
|d0|删除本行光标前面的内容|
|dd|剪切光标当前行，可以用 p 粘贴|
|ndd|删除当前行，以及其后的n-1行，可以用于粘贴|
|x|删除一个字符，光标后|
|X|删除一个字符，光标前|
|Ctrl+u|删除输入模式下的输入的文本|

## 替换(normal模式)

|指令|效果|
|---|---|
| r | 替换光标处的字符，同样支持汉字 |
| R |  进入替换模式，按esc回到正常模式 |

## 撤消与重做(normal模式)

|指令|效果|
|---|---|
| [n] u: | 取消一(n)个改动  |
| :undo 5 | – 撤销5个改变  |
| :undolist | – 你的撤销历史  |
| ctrl + r | 重做最后的改动  |
| U | 取消当前行中所有的改动  |
| :earlier 4m | 回到4分钟前 |
| :later 55s | 前进55秒 |

# 编辑模式

|按键|效果|
|---|---|
| Ctrl+n | next |
| Ctrl+d | undent |
| Ctrl+t | indent
| Ctrl+p | prev auto-complete |
| Ctrl+x | filename completion |

# 多窗口模式

|指令|效果|
|---|---|
|:split|创建新窗口|
|Ctrl+w|切换窗口|
|Ctrl+w =|所有窗口一样高|
|Ctrl+w+方向键|多窗口视图切换|

# 折叠

| 指令 | 说明 |
|:---|:---|
| zf | 创建折叠的命令，可以在一个可视区域上使用该命令 |
| zd | 删除当前行的折叠 |
| zD | 删除当前行的折叠 |
| zfap | 折叠光标所在的段 |
| zo | 打开折叠的文本 |
| zc | 收起折叠 |
| za | 打开/关闭当前折叠 |
| zr | 打开嵌套的折行 |
| zm | 收起嵌套的折行 |
| zR (zO) | 打开所有折行 |
| zM (zC) | 收起所有折行 |
| zj | 跳到下一个折叠处 |
| zk | 跳到上一个折叠处 |
| zi | enable/disable fold |

# 多文件编辑

|指令|效果|
|---|---|
|:args|列出当前编辑的文件名|
|:next|打开多文件，使用 n(Next) p(revious) | N(ext) 切换|
|:file|列出当前打开的所有文件|

# vim 自定义技巧

## 复制粘贴取消缩进

```
:set paste
```

进入paste模式以后，可以在插入模式下粘贴内容，不会有任何变形
这个参数做了这么多事：

```
textwidth设置为0
wrapmargin设置为0
set noai
set nosi
softtabstop设置为0
revins重置
ruler重置
showmatch重置
formatoptions使用空值
```

下面的选项值不变，但却被禁用

```
lisp
indentexpr
cindent
```

绑定快捷键来激活/取消 paste模式

```
:set pastetoggle=<F11>
```

出现粘贴换行符错位，设置一下 `.vimrc`

```
" this can change way of paste words
:set paste
" default tabstop=8
:set tabstop=4
" use keyboard F11 to change paste mode
:set pastetoggle=<F11>
```


### vim 缩进

Normal Mode下，命令`>>`将对当前行增加缩进，而命令`<<`则将对当前行减少缩进
在命令前使用数字，来指定命令作用的范围

```
5<<
```

在Insert/Replace Mode下

`Ctrl+Shift-t`可以增加当前行的缩进
`Ctrl+Shift-d`则可以减少当前行的缩进
使用`0-Ctrl+Shift-d`命令，将移除所有缩进

> 需要注意的是，当我们输入命令中的“0”时，Vim会认为我们要在文本中插入一个0，并在屏幕上显示输入的“0”；然后当我们执行命令0-Ctrl+Shift-d时，Vim就会意识到我们要做的是减少缩进，这时0会就会从屏幕上消失

### vim tab缩进

tab缩进宽度默认为8个空格

我们可以使用以下命令，来修改缩进宽度

```
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
```

- tabstop:表示一个 tab 显示出来是多少个空格的长度默认 8
- softtabstop:表示在编辑模式的时候按退格键的时候退回缩进的长度当使用 expandtab 时特别有用。
- shiftwidth:表示每一级缩进的长度一般设置成跟 softtabstop 一样。 当设置成 expandtab 时缩进用空格来表示noexpandtab 则是用制表符表示一个缩进

- expandtab选项，用来控制是否将Tab转换为空格,但是这个选项并不会改变已经存在的文本，如果需要应用此设置将所有Tab转换为空格，需要执行

```
:retab!
```

### vim 自动缩进

- cindent

```
:set cindent
```
vim可以很好的识别出C和Java等结构化程序设计语言，并且能用C语言的缩进格式来处理程序的缩进结构

- smartindent

```
:set smartindent
```

在这种缩进模式中，每一行都和前一行有相同的缩进量，同时这种缩进形式能正确的识别出花括号，当遇到右花括号（}），则取消缩进形式。此外还增加了识别C语言关键字的功能。如果一行是以#开头的，那么这种格式将会被特殊对待而不采用缩进格式。

- autoindent

```
:set autoindent
```
在这种缩进形式中，新增加的行和前一行使用相同的缩进形式

### 显示隐藏符号

- 默认不显示 `:set nolist`
- 显示 `:set invlist`

```
" normal is :set nolist | show hide is :set invlist
:set nolist
```

### 使用vim寄存器

使用vim寄存器 “+p 粘贴

根本不用考虑是否自动缩进，是否paste模式，直接原文传递

如果想保存原寄存器中内容而同时增加新的内容
就要在yy前增加标签
标签以双引号开始，跟着的是标签名称，可以是数字0-9，也可以是26个字母

显示所有寄存器内容

```
:reg
```

注意两个特殊的寄存器：`*` 和 `+`

这两个寄存器是和系统相通的，前者关联系统选择缓冲区，后者关联系统剪切板
通过它们可以和其他程序进行数据交换

> 若寄存器列表里无 `*` 或 `+` 寄存器，则可能是由于没有安装vim的图形界面所致
> sudo apt-get install vim-gnome

## 设置vim永远显示行号

修改vim的配置文件加入 set nu

```sh
vi ~/.vimrc
```

然后输入

```
set nu
```

当然也可以输入其他配置类似

```
set nonu
syntax on
```

## vimrc 常用配置

```
" open syntax
syntax on
" set not show line number can change by :set nu
:set nonu
" set show line number when in edit
:set ruler
" set tab button stop
" default tabstop=8
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
" use keyboard F11 to change paste mode
:set pastetoggle=<F11>
" insert mode to use Shift + tab to insert table
:inoremap <S-Tab> <C-V><Tab>
" normal is :set nolist | show hide is :set invlist
:set nolist

" fix mac vim keyboard delete can not delete error, so as set backspace=indent,eol,start
set backspace=2

" insert mode shortcut
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-d> <DELETE>

" ------------
" install plug-in manager see https://github.com/VundleVim/Vundle.vim
```

## 查看vim设置的样例文件

- linux 查看

```sh
find /usr/share/ -name "*example.vim"
```

- mac 查看方法

```sh
locate example.vim
```

> 如果是第一次运行会报告错误，需要建立索引，根据提示操作即可，建议运行一次 updatedb

找到标识为 `example.vim` 的文件就是样例

# 配置文件

## 基础热键修改-无插件

```rc
" iab
:iab author author:sinlov sinlovgmppt@gmail.com
:iab Copyright Copyright® sinlov sinlovppt@gmail.com

" open syntax
syntax on
" set not show line number can change by :set nu
:set nonu
" set show line number when in edit
:set ruler
" set tab button stop
" default tabstop=8
:set tabstop=4
:set softtabstop=4
:set shiftwidth=4
:set expandtab
" use keyboard F11 to change paste mode
:set pastetoggle=<F11>
" insert mode to use Shift + tab to insert table
:inoremap <S-Tab> <C-V><Tab>
" normal is :set nolist | show hide is :set invlist
:set nolist

" fix mac vim keyboard delete can not delete error, so as set backspace=indent,eol,start
set backspace=2

" mark or goto mark ignore lower case
nnoremap ma mA
nnoremap 'a 'A
nnoremap ms mS
nnoremap 's 'S
nnoremap md mD
nnoremap 'd 'D
nnoremap mf mF
nnoremap 'f 'F

" insert mode shortcut
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-d> <DELETE>

" ------------
" install plug-in manager see https://github.com/VundleVim/Vundle.vim
```
