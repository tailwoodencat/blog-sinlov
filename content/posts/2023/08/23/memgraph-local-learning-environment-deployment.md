---
title: "memgraph 本地学习环境部署"
date: 2023-08-23T17:43:54+08:00
description: "介绍 图数据库 memgraph  本地学习环境部署"
draft: false
categories: ['database']
tags: ['database', 'graph-database', 'memgraph']
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

开源 图数据库，专为 实时流数据构建，兼容 [Neo4j](https://neo4j.com/)

使用授权是 the Business Source License 1.1 (BSL)

- 官方地址 [https://memgraph.com/](https://memgraph.com/)
- 源码地址 [https://github.com/memgraph/memgraph](https://github.com/memgraph/memgraph)

> 企业版是 额外提供权限管理功能，详细见官网

## 特性介绍

- Graph DBMS 数据模型
- 支持 多种数据源导入导出 [memgraph/import-data](https://memgraph.com/docs/memgraph/import-data)
- 支持强一致性ACID事务 [https://memgraph.com/blog/acid-transactions-meaning-of-isolation-levels](https://memgraph.com/blog/acid-transactions-meaning-of-isolation-levels)
- 兼容 Neo4j [migrate-from-neo4j](https://memgraph.com/docs/memgraph/tutorials/migrate-from-neo4j)
- 支持 迁移 PostgreSQL 或者 MySQL 数据 [migrate/postgresql](https://memgraph.com/docs/memgraph/import-data/migrate/postgresql)
- 多种编程语言 客户端接入 [connect-to-memgraph/drivers](https://memgraph.com/docs/memgraph/connect-to-memgraph/drivers)

注意:

> memgraph 3.0 版本前，Memgraph不支持跨多个物理位置运行和存储数据
> Memgraph 3.0 将启用水平扩容。查看计划 [Memgraph 3.0 on GitHub](https://github.com/orgs/memgraph/projects/5)

- 由于 图数据库 是作为 数据仓库 部分，图数据库本身数据很大，一般用于热点数据的计算，不少大厂使用 分布式 k-v 库来计算图数据，所以不太需要长期持久化，所以分布式存储数据的需求不太强烈
  - 更多的情况，是动态的启动复数图数据库，挂到内存中，作为高速访问的服务
  - 多点部署后，对应带来的分布式一致性问题，Global ACID 问题需要解决，这些需要提前做好预案

## 2.0 版本

- 运行 Memgraph 的 Docker容器架构

![](https://memgraph.com/docs/assets/images/docker-architecture-3ab689d5267b25c3a9ddbed45b08cfcf.png)


使用三个Docker映像来运行Memgraph

- [memgraph-platform](https://hub.docker.com/r/memgraph/memgraph-platform) - installs the whole Memgraph Platform, which includes
	- MemgraphDB: the graph database
	- mgconsole: a command-line interface for running queries
	- Memgraph Lab: 用于运行查询和可视化图形数据的可视化用户交互界面
	- MAGE: 图形算法和自定义Cypher程序的开源库

- [memgraph-mage](https://hub.docker.com/r/memgraph/memgraph-mage) - installs `MemgraphDB`, `mgconsole` and `MAGE`
- [memgraph](https://hub.docker.com/r/memgraph/memgraph) - installs `MemgraphDB` and `mgconsole`

### docker 部署前准备

- memgraph 镜像都很大，需要提前获取

```bash
$ docker pull memgraph/memgraph-platform:2.10.0-memgraph2.10.0-lab2.8.0-mage1.9
$ docker pull memgraph/memgraph-mage:1.9-memgraph-2.10.0
# optional
$ docker pull memgraph/memgraph:2.10.0
```

- [https://memgraph.com/docs/memgraph/how-to-guides/work-with-docker](https://memgraph.com/docs/memgraph/how-to-guides/work-with-docker)

- config [https://memgraph.com/docs/memgraph/reference-guide/configuration](https://memgraph.com/docs/memgraph/reference-guide/configuration)

  - `--log-level=WARNING` Allowed values: TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL
  - `--memory-limit=0` Total memory limit in MiB. Set to 0 to use the default values which are 100% of the physical memory if the swap is enabled and 90% of the physical memory otherwise.

#### docker-compose 模式部署

- 创建文件夹 `memgraph-docker`, 进入这个文件夹

- 创建文件 file `.env` 内容为

```env
# 用户名称
ENV_MEMGRAPH_MAGE_USER="foo"
# 这里使用 `openssl rand -hex 16` 来初始化一个密码
ENV_MEMGRAPH_MAGE_PWD=""
```

- 编写配置 `docker-compose.yml` 文件

```yml
# copy right by 2023 sinlovgmpp@gmail.com
# license under MIT
# more info see https://docs.docker.com/compose/compose-file/
version: '3.8' # https://docs.docker.com/compose/compose-file/compose-versioning/
services:
  memgraph-platform: # https://hub.docker.com/r/memgraph/memgraph-platform
    container_name: "memgraph-platform"
    image: memgraph/memgraph-platform:2.10.0-memgraph2.10.0-lab2.8.0-mage1.9 # https://hub.docker.com/r/memgraph/memgraph-platform/tags
    ports:
      - 13000:3000 # connection to the Memgraph Lab application when running Memgraph Platform
    volumes:
      # bind mounts to transfer durability files such as snapshot or wal files inside the container to restore data, or CSV files
      - './data/memgraph-platform/data:/usr/lib/memgraph/data'
      #  directory containing log files
      - './data/memgraph-platform/log/memgraph:/var/log/memgraph'
      # directory containing data, enables data persistency
      - './data/memgraph-platform/lib/memgraph:/var/lib/memgraph'
      # directory containing the configuration file
      # The configuration file can usually be found at /etc/memgraph/_data/memgraph.conf
      # - './data/memgraph-platform/etc/memgraph:/etc/memgraph'
    environment:
      # set the log level to WARNING Allowed values: TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL
      # memory limit in MiB
      MEMGRAPH: --memory-limit=50 --log-level=TRACE
    restart: always # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: "json-file"
      options:
        max-size: "2m"
  memgraph-mage: # https://hub.docker.com/r/memgraph/memgraph-mage
    container_name: 'memgraph-mage'
    image: memgraph/memgraph-mage:1.9-memgraph-2.10.0 # https://hub.docker.com/r/memgraph/memgraph-mage/tags
    user: root
    env_file: .env
    ports:
      - 17444:7444 # connection to fetch log files from Memgraph Lab, version 2.+ and new
      - 17687:7687 # connection to the database instance, the Bolt protocol uses this port by default
    volumes:
      # bind mounts to transfer durability files such as snapshot or wal files inside the container to restore data, or CSV files
      - './data/memgraph-mage/data:/usr/lib/memgraph/data'
      #  directory containing log files
      - './data/memgraph-mage/log/memgraph:/var/log/memgraph'
      # directory containing data, enables data persistency
      - './data/memgraph-mage/lib/memgraph:/var/lib/memgraph'
      # directory containing the configuration file
      # The configuration file can usually be found at /etc/memgraph/_data/memgraph.conf
      # - './data/memgraph-mage/etc/memgraph:/etc/memgraph'
    environment:
      # set the log level to WARNING Allowed values: TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL
      # memory limit in MiB
      MEMGRAPH: --memory-limit=50 --log-level=WARNING
      MEMGRAPH_USER: ${ENV_MEMGRAPH_MAGE_USER}
      MEMGRAPH_PASSWORD: ${ENV_MEMGRAPH_MAGE_PWD}
    restart: on-failure:3  # always on-failure:3 or unless-stopped default "no"
    logging:
      driver: "json-file"
      options:
        max-size: "2m"
```

配置好后，目录结构为

```bash
➜ tree -L 2 -a
.
├── .env
└── docker-compose.yml
```

- 启动数据库及工具

```bash
# 启动这组服务
$ docker-compose up -d --remove-orphans
# 查看这组服务的状态
$ docker-compose ps
# 滚动运行 std 日志
$ docker-compose logs -f
# 关闭这组 app
$ docker-compose down
```

- 这里启动了 memgraph-platform 管理服务地址 http://ip:port:13000
- 点击 左侧 `New connection`  菜单，使用 `Connect Manually to Memgraph` 模式连接私有部署数据库
- memgraph-mage 数据库 连接配置
  - Host `ip`
  - Port `17687`
  - Advanced Settings:
    - Database name: `初次留空`
    - Username: `<.env file set ENV_MEMGRAPH_MAGE_USER>`
    - Password: `<.env file set ENV_MEMGRAPH_MAGE_PWD>`
    - Monitoring port: `17444`

### 使用数据库

在 memgraph lib 中已经包含了不少例子，点击左下方 `LAYOUT` 可以方便的切分视图

- `Overview` 中包含了测试服务状态的内容 比如 创建

```cypher
CREATE (c1:Country {name: 'Belgium'}),
(c2:Country {name: 'Netherlands'})
CREATE (c1)-[r:BORDERS_WITH]->(c2)
RETURN r;
```

- 合并

```cypher
MERGE (c:Country {name: 'Croatia'})
RETURN c;
```

图数据库的使用是一个单独的学习过程，这里不再赘述，本地学习环境部署到这里就完成啦
