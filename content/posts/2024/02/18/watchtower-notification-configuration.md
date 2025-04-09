---
title: "watchtower notifications 配置方法"
date: 2024-02-18T13:20:12+00:00
description: "Watchtower notification configuration"
draft: false
categories: ['container']
tags: ['container', 'docker']
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

## 配置说明

- [watchtower 更新通知](https://containrrr.dev/watchtower/notifications/)
	- [shoutrrr](https://github.com/containrrr/shoutrrr) 通知，支持类型非常多
		- [Bark](https://containrrr.dev/shoutrrr/v0.8/services/bark/)
		- [Gotify](https://containrrr.dev/shoutrrr/v0.8/services/gotify/)
		- [Slack](https://containrrr.dev/shoutrrr/v0.8/services/slack/)

## Bark 通知

bark 是 iOS 平台下非常好用的个人推送服务

- [bark 使用文档](https://bark.day.app/#/?id=bark)
- 通知图标来源  [https://containrrr.dev/watchtower/images/logo-450px.png](https://containrrr.dev/watchtower/images/logo-450px.png) ，可以自行修改

- 需要准备 {host}，也就是 公开或者私人部署的 bark 服务
- 通知到的客户端 {devicekey}，bark 限制只能通知到一台设备

替换后，测试 bark 配置正确与否

```test
https://{host}/{devicekey}/?icon=https://containrrr.dev/watchtower/images/logo-450px.png&Title=Watchtower
```

- 需要替换
	- {devicekey}
	- {host}
- compose

```yaml
services:
  utils-watchtower:
    container_name: 'utils-watchtower'
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      WATCHTOWER_NOTIFICATION_REPORT: "true"
      # default log level is info. Possible values are: panic, fatal, error, warn, info, debug or trace
      WATCHTOWER_NOTIFICATIONS_LEVEL: "info"
      WATCHTOWER_NOTIFICATION_URL: "bark://:{devicekey}@{host}/?icon=https://containrrr.dev/watchtower/images/logo-450px.png&Title=Watchtower"
      WATCHTOWER_NOTIFICATION_TEMPLATE: |
        {{- if .Report -}}
          {{- with .Report -}}
        {{len .Scanned}} Scanned, {{len .Updated}} Updated, {{len .Failed}} Failed
              {{- range .Updated}}
        - {{.Name}} ({{.ImageName}}): {{.CurrentImageID.ShortID}} updated to {{.LatestImageID.ShortID}}
              {{- end -}}
              {{- range .Fresh}}
        - {{.Name}} ({{.ImageName}}): {{.State}}
            {{- end -}}
            {{- range .Skipped}}
        - {{.Name}} ({{.ImageName}}): {{.State}}: {{.Error}}
            {{- end -}}
            {{- range .Failed}}
        - {{.Name}} ({{.ImageName}}): {{.State}}: {{.Error}}
            {{- end -}}
          {{- end -}}
        {{- else -}}
          {{range .Entries -}}{{.Message}}{{"\n"}}{{- end -}}
        {{- end -}}
```

配置后成功后，马上会收到告知 容器更新的策略信息