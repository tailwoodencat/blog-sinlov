---
title: "drone-runner 配置"
date: 2022-10-22T14:58:00+00:00
description: "drone-runner 配置"
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

## attention 注意

### steps ENV

- env `DRONE_WORKSPACE`
	- pipeline/environment/reference/drone-workspace/ [offical doc](https://docs.drone.io/pipeline/environment/reference/drone-workspace/)
	  - with `empty` on mode  `type: docker`
	  - with `path of runner temp folder` on mode `type: exec`, and will remove after build

### .drone.yml 文件中 `when ref`

use [https://docs.drone.io/pipeline/docker/syntax/conditions/](https://docs.drone.io/pipeline/docker/syntax/conditions/)

- glob style [https://en.wikipedia.org/wiki/Glob_(programming)](https://en.wikipedia.org/wiki/Glob_(programming))

## docker-runner

### docker-runner on linux

- env file

```env
ENV_DRONE_RUNNER_NAME=""
ENV_DRONE_RPC_PROTO="http"
ENV_DRONE_RPC_HOST=""
ENV_DRONE_RPC_SECRET=""
ENV_DRONE_UI_DISABLE="false"
ENV_DRONE_UI_USERNAME=""
ENV_DRONE_UI_PASSWORD=""
ENV_DRONE_RUNNER_CAPACITY="2"
```

- [https://docs.drone.io/runner/docker/installation/linux/](https://docs.drone.io/runner/docker/installation/linux/)

```yml
  drone-runner: # https://hub.docker.com/r/drone/drone-runner-docker
    container_name: "drone-runner"
    image: 'drone/drone-runner-docker:1.8.2' # https://hub.docker.com/r/drone/drone-runner-docker/tags
    # https://docs.docker.com/compose/compose-file/#env_file
    env_file: .env
    environment: # https://docs.drone.io/runner/docker/installation/linux
      - TZ=Asia/Shanghai
      # - DRONE_DEBUG=true
      # - DRONE_TRACE=true
      # #  Enables the new logging lifecycle to help prevent log truncation. Available in v.1.8.1
      # - DRONE_DEFER_TAIL_LOG=true
      # - DRONE_RUNNER_LABELS=foo:bar,baz:qux
      - DRONE_RUNNER_LABELS=docker_os:linux,docker_arch:amd64
      # - DRONE_LIMIT_REPOS=octocat/hello-world,spaceghost/*
      # - DRONE_LIMIT_EVENTS=push,tag
      # # https://docs.drone.io/runner/docker/configuration/reference/drone-runner-volumes/
      # - DRONE_RUNNER_VOLUMES=/path/on/host:/path/in/container
      # # https://docs.drone.io/runner/docker/configuration/reference/drone-runner-privileged-images/
      # - DRONE_RUNNER_PRIVILEGED_IMAGES
      - DRONE_RPC_PROTO=${ENV_DRONE_RPC_PROTO}
      - DRONE_RPC_HOST=${ENV_DRONE_RPC_HOST}
      - DRONE_RPC_SECRET=${ENV_DRONE_RPC_SECRET}
      - DRONE_RUNNER_NAME=${ENV_DRONE_RUNNER_NAME}
      # - DRONE_CPU_PERIOD=100000
      # - DRONE_CPU_QUOTA=100
      # - DRONE_CPU_SET=1,3
      # - DRONE_CPU_SHARES=1024
      # - DRONE_MEMORY_LIMIT=500000000
      # - DRONE_MEMORY_SWAP_LIMIT=500000000
      - DRONE_RUNNER_CAPACITY=${ENV_DRONE_RUNNER_CAPACITY}
      # - DRONE_RUNNER_NETWORKS=networkA,networkB
      # https://docs.drone.io/runner/docker/configuration/reference/drone-ui-disable/
      - DRONE_UI_DISABLE=${ENV_DRONE_UI_DISABLE}
      - DRONE_UI_USERNAME=${ENV_DRONE_UI_USERNAME}
      - DRONE_UI_PASSWORD=${ENV_DRONE_UI_PASSWORD}
      # - DRONE_REGISTRY_PLUGIN_ENDPOINT=http://1.2.3.4:3000
      # - DRONE_REGISTRY_PLUGIN_SKIP_VERIFY=false
      # - DRONE_REGISTRY_PLUGIN_TOKEN=
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
    ports:
      - "43000:3000" # http://127.0.0.1:43000/
    restart: always # on-failure:3 or unless-stopped default "no"
```

### drone-runner error docker.sock

```bash
level=error msg="cannot ping the docker daemon" error="Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?"
```
not set volumes
```yml
drone-runner:
    container_name: "drone-runner"
    image: 'drone/drone-runner-docker:1.6.2'
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
```

### 自定义 docker-register

- 使用插件 `plugins/docker`

```yaml
steps:
- name: docker
  image: plugins/docker
  settings:
    username: kevinbacon
    password: pa55word
    repo: index.company.com/foo/bar
    registry: index.company.com
```

> more use see [http://plugins.drone.io/drone-plugins/drone-docker/](http://plugins.drone.io/drone-plugins/drone-docker/)


### docker cache auto clean

- install `tmpreaper` (Debian or ubuntu) or `tmpwatch` then add cron task

```bash
# need sudo
export EDITOR=vim && sudo crontab -e
````

- Debian or ubuntu add

```cron
# drone dist test auto clean
0 1 * * * /usr/sbin/tmpreaper 3d /tmp/cache/dist/test
```

- others add

```cron
# drone dist test auto clean
0 1 * * * /usr/sbin/tmpwatch 3d /tmp/cache/dist/test
```

- then take effect

```bash
$ sudo systemctl restart cron.service
$ sudo systemctl status cron.service
```

## exec-runner

- document [https://docs.drone.io/runner/exec/overview/](https://docs.drone.io/runner/exec/overview/)

- exec reference [https://docs.drone.io/runner/exec/configuration/reference/](https://docs.drone.io/runner/exec/configuration/reference/)

### drone-exec On Windows

- document [https://docs.drone.io/runner/exec/installation/windows/](https://docs.drone.io/runner/exec/installation/windows/)

#### first error

```
+ CategoryInfo : SecurityError: (:) []，PSSecurityException
+ FullyQualifiedErrorId : UnauthorizedAccess
```

首次在计算机上启动 Windows PowerShell 时，现用执行策略很可能是 `Restricted（默认设置）`
获取当前策略

```ps1
Get-Executionpolicy
# 获取设置帮助
Get-Help Set-ExecutionPolicy
```

- `Restricted` 策略不允许任何脚本运行
- `RemoteSigned` 允许运行您编写的未签名脚本和来自其他用户的签名脚本

```ps1
# 改变策略，运行按需运行
Set-ExecutionPolicy Bypass -Scope Process
```

最终效果为

```ps1
➜ Get-ExecutionPolicy -List

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process          Bypass
  CurrentUser          Bypass
 LocalMachine          Bypass
```

- fix

#### install exec for windows

- download lastest [drone_runner_exec_windows_amd64.tar.gz](https://github.com/drone-runners/drone-runner-exec/releases/latest/download/drone_runner_exec_windows_amd64.tar.gz)
- unzip download file and let `drone-runner-exec.exe` to `C:\Windows` (need administrator)

- then new `cmd` or `powershell` show help

```bash
drone-runner-exec.exe --help
```

#### config for windows

run `cmd`

```bash
$ mkdir C:\Drone\drone-runner-exec
$ cd mkdir C:\Drone\drone-runner-exec
# new file by vscode, you can use other editor
$ code C:\Drone\drone-runner-exec\config
```

- in `C:\Drone\drone-runner-exec\config`

```cfg
# DRONE_RUNNER_ENVFILE=C:\Drone\drone-runner-exec\file.env
# DRONE_RUNNER_LABELS=goos:windows,goarch:amd64
#DRONE_RUNNER_NAME=this-pc-name
# https://docs.drone.io/runner/exec/configuration/reference/drone-runner-root/
DRONE_RUNNER_MAX_PROCS=10
DRONE_RUNNER_ROOT=C:\Drone\ws
# https://docs.drone.io/runner/exec/configuration/reference/drone-http-bind/

DRONE_HTTP_BIND=:3000
# https://docs.drone.io/runner/exec/configuration/reference/drone-http-host/
# DRONE_HTTP_HOST=runner.company.com:3000
DRONE_RPC_PROTO=https
DRONE_RPC_HOST=drone.company.com
DRONE_RPC_SECRET=super-duper-secret

DRONE_LOG_FILE=C:\Drone\drone-runner-exec\log.txt
DRONE_LOG_FILE_MAX_SIZE=10
DRONE_LOG_FILE_MAX_AGE=30
DRONE_LOG_FILE_MAX_BACKUPS=7
DRONE_DEBUG=false
DRONE_TRACE=false
```

- `DRONE_RUNNER_ENVFILE` [runner env file](https://docs.drone.io/runner/exec/configuration/reference/drone-runner-envfile/)
- `DRONE_RUNNER_LABELS` [runner labels](https://docs.drone.io/runner/exec/configuration/reference/drone-runner-labels/)
- `DRONE_RUNNER_MAX_PROCS` [runner max procs](https://docs.drone.io/runner/exec/configuration/reference/drone-runner-max-procs/)  Limits the number of concurrent steps that a runner can execute for a single pipeline
- `DRONE_RUNNER_ROOT` [root build path](https://docs.drone.io/runner/exec/configuration/reference/drone-runner-root/), if in windows is `$env:SystemDrive\WINDOWS\TEMP`
- `DRONE_RUNNER_NAME` Sets the name of the runner. The runner name is stored in the server and can be used to trace a build back to a specific runner
- `DRONE_RPC_PROTO` provides the protocol used to connect to your Drone server. The value must be either http or https.
- `DRONE_RPC_HOST` provides the hostname (and optional port) of your Drone server
- `DRONE_RPC_SECRET` provides the shared secret used to authenticate with your Drone server.
- `DRONE_LOG_FILE`  log file location should be configured in the environment file before you start the service

#### Install and start the service

```bash
drone-runner-exec.exe service install --config [file] --desc [name]
drone-runner-exec.exe service uninstall --config [file] --desc [name]

# run as service
drone-runner-exec.exe service start --config [file]
drone-runner-exec.exe service stop --config [file]
```

- error

```bash
❯ drone-runner-exec.exe service install
read configuration C:\Drone\drone-runner-exec\config
installing service drone-runner-exec
drone-runner-exec.exe: error: Access is denied., try --help
```

must use `administrator` to run this

#### 让 drone-runner-exec 开机启动

> tips: 以下脚本都需要 管理员权限运行
> 服务被命名为 `drone-runner-exec-gitea` 请根据实际情况改动

- at path `C:\Drone\drone-runner-exec`，新建文件  `install-drone.bat`，内容为

```bat
@echo off
echo "%~dp0drone-runner-exec.exe"

%~dp0drone-runner-exec.exe service install --config %~dp0config --name "drone-runner-exec-gitea" --desc "Drone Exec Runner gitea"

pause
```

- 相应的 卸载服务 的脚本 `uninstall-drone.bat`

```bat
@echo off
echo "%~dp0\drone-runner-exec.exe"

%~dp0\drone-runner-exec.exe service stop --config %~dp0config --name "drone-runner-exec-gitea"
%~dp0\drone-runner-exec.exe service uninstall --config %~dp0config --name "drone-runner-exec-gitea" --desc "Drone Exec Runner gitea"

pause
```

- 启动服务的脚本 `service-restart-drone.bat`

```bat
@echo off
echo "%~dp0\drone-runner-exec.exe"

%~dp0\drone-runner-exec.exe service stop --config %~dp0config --name "drone-runner-exec-gitea"
%~dp0\drone-runner-exec.exe service start --config %~dp0config --name "drone-runner-exec-gitea"

pause
```

- 停止服务的脚本 `service-stop-drone.bat`

```bat
@echo off
echo "%~dp0\drone-runner-exec.exe"

%~dp0\drone-runner-exec.exe service stop --config %~dp0config --name "drone-runner-exec-gitea

pause
```

#### error about Execution Policies


```
https:/go.microsoft.com/fwlink/?LinkID=135170 ... about_Execution_Policies ...
```

- admin run powershell

```ps1
> Get-ExecutionPolicy -List
        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser          Bypass
 LocalMachine       AllSigned
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- then `restart drone-exec runner`
