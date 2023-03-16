---
title: "Markdown 数学公式排版 KaTex 语法"
date: 2023-03-16T16:51:06+08:00
description: "markdown 数学公式排版 KaTex 语法说明和注意事项"
draft: false
categories: ['basics']
tags: ['basics']
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

## $\KaTeX$介绍

$\TeX$ 数学公式是以文本的形式和规则书写，由公式渲染器进行渲染，可以嵌入Markdown，HTML网页等内容。知名且广泛使用的数学JS渲染器支持有$MathJax$，$\KaTeX$  ，两者底层采用的都是 [$\TeX$](https://www.tug.org/) 排版协议

[$MathJax$](https://www.mathjax.org/) 支持的公式功能更多更全面，但是 [$\KaTeX$](https://katex.org/)  渲染速度更快，而且其特性覆盖范围足够大多数人使用

> 关于公式内换行，标准的$MathJax$和$\KaTeX$是 `\\`，而本文主题的$\KaTeX$是 `\\\\` ，这个很重要！（尤其是输入矩阵这类多行公式 ）
> $\KaTeX$ 使用 `\` 对其他单个字符进行转义时，也是类似，比如公式内空格可以 `\space` 或者用 `\\,` 或 `\\;` ，某些场合需要大括号 `{}` ,也是使用 `\\{` 和 `\\}` $\Longrightarrow$
> 注意 $\KaTeX$ 对于单个符号转义就是用2个斜杠 `\`

### 非常有帮助网址

- [Katex官方：在线语法测试](https://katex.org/#demo)
- [Katex官方：Supported Functions](https://katex.org/docs/supported.html)
- [Katex官方：Support Table](https://katex.org/docs/support_table.html)
- [清华镜像站Mannual-PDF：A Gentle Introduction to TEX](https://mirrors.tuna.tsinghua.edu.cn/CTAN/info/gentle/gentle.pdf)
- [Cmd Markdown 公式指导手册](https://ericp.cn/cmd)
- [MathJax basic tutorial and quick reference](https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference)

## 公式基础语法

### 如何插入公式

$\LaTeX$ 的数学公式有两种：行内公式和独立公式。行中公式放在文中与其它文字混编，独立公式单独成行

行内公式可以用单个美元符号包裹表示：例如 `$a^2+b^2 = c^2$`，渲染后$a^2+b^2 = c^2$

独立成行的公式用2个美元符号包裹表示：例如 `$$a^2+b^2 = c^2$$` ,渲染后：

$$a^2+b^2 = c^2$$

### 输入上下标

`^` 表示上标, `_` 表示下标。如果上下标的内容多于一个字符，需要用 `{}` 将这些内容括成一个整体

上下标可以嵌套，也可以同时使用

例子：

```tex
$$ x^{y^z}=(1+{\rm e}^x)^{-2xy^w} $$
```

显示：

$$ x^{y^z}=(1+{\rm e}^x)^{-2xy^w} $$

### 输入括号和分隔符

`()`、`[]` 和 `|` 表示符号本身，使用 `\{\}` 来表示 `{}`

当要显示大号的括号或分隔符时，要用 `\left` 和 `\right` 命令

一些特殊的括号

|输入 | 显示 |	输入	| 显示 |
|------|-----|-----|-----|
| \langle | $\langle$ | \rangle | $\rangle$ |
| \lceil | $\lceil$ | \rceil | $\rceil$ |
| \lfloor | $\lfloor$ | \rfloor | $\rfloor$ |
| \lbrace | $\lbrace$ | \rbrace | $\rbrace$ |
| \lvert | $\lvert$ | \rvert | $\rvert$ |
| \lVert | $\lVert$ | \rVert | $\rVert$ |

> 有时，我们需要在行内使用两个竖杠表示向量间的某种空间距离，可以这样写
> `\lVert \boldsymbol{X}_i - \boldsymbol{S}_j \rVert^2`  →  $\lVert \boldsymbol{X}_i - \boldsymbol{S}_j \rVert^2$

例子：

```tex
$$ f(x,y,z) = 3y^2z \left( 3+\frac{7x+5}{1+y^2} \right) $$
```

显示：

$$ f(x,y,z) = 3y^2z \left( 3+\frac{7x+5}{1+y^2} \right) $$

有时要用 `\left.` 或 `\right.` 进行匹配而不显示本身

```tex
$$ \left. \frac{{\rm d}u}{{\rm d}x} \right| _{x=0} $$
```

显示：

$$ \left. \frac{{\rm d}u}{{\rm d}x} \right| _{x=0} $$

### 输入分数

通常使用 `\frac {分子} {分母}` 来生成一个分数，分数可多层嵌套

如果分式较为复杂，亦可使用 `分子 \over 分母` 此时分数仅有一层

例子：

```tex
$$ \frac{a-1}{b-1} \quad or \quad {a+1 \over b+1} $$
```

显示：

$$ \frac{a-1}{b-1} \quad or \quad {a+1 \over b+1} $$

当分式 仅有两个字符时 可直接输入 `\frac ab` 来快速生成一个 $\large\frac ab$

例子：

```tex
$$ \frac 12,\frac 1a,\frac a2 \quad \mid \quad \text{2 letters only:} \quad \frac 12a \\,, k\frac q{r^2} $$
```

显示：

$$ \frac 12,\frac 1a,\frac a2 \quad \mid \quad \text{2 letters only:} \quad \frac 12a \\,, k\frac q{r^2} $$

### 输入开方

使用 `\sqrt [根指数，省略时为2] {被开方数}` 命令输入开方

例子：

```tex
$$ \sqrt{2} \quad or \quad \sqrt[n]{3} $$
```

显示：

$$ \sqrt{2} \quad or \quad \sqrt[n]{3} $$

### 输入省略号

数学公式中常见的省略号有两种

- `\ldots` 表示与 文本底线 对齐的省略号
- `\cdots` 表示与 文本中线 对齐的省略号

例子：

```tex
$$ f(x_1,x_2  \ldots x_n) = x_1^2 + x_2^2 + \cdots + x_n^2 $$
```

显示：

$$ f(x_1,x_2  \ldots x_n) = x_1^2 + x_2^2 + \cdots + x_n^2 $$

### 输入向量

使用 `\vec{向量}` 来自动产生一个向量

也可以使用 `\overrightarrow` 等命令自定义字母上方的符号

例子：

```tex
$$ \vec{a} \cdot \vec{b}=0 $$
```

显示：

$$ \vec{a} \cdot \vec{b}=0 $$

例子：

```tex
$$ xy \text{ with arrows:} \quad \overleftarrow{xy} \\; \mid \\; \overleftrightarrow{xy} \\; \mid \\; \overrightarrow{xy} $$
```

显示：

$$ xy \text{ with arrows:} \quad \overleftarrow{xy} \\; \mid \\; \overleftrightarrow{xy} \\; \mid \\; \overrightarrow{xy} $$

### 输入积分

使用 `\int_积分下限^积分上限 {被积表达式}` 来输入一个积分

例子：

```tex
$$ \int_0^1 {x^2} \,{\rm d}x $$
```

显示：

$$ \int_0^1 {x^2} \,{\rm d}x $$

本例中 `\,` 和 `{\rm d}` 部分可省略，但加入能使式子更美观，详见 [在字符间加入空格](#在字符间加入空格)及 [如何进行字体转换](#如何进行字体转换)

### 输入极限运算

使用 `\lim_{变量 \to 表达式}` 表达式 来输入一个极限

如有需求，可以更改 `\to` 符号至任意符号

例子：

```tex
$$ \lim_{n \to \infty} \frac{1}{n(n+1)} \quad and \quad \lim_{x\leftarrow{示例}} \frac{1}{n(n+1)} $$
```

显示：

$$ \lim_{n \to \infty} \frac{1}{n(n+1)} \quad and \quad \lim_{x\leftarrow{示例}} \frac{1}{n(n+1)} $$

### 输入累加、累乘运算

使用 `\sum_{下标表达式}^{上标表达式} {累加表达式}` 来输入一个累加

与之类似，使用 `\prod` `\bigcup` `\bigcap` 来分别输入累乘、并集和交集

更多符号可参考 [输入其它特殊字符](#输入其它特殊字符)

此类符号在行内显示时上下标表达式将会移至右上角和右下角，如 $\sum_{i=1}^n \frac{1}{i^2}$

例子：

```tex
$$ \sum_{i=1}^n \frac{1}{i^2} \quad and \quad \prod_{i=1}^n \frac{1}{i^2} \quad and \quad \bigcup_{i=1}^{2} \Bbb{R} $$
```

显示：

$$ \sum_{i=1}^n \frac{1}{i^2} \quad and \quad \prod_{i=1}^n \frac{1}{i^2} \quad and \quad \bigcup_{i=1}^{2} \Bbb{R} $$

### 输入希腊字母

输入 `\小写希腊字母英文全称` 和 `\首字母大写希腊字母英文全称` 来分别输入小写和大写希腊字母

> 对于大写希腊字母与现有字母相同的，直接输入大写字母即可

| 希腊字母小写 | 希腊字母大写 | 音读 | 常见用途 | KaTex 小写 | KaTex 大写 |
|:-----------|:----|:----|:--------|:----|:-----|
| α | Α | alpha 阿尔法 | 角度；系数 | `\alpha` | `A` |
| β | Β | beta 贝塔 | 磁通系数；角度；系数 | `\beta` | `B` |
| γ | Γ | gamma 伽马 | 电导系数（小写） | `\gamma` | `\Gamma` |
| δ | Δ | delta 德尔塔 | 变动；密度；屈光度 | `\delta` | `\Delta` |
| ϵ,ε | Ε | epsilon 伊普西龙 | 对数之基数 | `\epsilon` `\varepsilon` | `E` |
| ζ | Ζ | zeta 截塔 | 系数；方位角；阻抗；相对粘度；原子序数 | `\zeta` | `Z` |
| η | Η | eta 依塔 | 磁滞系数；效率（小写） | `\eta` | `H` |
| θ,ϑ | Θ | theta 西塔 | 温度；相位角 | `\theta` `\vartheta` | `\Theta` |
| ι | Ι | aiot 艾欧塔 | 微小，一点儿 | `\iota` | `I` |
| κ | Κ | kappa 喀帕 | 介质常数 | `\kappa` | `K` |
| λ | ∧ | lambda 兰布达 | 波长（小写）；体积 | `\lambda` | `\Lambda` |
| μ | Μ | mu 缪 | 磁导系数；微（千分之一）；放大因数（小写） | `\mu` | `M` |
| ν | Ν | nu 纽 | 磁阻系数 | `\nu` | `N` |
| ξ | Ξ | kxi 克西 | | `\xi` | `\Xi` |
| ο | Ο | omicron 奥密克戎 | | `o` | `O` |
| π | ∏ | pai 派 | 圆周率 | `\pi` | `\Pi` |
| ρ,ϱ | Ρ | rou 柔 | 电阻系数（小写） | `\rho` `\varrho` | `P` |
| σ | ∑ | sigma 西格玛 | 总和（大写），表面密度；跨导（小写） | `\sigma` | `\Sigma` |
| τ | Τ | tau 套 | 时间常数 | `\tau` | `T` |
| υ | Υ | upsilon 宇普西龙 | | `\upsilon` | `\Upsilon` |
| ϕ,φ | Φ | fai 佛爱 | 磁通；角 | `\phi` `\varpi` | `\Phi` |
| χ | Χ | chi 器 | | `\chi` | `X` |
| ψ | Ψ | psai 普赛 | 角速；介质电通量（静电力线）；角 | `\psi` | `\Psi` |
| ω | Ω | omega 欧米伽 | 欧姆（大写）；角速（小写）；角 | `\omega` | `\Omega` |

部分字母有变量专用形式，以 `\var-` 开头

| 小写形式 |	大写形式 |	变量形式 |	显示 |
|--------|-------|-------|------|
| \epsilon | E | \varepsilon | $\epsilon \mid E \mid \varepsilon$ |
| \theta | \Theta | \vartheta | $\theta \mid \Theta \mid \vartheta$ |
| \rho | P | \varrho | $\rho \mid P \mid \varrho$ |
| \sigma | \Sigma | \varsigma | $\sigma \mid \Sigma \mid \varsigma$ |
| \phi | \Phi | \varphi | $\phi \mid \Phi \mid \varphi$ |


### 输入其它特殊字符

完整的 $\LaTeX$ 可用符号列表可以在 文档 [The Comprehensive LATEX Symbol List.pdf](https://mirror.its.dal.ca/ctan/info/symbols/comprehensive/symbols-a4.pdf) 中查阅，大部分常用符号可以参阅 当前 精简版文档

> 若需要显示更大或更小的字符，在符号前插入 `\large` 或 `\small` 命令，比如`$\small{x} + \normalsize{x}+\large{x}$`，显示为$\small{x} + \normalsize{x}+\large{x}$
> $KaTeX$  针对任意元素均提供从小至大 `\tiny`  `\scriptsize` `\small` `\normalsize` `\large` `\Large` `\LARGE` `\huge` `\Huge` 等渲染尺寸

#### 关系运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|-----|----|
| \pm | $\pm$ | \times | $\times$ | \div | $\div$ | \mid | $\mid$ |
| \nmid | $\nmid$ | \cdot | $\cdot$ | \circ | $\circ$ | \ast | $\ast$ |
| \bigodot | $\bigodot$ | \bigotimes | $\bigotimes$ | \bigoplus | $\bigoplus$ | \leq | $\leq$ |
| \geq | $\geq$ | \neq | $\neq$ | \approx | $\approx$ | \equiv | $\equiv$ |
| \sum | $\sum$ | \prod | $\prod$ | \coprod | $\coprod$ | \backslash | $\backslash$ |

#### 集合运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \emptyset | $\emptyset$ | \in | $\in$ | \notin | $\notin$ |
| \subset | $\subset$ | \supset | $\supset$ | \subseteq | $\subseteq$ |
| \supseteq | $\supseteq$ | \cap | $\cap$ | \cup | $\cup$ |
| \vee | $\vee$ | \wedge | $\wedge$ | \uplus | $\uplus$ |
| \top | $\top$ | \bot | $\bot$ | \complement | $\complement$ |

#### 对数运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \log | $\log$ | \lg | $\lg$ | \ln | $\ln$ |

#### 三角运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \backsim | $\backsim$ | \cong | $\cong$ | \angle A | $\angle A$ |
| \sin | $\sin$ | \cos | $\cos$ | \tan | $\tan$ |
| \csc | $\csc$ | \sec | $\sec$ | \cot | $\cot$ |

#### 微积分运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \int | $\int$ | \iint | $\iint$ | \iiint | $\iiint$ |
| \partial | $\partial$ | \oint | $\oint$ | \prime | $\prime$ |
| \lim | $\lim$ | \infty | $\infty$ | \nabla | $\nabla$ |

#### 逻辑运算符

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \because | $\because$ | \therefore | $\therefore$ | \neg | $\neg$ |
| \forall | $\forall$ | \exists | $\exists$ | \not\subset | $\not\subset$ |
| \not< | $\not<$ | \not> | $\not>$ | \not= | $\not=$ |

#### 戴帽符号

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \hat{xy} | $\hat{xy}$ | \widehat{xyz} | $\widehat{xyz}$ | \bar{y} | $\bar{y}$ |
| \tilde{xy} | $\tilde{xy}$ | \widetilde{xyz} | $\widetilde{xyz}$ | \acute{y} | $\acute{y}$ |
| \breve{y} | $\breve{y}$ | \check{y} | $\check{y}$ | \grave{y} | $\grave{y}$ |
| \dot{x} | $\dot{x}$ | \ddot{x} | $\ddot{x}$ |

若需要在 `特定文字顶部\底部放置内容` ，可使用

- `\overset{顶部内容}{正常内容}`
- `\underset{底部内容}{正常内容}`

例子：

```tex
$$ \verb+\overset{above}{level}+ \qquad \overset{xx}{ABC} \\;\\; \mid \quad \overset{x^2}{\longmapsto}\ \, \mid \quad \overset{\bullet\circ\circ\bullet}{T} $$
```

显示：

$$ \verb+\overset{above}{level}+ \qquad \overset{xx}{ABC} \\;\\; \mid \quad \overset{x^2}{\longmapsto}\ \, \mid \quad \overset{\bullet\circ\circ\bullet}{T} $$

此命令可叠加嵌套使用，生成类似化学反应式的多重条件符号， 例子：

```tex
$$ \rm {SrO} + V^{''}_{Sr} \overset{H_2}{\underset{1300℃}{\Longleftrightarrow}} 2e^{'}+\frac  12O_2(g) + Sr^{\times}_S $$
```

显示：

$$ \rm {SrO} + V^{''}_{Sr} \overset{H_2}{\underset{1300℃}{\Longleftrightarrow}} 2e^{'}+\frac  12O_2(g) + Sr^{\times}_S $$

#### 连线符号

其它可用的文字修饰符可参见官方文档 [Fussy spacing issues](https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference#answer-13081)

| 输入 | 显示 |
|-------|-------|
| 需声明 enclose 标签 \fbox{a+b+c+d}  | $\fbox{a+b+c+d}$ |
| \overleftarrow{a+b+c+d} | $\overleftarrow{a+b+c+d}$ |
| \overrightarrow{a+b+c+d} | $\overrightarrow{a+b+c+d}$ |
| \overleftrightarrow{a+b+c+d} | $\overleftrightarrow{a+b+c+d}$ |
| \underleftarrow{a+b+c+d} | $\underleftarrow{a+b+c+d}$ |
| \underrightarrow{a+b+c+d} | $\underrightarrow{a+b+c+d}$ |
| \underleftrightarrow{a+b+c+d} | $\underleftrightarrow{a+b+c+d}$ |
| \overline{a+b+c+d} | $\overline{a+b+c+d}$ |
| \underline{a+b+c+d} | $\underline{a+b+c+d}$ |
| \overbrace{a+b+c+d}^{Sample} | $\overbrace{a+b+c+d}^{Sample}$ |
| \underbrace{a+b+c+d}_{Sample} | $\underbrace{a+b+c+d}_{Sample}$ |
| \overbrace{a+\underbrace{b+c}_{1.0}+d}^{2.0} | $\overbrace{a+\underbrace{b+c}_{1.0}+d}^{2.0}$ |
| \underbrace{a\cdot a\cdots a}_{b\text{ times}} | $\underbrace{a\cdot a\cdots a}_{b\text{ times}}$ |

#### 箭头符号

| 输入 | 显示	| 输入 | 显示 | 输入 | 显示 |
|------|-----|-----|------|-----|-----|
| \to | $\to$ | \mapsto | $\mapsto$ | \underrightarrow{1℃/min} | $\underrightarrow{1℃/min}$ |
| \implies | $\implies$ | \iff | $\iff$ | \impliedby | $\impliedby$ |

##### 其它可用箭头符号

| 输入 | 显示	| 输入 | 显示 |
|------|-----|-----|------|
| \uparrow | $\uparrow$ | \Uparrow | $\Uparrow$ |
| \downarrow | $\downarrow$ | \Downarrow | $\Downarrow$ |
| \leftarrow | $\leftarrow$ | \Leftarrow | $\Leftarrow$ |
| \rightarrow | $\rightarrow$ | \Rightarrow | $\Rightarrow$ |
| \leftrightarrow | $\leftrightarrow$ | \Leftrightarrow | $\Leftrightarrow$ |
| \longleftarrow | $\longleftarrow$ | \Longleftarrow | $\Longleftarrow$ |
| \longrightarrow | $\longrightarrow$ | \Longrightarrow | $\Longrightarrow$ |
| \longleftrightarrow | $\longleftrightarrow$ | \Longleftrightarrow | $\Longleftrightarrow$ |

### 如何进行字体转换

若要对公式的某一部分字符进行字体转换 可以用 `{\字体 {需转换的部分字符}}` 命令

其中 `\字体` 部分可以参照下表选择合适的字体。一般情况下，公式默认为斜体字 $italic$

> 注意: 示例中 **全部大写** 的字体仅大写可用

| 输入 | 全字母可用 | 显示 | 输入 | 仅大写可用 | 显示 |
|------|-----|-----|-----|-----|-----|
| \rm | 罗马体 | $\rm{Sample}$ | \mathcal | 花体（数学符号等） | $\mathcal{SAMPLE}$ |
| \it | 斜体 | $\it{Sample}$ | \mathbb | 黑板粗体（定义域等） | $\mathbb{SAMPLE}$ |
| \bf | 粗体 | $\bf{Sample}$ | \mathit | 数学斜体 | $\mathit{SAMPLE}$ |
| \sf | 等线体 | $\sf{Sample}$ | \mathscr | 手写体 | $\mathscr{SAMPLE}$ |
| \tt | 打字机体 | $\tt{Sample}$ |
| \frak | 旧德式字体 | $\frak{Sample}$ |

> 注意： `\boldsymbol{\vec \alpha}` 用来表示向量或者矩阵的加粗斜体，如向量 $\boldsymbol{\vec\alpha}$

转换字体十分常用，例如在积分中

例子：

```tex
\begin{array}{cc}
    \mathrm{Bad} & \mathrm{Better} \\
    \hline \\
    \int_0^1 x^2 dx & \int_0^1 x^2  \,{\rm d}x
\end{array}
```

显示：

$$
\begin{array}{cc}
    \mathrm{Bad} & \mathrm{Better} \\
    \hline \\
    \int_0^1 x^2 dx & \int_0^1 x^2  \,{\rm d}x
\end{array}
$$

> 注意: 比较两个式子间 $dx$ 与 ${\rm d} x$ 的不同

使用 `\operatorname` 命令也可以达到相同的效果

### 大括号和行标的使用

在 `\left` 和 `\right` 之后加上要使用的括号来创建自动匹配高度的圆括号 `(` `)`，方括号 `[` `]` 和花括号 `\{` `\}`

在每个公式末尾前使用 `\tag {行标}` 来实现行标

> 注意：$\KaTeX$ 使用 `\\{` 和 `\\}` 对左、右括号转义，如果是 $MathJax$，使用 `\{` 和 `\}`

```tex
$$
f\left(
   \left[
     \frac{
       1+\left\{x,y\right\}
     }{
       \left(
          \frac xy + \frac yx
       \right)
       (u+1)
     }+a
   \right]^{3/2}
\right)
\tag {行标}
$$
```

显示：

$$
f\left(
   \left[
     \frac{
       1+\left\\{x,y\right\\}
     }{
       \left(
          \frac xy + \frac yx
       \right)
       (u+1)
     }+a
   \right]^{3/2}
\right)
\tag {行标}
$$

如果你需要在不同的行显示对应括号，可以在每一行对应处使用 `\left.` 或 `\right.` 来放一个 `不存在的括号`

```tex
$$
\begin{aligned}
    a=&\left(1+2+3+ \cdots \right. \\\\
      &\cdots+\left. \infty-2+\infty-1+\infty\right)
\end{aligned}
$$
```

显示：

$$
\begin{aligned}
    a=&\left(1+2+3+ \cdots \right. \\\\
      &\cdots+\left. \infty-2+\infty-1+\infty\right)
\end{aligned}
$$

### 其它命令

#### 添加注释文字

在 `\text {文字}` 中仍可以使用 `$公式$` 插入其它公式

例子：

```tex
$$ f(n)= \begin{cases} n/2, & \text {if $n$ is even} \\\\ 3n+1, & \text{if $n$ is odd} \end{cases} $$
```

显示：

$$ f(n)= \begin{cases} n/2, & \text {if $n$ is even} \\\\ 3n+1, & \text{if $n$ is odd} \end{cases} $$

#### 在字符间加入空格

有四种宽度的空格可以使用： `\\,`、`\\;`、`\quad` 和 `\qquad`

灵活使用 `\text{n个空格}` 也可以在任意位置实现空格

> 提醒：$\KaTeX$ 是使用2个斜杠来转义，所以是 `\\;` 和 `\\,` ，如果是$MathJax$，则是一个斜杠，即 `\,` 和 `\;`

```tex
$$
A B \quad Vs \quad A\\,B  \\\\
C D \quad Vs \quad C\\;D   \\\\
E F \quad Vs \quad E\space F
$$
```

显示：

$$
A B \quad Vs \quad A\\,B  \\\\
C D \quad Vs \quad C\\;D   \\\\
E F \quad Vs \quad E\space F
$$


> 注意$AB$在公式中手动输入空格是没用的，需要上述的特殊字符作为空格

一些常见的公式单位可表达如下：

> 提醒：$\KaTeX$ 是使用2个斜杠来转义，所以是 `\\!` ，如果是$MathJax$，则是一个斜杠，即 `\!`

```tex
$$ \mu_0=4\pi\times10^{-7} \ \left.\mathrm{\mathrm{T}\\!\cdot\\!\mathrm{m}}\middle/\mathrm{A}\right.$$

$$ 180^\circ=\pi \ \mathrm{rad} $$

$$ \mathrm{N_A} = 6.022\times10^{23} \ \mathrm{mol}^{-1}$$
```

$$ \mu_0=4\pi\times10^{-7} \ \left.\mathrm{\mathrm{T}\!\cdot\!\mathrm{m}}\middle/\mathrm{A}\right.$$

$$ 180^\circ=\pi \ \mathrm{rad} $$

$$ \mathrm{N_A} = 6.022\times10^{23} \ \mathrm{mol}^{-1}$$

#### 更改文字颜色

使用 `\color{颜色}{文字}` 来更改特定的文字颜色

更改文字颜色需要浏览器支持 ，如果浏览器不知道你所需的颜色，那么文字将被渲染为黑色

> 对于较旧的浏览器（HTML4 & CSS2），以下颜色是被支持的

| 输入 | 显示	| 输入 | 显示 |
|------|-----|-----|------|
| black | $\color{black}{text}$ | grey | $\color{grey}{text}$ |
| silver | $\color{silver}{text}$ | white | $\color{white}{text}$ |
| maroon | $\color{maroon}{text}$ | red | $\color{red}{text}$ |
| yellow | $\color{yellow}{text}$ | lime | $\color{lime}{text}$ |
| olive | $\color{olive}{text}$ | green | $\color{green}{text}$ |
| teal | $\color{teal}{text}$ | auqa | $\color{auqa}{text}$ |
| blue | $\color{blue}{text}$ | navy | $\color{navy}{text}$ |
| purple | $\color{purple}{text}$ | fuchsia | $\color{fuchsia}{text}$ |

对于较新的浏览器（HTML5 & CSS3），HEX 颜色将被支持：

输入 `\color {#rgb} {text}` 来自定义更多的颜色

> 其中 `#rgb` 或 #rrggbb 的 r g b 可输入 0-9 和 a-f 来表示红色、绿色和蓝色的纯度（饱和度）

例子：

```tex
$$
\begin{array}{|rrrrrrrr|}\hline
    \verb+#000+ & \color{#000}{text} & & &
    \verb+#00F+ & \color{#00F}{text} & & \\\\
    & & \verb+#0F0+ & \color{#0F0}{text} &
    & & \verb+#0FF+ & \color{#0FF}{text} \\\\
    \verb+#F00+ & \color{#F00}{text} & & &
    \verb+#F0F+ & \color{#F0F}{text} & & \\\\
    & & \verb+#FF0+ & \color{#FF0}{text} &
    & & \verb+#FFF+ & \color{#FFF}{text} \\\\
\hline\end{array}
$$
```
显示：

$$
\begin{array}{|rrrrrrrr|}\hline
    \verb+#000+ & \color{#000}{text} & & &
    \verb+#00F+ & \color{#00F}{text} & & \\\\
    & & \verb+#0F0+ & \color{#0F0}{text} &
    & & \verb+#0FF+ & \color{#0FF}{text} \\\\
    \verb+#F00+ & \color{#F00}{text} & & &
    \verb+#F0F+ & \color{#F0F}{text} & & \\\\
    & & \verb+#FF0+ & \color{#FF0}{text} &
    & & \verb+#FFF+ & \color{#FFF}{text} \\\\
\hline\end{array}
$$

```tex
$$
\begin{array}{|rrrrrrrr|}\hline
    \verb+#000+ & \color{#000}{text} & \verb+#005+ & \color{#005}{text} & \verb+#00A+ & \color{#00A}{text} & \verb+#00F+ & \color{#00F}{text}  \\\\
    \verb+#500+ & \color{#500}{text} & \verb+#505+ & \color{#505}{text} & \verb+#50A+ & \color{#50A}{text} & \verb+#50F+ & \color{#50F}{text}  \\\\
    \verb+#A00+ & \color{#A00}{text} & \verb+#A05+ & \color{#A05}{text} & \verb+#A0A+ & \color{#A0A}{text} & \verb+#A0F+ & \color{#A0F}{text}  \\\\
    \verb+#F00+ & \color{#F00}{text} & \verb+#F05+ & \color{#F05}{text} & \verb+#F0A+ & \color{#F0A}{text} & \verb+#F0F+ & \color{#F0F}{text}  \\\\
\hline
    \verb+#080+ & \color{#080}{text} & \verb+#085+ & \color{#085}{text} & \verb+#08A+ & \color{#08A}{text} & \verb+#08F+ & \color{#08F}{text}  \\\\
    \verb+#580+ & \color{#580}{text} & \verb+#585+ & \color{#585}{text} & \verb+#58A+ & \color{#58A}{text} & \verb+#58F+ & \color{#58F}{text}  \\\\
    \verb+#A80+ & \color{#A80}{text} & \verb+#A85+ & \color{#A85}{text} & \verb+#A8A+ & \color{#A8A}{text} & \verb+#A8F+ & \color{#A8F}{text}  \\\\
    \verb+#F80+ & \color{#F80}{text} & \verb+#F85+ & \color{#F85}{text} & \verb+#F8A+ & \color{#F8A}{text} & \verb+#F8F+ & \color{#F8F}{text}  \\\\
\hline
    \verb+#0F0+ & \color{#0F0}{text} & \verb+#0F5+ & \color{#0F5}{text} & \verb+#0FA+ & \color{#0FA}{text} & \verb+#0FF+ & \color{#0FF}{text}  \\\\
    \verb+#5F0+ & \color{#5F0}{text} & \verb+#5F5+ & \color{#5F5}{text} & \verb+#5FA+ & \color{#5FA}{text} & \verb+#5FF+ & \color{#5FF}{text}  \\\\
    \verb+#AF0+ & \color{#AF0}{text} & \verb+#AF5+ & \color{#AF5}{text} & \verb+#AFA+ & \color{#AFA}{text} & \verb+#AFF+ & \color{#AFF}{text}  \\\\
    \verb+#FF0+ & \color{#FF0}{text} & \verb+#FF5+ & \color{#FF5}{text} & \verb+#FFA+ & \color{#FFA}{text} & \verb+#FFF+ & \color{#FFF}{text}  \\\\
\hline\end{array}
$$
```

显示：

$$
\begin{array}{|rrrrrrrr|}\hline
    \verb+#000+ & \color{#000}{text} & \verb+#005+ & \color{#005}{text} & \verb+#00A+ & \color{#00A}{text} & \verb+#00F+ & \color{#00F}{text}  \\\\
    \verb+#500+ & \color{#500}{text} & \verb+#505+ & \color{#505}{text} & \verb+#50A+ & \color{#50A}{text} & \verb+#50F+ & \color{#50F}{text}  \\\\
    \verb+#A00+ & \color{#A00}{text} & \verb+#A05+ & \color{#A05}{text} & \verb+#A0A+ & \color{#A0A}{text} & \verb+#A0F+ & \color{#A0F}{text}  \\\\
    \verb+#F00+ & \color{#F00}{text} & \verb+#F05+ & \color{#F05}{text} & \verb+#F0A+ & \color{#F0A}{text} & \verb+#F0F+ & \color{#F0F}{text}  \\\\
\hline
    \verb+#080+ & \color{#080}{text} & \verb+#085+ & \color{#085}{text} & \verb+#08A+ & \color{#08A}{text} & \verb+#08F+ & \color{#08F}{text}  \\\\
    \verb+#580+ & \color{#580}{text} & \verb+#585+ & \color{#585}{text} & \verb+#58A+ & \color{#58A}{text} & \verb+#58F+ & \color{#58F}{text}  \\\\
    \verb+#A80+ & \color{#A80}{text} & \verb+#A85+ & \color{#A85}{text} & \verb+#A8A+ & \color{#A8A}{text} & \verb+#A8F+ & \color{#A8F}{text}  \\\\
    \verb+#F80+ & \color{#F80}{text} & \verb+#F85+ & \color{#F85}{text} & \verb+#F8A+ & \color{#F8A}{text} & \verb+#F8F+ & \color{#F8F}{text}  \\\\
\hline
    \verb+#0F0+ & \color{#0F0}{text} & \verb+#0F5+ & \color{#0F5}{text} & \verb+#0FA+ & \color{#0FA}{text} & \verb+#0FF+ & \color{#0FF}{text}  \\\\
    \verb+#5F0+ & \color{#5F0}{text} & \verb+#5F5+ & \color{#5F5}{text} & \verb+#5FA+ & \color{#5FA}{text} & \verb+#5FF+ & \color{#5FF}{text}  \\\\
    \verb+#AF0+ & \color{#AF0}{text} & \verb+#AF5+ & \color{#AF5}{text} & \verb+#AFA+ & \color{#AFA}{text} & \verb+#AFF+ & \color{#AFF}{text}  \\\\
    \verb+#FF0+ & \color{#FF0}{text} & \verb+#FF5+ & \color{#FF5}{text} & \verb+#FFA+ & \color{#FFA}{text} & \verb+#FFF+ & \color{#FFF}{text}  \\\\
\hline\end{array}
$$

## 矩阵使用

### 输入无框矩阵

在开头使用 `\begin{matrix}`，在结尾使用 `\end{matrix}`，在中间插入矩阵元素，每个元素之间插入 `&` ，并在每行结尾处使用 `\\`

> 不同于标准的 $\KaTeX$ ，有些需要使用4个反斜杠换行，即 `\\\\`

使用矩阵时必须声明 $ 或 $$ 符号

```tex
$$
\begin{matrix}
    1 & x & x^2 \\
    1 & y & y^2 \\
    1 & z & z^2 \\
\end{matrix}
$$
```

显示：

$$
\begin{matrix}
    1 & x & x^2 \\\\
    1 & y & y^2 \\\\
    1 & z & z^2 \\\\
\end{matrix}
$$

### 输入边框矩阵

将 `matrix` 替换为 `pmatrix` `bmatrix` `Bmatrix` `vmatrix` `Vmatrix`

```tex
$ \begin{matrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{matrix} $
$ \begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{pmatrix} $
$ \begin{bmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{bmatrix} $
$ \begin{Bmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{Bmatrix} $
$ \begin{vmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{vmatrix} $
$ \begin{Vmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{Vmatrix} $
```

| matrix | pmatrix | bmatrix | Bmatrix | vmatrix | Vmatrix |
|--------|--------|--------|--------|--------|--------|
| $ \begin{matrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{matrix} $| $ \begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{pmatrix} $| $ \begin{bmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{bmatrix} $| $ \begin{Bmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{Bmatrix} $| $ \begin{vmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{vmatrix} $| $ \begin{Vmatrix} 1 & 2 \\\\ 3 & 4 \\\\ \end{Vmatrix} $ |

### 输入带省略符号的矩阵

使用 `\cdots` $\cdots$ , `\ddots` $\ddots$ , `\vdots` $\vdots$ 来输入省略符号

```tex
$$
\begin{pmatrix}
    1 & a_1 & a_1^2 & \cdots & a_1^n \\\\
    1 & a_2 & a_2^2 & \cdots & a_2^n \\\\
    \vdots & \vdots & \vdots & \ddots & \vdots \\\\
    1 & a_m & a_m^2 & \cdots & a_m^n \\\\
\end{pmatrix}
$$
```

显示：

$$
\begin{pmatrix}
    1 & a_1 & a_1^2 & \cdots & a_1^n \\\\
    1 & a_2 & a_2^2 & \cdots & a_2^n \\\\
    \vdots & \vdots & \vdots & \ddots & \vdots \\\\
    1 & a_m & a_m^2 & \cdots & a_m^n \\\\
\end{pmatrix}
$$

### 输入带分割符号的矩阵

详见 [数组与表格使用](#数组与表格使用)

```tex
$$
\left[
    \begin{array}{cc|c}
        1 & 2 & 3 \\\\
        4 & 5 & 6 \\\\
    \end{array}
\right]
$$
```

显示：

$$
\left[
    \begin{array}{cc|c}
        1 & 2 & 3 \\\\
        4 & 5 & 6 \\\\
    \end{array}
\right]
$$

> 其中 `cc|c` 代表在一个三列矩阵中的第二和第三列之间插入分割线

### 输入行中矩阵

若想在一行内显示矩阵， 使用 `\bigl(\begin{smallmatrix} ... \end{smallmatrix}\bigr)`

```tex
这是一个行中矩阵的示例 $\bigl(\begin{smallmatrix} a & b \\\\ c & d \end{smallmatrix}\bigr)$
```

显示：

这是一个行中矩阵的示例 $\bigl(\begin{smallmatrix} a & b \\\\ c & d \end{smallmatrix}\bigr)$

## 方程式序列使用

### 输入一个方程组

使用 `\begin{array} … \end{array}` 和 `\left\{ … \right.` 来创建一个方程组

在等号 `=` 前加符号 `&` 是为了让等号以后的内容对齐

> 标准$\KaTeX$ 和$MathJax$都是使用 `\\`换行，以及对符号 `\{` 的转义，有些渲染器去要额为写为 `\\\\` 和 `\\{`

```tex
$$
\left\{
    \begin{array}{c}
        a_1x+b_1y+c_1z &=d_1 \\
        a_2x+b_2y+c_2z &=d_2 \\
        a_3x+b_3y+c_3z &=d_3 \\
    \end{array}
\right.
$$
```

$$
\left\\{
    \begin{array}{c}
        a_1x+b_1y+c_1z &=d_1 \\\\
        a_2x+b_2y+c_2z &=d_2 \\\\
        a_3x+b_3y+c_3z &=d_3 \\\\
    \end{array}
\right.
$$


或使用条件表达式组 `\begin{cases} … \end{cases}` 来实现相同效果

```tex
$$
\begin{cases}
    a_1x+b_1y+c_1z &=d_1 \\
    a_2x+b_2y+c_2z &=d_2 \\
    a_3x+b_3y+c_3z &=d_3 \\
\end{cases}
$$
```

$$
\begin{cases}
    a_1x+b_1y+c_1z &=d_1 \\\\
    a_2x+b_2y+c_2z &=d_2 \\\\
    a_3x+b_3y+c_3z &=d_3 \\\\
\end{cases}
$$

### 输入一个方程式序列

经常想要一列 `等号对齐且居中` 的方程式序列

使用 `\begin{align}…\end{align}` 来创造一列方程式

每行结尾处使用 `\\`，有些渲染器去要额为写为 `\\\\`

使用方程式序列无需声明公式符号 `$` 或 `$$`

> 请注意 `{align}` 语句是自动编号的，使用 `{aligned}` 声明不自动编号 [参考 Other KaTeX Environments](https://katex.org/docs/supported.html#other-katex-environments)

```tex
$$
\begin{aligned}
    \sqrt{37} & = \sqrt{\frac{73^2-1}{12^2}} \\
              & = \sqrt{\frac{73^2}{12^2}\cdot\frac{73^2-1}{73^2}} \\
              & = \sqrt{\frac{73^2}{12^2}}\sqrt{\frac{73^2-1}{73^2}} \\
              & = \frac{73}{12}\sqrt{1-\frac{1}{73^2}} \\
              & \approx \frac{73}{12}\left(1-\frac{1}{2\cdot73^2}\right) \\
\end{aligned}
$$
```

显示：

$$
\begin{aligned}
    \sqrt{37} & = \sqrt{\frac{73^2-1}{12^2}} \\\\
              & = \sqrt{\frac{73^2}{12^2}\cdot\frac{73^2-1}{73^2}} \\\\
              & = \sqrt{\frac{73^2}{12^2}}\sqrt{\frac{73^2-1}{73^2}} \\\\
              & = \frac{73}{12}\sqrt{1-\frac{1}{73^2}} \\\\
              & \approx \frac{73}{12}\left(1-\frac{1}{2\cdot73^2}\right) \\\\
\end{aligned}
$$

### 方程式序列每一行注释

在 `{align}` 或 `{aligned}` 中后添加 `&` 符号来自动对齐后面的内容

可灵活组合 `\text` 和 `\tag` 语句

> `\tag` 语句编号优先级高于自动编号

```tex
$$
\begin{aligned}
    v + w & = 0  & \text{Given}  \\
       -w & = -w + 0 & \text{additive identity}   \\
   -w + 0 & = -w + (v + w) & \text{equations} \\
\end{aligned}
$$
```

显示：

$$
\begin{aligned}
    v + w & = 0  & \text{Given}  \\\\
       -w & = -w + 0 & \text{additive identity}   \\\\
   -w + 0 & = -w + (v + w) & \text{equations} \\\\
\end{aligned}
$$

## 条件表达式组的使用

### 输入一个条件表达式组

使用 `\begin{cases}…\end{cases}` 来创造一组条件表达式

在每一行条件中插入 `&` 来指定需要对齐的内容

并在每一行结尾处使用 `\\`，有些渲染器去要额为写为 `\\\\` ，`\}` 修音改为 `\\}`

```tex
$$
    f(n) =
        \begin{cases}
            n/2,  & \text{if $n$ is even} \\
            3n+1, & \text{if $n$ is odd} \\
        \end{cases}
$$
```

显示：

$$
    f(n) =
        \begin{cases}
            n/2,  & \text{if $n$ is even} \\\\
            3n+1, & \text{if $n$ is odd} \\\\
        \end{cases}
$$

### 左侧对齐的条件表达式组

想让文字 `在左侧对齐显示`，则有如下方式

```tex
$$
    \left.
        \begin{array}{l}
            \text{if $n$ is even:} & n/2 \\
            \text{if $n$ is odd:} & 3n+1 \\
        \end{array}
    \right\}
    =f(n)
$$
```

显示：

$$
    \left.
        \begin{array}{l}
            \text{if $n$ is even:} & n/2 \\\\
            \text{if $n$ is odd:} & 3n+1 \\\\
        \end{array}
    \right\\}
    =f(n)
$$


### 适配指定行高

在一些情况下，条件表达式中某些行的行高为非标准高度，此时使用 `\\[2ex]` 语句代替该行末尾的 `\\` 来让编辑器适配2倍行高

> 一个 `[ex]` 指一个 **X-Height**，即 x 字母高度，可以根据情况指定多个 `[ex]`，如 `[3ex]`、`[4ex]` 等

不适配2倍行高[2ex]：

```tex
$$
f(n) =
    \begin{cases}
        \frac{n}{2}, & \text{if $n$ is even} \\
        3n+1,        & \text{if $n$ is odd} \\
    \end{cases}
$$
```

$$
f(n) =
    \begin{cases}
        \frac{n}{2}, & \text{if $n$ is even} \\\\
        3n+1,        & \text{if $n$ is odd} \\\\
    \end{cases}
$$

适配2倍行高[2ex]：

```tex
$$
f(n) =
    \begin{cases}
        \frac{n}{2}, & \text{if $n$ is even} \\[2ex]
        3n+1,        & \text{if $n$ is odd} \\
    \end{cases}
$$
```

$$
f(n) =
    \begin{cases}
        \frac{n}{2}, & \text{if $n$ is even} \\\\[2ex]
        3n+1,        & \text{if $n$ is odd} \\\\
    \end{cases}
$$

其实可以在任意换行处使用 `\\[2ex]` 语句，只要你觉得合适

## 数组与表格使用

### 输入一个数组或表格

通常，一个格式化后的表格比单纯的文字或排版后的文字更具有可读性

- 数组和表格均以 `\begin{array}` 开头，并在其后定义列数及每一列的文本对齐属性
- `c` `l` `r` 分别代表居中、左对齐及右对齐
- 若需要插入垂直分割线，在定义式中插入 `|`
- 若要插入水平分割线，在下一行输入前插入 `\hline`
- 与矩阵相似，每行元素间均须要插入 `&` ，每行元素以 `\\` 结尾
- 最后以 `\ end{array}` 结束数组

使用单个数组或表格时无需声明 `$` 或 `$$` 符号

```tex
$$
\begin{array}{c|lcr}
    n & \text{左对齐} & \text{居中对齐} & \text{右对齐} \\
    \hline
    1 & 0.24 & 1 & 125 \\
    2 & -1 & 189 & -8 \\
    3 & -20 & 2000 & 1+10i \\
\end{array}
$$
```

显示：

$$
\begin{array}{c|lcr}
    n & \text{左对齐} & \text{居中对齐} & \text{右对齐} \\\\
    \hline
    1 & 0.24 & 1 & 125 \\\\
    2 & -1 & 189 & -8 \\\\
    3 & -20 & 2000 & 1+10i \\\\
\end{array}
$$

### 输入一个嵌套的数组或表格

多个数组\表格可 **互相嵌套** 并组成一组数组或表格。 使用嵌套前必须声明 `$$` 符号

```tex
$$
\begin{array}{c} % 总表格
    \begin{array}{cc} % 第一行内分成两列
        \begin{array}{c|cccc} % 第一列"最小值"数组
            \text{min} & 0 & 1 & 2 & 3 \\
            \hline
            0 & 0 & 0 & 0 & 0 \\
            1 & 0 & 1 & 1 & 1 \\
            2 & 0 & 1 & 2 & 2 \\
            3 & 0 & 1 & 2 & 3 \\
        \end{array}
        &
        \begin{array}{c|cccc} % 第二列"最大值"数组
            \text{max} & 0 & 1 & 2 & 3 \\
            \hline
            0 & 0 & 1 & 2 & 3 \\
            1 & 1 & 1 & 2 & 3 \\
            2 & 2 & 2 & 2 & 3 \\
            3 & 3 & 3 & 3 & 3 \\
        \end{array}
    \end{array} % 第一行表格组结束
    \\
    \begin{array}{c|cccc} % 第二行 Delta 值数组
        \Delta & 0 & 1 & 2 & 3 \\
        \hline
        0 & 0 & 1 & 2 & 3 \\
        1 & 1 & 0 & 1 & 2 \\
        2 & 2 & 1 & 0 & 1 \\
        3 & 3 & 2 & 1 & 0 \\
    \end{array} % 第二行表格结束
\end{array} % 总表格结束
$$
```

显示：

$$
\begin{array}{c} % 总表格
    \begin{array}{cc} % 第一行内分成两列
        \begin{array}{c|cccc} % 第一列"最小值"数组
            \text{min} & 0 & 1 & 2 & 3 \\\\
            \hline
            0 & 0 & 0 & 0 & 0 \\\\
            1 & 0 & 1 & 1 & 1 \\\\
            2 & 0 & 1 & 2 & 2 \\\\
            3 & 0 & 1 & 2 & 3 \\\\
        \end{array}
        &
        \begin{array}{c|cccc} % 第二列"最大值"数组
            \text{max} & 0 & 1 & 2 & 3 \\\\
            \hline
            0 & 0 & 1 & 2 & 3 \\\\
            1 & 1 & 1 & 2 & 3 \\\\
            2 & 2 & 2 & 2 & 3 \\\\
            3 & 3 & 3 & 3 & 3 \\\\
        \end{array}
    \end{array} % 第一行表格组结束
    \\\\
    \begin{array}{c|cccc} % 第二行 Delta 值数组
        \Delta & 0 & 1 & 2 & 3 \\\\
        \hline
        0 & 0 & 1 & 2 & 3 \\\\
        1 & 1 & 0 & 1 & 2 \\\\
        2 & 2 & 1 & 0 & 1 \\\\
        3 & 3 & 2 & 1 & 0 \\\\
    \end{array} % 第二行表格结束
\end{array} % 总表格结束
$$

## 连分数使用

连分数通常都太大以至于不易排版，所以建议在连分数前后声明 `$$` 符号，或使用像 `[a0,a1,a2,a3,…]` 一样的紧缩记法

### 输入一个连分数

就像输入分式时使用 `\frac` 一样，使用 `\cfrac` 来创建一个连分数

```tex
x = a_0 + \cfrac{1^2}{a_1 +
            \cfrac{2^2}{a_2 +
              \cfrac{3^2}{a_3 +
                \cfrac{4^4}{a_4 +
                  \cdots
                }
              }
            }
          }
$$
```

显示：

$$
x = a_0 + \cfrac{1^2}{a_1 +
            \cfrac{2^2}{a_2 +
              \cfrac{3^2}{a_3 +
                \cfrac{4^4}{a_4 +
                  \cdots
                }
              }
            }
          }
$$

不要使用普通的 `\frac` 或 `\over` 来生成连分数，这样会看起来很奇怪，比如

```tex
$$
x = a_0 + \frac{1^2}{a_1 +
            \frac{2^2}{a_2 +
              \frac{3^2}{a_3 +
                \frac{4^4}{a_4 +
                  \cdots
                }
              }
            }
          }
$$
```

$$
x = a_0 + \frac{1^2}{a_1 +
            \frac{2^2}{a_2 +
              \frac{3^2}{a_3 +
                \frac{4^4}{a_4 +
                  \cdots
                }
              }
            }
          }
$$

不过，你可以使用 `\frac` 来表达连分数的**紧缩记法**

```tex
$$
x = a_0 + \frac{1^2}{a_1 +}
          \frac{2^2}{a_2 +}
          \frac{3^2}{a_3 +}
          \frac{4^4}{a_4 +}
          \cdots
$$
```

$$
x = a_0 + \frac{1^2}{a_1 +}
          \frac{2^2}{a_2 +}
          \frac{3^2}{a_3 +}
          \frac{4^4}{a_4 +}
          \cdots
$$


## 其他注意事项

并**不会影响公式的正确显示，但能让它们看起来明显更好看**

### e为底时的技巧

在`以 e 为底`的指数函数、极限和积分中尽量不要使用 `\frac` 符号

⟹ 它会使整段函数看起来很奇怪并可能产生歧义，因此它在专业数学排版中不会被采用

可试着横着写这些分式，中间使用斜线间隔 `/` （用斜线代替分数线）

```tex
$$
\begin{array}{cc}
\mathrm{Bad} & \mathrm{Better} \\
\hline \\
\large e^{i\frac{\pi}2} \quad e^{\frac{i\pi}2}& \large e^{i\pi/2} \\[2ex]
\int_{-\frac\pi2}^\frac\pi2 \sin x\\,dx & \int_{-\pi/2}^{\pi/2}\sin x\\,dx \\
  \end{array}
$$
```

$$
\begin{array}{cc}
\mathrm{Bad} & \mathrm{Better} \\\\
\hline \\\\
\large e^{i\frac{\pi}2} \quad e^{\frac{i\pi}2}& \large e^{i\pi/2} \\\\[2ex]
\int_{-\frac\pi2}^\frac\pi2 \sin x\\,dx & \int_{-\pi/2}^{\pi/2}\sin x\\,dx \\\\
  \end{array}
$$

### 分隔符时会产生错误的间距

使用 `|` 符号作为分隔符时会产生错误的间距，因此在需要分隔时最好使用 `\mid` 来代替它

```tex
$$
\begin{array}{cc}
  \mathrm{Bad} & \mathrm{Better} \\
  \hline \\
  \{x|x^2\in\Bbb Z\} & \{x\mid x^2\in\Bbb Z\} \\
\end{array}
$$
```

$$
\begin{array}{cc}
  \mathrm{Bad} & \mathrm{Better} \\\\
  \hline \\\\
  \{x|x^2\in\Bbb Z\} & \{x\mid x^2\in\Bbb Z\} \\\\
\end{array}
$$

### 多重积分符号

使用多重积分符号时，不要多次使用 `\int` 来声明，直接使用 `\iint` 来表示二重积分，使用 `\iiint` 来表示三重积分

在表示面积分和体积分时下标建议使用 `\boldsymbol{S}` 和 `\boldsymbol{V}` 符号

```tex
$$
\begin{array}{cc}
    \mathrm{Bad} & \mathrm{Better} \\
    \hline \\
    \int\int_S f(x)\,dy\,dx & \iint_{\boldsymbol{S}} f(x)\,{\rm d}y\,{\rm d}x \\
    \int\int\int_V f(x)\,dz\,dy\,dx & \iiint_{\boldsymbol{V}} f(x)\,{\rm d}z\,{\rm d}y\,{\rm d}x \\[3ex]
    \hline \\
\end{array}
$$
```

$$
\begin{array}{cc}
    \mathrm{Bad} & \mathrm{Better} \\\\
    \hline \\\\
    \int\int_S f(x)\\,dy\\,dx & \iint_{\boldsymbol{S}} f(x)\\,{\rm d}y\\,{\rm d}x \\\\
    \int\int\int_V f(x)\\,dz\\,dy\\,dx & \iiint_{\boldsymbol{V}} f(x)\\,{\rm d}z\\,{\rm d}y\\,{\rm d}x \\\\[3ex]
    \hline \\\\
\end{array}
$$

使用多重积分时，在被积变量后加入 `\`, 或 `\space`（或在微分符号 `${\rm d}$` 之前）插入一个小的间距否则各种被积变量将会挤成一团

$$
\begin{array}{cc}
    \mathrm{Bad} & \mathrm{Better} \\\\
    \hline \\\\
    \iiint_V f(x){\rm d}z {\rm d}y {\rm d}x & \iiint_{\boldsymbol{V}} f(x)\\,{\rm d}z\\,{\rm d}y\\,{\rm d}x \\\\
\end{array}
$$
