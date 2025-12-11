---
title: "macOS 调整系统菜单栏各个图标之间的间距"
date: 2025-12-11T09:06:28+08:00
description: "macOS adjusts the spacing between icons in the system menu bar"
draft: false
categories: ['basics']
tags: ['basics', 'macOS']
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

## 存在问题

新款的 Macbook 都有刘海，刘海图标会有一定边距，缩小每个图标之间的间隔，这样就可以显示更多的图标

> tips: 如果图标非常多，那还是会被刘海挡住，减少图标间距只能缓解一部分问题

## 解决方法

> 参考 [Built-in workaround for applications hiding under the MacBook Pro notch](https://flaky.build/built-in-workaround-for-applications-hiding-under-the-macbook-pro-notch)

使用 macOS 自带的命令，无需安装第三方工具

```bash
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6

defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
```

值可以在 `0-6` 之间调整

- 当值为 `0` 时，间距最小，这样看上去图片有点挤
- 数值为 `4-6` 的时候，看上去比较协调

**注意：需要调整后，需要退出登录，重新登录才会生效**

## 改回默认值

对修改后的图标间距不满意，可以恢复默认宽度，输入下面两行命令

```bash
defaults -currentHost delete -globalDomain NSStatusItemSelectionPadding

defaults -currentHost delete -globalDomain NSStatusItemSpacing
```

和修改系统菜单栏图标间距一样，需要退出登录，重新登录才会生效