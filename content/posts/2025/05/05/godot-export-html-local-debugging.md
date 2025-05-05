---
title: "godot 导出 HTML 本地调试"
date: 2025-05-05T12:11:20+08:00
description: "godot 导出 HTML 解决本地调试跨域问题"
draft: false
categories: ['game']
tags: ['godot', 'game']
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

## webGL 导出不能直接运行原因

默认导出的 HTML 页面不能直接使用，会报告 CORS 错误

- [https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_web.html#doc-javascript-secure-contexts](https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_web.html#doc-javascript-secure-contexts)

只有在使用 Use Threads 导出时，为了确保低音频延迟和在 Web 导出中使用 Thread 的能力，Godot 4 Web 导出才使用 SharedArrayBuffer。这需要一个安全的上下文，同时还需要在提供文件时设置以下 CORS 标头：

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

## godot 导出到 web 本地调试辅助

- 导出设置 导出目录  `dist/webGL/static/index.html`

> 建议在每次导出前，清空 `dist/webGL/static` 目录

- 导出结构为

```
dist/webGL
├── index.js
├── package.json
├── README.md
└── static
    ├── index.js
    ├── index.pck
    ├── index.png
    └── index.html
```

- `dist/webGL/package.json` 内容为

```json
{
  "name": "game",
  "version": "1.0.0",
  "description": "Example node.js server for locally testing exported web builds",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": {
    "name": "sinlov",
    "email": "sinlovgmppt@gmail.com"
  },
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

- `index.js` 内容为

```js
const express = require("express");

const app = express();

const server = require("http").createServer(app);
const port = process.env.PORT || 3000;

app.use(function (req, res, next) {
  res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
  res.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
  next();
});

app.use(express.static("static"));

server.listen(port, function () {
  console.log("Listening on port:", port);
});
```

本地调试执行

```bash
npm install
npm start

## 或者设置 PORT 环境变量
# unix
export PORT=33000 && npm start
# windows powershell
$env:PORT="33000" ; npm start
```

网页访问本地即可

## 参考文档

- [godotengine 为 Web 导出](https://docs.godotengine.org/zh-cn/4.x/tutorials/export/exporting_for_web.html)
