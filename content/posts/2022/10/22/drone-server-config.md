---
title: "drone-server 配置使用"
date: 2022-10-22T11:58:00+00:00
description: "drone-server 配置使用"
draft: false
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

## doc

- [https://docs.drone.io/](https://docs.drone.io/)
- enterprise [https://docs.drone.io/enterprise/](https://docs.drone.io/enterprise/)

## official image

### drone with gitea

- [https://hub.docker.com/r/drone/drone](https://hub.docker.com/r/drone/drone)
- [https://docs.drone.io/server/reference/](https://docs.drone.io/server/reference/)

```yaml
  drone-server: # https://hub.docker.com/r/drone/drone
    container_name: "drone-server"
    image: 'drone/drone:2.14.0' # https://hub.docker.com/r/drone/drone/tags
    environment: # https://docs.drone.io/installation/providers/gitea/ # https://docs.gitea.io/en-us/oauth2-provider/
      - TZ=Asia/Shanghai
      - DRONE_OPEN=true
      - DRONE_AGENTS_ENABLED=true
      # https://docs.drone.io/server/reference/drone-database-secret/ use DRONE_DATABASE_DATASOURCE or openssl rand -hex 16 for sqlite3
      - DRONE_DATABASE_SECRET=${ENV_DRONE_POSTGRESQL_PASSWORD}
      - DRONE_GITEA_SERVER=${ENV_DRONE_GITEA_SERVER}
      # https://docs.gitea.io/en-us/oauth2-provider/
      - DRONE_GITEA_CLIENT_ID=${ENV_DRONE_GITEA_CLIENT_ID}
      - DRONE_GITEA_CLIENT_SECRET=${ENV_DRONE_GITEA_CLIENT_SECRET}
      - DRONE_SERVER_HOST=${ENV_DRONE_SERVER_HOST}
      - DRONE_SERVER_PROTO=http
      # https://docs.drone.io/server/reference/drone-rpc-secret/ openssl rand -hex 16
      - DRONE_RPC_SECRET=${ENV_DRONE_RPC_SECRET}
      - DRONE_USER_CREATE=username:${ENV_DRONE_USER_ADMIN_CREATE},admin:true # https://docs.drone.io/server/reference/drone-user-create/ let ENV_DRONE_USER_ADMIN_CREATE be admin to open Trusted
      # https://docs.drone.io/server/reference/drone-registration-closed/
      - DRONE_REGISTRATION_CLOSED=false
    volumes:
      - ./data/drone-server:/data
    ports:
      - 30200:80
      - 30201:443
    restart: always # on-failure:3 or unless-stopped default "no"
```

## nolimit image

- with sqlite3 at `docker-compose.yml`
- [https://docs.drone.io/server/reference/](https://docs.drone.io/server/reference/)

- env file

```env
ENV_DRONE_SERVER_PROTO="http"
ENV_DRONE_SERVER_HOST=""
ENV_DRONE_RPC_PROTO="http"
ENV_DRONE_RPC_HOST=""
ENV_DRONE_RPC_SECRET=""
ENV_DRONE_RUNNER_NAME="you-host-name"
ENV_DRONE_UI_DISABLE="false"
ENV_DRONE_UI_USERNAME=""
ENV_DRONE_UI_PASSWORD=""
ENV_DRONE_RUNNER_CAPACITY="2"
```

- docker-compose.yml

```yml
# copy right by sinlov at https://github.com/sinlov
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.7'
services:
  ## drone start
  drone-server: # https://hub.docker.com/r/drone/drone
    container_name: "drone-server"
    image: 'sinlov/docker-drone-server:latest' # https://hub.docker.com/r/sinlov/docker-drone-server/tags
    depends_on:
      - drone-db
    # https://docs.docker.com/compose/compose-file/#env_file
    env_file: .env
    environment: # https://docs.drone.io/installation/providers/gitea/
      - DRONE_OPEN=true
      - DRONE_AGENTS_ENABLED=true
      # https://docs.drone.io/server/reference/drone-database-secret/ use DRONE_DATABASE_DATASOURCE or openssl rand -hex 16 for sqlite3
      - DRONE_DATABASE_SECRET=${ENV_DRONE_POSTGRESQL_PASSWORD}
      - DRONE_GIT_ALWAYS_AUTH=true
      - DRONE_GITEA_SERVER=${ENV_DRONE_GITEA_SERVER}
      # https://docs.gitea.io/en-us/oauth2-provider/
      - DRONE_GITEA_CLIENT_ID=${ENV_DRONE_GITEA_CLIENT_ID}
      - DRONE_GITEA_CLIENT_SECRET=${ENV_DRONE_GITEA_CLIENT_SECRET}
      - DRONE_SERVER_HOST=${ENV_DRONE_SERVER_HOST}
      - DRONE_SERVER_PROTO=${ENV_DRONE_SERVER_PROTO}
      # https://docs.drone.io/server/reference/drone-rpc-secret/ openssl rand -hex 16
      - DRONE_RPC_SECRET=${ENV_DRONE_RPC_SECRET}
      - DRONE_BRANCH=main
      - DRONE_REPO_BRANCH=main
      - DRONE_COMMIT_BRANCH=main
      - DRONE_USER_CREATE=username:${ENV_DRONE_USER_ADMIN_CREATE},admin:true # https://docs.drone.io/server/reference/drone-user-create/ let ENV_DRONE_USER_ADMIN_CREATE be admin to open Trusted
      # https://docs.drone.io/server/reference/drone-registration-closed/
      - DRONE_REGISTRATION_CLOSED=false
    volumes:
      - ./data/drone-server:/data
    ports:
      - 30200:80
      - 30201:443
    restart: always # on-failure:3 or unless-stopped default "no"
  ## drone end
```

- with postgresql db at `docker-compose.yml`

```yaml
# copy right by sinlov at https://github.com/sinlov
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.7'
services:
  ## drone start
  fix-drone-db:
    container_name: "drone-db-fix"
    image: 'bitnami/postgresql:14.5.0' # https://hub.docker.com/r/bitnami/postgresql
    user: root
    command: chown -R 1001:1001 /bitnami
    volumes:
      - './data/drone-postgresql-db:/bitnami/postgresql'
  drone-db:
    container_name: "drone-db"
    image: 'bitnami/postgresql:14.5.0' # https://hub.docker.com/r/bitnami/postgresql
    depends_on:
      - fix-drone-db
    volumes:
      - './data/drone-postgresql-db:/bitnami/postgresql'
    ports:
      - '5432'
    environment:
      - POSTGRESQL_DATABASE=drone
      - POSTGRESQL_USERNAME=drone
      - POSTGRESQL_PASSWORD=${ENV_DRONE_POSTGRESQL_PASSWORD}
    # you can set restart: on-failure:3 or unless-stopped
    restart: always # always on-failure:3 or unless-stopped default "no"
  drone-server: # https://hub.docker.com/r/drone/drone
    container_name: "drone-server"
    image: 'sinlov/docker-drone-server:latest' # https://hub.docker.com/r/sinlov/docker-drone-server/tags
    depends_on:
      - drone-db
    # https://docs.docker.com/compose/compose-file/#env_file
    env_file: .env
    environment: # https://docs.drone.io/installation/providers/gitea/
      - DRONE_OPEN=true
      - DRONE_AGENTS_ENABLED=true
      # - DRONE_DEBUG=true
      # https://docs.drone.io/server/reference/drone-database-driver/
      - DRONE_DATABASE_DRIVER=postgres
      # https://docs.drone.io/server/reference/drone-database-datasource/
      - DRONE_DATABASE_DATASOURCE=postgres://drone:${ENV_DRONE_POSTGRESQL_PASSWORD}@drone-db:5432/drone?sslmode=disable
      # https://docs.drone.io/server/reference/drone-database-secret/ use DRONE_DATABASE_DATASOURCE or openssl rand -hex 16 for sqlite3
      - DRONE_DATABASE_SECRET=${ENV_DRONE_POSTGRESQL_PASSWORD}
      # https://docs.drone.io/server/reference/drone-database-max-connections/
      - DRONE_DATABASE_MAX_CONNECTIONS=45
      - DRONE_GIT_ALWAYS_AUTH=true
      # - DRONE_GIT_USERNAME=
      # - DRONE_GIT_PASSWORD=
      - DRONE_GITEA_SERVER=${ENV_DRONE_GITEA_SERVER}
      # https://docs.gitea.io/en-us/oauth2-provider/
      - DRONE_GITEA_CLIENT_ID=${ENV_DRONE_GITEA_CLIENT_ID}
      - DRONE_GITEA_CLIENT_SECRET=${ENV_DRONE_GITEA_CLIENT_SECRET}
      - DRONE_SERVER_HOST=${ENV_DRONE_SERVER_HOST}
      - DRONE_SERVER_PROTO=https
      # https://docs.drone.io/server/reference/drone-rpc-secret/ openssl rand -hex 16
      - DRONE_RPC_SECRET=${ENV_DRONE_RPC_SECRET}
      - DRONE_BRANCH=main
      - DRONE_REPO_BRANCH=main
      - DRONE_COMMIT_BRANCH=main
      - DRONE_USER_CREATE=username:${ENV_DRONE_USER_ADMIN_CREATE},admin:true # https://docs.drone.io/server/reference/drone-user-create/ let ENV_DRONE_USER_ADMIN_CREATE be admin to open Trusted
      # https://docs.drone.io/server/reference/drone-registration-closed/
      - DRONE_REGISTRATION_CLOSED=false
    volumes:
      - ./data/drone-server:/data
    ports:
      - 30200:80
      - 30201:443
    restart: always # always on-failure:3 or unless-stopped default "no"
  ## drone end
```

