---
title: "私有 git registry 工具 2024 年度比较"
date: 2024-01-30T14:54:10+08:00
description: "比较 开源的私有 git 仓库 工具"
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

## 介绍

私有 git 仓库，作为软件工程的底层基建，市面上有很多开源解决方案

- 本文比较时间为 2024 年 1月，如有新增改动，不属于本文比较范畴
- 部分比较，比如 `开源程度` `版本管理` 由个人主观统计开源对外展现，如有异议，为本人主观统计

## 比较项目

- [gitlab](https://about.gitlab.com/) 由 GitLab公司开发的、基于Git的集成软件开发平台，开源版本 [https://gitlab.com/rluna-gitlab/gitlab-ce](https://gitlab.com/rluna-gitlab/gitlab-ce)
- [gogs](https://gogs.io/) 由开源组织维护的轻量级 Git 平台，托管在 [https://github.com/gogs/gogs](https://github.com/gogs/gogs)
- [gitea](https://about.gitea.com/) 原本是Gogs软件的分支项目，尽管Gogs是一个开源项目，但是它的代码仓库是由单个维护者控制的，这导致开源社区在开发上的互动受限，社区化后形成的 go-gitea 项目 目前托管在[https://github.com/go-gitea/gitea](https://github.com/go-gitea/gitea)
- [TortoiseGit](https://tortoisegit.org/) 由 TortoiseGit team 维护的 Windows 平台下的 Git 服务客户端，目前托管在[https://github.com/TortoiseGit/TortoiseGit](https://github.com/TortoiseGit/TortoiseGit)
- [onedev](https://onedev.io/) 由开源个人维护的 基于 Git 的 集成软件开发平台 ，托管在 [https://github.com/theonedev/onedev](https://github.com/theonedev/onedev)

## 基础参数比较

| 项目 | gitlab  |  gogs  |  gitea | TortoiseGit | onedev |
|------|---|---|---|---|---|
| 首发时间  | 2011 | 2015 | 2016  | 2008 | 2020 |
| 开源程度  | 开源CE版本授权受限  | 个人维护响应缓慢  | 社区维护响应快  | 社区维护几乎停止  | 关闭 issues 不对外沟通  |
| 维护类型   | [GitLab 公司](https://docs.gitlab.com/)  | 个人 [unknwon](https://github.com/unknwon) | 开源组织 [go-gitea](https://github.com/go-gitea)  | [TortoiseGit team](https://github.com/TortoiseGit/) | 个人 [robinshine](https://github.com/robinshine) |
| 版本管理  | 严格日志详细 | 版本严格，日志详细  | 版本严格，日志详细  | 文档日志详细，无改动跟踪 | 版本变更大，全是MAJOR改动，且无改动跟踪 |
| 开发语言  | ruby  | golang  | golang  | C++  | java |
| Git 基建  | [rugged](https://github.com/libgit2/rugged)<br/>(binding for github.com/libgit2/libgit2) | [github.com/gogs/git-module](https://github.com/gogs/git-module)  | [github.com/go-git/go-git](https://github.com/go-git/go-git)  |  [github.com/libgit2/libgit2](https://github.com/libgit2/libgit2) | [org.eclipse.jgit](https://github.com/eclipse-mirrors/org.eclipse.jgit) |
| 数据库驱动  | [ruby-pg](https://github.com/ged/ruby-pg)<br/>(写死 postgres 修改需要改源码)  | [github.com/go-xorm/xorm](https://github.com/go-xorm/xorm) | [xorm.io/xorm](https://gitea.com/xorm/xorm)  |  N/A | [org.hibernate](https://github.com/hibernate) |
| Web 基础 | [Ruby on Rails](https://github.com/rails/rails) | [gopkg.in/macaron.v1](https://github.com/go-macaron/macaron) | [github.com/go-chi/chi](https://github.com/go-chi/chi) | N/A | [org.apache.wicket](https://github.com/wicketstuff/core) |

## 功能比较

| 项目 | gitlab  | gogs  |  gitea | TortoiseGit | onedev |
|------|---|---|---|---|---|
| git基础功能  | 完整  | 完整  | 完整  | 只包含 windows 平台  | 完整  |
| git lfs  | 支持  | 受限最大单文件1G  | 支持  | 不支持  | [受限支持，不推荐使用git lfs](https://docs.onedev.io/tutorials/code/sync-guide#setup)  |
| 仓库镜像  | [EE version Repository mirroring](https://docs.gitlab.com/ee/user/project/repository/mirror/)  |  支持无官方文档链接 | [Repository Mirror](https://docs.gitea.com/usage/repo-mirror)  |  N/A | [OneDev 7.1+](https://docs.onedev.io/tutorials/code/repo-mirror) |
| 管理模型  | pull request  | pull request  | pull request  | 无管理模型  | pull request  |
| 版本支持  | tag/release  | tag/release  | tag/release  |  tag | tag/release  |
| 仓库支持  | 不支持([企业版支持 package registry](https://docs.gitlab.com/ee/user/packages/package_registry/))  |  | 不支持 | 支持[主流仓库，点击查看](https://docs.gitea.com/usage/packages/overview)  |  不支持  | 支持[部分仓库，点击查看](https://docs.onedev.io/category/packages)
| CI/CD  | [自带 master/agent runner](https://docs.gitlab.com/runner/)   | 不支持  | [自带 act-runner](https://docs.gitea.com/usage/actions/act-runner)<br/>或者使用三方<br/>[drone](https://drone.io/)<br/>[woodpecker-ci](https://woodpecker-ci.org/)   | 不支持 | [自带 master/agent 模式 ](https://docs.onedev.io/category/cicd)  |

