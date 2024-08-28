---
title: "drone feishu notify plugin"
date: 2022-11-07T11:09:51+08:00
description: "drone feishu notify 飞书群组机器人通知"
draft: false
categories: ['CI']
tags: ['CI', 'basics', 'drone']
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

## 使用前需飞书设置-特定群组自动推送消息

- 在`群/话题`中，新建 `群机器人`
- 点击，`群管理`
- 新建一个 `自定义机器人` 类机器人, [自定义机器人指南](https://open.feishu.cn/document/ukTMukTMukTM/ucTM5YjL3ETO24yNxkjN)
  - `机器人名称` 改为  `ns-drone:{url}` ，其中 `{url}` 改为 drone 地址便于管理，`ns-drone` 为 notifications message drone 简写，当然也可以自定义不影响效果
  - `描述` 改为通过 webhook 推送 `https://{url}` 构建通知
  -  确认后，会产生一个 webhook 地址，格式为 `https://open.feishu.cn/open-apis/bot/v2/hook/{webhook}`记录下来
  -  添加  `自定义关键词`: 比如 Drone CI Notification 作为通知 title
  -  勾选 `仅群主和添加者可编辑、移除此机器人`
  -  勾选 `签名校验` 可选 如果设置见文档 [方式三：签名校验](https://open.feishu.cn/document/ukTMukTMukTM/ucTM5YjL3ETO24yNxkjN#348211be)，后面会用到这个密钥

## drone 话题/群组 机器人插件

### 配置方法

对目标工程或者群组设置 secret [配置官方文档](https://docs.drone.io/secret/)

- `feishu_group_bot_token` 为上文 webhook 地址 {webhook} 部分
- `feishu_group_secret_bot` 开启 `签名校验` 会给的校验 key
- `自定义关键词` 可配置在 `feishu_msg_title` 中，作为筛选或者防打扰部分

- docker 的 runner 节点建议先执行拉取镜像

```bash
$ docker pull sinlov/drone-feishu-group-robot:1.7.0-alpine
```

- exec 的 runner 节点需要
	- 在 [https://github.com/sinlov/drone-feishu-group-robot/release](https://github.com/sinlov/drone-feishu-group-robot/releases)下载对应平台的二进制执行文件
	- 在 runner 的环境变量中配置好 `EXEC_DRONE_FEISHU_GROUP_ROBOT_FULL_PATH` 环境变量，作为runner的执行入口

- 更多配置见 [sinlov/drone-feishu-group-robot](https://github.com/sinlov/drone-feishu-group-robot)

### 通知模板 docker:failure

- 最常见配置在最末位的 step，目的是通知构建失败

```yaml
type: docker
steps:
  - name: notification-feishu-group-robot
    image: sinlov/drone-feishu-group-robot:1.7.0-alpine
    pull: if-not-exists
    # image: sinlov/drone-feishu-group-robot:latest
    settings:
      # debug: true # plugin debug switch
      # ntp_target: "pool.ntp.org" # if not set will not sync ntp time
      feishu_webhook:
        from_secret: feishu_group_bot_token
      feishu_secret:
        from_secret: feishu_group_secret_bot
      feishu_msg_title: "Drone CI Notification" # default [Drone CI Notification]
      # let notification card change more info see https://open.feishu.cn/document/ukTMukTMukTM/uAjNwUjLwYDM14CM2ATN
      feishu_enable_forward: true
    when:
      status: # only support failure/success,  both open will send anything
        - failure
        # - success
```

### 通知模板 exec:failure

- 最常见配置在最末位的 step，目的是通知构建失败

```yaml
type: exec
steps:
  - name: notify-failure-feishu-group-robot-exec
    # # must has runner-exec env:EXEC_DRONE_FEISHU_GROUP_ROBOT_FULL_PATH then exec tools
    environment:
      # PLUGIN_DEBUG: true # plugin debug switch
      PLUGIN_TIMEOUT_SECOND: 10 # default 10
      PLUGIN_FEISHU_WEBHOOK:
        from_secret: feishu_group_bot_token
      PLUGIN_FEISHU_SECRET:
        from_secret: feishu_group_secret_bot
      # let notification card change more info see https://open.feishu.cn/document/ukTMukTMukTM/uAjNwUjLwYDM14CM2ATN
      PLUGIN_FEISHU_MSG_TITLE: "Drone CI Notification" # default [Drone CI Notification]
      PLUGIN_FEISHU_ENABLE_FORWARD: true
    commands:
      # - chcp 65001 # change encoding to utf-8 at powershell
      - ${EXEC_DRONE_FEISHU_GROUP_ROBOT_FULL_PATH} `
        ""
    when:
      status: # only support failure/success,  both open will send anything
        - failure
        # - success
```

### 通知失败 19021

- 原因1: 签名不匹配，校验不通过，请检查配置
- 原因2:  时间戳距发送时已超过 1 小时，签名已过期
	- 在 docker runner 中，配置 `ntp_target` 指定时间同步服务器，来尝试同步时间修复
	- 在 exec runner 中需要手动做时间同步





