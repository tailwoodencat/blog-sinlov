---
title: "git lfs 使用详解"
date: 2019-10-20T19:30:01
description: "git-lfs 使用详细说明，以及使用技巧"
draft: false
categories: ['basics']
tags: ['basics', 'git']
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

- git可以管理二进制文件，但和二进制文件相性不好（二进制文件不太好进一步压缩）
- 二进制文件的内容版本多了以后会影响git的工作效率（存储和传输，主要是传输）进而影响用户体验
- 仓库二进制文件体量上来之后，存放 git 仓库的服务器也会受影响，响应变慢，甚至内存跑满

为了缓解这个问题，git 的大文件存储工具 [https://git-lfs.com/](https://git-lfs.com/) 产生了

在传输数据的时候从全量传输优化成了按需传输
并且让用户没有太大的感知，使用git的方式也只是稍有变化，也不会觉得和远程仓库交互时会耗时很久(取决于网络速度)

对服务器来说，节省了大量的带宽，LFS 数据单独管理，仓库的 gc 效率也变高

- 官方网站 [https://git-lfs.com/](https://git-lfs.com/)
- Bitbucket git-lfs 使用指南 [https://www.atlassian.com/git/tutorials/git-lfs](https://www.atlassian.com/git/tutorials/git-lfs)

### git-lfs 使用前注意

`git-lfs 需要仓库支持`，使用前需要确认 git 仓库本身支持，支持 git-lfs 列表官方收集的有
[https://github.com/git-lfs/git-lfs/wiki/Implementations](https://github.com/git-lfs/git-lfs/wiki/Implementations)

> github bitbucket gitea gitee gitlab 都支持但是支持的层级不一样，详细见 [https://github.com/git-lfs/git-lfs/wiki/Implementations#paid-commercial-some-with-free-versions-for-small-teams](https://github.com/git-lfs/git-lfs/wiki/Implementations#paid-commercial-some-with-free-versions-for-small-teams)

支持 git-lfs 的 GUI 客户端 [SourceTree](https://www.sourcetreeapp.com/)

当一个 git 项目`已经因为大二进制文件，pull clone 缓慢时，改为 git-lfs 不会有明显效果`
要么一开始就将大文件交给 git-lfs 管理，要么去掉已由提交，新开仓库改为 git-lfs 管理二进制文件

> 这个是由于已经被作为版本管理的大文件，不能删除导致，所以不少 git-lfs 评价认为不算一个大文件解决方案的原因

`git-lfs 解决二进制合并冲突不会太简便`，需要用到 [git-lfs 文件锁](#锁定-git-lfs-文件) 功能，防止误操作来降低合并成本

### git-lfs 原理

git-lfs（Large File Storage）是由 Atlassian, GitHub 以及其他开源贡献者开发的 Git 扩展，它通过延迟地（lazily）下载大文件的相关版本来减少大文件在仓库中的影响

具体来说，大文件是在 `checkout` 的过程中下载的，而不是 `clone` 或 `fetch` 过程中下载的

> 这意味着你在后台定时 fetch 远端仓库内容到本地时，并不会下载大文件内容，而是在你 checkout 到工作区的时候才会真正去下载大文件的内容

git-lfs 通过将仓库中的大文件替换为微小的指针（lfs-pointer） 文件来做到这一点

> lfs-pointer 的指针文件是一个文本文件，存储在 git 仓库中，对应大文件的内容存储在 lfs 服务器里，而不是 git 仓库中

在正常使用期间，你将永远不会看到这些指针文件，因为它们是由 git-lfs 自动处理

![](https://git-lfs.com/images/graphic.gif)

细节流程为:

1. 当你添加（执行 `git add` 命令）一个文件到你的仓库时，git-lfs 用一个指针替换其内容，并将文件内容存储在本地 git-lfs 缓存

![98eec38f0e6a7e14a6bcad23d6286141-yWzLuS](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/98eec38f0e6a7e14a6bcad23d6286141-yWzLuS.png)

> 本地 git-lfs 缓存位于仓库的 `.git/lfs/objects` 目录
> 指针文件很小，小于 1KB。其格式为 key-value 格式，第一行为指针文件规范 URL，第二行为文件的对象 id，也即 lfs 文件的存储对象文件名，第三行为文件的实际大小（单位为 字节 ）

2. 当你推送新的提交到服务器时，LFS 文件内容会直接从本地 git-lfs 缓存传输到远程 git-lfs 存储服务器

![67cc818d008558abc7e646fc0b88886e-ERDxuP](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/67cc818d008558abc7e646fc0b88886e-ERDxuP.png)

> 新推送的提交引用的所有 git-lfs 文件都会从本地 git-lfs 缓存传输到绑定到 Git 仓库的远程 git-lfs 存储

3. 当你 checkout 一个包含 git-lfs 指针的提交时，指针文件将替换为本地 git-lfs 缓存中的文件，或者从远端 git-lfs 存储区下载

![e10b680d45f52ec4528715188e6c0f5d-km2ja8](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/e10b680d45f52ec4528715188e6c0f5d-km2ja8.png)

## 安装

- [git-lfs-installing-doc](https://github.com/git-lfs/git-lfs?utm_source=gitlfs_site&utm_medium=installation_link&utm_campaign=gitlfs#installing)

```bash
# macOS
$ brew install git-lfs

# debian
$ sudo apt install git-lfs -y
# redhat
$ sudo yum install git-lfs
# more see https://github.com/git-lfs/git-lfs/blob/main/INSTALLING.md

# windows scoop
$ sudo scoop install git-lfs
```

### 安装后配置技巧

`git-lfs` 和 git 别名 `git lfs` 是等效的

为了使用方便，建议添加 git 全局别名来做日常维护

```bash
## basic
# git lfss
git config --global alias.lfss "lfs status"

# git lfsls
git config --global alias.lfsls "lfs ls-files"

# git lfsfh
git config --global alias.lfsfh "lfs fetch"

# git lfsp
git config --global alias.lfsp "lfs pull"

# git lfspc
git config --global alias.lfspc "-c filter.lfs.smudge= -c filter.lfs.required=false pull"

# git lfstd
git config --global alias.lfstd "lfs track --dry-run"

# git lfstk
git config --global alias.lfstk "lfs track"

# git lfsuk
git config --global alias.lfsuk "lfs track"

# git lfsph
git config --global alias.lfsph "lfs push"

## lock / unlock

# git lfstl
git config --global alias.lfstl "lfs track --lockable"

# git lfslk
git config --global alias.lfslk "lfs lock"

# git lfsuk
git config --global alias.lfsuk "lfs unlock"

## prune

# git lfsdryprune
git config --global alias.lfsdryprune "lfs prune --dry-run --verbose"

# git lfsprunesafe
git config --global alias.lfsprunesafe "lfs prune --verify-remote"
```

## 使用

- 工程初次使用需要开启/初始化lsf功能：`git-lfs install`

```bash
$ git lfs install
Updated Git hooks.
git-lfs initialized.
```

### 查看状态

```bash
$ git lfs status
Objects to be pushed to origin/main:


Objects to be committed:


Objects not staged for commit:
```

### 添加文件到 lfs

> 注意: git-lfs 支持 glob style [https://en.wikipedia.org/wiki/Glob_(programming)](https://en.wikipedia.org/wiki/Glob_(programming))
> 因为 go-lfs 为 go 实现的，实际为 [go style 下的 glob](https://pkg.go.dev/path#Match)

```bash
# 添加前可以加参数 --dry-run 来测试是不是要添加的目标
$ git lfs track --dry-run [files]

# 推荐 2种 方式将大型文件添加到lfs管理
# 文件形式
$ git lfs track *.png

## 文件夹形式
# 包含文件夹本身的
$ git lfs track model/**

# 不包含文件夹本身的
$ git lfs track model/*

# 参数 --filename
# 视为文字文件名，而不是 glob
# 写入 .gitattributes 时，文件名中的字符将被转义
$ git lfs track --filename '**/png'
```

- 添加后会产生文件 `.gitattributes`
- 如果文件存在则在这个文件添加内容

### 移除

```bash
# 移除也是类似方法

# 包含文件夹本身的
$ git lfs untrack model/**

# 不包含文件夹本身的
$ git lfs untrack model/*
```

### 查看 lfs 追踪文件

```bash
$ git lfs ls-files
```

### 检出

```bash
$ git lfs checkout
```

### 克隆

clone 时 使用 `git clone` 或 `git lfs clone` 均可

#### 加快克隆速度

如果你正在克隆包含大量 LFS 文件的仓库，显式使用 git lfs clone 命令可提供更好的性能

> git lfs clone 命令不会一次下载一个 git-lfs 文件，而是等到检出（checkout）完成后再批量下载所有必需的 git-lfs 文件
> 利用了并行下载的优势，并显著减少了产生的 HTTP 请求和进程的数量，尤其在 Windows 上非常明显）

### 拉取

```bash
$ git lfs pull
```

> 技巧: 如果 `checkout/clone 因为意外原因而失败`，你可以通过使用 `git lfs pull` 命令来下载当前提交的所有丢失的 git-lfs 内容

#### 加快拉取速度

如果你知道自上次拉取以来已经更改了大量文件

不妨显式使用 git lfs pull 命令来批量下载 git-lfs 内容，而禁用在检出期间自动下载 git-lfs

```bash
$ git -c filter.lfs.smudge= -c filter.lfs.required=false pull
$ git lfs pull
```

由于输入的内容很多，你可能希望创建一个简单的 git 别名来为你执行批处理的 git 和 git lfs 拉取

```bash
# 设置别名 git lfsp
# git lfsp
git config --global alias.lfsp "lfs pull"

# git lfspc
git config --global alias.lfspc "-c filter.lfs.smudge= -c filter.lfs.required=false pull"

# 使用
$ git lfsp
```

### 获取

```bash
$ git lfs fetch
```

### 推送 lfs

```bash
$ git lfs push origin main
```

### 在托管源之间移动 git-lfs 仓库

要将 git-lfs 仓库从一个托管提供者迁移到另一个托管提供者序，你可以结合使用指定了 `-all` 选项的 `git lfs fetch` 和 `git lfs push` 命令

例如，要将所有 git 和 git-lfs 仓库从名为 github 的远端移动到名为 bitbucket 的远端

```bash
# create a bare clone of the gitHub repository
$ git clone --bare git@github.com:sinlov/sinlov.git
$ cd sinlov

# set up named remotes for bitbucket and gitHub
$ git remote add bitbucket git@bitbucket.org:sinlov/sinlov.git
$ git remote add github git@github.com:sinlov/sinlov.git

# fetch all git-lfs content from gitHub
$ git lfs fetch --all github

# push all git and git-lfs content to bitbucket
$ git push --mirror bitbucket
$ git lfs push --all bitbucket
```

### 获取额外的 git-lfs 历史记录

git-lfs 通常仅下载你实际在本地检出的提交所需的文件

但是，你可以使用 `git lfs fetch --recent` 命令强制 git-lfs 为其他最近修改的分支下载额外的内容

![9f67ddf6d82442e239ec7ba18154a998-LCorwW](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/9f67ddf6d82442e239ec7ba18154a998-LCorwW.png)

这个在多个 branch 比对时，进行合并前，可以做到预热拉取的作用

git-lfs 会包含最近提交超过 7 天的提交的任何分支或标签

可以通过设置 `lfs.fetchrecentrefsdays` 属性来配置被视为最近的天数

```bash
# download git-lfs content for branches or tags updated in the last 10 days
$ git config lfs.fetchrecentrefsdays 10
```

将 git-lfs 配置为在最近的分支和标签上下载更早提交的内容，这个默认值为 3

```bash
$ git config lfs.fetchrecentcommitsdays 3
```

注意：如果分支移动很快，则可能会导致下载大量数据

但是，如果你需要查看分支上的插页式更改，跨分支的 cherry-pick 提交或重写历史记录

![1d684fe2b6b37c8a05e10dafa51ea467-TY8ZHD](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/1d684fe2b6b37c8a05e10dafa51ea467-TY8ZHD.png)

### 删除本地 git-lfs 文件

使用 `git lfs prune` 命令从本地 git-lfs 缓存中删除文件

```bash
$ git lfs prune
✔ 10 local objects, 312 retained
Pruning 2 files, (1.1 MB)
✔ Deleted 2 files
```

作为附加的安全检查，你可以使用 `--verify-remote` 选项在删除之前，检查远程 git-lfs 存储区是否具有你的 git-lfs 对象的副本

```bash
$ git lfs prune --verify-remote
prune: 13 local objects, 9 retained, 5 verified with remote, done.
prune: Deleting objects: 100% (5/5), done.
```

修剪过程明显变慢，但是你可以从服务器上恢复所有修剪的对象，从而使你高枕无忧

你可以通过全局配置 `lfs.pruneverifyremotealways` 属性为系统永久启用 --verify-remote 选项

```bash
$ git config --global lfs.pruneverifyremotealways true
```

#### 删除规则

这将删除所有被认为是旧的本地 git-lfs 文件。 旧文件是以下未被引用的任何文件

- 当前检出的提交
- 尚未推送 `origin`，为设置任何 `lfs.pruneremotetocheck` 的提交
- 最近一次提交

> 默认情况下，最近的提交是最近十天内创建的任何提交

![de6024aa60bcaed3a39d22b17522a553-QowCxf](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/de6024aa60bcaed3a39d22b17522a553-QowCxf.png)

你可以配置 prune 偏移量以将 git-lfs 内容保留更长的时间

```bash
# don't prune commits younger than four weeks (7 + 21)
$ git config lfs.pruneoffsetdays 21
```

与 `git 的内置垃圾收集不同`，git-lfs 内容不会自动修剪

因此，定期运行 `git lfs prune` 命令是保持本地仓库大小减小的好主意

使用 `git lfs prune --verbose --dry-run` 命令精确查看哪些 git-lfs 对象将被修剪

```bash
$ git lfs prune --dry-run --verbose
prune: 13 local objects, 9 retained, done.
prune: 5 files would be pruned (18 KB)
 * 42d0956100367163188d3d630fd04894909be511433b5d8b19b6ebe8c9b17e53 (3.5 KB)
 * 4be985bf74133935d4f19fc59f9e7f3b148098a0b2f69aeadc1f973f95ae7ddb (3.5 KB)
 * 1f627791bf9f6eb72f40bad3f3dcb77618788342ce27b382df2de4979a16ef33 (3.5 KB)
 * 105a33227836aa3c548e4dfc3c6a221279e871defd155a6fcbb30049e4916e6f (3.5 KB)
 * f75eadad74cd15c9f0ab81456ee1a1c3a99d18cee469a0e07b33d5e042f3e5b6 (3.5 KB)
 * f75eadad74cd15c9f0ab81456ee1a1c3a99d18cee469a0e07b33d5e042f3e5b6 (3.5 KB), done.
```

`--verbose` 模式输出的长十六进制字符串是要修剪的 git-lfs 对象的 SHA-256 哈希 被称为 ID 或者 OID，[查看这些文件对象信息](#查找引用-git-lfs-对象的路径或提交)

### 从服务器删除远端 git-lfs 文件

git-lfs 命令行客户端不支持删除服务器上的文件，因此如何删除他们取决于你的托管服务提供商

比如 gitea 提供的 lfs 删除在仓库设置

![a486ac73cb34bc383682beba109e982e-G5RePO](https://cdn.jsdelivr.net/gh/tailwoodencat/CDN@main/uPic/2023/04/16/a486ac73cb34bc383682beba109e982e-G5RePO.png)

### 查找引用 git-lfs 对象的路径或提交

如果你有一个 git-lfs SHA-256 OID，你可以使用 `git log --all -p -S` 命令确定哪些提交引用了它

```bash
$ git log --all -p -S [OID]
```

如果你怀疑特定的 git-lfs 对象位于当前的 HEAD 或特定的分支中，则可以使用 `git grep` 查找引用它的文件路径

```bash
# find a particular object by OID in HEAD
$ git grep [OID] HEAD
#  find a particular object by OID on the "dev" branch
$ git grep [OID] dev
```

### 包含/排除 git-lfs 文件

在某些情况下，你可能指向为特定提交下载可用的 git-lfs 内容的子集

> 例如，在配置 CI 构建以运行单元测试时，你可能只需要源代码，因此可能要排除构建代码不需要的重量级文件

你可以使用 `git lfs fetch -X`（或 `--exclude` ）排除模式或子目录

```bash
$ git lfs fetch -X "Assets/**"
```

或者，你可能只想包含特定的模式或子目录

```bash
# 音频工程师仅获取 ogg 和 wav 文件
$ git lfs fetch -I "*.ogg,*.wav"
```

将 `包含和排除合并在一起使用`，则`只会获取与包含模式匹配`，但包含排除模式不匹配的文件

```bash
$ git lfs fetch -I "Assets/**" -X "*.gif"
```

排除和包含支持与 `git lfs track` 和 `.gitignore` 相同的模式

可以通过设置 `lfs.fetchinclude` 和 `lfs.fetchexclude` 配置属性，使这些模式对于特定仓库来说永久生效

```bash
$ git config lfs.fetchinclude "Assets/**"
$ git config lfs.fetchexclude "*.gif"
```

### 锁定 git-lfs 文件

官方文档 [https://github.com/git-lfs/git-lfs/wiki/File-Locking](https://github.com/git-lfs/git-lfs/wiki/File-Locking)

> tips: 不幸的是，`没有解决二进制合并冲突的简便方法`，请一定仔细阅读并测试后使用 lock 功能

使用 git-lfs 文件锁定，你可以`按扩展名或文件名锁定文件，并防止二进制文件在合并期间被覆盖`

用 LFS 的文件锁定功能，你首先需要告诉 git 哪些类型的文件是可锁定的

在 `git lfs track` 命令后附加了 `--lockable` 标志 既将文件存储在 lfs 中，又将它们标记为可锁定

```bash
$ git lfs track "*.psd" --lockable
```

会将以下内容添加到 .gitattributes 文件中

```bash
*.psd filter=lfs diff=lfs merge=lfs -text lockable
```

在准备对 lfs 文件进行更改时，你将使用 lock 命令以便将文件在 Git 服务器上注册为锁定的文件

```bash
$ git lfs lock docs/foo.psd
Locked docs/foo.psd
```

一旦不再需要文件锁定，你可以使用 git-lfs 的 `unlock` 命令将其移除

```bash
$ git lfs unlock docs/foo.psd
```

与 git push 类似，可以使用 `--force` 标志覆盖 git-lfs 文件锁

```bash
$ git lfs unlock docs/foo.psd --force
```