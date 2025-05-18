---
title: "rust 版本记录和查询"
date: 2024-09-20T13:03:57+00:00
description: "rust version record and query"
draft: false
categories: ['rust']
tags: ['rust']
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

## release

- 官方发布博客 release blog [https://blog.rust-lang.org/releases/](https://blog.rust-lang.org/releases/)
- 三方统计，Rust Changelogs [https://releases.rs/](https://releases.rs/)
	- since `1.1.0`
	- 指向 issues 或者 PR 讨论贴，对应的用法也在 讨论贴中

### rustup-components-history

- [https://rust-lang.github.io/rustup/concepts/toolchains.html](https://rust-lang.github.io/rustup/concepts/toolchains.html)
- [https://rust-lang.github.io/rustup-components-history/](https://rust-lang.github.io/rustup-components-history/)

记录了 toolchain 最新支持的 Tier 和 信息，用于交叉编译查询

## nightly

- nightly 功能 索引在 [https://doc.rust-lang.org/unstable-book/the-unstable-book.html](https://doc.rust-lang.org/unstable-book/the-unstable-book.html)
	- 这些功能绝大多数，指向 issues 或者 PR 讨论贴，对应的用法也在 讨论贴中
	- 当编译器告诉您某个不稳定的功能不存在时，[请咨询该功能的跟踪问题](https://github.com/rust-lang/rust/issues?q=label%3AC-tracking-issue)，并弄清楚它是否早于或晚于您正在尝试的夜间版本，并考虑该信息以供您的下一个版本尝试

### unstablerust.dev

- [https://unstablerust.dev/](https://unstablerust.dev/)
	- source [https://github.com/Systemcluster/unstablerust](https://github.com/Systemcluster/unstablerust)

- View and compare unstable features of nightly Rust versions
- since `Rust 1.68.0`

