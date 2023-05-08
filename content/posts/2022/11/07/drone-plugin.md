---
title: "drone 插件收集"
date: 2022-11-07T11:11:28+08:00
description: "drone 插件收集"
draft: true
categories: ['basics']
tags: ['basics', 'drone']
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

## 插件地址

- [https://plugins.drone.io/](https://plugins.drone.io/)

## notifications

### drone-email

- [https://github.com/Drillster/drone-email](https://github.com/Drillster/drone-email)
- mail sending

```yml
  - name: notify-docker-email # https://plugins.drone.io/plugins/email
    # https://github.com/Drillster/drone-email
    image: drillster/drone-email # https://hub.docker.com/r/drillster/drone-email
    pull: if-not-exists
#     depends_on: [deploy]
    environment: # must drone orgsecret add keys
      PLUGIN_FROM_ADDRESS:
        from_secret: email_from_address
      PLUGIN_FROM_NAME:
        from_secret: email_from_name
      PLUGIN_HOST:
        from_secret: email_smtp_host
      PLUGIN_PORT:
        from_secret: email_smtp_port
      PLUGIN_USERNAME:
        from_secret: email_smtp_user_name
      PLUGIN_PASSWORD:
        from_secret: email_smtp_password
    settings: # https://github.com/Drillster/drone-email/blob/master/DOCS.md
      recipients: #  List of recipients to send this mail to (besides the commit author)
        - ci-robot@mail.com
    when:
      event: # https://docs.drone.io/pipeline/exec/syntax/conditions/#by-event
        - promote
        - rollback
        - push
        - pull_request
        - tag
      status: # only support failure/success,  both open will send anything
        - failure
        # - success
```

### Wechat Plugin

- [https://github.com/lizheming/drone-wechat](https://github.com/lizheming/drone-wechat)
- [https://plugins.drone.io/plugins/wechat](https://plugins.drone.io/plugins/wechat)
- 微信通知

```yml
kind: pipeline
name: default

steps:
- name: wechat # https://plugins.drone.io/plugins/wechat
  image: lizheming/drone-wechat # https://hub.docker.com/r/lizheming/drone-wechat
  settings: # https://github.com/lizheming/drone-wechat#drone-wechat
    corpid:
      from_secret: wechat_corpid
    corp_secret:
      from_secret: wechat_corp_secret
    agent_id:
      from_secret: agent_id
    to_user: 111
    to_party: 112
    to_tag: ${DRONE_REPO_NAME}
    msg_url: ${DRONE_BUILD_LINK}
    safe: 1
    btn_txt: more
    title: ${DRONE_REPO_NAME}
    message: >
      {%if success %}
        build {{build.number}} succeeded. Good job.
      {% else %}
        build {{build.number}} failed. Fix me please.
      {% endif %}
```

### DingTalk Message Plugin

- [https://github.com/lddsb/drone-dingtalk-message](https://github.com/lddsb/drone-dingtalk-message)
- 钉钉群组机器人通知

```yml
kind: pipeline
name: default

steps:
  - name: dingtalk-push # https://plugins.drone.io/plugins/dingtalk-message
    image: lddsb/drone-dingtalk-message # https://hub.docker.com/r/lddsb/drone-dingtalk-message
	  pull: if-not-exists
#     depends_on: [deploy]
    settings: # https://github.com/lddsb/drone-dingtalk-message#drone-ci-dingtalk-message-plugin
      token: xxxxxxxxxxxxxxxxxxxxxxxxxxx
      type: markdown
      message_pic: true
      sha_link: true
    when:
      event: # https://docs.drone.io/pipeline/exec/syntax/conditions/#by-event
        - promote
        - rollback
        - push
        - pull_request
        - tag
      status: # only support failure/success,  both open will send anything
        - failure
        - success
```

### 飞书群组通知

- [https://github.com/sinlov/drone-feishu-group-robot](https://github.com/sinlov/drone-feishu-group-robot)

- 简单配置

```yaml
steps:
  - name: notification-feishu-group-robot
    # depends_on: # https://docs.drone.io/pipeline/exec/syntax/parallelism/
    #   - dist-release
    image: sinlov/drone-feishu-group-robot:1.5.0-alpine
    pull: if-not-exists
    settings:
      # debug: true # plugin debug switch
	  # ntp_target: "pool.ntp.org" # if not set will not sync ntp time
      feishu_webhook:
        # https://docs.drone.io/pipeline/environment/syntax/#from-secrets
        from_secret: feishu_group_bot_token
      feishu_secret:
        from_secret: feishu_group_secret_bot
      feishu_msg_title: "Drone CI Notification" # default [Drone CI Notification]
      # let notification card change more info see https://open.feishu.cn/document/ukTMukTMukTM/uAjNwUjLwYDM14CM2ATN
      feishu_enable_forward: true
    when:
      event: # https://docs.drone.io/pipeline/exec/syntax/conditions/#by-event
        - promote
        - rollback
        - push
        - pull_request
        - tag
      status: # only support failure/success,  both open will send anything
        - failure
        - success
```

- 完整配置

```yaml
steps:
  - name: notification-feishu-group-robot
    image: sinlov/drone-feishu-group-robot:1.3.1-alpine
    pull: if-not-exists
    settings:
      debug: false
      # ntp_target: "pool.ntp.org" # if not set will not sync ntp time
      timeout_second: 10 # default 10
      feishu_webhook:
        # https://docs.drone.io/pipeline/environment/syntax/#from-secrets
        from_secret: feishu_group_bot_token
      feishu_secret:
        from_secret: feishu_group_secret_bot
      # let notification card change more info see https://open.feishu.cn/document/ukTMukTMukTM/uAjNwUjLwYDM14CM2ATN
      feishu_msg_title: "Drone CI Notification" # default [Drone CI Notification]
      feishu_enable_forward: true
      feishu_oss_host: "https://xxx.com" # OSS host for show oss info, if empty will not show oss info
      feishu_oss_info_send_result: ${DRONE_BUILD_STATUS} # append oss info must set success
      feishu_oss_info_user: "admin" # OSS user for show at card
      feishu_oss_info_path: "dist/foo/bar" # OSS path for show at card
      feishu_oss_resource_url: "https://xxx.com/s/xxx" # OSS resource url
      feishu_oss_page_url: "https://xxx.com/p/xxx" # OSS page url
      feishu_oss_page_passwd: "abc_xyz" # OSS password at page url, will hide PLUGIN_FEISHU_OSS_RESOURCE_URL when PAGE_PASSWD not empty
    when:
      event: # https://docs.drone.io/pipeline/exec/syntax/conditions/#by-event
        - promote
        - rollback
        - push
        - pull_request
        - tag
      status: # only support failure/success,  both open will send anything
        - failure
        - success
```
