---
title: "ollama 本地大模型 for macbook"
date: 2024-09-16T12:24:13+08:00
description: "Ollama local large model for macbook"
draft: false
categories: ['AI']
tags: ['AI', 'ollama']
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

## 准备

- 良好的网络，下载容器镜像和模型非常需要
	- 配置代理等不属于本文范围
- 建议 盘大亿点点，后面会用到
- 安装好 容器
	- 建议 [OrbStack](https://docs.orbstack.dev/) 性能更好
	- [docker](https://docs.docker.com/desktop/)

- 下载 [ollama](https://ollama.com/download)

##  安装 ollama

- 下载的安装包，解压后，拖拽到 `应用程序` 文件夹
- 打开 ollama 后 点击确认
- 再 提示 `Install the command line`，点击输入管理员密码后
- 提示 `Finish`

- 确认安装

```bash
$ ollama --help
# 确认 ollama 运行在 11434 端口上
$ lsof -i :11434
COMMAND   PID   USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
ollama  76055 sinlov    6u  IPv4  0x832815bf96a7e5b      0t0  TCP localhost:11434 (LISTEN)
```

### ollama cli 基本使用

- `list`列出已经安装的模型
- `pull` 拉取模型
- `run`  run 除了拉取模型，还同时将模型对应的交互式控制台运行了起来，不建议这么做，限定死了启动方式
- `rm` 移除本地下载的模型
- `ps`查看当前硬件资源占用
- `serve` 启动 大模型后台服务

### ollama 硬盘占用说明

macOS 上的 Ollama 将文件存储在几个不同的位置

- `~/.ollama/`
	- `~/.ollama/models` 拉取的本地模型所在目录
	- `~/.ollama/logs`  本地日志
- `/Applications/Ollama.app`程序文件夹
- `~/Library/Preferences/com.electron.ollama.plist` 设置文件
- `~/Library/Application\ Support/Ollama` 支持目录
- `~/Library/Saved\ Application\ State/com.electron.ollama.savedState` 状态文件夹

## 拉取模型

[查找模型的链接](https://ollama.com/library)

- 模型格式 `<name>:<num><arg>`
	- name 为模型发布名称，后面 `<num><arg>` 多少 B 表示模型有 多少 十亿 参数
	- 参数规模规格为  `B 十亿` `M 百万` `K 千`
	- 参数越多，所需 显存 越大，30b 左右差不多需要 20G 专有显存推理
	- 参数多不代表准确，不过太小参数的 LLM 容易出现幻觉(瞎扯给结果)

> tips: 7b 左右的专业模型，就可以勉强使用了，显卡不好的 20b 开始就明显表现为缓慢

下面演示常用模型

```bash
## 多模态模型，可以混和图文处理
ollama pull llava:13b
ollama pull llava:34b
ollama pull bakllava:7b

## 文本大模型，只针对文本处理
ollama pull deepseek-r1:8b
ollama pull deepseek-r1:14b
ollama pull deepseek-r1:32b
ollama pull qwen2.5:7b
ollama pull qwen2.5:14b
ollama pull qwen2:7b
ollama pull qwen:14b
ollama pull qwen:32b
# 翻译常用模型
ollama pull llama3.2:3b
ollama pull llama3.1:8b
ollama pull llama3:8b
# 70b 4090 24G 显存会不够必须集群跑
ollama pull llama3:70b

## 编码大模型
# 总结 commit
ollama pull mistral:7b
# 代码提示
ollama pull codeqwen:7b
ollama pull codellama:7b
ollama pull codellama:13b
ollama pull codellama:34b
ollama pull deepseek-coder-v2:16b
ollama pull deepseek-coder:6.7b
ollama pull deepseek-coder:33b
ollama pull starcoder2:3b
ollama pull starcoder2:7b
ollama pull starcoder2:15b
```

## 设置 ollama 服务

打开应用其实已经在后台 端口 11434 运行

- [OLLAMA 支持的环境变量和用途见 源码](https://github.com/ollama/ollama/blob/main/envconfig/config.go)

- `OLLAMA_KEEP_ALIVE` 修改这个时间，可以防止重复挂载模型，缺点是更占用资源
- `OLLAMA_HOST` 定义当前运行 服务 host
- `OLLAMA_ORIGINS` 跨域配置，这个需要点跨域知识，实在不会问生成式AI，大不了错几次
- `OLLAMA_MODELS` 模型文件存储位置，这个选项可以更换下载位置

```bash
# 修改模型载入保留时间
launchctl setenv OLLAMA_KEEP_ALIVE "30m"

# 设置跨域主要是允许 容器使用
launchctl setenv OLLAMA_ORIGINS "http://127.0.0.1:*,http://localhost:*,http://172.17.0.1:*,http://host.docker.internal:*"

# 可选项设置跨域
launchctl setenv OLLAMA_ORIGINS "http://127.0.0.1:*,http://localhost:*,http://172.17.0.1:*,http://host.docker.internal:*,http://192.168.50.0:*"
```

修改后，重启 ollama 服务，方法是 在状态栏点击退出，重新打开即可

说明文档见
- [How can I allow additional web origins to access Ollama?](https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-allow-additional-web-origins-to-access-ollama)
- [Setting environment variables on Mac](https://github.com/ollama/ollama/blob/main/docs/faq.md#setting-environment-variables-on-mac)

### 自定义开启服务

```bash
OLLAMA_HOST="0.0.0.0:11433"
OLLAMA_KEEP_ALIVE="30m"
OLLAMA_ORIGINS="http://127.0.0.1:*,http://localhost:*,http://172.17.0.1:*,http://host.docker.internal:*,http://192.168.50.0:*"

# 这里修改了启动端口 11433
# ollama 启动！！！
ollama serve
```

## 应用

### 本地 open-webui 使用ollama 服务

> **注意**： ollama 是一组后台服务， 使用 `大模型` 的 `交互前端` 需要另外的部署，这里演示的是 open-webui

创建目录，新增 docker-compose.yml 文件

```bash
$ mkdir ollama-app && cd ollama-app
# 使用 vscode 打开目录
$ code .
```

- docker-compose
	- environment
		- `WEBUI_SECRET_KEY` webui secret key 可以通过 `openssl rand -hex 16` 生成
		- `OLLAMA_BASE_URL` 这个根据实际情况配置
		- `HF_ENDPOINT` 可以加速模型下载
	- volumes
		- `./open-webui/data:/app/backend/data` 这个为 当前 `docker-compose.yml` 文件相对目录存储数据
	- ports
		- `11435:8080` 这个是 webUI 对外服务的 端口 设置 映射到 `11435`，如果端口占用可以跟换
	- `network_mode: host` 如果开启，需要 OrbStack 支持，并且 webUI 服务端口就是 8080

```yml
services:
  ollama-local-open-ui:
    container_name: "ollama-local-open-ui"
    # image: ghcr.io/open-webui/open-webui:v0.3.21-ollama
    image: ghcr.io/open-webui/open-webui:v0.3.21
    pull_policy: if_not_present
    environment: # https://docs.openwebui.com/getting-started/env-configuration/
      OLLAMA_BASE_URL: 'http://host.docker.internal:11434' # 这里需要注意，这个地址连不上，也就是支持 extra_hosts 有问题，使用完整 IP address 即可
      HF_ENDPOINT: 'https://hf-mirror.com' # 从 https://hf-mirror.com 镜像，而不是https://huggfacing.co 官网下载所需的模型
      WEBUI_SECRET_KEY: 'e2ac9c8f3462a9831b238601b8546807' # webui secret key
      # PORT: '11435'
    extra_hosts:
      - host.docker.internal:host-gateway
    ports:
      - "11435:8080"
    # network_mode: host
    volumes:
      - "./open-webui/data:/app/backend/data"
    restart: unless-stopped # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: json-file
      options:
        max-size: 2m
```

#### 使用 本地 open-webui

第一次需要注册账号

- 设置，进入设置 `Settings`
	- 修改语言 `General` -> `Language` 修改为你需要的语言

- 设置，进入 `设置` -> `管理员设置`
	- `外部链接`  确认本地 ollama 链接 `http://host.docker.internal:11434` 可以正常使用
	-  也可以添加远程 ollama 链接

![](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/09/17/9y9Idp-IGa5Ua.png)

#### 模型拉取

- 可用模型 [https://ollama.com/library](https://ollama.com/library)

- 设置，进入 `设置` -> `管理员设置` -> `模型`

输入需要拉的模型

![](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2024/09/17/TOdc0X-KAdbKD.png)

## 应用

### IDE ollama 扩展

查询扩展 [https://github.com/ollama/ollama?tab=readme-ov-file#extensions--plugins](https://github.com/ollama/ollama?tab=readme-ov-file#extensions--plugins)，其中推荐试用

#### Continue

- [Continue](https://docs.continue.dev) 代码助手，支持 vscode 和 JetBrains

### Chatbox

AI 对话客户端  [Chatbox](https://chatboxai.app/)

- 本地模型支持
- 一次使用一种模型

```bash
brew install chatbox
```

### Cherry Studio

AI 对话客户端  [Cherry Studio](https://cherry-ai.com/)

- 本地模型支持
- 支持 助手 话题 翻译  ，不同业态使用
- 支持 三 模型同时使用

```bash
brew install cherry-studio
```

- 该工具常用模型

```bash
## 助手
ollama pull deepseek-r1:8b
ollama pull deepseek-r1:14b
ollama pull deepseek-r1:32b

## 话题
ollama pull qwen2.5:7b
ollama pull qwen2.5:14b

## 翻译

ollama pull llama3.2:3b
ollama pull llama3:8b
```

### opencommit

AI 总结代码，生成提交信息，支持本地模型

```bash
npm install -g opencommit

## pull model at local
# 高配设备推荐这个
ollama pull qwen2.5:14b
# 低配设备推荐这个模型
ollama pull llama3.2:3b
# 也可以拉其他模型
ollama pull llama3:8b
ollama pull mistral:7b

# 报错  Ollama provider error: Invalid URL
oco config set OCO_API_URL='http://127.0.0.1:11434/api/chat'
# 如果您在 docker/另一台具有GPU（非本地）的机器上设置了 ollama
oco config set OCO_API_URL='http://192.168.50.10:11434/api/chat'

## config
# set language
oco config set OCO_LANGUAGE=en
# set description
oco config set OCO_DESCRIPTION=true
# set model
oco config set OCO_AI_PROVIDER='ollama'
oco config set OCO_MODEL='qwen2.5:14b'
oco config set OCO_MODEL='qwen2.5:7b'
oco config set OCO_MODEL='mistral:7b'
oco config set OCO_MODEL='llama3.2:3b'
# 推理模型会把推理过程加到提交中，不建议使用
oco config set OCO_MODEL='deepseek-r1:14b'

# usage
git add <files...>
oco

# 跳过提交确认
oco --yes
```

- 配置文件并使用oco config set命令进行设置 到 文件 `~/.opencommit`

```
OCO_AI_PROVIDER=<openai (default), anthropic, azure, ollama, gemini, flowise, deepseek>
OCO_API_KEY=<your OpenAI API token> // or other LLM provider API token
OCO_API_URL=<may be used to set proxy path to OpenAI api>
OCO_TOKENS_MAX_INPUT=<max model token limit (default: 4096)>
OCO_TOKENS_MAX_OUTPUT=<max response tokens (default: 500)>
OCO_DESCRIPTION=<postface a message with ~3 sentences description of the changes>
OCO_EMOJI=<boolean, add GitMoji>
OCO_MODEL=<either 'gpt-4o', 'gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo' (default), 'gpt-3.5-turbo-0125', 'gpt-4-1106-preview', 'gpt-4-turbo-preview' or 'gpt-4-0125-preview' or any Anthropic or Ollama model or any string basically, but it should be a valid model name>
OCO_LANGUAGE=<locale, scroll to the bottom to see options>
OCO_MESSAGE_TEMPLATE_PLACEHOLDER=<message template placeholder, default: '$msg'>
OCO_PROMPT_MODULE=<either conventional-commit or @commitlint, default: conventional-commit>
OCO_ONE_LINE_COMMIT=<one line commit message, default: false>
```

支持 本地 `.env` 文件导入

### jetbrains AI Git Commit

- [https://plugins.jetbrains.com/plugin/24851-ai-git-commit](https://plugins.jetbrains.com/plugin/24851-ai-git-commit)

- Support for OpenAI API.
- Support for Gemini.
- Support for DeepSeek.
- Support for Ollama.
- Support for Cloudflare Workers AI.
- Support for 阿里云百炼(Model Hub).
- Support for SiliconFlow(Model Hub).

本地使用 ollama 需要提前拉模型

```bash
## pull model at local
# 高配设备推荐这个
ollama pull qwen2.5:14b
# 低配设备推荐这个模型
ollama pull llama3.2:3b
```

### 代码补全

#### continue 代码插件

 **[Continue](https://docs.continue.dev) 是领先的开源AI代码助手。您可以连接任何模型和任何上下文，在其中构建自定义的自动完成和聊天体验 [VS Code](https://marketplace.visualstudio.com/items?itemName=Continue.continue) 或者 [JetBrains](https://plugins.jetbrains.com/plugin/22707-continue-extension)**

 配置前，[查找模型的链接](https://ollama.com/library)， 需要先拉本地模型

```bash
# 文本大模型
ollama pull qwen2:7b

# 代码大模型
ollama pull codellama:7b
ollama pull starcoder2:7b
ollama pull codeqwen:7b

# 也可以调整当前设备可以支持
```

工程目录下

- 新增文件 `.continuerc.json`
	- `apiBase` 内容 `http://127.0.0.1:11434` 更换为其他地址，也可以

```json
{
  "cody.autocomplete.advanced.provider": "experimental-ollama",
  "models": [
    {
      "title": "codellama:7b",
      "model": "codellama:7b",
      "provider": "ollama",
      "apiBase": "http://127.0.0.1:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "StarCoder2:7b",
    "model": "starcoder2:7b",
     "contextLength": 16384,
    "provider": "ollama",
    "apiBase": "http://127.0.0.1:11434"
  },
  "embeddingsProvider": {
    "title": "qwen2:7b",
    "model": "qwen2:7b",
	  "contextLength": 2048,
    "provider": "ollama",
    "apiBase": "http://127.0.0.1:11434"
  },
  "customCommands": [
    {
      "name": "test",
      "prompt": "{{{ input }}}\n\nWrite a comprehensive set of unit tests for the selected code. It should setup, run tests that check for correctness including important edge cases, and teardown. Ensure that the tests are complete and sophisticated. Give the tests just as chat output, don't edit any file.",
      "description": "Write unit tests for highlighted code"
    }
  ],
  "contextProviders": [
    {
      "name": "diff",
      "params": {}
    },
    {
      "name": "folder",
      "params": {}
    },
    {
      "name": "codebase",
      "params": {}
    },
    {
      "name": "terminal"
    },
    {
      "name": "docs"
    },
    { "name": "search" },
    { "name": "tree" },
    { "name": "os" },
    {
      "name": "locals",
      "params": {
        "stackDepth": 3
      }
    },
    {
      "name": "open",
      "params": {
        "onlyPinned": true
      }
    }
  ],
  "slashCommands": [
    {
      "name": "edit",
      "description": "Edit selected code"
    },
    {
      "name": "comment",
      "description": "Write comments for the selected code"
    },
    {
      "name": "share",
      "description": "Export the current chat session to markdown"
    },
    {
      "name": "commit",
      "description": "Generate a git commit message"
    }
  ]
}
```

- 如果内存小可以使用这个配置

```json
{
  "cody.autocomplete.advanced.provider": "experimental-ollama",
  "models": [
    {
      "title": "qwen2:7b",
      "model": "qwen2:7b",
      "provider": "ollama",
      "apiBase": "http://127.0.0.1:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "StarCoder2:7b",
    "model": "starcoder2:7b",
     "contextLength": 16384,
    "provider": "ollama",
    "apiBase": "http://127.0.0.1:11434"
  },
  "embeddingsProvider": {
    "title": "qwen2:7b",
    "model": "qwen2:7b",
	  "contextLength": 2048,
    "provider": "ollama",
    "apiBase": "http://127.0.0.1:11434"
  },
  "customCommands": [
    {
      "name": "test",
      "prompt": "{{{ input }}}\n\nWrite a comprehensive set of unit tests for the selected code. It should setup, run tests that check for correctness including important edge cases, and teardown. Ensure that the tests are complete and sophisticated. Give the tests just as chat output, don't edit any file.",
      "description": "Write unit tests for highlighted code"
    }
  ],
  "contextProviders": [
    {
      "name": "diff",
      "params": {}
    },
    {
      "name": "folder",
      "params": {}
    },
    {
      "name": "codebase",
      "params": {}
    },
    {
      "name": "terminal"
    },
    {
      "name": "docs"
    },
    { "name": "search" },
    { "name": "tree" },
    { "name": "os" },
    {
      "name": "locals",
      "params": {
        "stackDepth": 3
      }
    },
    {
      "name": "open",
      "params": {
        "onlyPinned": true
      }
    }
  ],
  "slashCommands": [
    {
      "name": "edit",
      "description": "Edit selected code"
    },
    {
      "name": "comment",
      "description": "Write comments for the selected code"
    },
    {
      "name": "share",
      "description": "Export the current chat session to markdown"
    },
    {
      "name": "commit",
      "description": "Generate a git commit message"
    }
  ]
}
```