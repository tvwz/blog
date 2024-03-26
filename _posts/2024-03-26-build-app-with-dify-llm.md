---
categories: [人工智能, LLM]
date: 2024-03-26 14:00:00 +0800
last_modified_at: 2024-03-26 14:57:00 +0800
tags:
- Dify
- Docker
- Ubuntu
title: 如何基于 Dify 搭建大模型应用开发平台
---

## 简介

[Dify](https://github.com/langgenius/dify) 是一个强大的大模型应用开发平台，提供了一整套工具和功能，使得开发、部署和管理复杂应用变得简单。

前提条件：

- Ubuntu 22.04
- Docker
- Python 3.10
- Node.js 18

## 本地源码部署

### Docker 安装

1.安装 Docker 所需软件包

```bash
$ sudo apt update
$ sudo apt install ca-certificates curl gnupg lsb-release
```

2.获取 Docker 的官方 GPG 密钥

```bash
$ sudo mkdir -p /etc/apt/keyrings
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

3.安装 Docker

```bash
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

4.验证 Docker 安装是否成功
```bash
$ docker -v
```

### Node.js 安装

#### 1.安装 nvm

下载并执行 nvm 安装脚本：
```bash
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```

使环境变量生效：
```bash
$ source ~/.bashrc
```

验证安装是否成功：
```bash
$ nvm -v
```

#### 2.安装 node

安装指定 Node.js 版本：
```bash
$ nvm install 18.19.1
```

验证 node 安装是否成功
```bash
$ node -v
```

### Python 安装

#### 1.安装 Anaconda

安装 Anaconda 所需的软件包：
```bash
$ sudo apt install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
```

下载 Anaconda 安装程序：
```bash
$ curl -O https://repo.anaconda.com/archive/Anaconda3-2024.02-1-Linux-x86_64.sh
```

运行 Anaconda 安装程序：
```bash
$ bash Anaconda3-2024.02-1-Linux-x86_64.sh
```

使环境变量生效：
```bash
$ source /root/anaconda3/bin/activate
```

验证 Anaconda 是否安装成功：
```bash
$ conda -V
```

#### 2.安装 Python 环境

创建 Dify 独立的 Python 环境：
```bash
$ conda create --name dify python=3.10
```

切换至 Dify Python 环境：
```bash
$ conda activate dify
```

### Dify 安装

#### Dify 源码下载

```bash
$ git clone https://github.com/langgenius/dify.git
```

#### 中间件部署

部署 PostgresSQL / Redis / Weaviate：

```bash
$ cd dify/docker
$ docker compose -f docker-compose.middleware.yaml up -d
```

#### 服务端部署

1.进入 api 目录：

```bash
$ cd dify/api
```

2.复制环境变量配置文件：

```bash
$ cp .env.example .env
```

3.生成随机密钥，并替换 `.env` 中 `SECRET_KEY` 的值

```bash
$ openssl rand -base64 42
$ sed -i 's/SECRET_KEY=.*/SECRET_KEY=<your_value>/' .env
```

4.安装依赖包

```bash
$ pip install -r requirements.txt
```

5.执行数据库迁移，将数据库结构迁移至最新版本：

```bash
$ flask db upgrade
```

6.启动 API 服务：

```bash
$ flask run --host 0.0.0.0 --port=5001 --debug
```

7.启动 Worker 服务：

```bash
$ celery -A app.celery worker -P gevent -c 1 -Q dataset,generation,mail --loglevel INFO
```

#### 前端页面部署

1.进入 web 目录

```bash
$ cd web
```

2.安装依赖包

```bash
$ npm i
```

3.配置环境变量，复制 `.env.example` 到 `.env.local`

```bash
$ cp .env.example .env.local
```

4.构建代码

```bash
$ npm run build
```

5.启动 web 服务

```bash
$ npm run start
```

### Dify 访问

访问 http://localhost:3000 地址使用本地部署的 Dify。

## Docker Compose 部署

1.下载 Dify 源码

```bash
$ git clone https://github.com/langgenius/dify.git
```

2.进入 Dify 源代码的 docker 目录

```bash
$ cd dify/docker
```

3.执行一键启动命令

```bash
$ docker compose up -d
```

4. Dify 访问

访问 http://localhost:3000 地址使用 Docker 部署的 Dify。

5.升级

进入 Dify 源代码的 docker 目录，依次执行以下命令：

```bash
$ cd dify/docker
$ git pull origin main
$ docker compose down
$ docker compose pull
$ docker compose up -d
```
