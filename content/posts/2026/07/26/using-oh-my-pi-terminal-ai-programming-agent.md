---
title: "oh-my-pi 终端 AI 编程代理使用"
date: 2026-07-26T08:23:24+08:00
description: "使用 oh-my-pi 终端 AI 编程代理进行编程的指南和示例"
draft: false
categories: ['AI']
tags: ['AI', 'oh-my-pi', 'agent']
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

[Oh My Pi（简称 omp）是一个终端 AI 编程代理](https://omp.sh/), 由 [Can Bölük 重写为编码优先的工具](https://github.com/can1357/oh-my-pi)

同 OpenCode、Claude Code、Codex CLI 是竞品，可以同时存在

- [oh-ny-pi 官方文档](https://omp.sh/docs)
- [oh-my-pi Discord](https://discord.com/invite/oh-my-pi)

核心特性：

- 开源（MIT），~55k 行 Rust 核心，跨平台原生
- 32 个内置工具（读写文件、搜索、shell、LSP、调试器、浏览器、子代理……）
- 40+ 模型 provider，自定义 models.yml 接入任何 OpenAI 兼容端点
- Hashline 编辑格式：基于内容哈希锚点，编辑精准、省 token
- 子代理（subagents）：并行任务分发，隔离工作区
- LSP 深度集成：重命名、引用查找、诊断——IDE 知道的它都知道
- DAP 调试器：lldb、dlv、debugpy，直接附加进程调试
- 浏览器驱动：puppeteer 控制 chromium 或 electron 应用
- MCP 支持：标准化外部工具接入
- 25 个搜索后端：auto 模式自动链式查找
- 支持多人合作会话
- LSP 深度操作
- 内置记忆系统(需开启)
- 顾问模型(需开启)

### omp 和竞品对比

| item | omp | opencode | claude code | codex cli |
| --- | --- | --- | --- | --- |
| 开源  | MIT | MIT | ❌   | Apache 2.0 |
| 内置工具 | ~32 | ~12 | ~15 | ~10 |
| LSP 集成 | 14 opt | 基础诊断 | 有限  | 插件  |
| 调试器 | DAP(28 ops) | N/A | N/A | N/A |
| 浏览器 | 内置 Puppeteer | N/A | N/A | N/A |
| 子代理 | 内置可开发 | 内置可开发 | subagent | 支持需开发 |
| 编辑方式 | Hashline | edit/patch | str_replace | apply_patch |
| 性能  | rust N-API in-process | go native | node | node |

> 简单说：omp 功能最全的——别人需要装插件的东西它出厂自带。代价是体积更大、配置项更多

## 安装 omp

各平台安装命令

```bash
# macOS / Linux（推荐）
curl -fsSL https://omp.sh/install | sh

# Homebrew
brew install can1357/tap/omp

# Windows PowerShell
irm https://omp.sh/install.ps1 | iex
```

WSL 用户推荐用 bun 安装（避免权限问题），安装到 `~/.bun/bin`

> 别装在 /mnt/c 等 Windows 挂载盘上，I/O 慢， wsl 本质时虚拟机，跨系统 IO 非常烂

```bash
bun --version || npm install -g bun
bun install -g @oh-my-pi/pi-coding-agent
hash -r; omp --version
```

### 开启自动补全

配置 平台命令自动补全, 目前只支持 zsh bash fish

- 使用  zsh 作为基础的 添加到 ~/.zshrc

```bash
# omp https://github.com/can1357/oh-my-pi
eval "$(omp completions zsh)"
```

bash fish 请参考官方文档配置

### 开启 omp 常用功能

```bash
# 开启 顾问模型
omp config set advisor.enabled true
# 开启 Hindsight 记忆系统
omp config set memory.backend hindsight
```

## 配置 omp

### omp 配置文件

[omp settings](https://omp.sh/docs/settings)

配组文件在 `~/.omp/agent/config.yml`

覆盖父目录使用环境变量 `PI_CODING_AGENT_DIR` 或重命名 配置根目录环境变量 `PI_CONFIG_DIR`

> 文件是一个纯YAML树；缺失的键会回退到内置默认值

```bash
# 获取配置目录
omp config path

# 编辑配置文件
vim $(omp config path)/config.yml

code $(omp config path)/config.yml
```

配置文件可以为

```yml
advisor:
  enabled: true
memory:
  backend: hindsight
modelRoles:
  default: deepseek/deepseek-v4-flash
symbolPreset: nerd
theme:
  dark: titanium
setupVersion: 1
```

### 配置 模型 接入

omp 通过 `~/.omp/agent/models.yml` 配置自定义模型 provider

```bash
vim $(omp config path)/models.yml

code $(omp config path)/models.yml
```

#### deepseek 接入 omp

```yaml
providers:
  deepseek:
    baseUrl: https://api.deepseek.com
    apiKey: "<YOUR_DEEPSEEK_API_KEY>"
    api: openai-completions
    authHeader: true
    models:
      - id: deepseek-v4-flash
        name: deepseek-v4-flash
        reasoning: true
        input: [text]
        contextWindow: 1024000
        maxTokens: 65536
      - id: deepseek-v4-pro
        name: deepseek-v4-pro
        reasoning: true
        input: [text]
        contextWindow: 1024000
        maxTokens: 65536
```

- 配置后确认

```bash
# 刷新 models 配置
omp models refresh

# 列出当前所有可用模型
omp models list

# 查找 模型 deepseek
omp models find deepseek

omp --model deepseek-v4-flash -p "你好，介绍一下自己，包括当前 模型provider 系统环境等信息"
```

## 日常使用

### 启动 omp

```bash
# omp 以目录为记忆单位，不要随意开启 omp
# 建议先到某个目录后开启
cd foo-folder

## 交互模式（默认模式）
# 如果没有做任何设置，omp 会引导你执行一次配置
omp

# 单次命令
omp -p "你好"

# 指定模型
omp --model deepseek-v4-flash -p "你好，介绍一下自己，包括当前 模型provider 系统环境等信息"

# 继续上次会话，非常常用
omp -c

# 选择历史会话
omp --resume
```

### 交互模式快捷键

> tui 用户最常用操作就是各种快捷键

| 快捷键 | 功能  |
| --- | --- |
| ctrl + c | 中断当前生成 |
| ctrl + p | 切换模型， 当前角色的模型间循环切换 |
| ctrl + g | 查看子代理 |
| Esc Esc | 会话树/分支 |

### 交互模式常用命令

```bash
/exit              # 退出
/model             # 切换模型
/mcp               # 查看 MCP server 状态
/review            # 代码审查
/collab            # 协作分享会话
/debug             # 调试面板
/advisor           # 开启/查看 advisor 顾问模型状态
```

### 模型角色系统

omp 有独特的模型角色设计，按任务意图路由不同模型

| 角色  | 命令行指定 | 用途  |
| --- | --- | --- |
| default | `--model` | 常用 对话/编码 |
| smol | `--smol` | 廉价子代理 fan-out, 小模型，低成本 |
| slow | `--slow` | 深度推理，慢速模型 |
| plan | `--plan` | 规划模式，只探讨不执行 |

常用配置策略

```bash
omp --model "deepseek-v4-pro" \
  --smol "deepseek-v4-flash" \
  --slow "glm-5.2" \
  --plan "deepseek-v4-pro"

omp --model "deepseek-v4-flash" \
  --slow "gpt-5.6-sol" \
  --smol "gpt-5.4-mini"
```

## 使用 omp

omp 是一款开箱配置完全，但不是开箱即用的 agent 工具，有非常多的特色功能

### 子代理 subagents

omp 的杀手锏之一。把任务拆分成多个并行 worke

```bash
> 帮我重构 src/services/ 下的 5 个文件，每个文件转成 TypeScript 并加类型注解
```

> omp 会自动用 task 工具 spawn 多个子代理，每个处理一个文件，互不干扰

### plan 模式

先规划再执行

```bash
omp --plan-yolo "把这个项目从 CommonJS 迁移到 ESM"
```

agent 先用 plan 模型制定方案，确认后切到执行模型实施

### advisor 顾问模型

开启后，一个独立模型实时审阅主 agent 的每一步

```bash
omp config set advisor.enabled true
```

顾问发现问题会内联提示（concern/blocker），主 agent 看到后自行修正

### LSP 深度操作

不只是诊断—— 为编程语言 LSP 服务额外提供的，支持重命名、查找引用、跳转定义、代码操作

```bash
> 把 getUserName 重命名为 getUsername，确保所有引用都更新
```

omp 调用 lsp 工具的 workspace/willRenameFiles，barrel files、re-exports 全部自动更新

### 浏览器控制

> 打开 http://localhost:3000，截个图看看页面渲染是否正确

内置 Puppeteer 驱动，隐身模式默认开启。还能控制 electron 应用

### 协作会话

```bash
/collab           # 生成共享链接 + 二维码
/collab view      # 只读分享
```

别人用 `omp join <link>` 或浏览器加入，实时协作。端到端加密

### 记忆系统 Hindsight

```bash
omp config set memory.backend hindsight
```

项目级隔离的 agent 跨会话记忆，用 retain 实时写入，recall 检索，reflect 综合分析

### 自动继承其他工具配置

omp 自动读取

- `.claude/`
- `.cursor/`
- `.opencode/`
- `.codex/`
- `.cline/`
- `.vscode/`

等目录的规则和 MCP 配置。不需要迁移

### MCP 扩展

[MCP Extension](https://omp.sh/docs/mcp)

`~/.omp/agent/mcp.json` 注册外部工具 比如 imagegen-mcp

```json
{
  "mcpServers": {
    "imagegen": {
      "command": "npx",
      "args": ["-y", "tsx", "~/projects/imagegen-mcp/src/server.ts"],
      "env": { "SILICONFLOW_API_KEY": "sk-xxx" }
    }
  }
}
```

### prewalk 模式

```bash
omp --prewalk --prewalk-into "deepseek-v4-flash"
```

## omp 调优

### 性能调优

#### Fallback 链

模型 429 时自动降级，在 文件 ~/.omp/agent/config.yml 中添加

```yaml
retry:
  fallbackChains:
    "glm-5.2":
      - "deepseek-v4-pro"
      - "deepseek-v4-flash"
```

#### Thinking Level

```bash
# 复杂任务
omp --thinking high
# 简单问答
omp --thinking low
# 最深度推理
omp --thinking max
```

## 使用案例

- 案例都需要 进入项目工程目录，按工程隔离

### 案例 1：大规模重构工程

```bash
omp --model "glm-5.2" --thinking high

> 这是一个 Express + JS 项目，帮我：
> 1. 分析模块依赖
> 2. 从底层开始逐个转 TypeScript
> 3. 每转完一个文件就跑测试确认没破坏
```

omp 会用 subagents 并行处理独立模块，用 LSP 确保类型正确

### 案例 2：PR Review

```bash
omp

/review main..feature-branch
```

spawn 专门的 reviewer subagent，按 P0-P3 分级输出问题和 verdict