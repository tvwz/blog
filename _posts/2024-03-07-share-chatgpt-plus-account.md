---
categories: [计算机网络, 建站]
date: 2024-03-07 14:00:00 +0800
last_modified_at: 2024-03-07 14:46:00 +0800
tags:
- ChatGPT
- ChatGPT Plus
- Docker
- VPS
- ninja
title: 使用 ChatGPT Web Share 共享 ChatGPT Plus
---

## 如何共享 ChatGPT Plus？

由于 ChatGPT Plus 价格为 **20 美元 / 每月**，个人使用有点小贵，加上个人账号的使用频率远远没有达到 **40 次 / 每 3 小时**，同时也为了账号的共享使用，本文将使用开源的 [ChatGPT Web Share](https://github.com/chatpire/chatgpt-web-share) 项目，来完成 ChatGPT 账号的共享，合理利用资源。

> 共享 ChatGPT Plus 账号使用有一定封号风险，请谨慎使用！
{: .prompt-warning }

前提条件：

- 一个 ChatGPT Plus 账号
- 一台解锁 ChatGPT 访问的 VPS 服务器
- VPS 需提前安装好 Docker

### 1.创建应用目录并生成配置文件

为了方便管理数据和配置，我们首先创建好 `/home/ubuntu/cws`{: .filepath} 目录：

```bash
$ cd ~
$ mkdir cws && cd cws
$ mkdir -p data/config
```

然后将 MongoDB 密码和系统管理员密码写入环境变量：

```bash
$ export MONGODB_PASSWORD=password
$ export INITIAL_ADMIN_PASSWORD=password
```

接着，我们运行一次 Docker 容器，用来生成配置文件：

```bash
$ docker run -it --rm \
  -v $PWD/data/config:/tmp/config \
 ghcr.io/chatpire/chatgpt-web-share:latest \
  python /app/backend/manage.py create_config -O /tmp/config --generate-secrets --mongodb-url "mongodb://cws:${MONGODB_PASSWORD}@mongo:27017" --initial-admin-password "${INITIAL_ADMIN_PASSWORD}" --chatgpt-base-url http://ninja:7999/backend-api/
```

> 上面的命令将在 `/home/ubuntu/cws/data/config`{: .filepath} 目录下生成 `config.yaml` 和 `credentials.yaml` 文件。
{: .prompt-tip }

### 2.编写 docker-compose.yml 脚本

首先，创建环境变量配置文件 `/home/ubuntu/cws/.env`{: .filepath}：

```bash
$ echo "TZ=Asia/Shanghai" > .env
$ echo "MONGO_INITDB_DATABASE=cws" >> .env
$ echo "MONGO_INITDB_ROOT_USERNAME=cws" >> .env
$ echo "MONGO_INITDB_ROOT_PASSWORD=$MONGODB_PASSWORD" >> .env
```

然后，编写 `/home/ubuntu/cws/docker-compose.yml`{: .filepath} 脚本：

```yaml
version: "3"

services:
  chatgpt-web-share:
    image: ghcr.io/chatpire/chatgpt-web-share:latest
    container_name: cws
    restart: unless-stopped
    ports:
      - 5000:80
    volumes:
      - ./data:/app/backend/data
    environment:
      - TZ=${TZ}
      - CWS_CONFIG_DIR=/app/backend/data/config
    depends_on:
      - mongo

  mongo:
    container_name: mongo
    image: mongo:6.0
    restart: always
    # ports:
    #   - 27017:27017
    volumes:
      - ./mongo_data:/data/db
    environment:
      MONGO_INITDB_DATABASE: ${MONGO_INITDB_DATABASE}
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_INITDB_ROOT_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD}

  ninja:
    image: ninja:latest
    container_name: ninja
    restart: unless-stopped
    command: run --arkose-har-dir /root/.ninja
    ports:
      - "7999:7999"
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - "./har:/root/.ninja"
```

### 3.构建 ninja 镜像

首先，创建 `/home/ubuntu/cws/ninja`{: .filepath}目录：

```bash
$ mkdir ninja && cd ninja
```

然后，创建 `/home/ubuntu/cws/ninja/Dockerfile`{: .filepath} 文件，并将以下内容保存到文件：

```dockerfile
# Stage 1: Build ninja
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y \
 git \
 cmake \
 libclang-dev \
 build-essential \
 curl \
 && rm -rf /var/lib/apt/lists/*

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set PATH to include cargo
ENV PATH="/root/.cargo/bin:${PATH}"

RUN git clone https://github.com/HarrisonWang/ninja.git && cd ninja

WORKDIR /ninja

RUN cargo build --release

# Stage 2: Run ninja
FROM ubuntu:22.04 AS runtime

ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=C

COPY --from=builder /ninja/target/release/ninja /bin/ninja

ENTRYPOINT ["/bin/ninja"]
```

接着，执行以下命令构建 ninja 镜像：

```bash
$ docker build -t ninja:latest .
```

构建需要一点时间，请耐心等待。

### 4.运行容器

构建完成后，我们首先切换到主目录：

```bash
$ cd /home/ubuntu/cws
```

然后，使用以下命令运行容器：

```bash
$ docker compose up -d
```

接着，查看容器运行日志：

```bash
$ docker logs cws -f
```

若一切正常，我们输入 `http://<ip>:5000` 地址访问 CWS 应用，使用默认账号 `admin` 和设置的管理员密码 `password` 登录。

> 若端口无法访问，请将防火墙 的 5000 端口放开。
{: .prompt-tip }

### 5. 抓取 HAR 文件上传给 ninja

首先，登录 ChatGPT，使用 <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd> 按键开启浏览器调试模式，然后切换到 GPT-4 模型，开启新的会话，找到 `https://tcr9i.chat.openai.com/fc/gt2/public_key/35536E1E-65B4-4D96-9D97-6ADB7EFF8147` 的网络请求：

![image-20240307135422604](/img/image-20240307135422604.png){: .shadow }

然后，右键**以 HAR 格式保存所有内容**将文件保存到桌面：

![image-20240307135507421](/img/image-20240307135507421.png){: .shadow }

接着，我们在 VPS 服务器上将 ninja 的 `7999` 端口临时放开， 然后打开 HAR 文件上传地址 `http://<ip>:7999/har/upload`，上传 har 文件，上传完成后记得将 `7999` 端口取消外网访问，上传完成后的界面如下：

![image-20240307140624816](/img/image-20240307140624816.png){: .shadow }

### 6. 后台配置 CWS

首先，打开 `https://chat.openai.com/api/auth/session` 页面，复制 access token：

![image-20240307141757620](/img/image-20240307141757620.png){: .shadow }

然后，登录 CWS 后台 `http://<ip>:5000/admin/system`，点击系统配置菜单，切换至 <kbd>credentials</kbd> 页签，粘贴复制 access token，点击<kbd>保存</kbd>：

![image-20240307141311223](/img/image-20240307141311223.png){: .shadow }

至此，所有的配置均已完成，我们可共享 ChatGPT Plus 账号的使用了。

### 7.创建 CWS 新用户共享使用

首先，我们切换到用户管理菜单，点击 <kbd>添加用户</kbd> 按钮进入添加用户页面，输入新用户信息然后点击<kbd>保存</kbd>：

![image-20240307142804120](/img/image-20240307142804120.png){: .shadow }

然后，我们给新账号设置 100 次调用 gpt_4，如下图：

![image-20240307143302927](/img/image-20240307143302927.png){: .shadow }

接着，我们切换到新用户登录，新建一个学习助手的会话：

![image-20240307143056110](/img/image-20240307143056110.png){: .shadow }

最后，任意输入消息后返回如下图：

![image-20240307143549067](/img/image-20240307143549067.png){: .shadow }

## 参考文档

1. ninja: [https://github.com/gngpp/ninja/wiki/2-Arkose](https://github.com/gngpp/ninja/wiki/2-Arkose)
2. ChatGPT Web Share: [https://cws-docs.pages.dev/zh/](https://cws-docs.pages.dev/zh/)
