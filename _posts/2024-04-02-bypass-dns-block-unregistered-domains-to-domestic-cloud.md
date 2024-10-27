---
categories: [计算机网络, DNS]
date: 2024-04-02 08:00:00 +0800
last_modified_at: 2024-04-02 09:05:00 +0800
tags:
- Cloudflare
- Tunnel
- DNS
- cloudflared
- Docker
- Ubuntu
- Nginx
- memos
title: 未备案域名绕过 DNS 阻断解析到国内云主机
---

## Cloudflare Tunnel 简介

Cloudflare Tunnel（原名为 Argo Tunnel）提供了一种安全的方法来连接你的网络服务到 Cloudflare 网络，而不需要开放服务器的端口到公网上，或者在 DNS 上直接暴露服务器的 IP 地址。这种方式能够帮助越过 DNS 阻断，并增强服务的安全性。

由于服务的真实 IP 地址不会在 DNS 查询中直接暴露，Cloudflare Tunnel 可以帮助绕过基于 DNS 的阻断。用户的请求首先到达 Cloudflare 的网络，然后通过建立好的安全隧道转发到后端的服务。这意味着，即使某些 DNS 请求被拦截或阻断，用户的请求仍然可以通过 Cloudflare 的网络到达目标服务。

因我此前购买了一台国内的主机，为了充分利用该服务器，我基于 Cloudflare Tunnel 搭建了一个 memos 应用，实现了基于域名的访问，成功绕过了国内了对未备案域名的 DNS 阻断。

前提条件：

- 一个自定义域名
- 一台国内云主机
- 一个 Cloudflare 账号
- 一张双币信用卡，用于开通 Cloudflare Zero Trust 的免费计划
- Ubuntu 22.04

### Docker 安装

1.更新包

```bash
$ sudo apt update
```

2.安装依赖包

```bash
$ sudo apt install ca-certificates curl gnupg lsb-release
```

3.配置镜像源 GPG 密钥

```bash
$ curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-ce-archive-keyring.gpg
```

4.添加腾讯云 Docker 软件源

```bash
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce-archive-keyring.gpg] https://mirrors.cloud.tencent.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list > /dev/null
```

5.再次更新包

```bash
$ sudo apt update
```

6.安装 Docker

```bash
$ sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

7.设置普通用户可运行 Docker

```bash
$ sudo usermod -aG docker ubuntu
```

> 使用 `usermod` 命令将普通用户添加到 docker 组，就不用每次运行 docker 时使用 `sudo` 了。
{: .prompt-info }

8.查看 usermod 配置是否生效

```bash
$ getent group | grep docker
```

> 完成后开启新的终端窗口，不需要带上 `sudo` 提权即可启动。
{: .prompt-info }

### memos 安装

首先，创建 memos 目录：

```bash
$ mkdir ~/memos && cd ~/memos
```

然后编写 docker-compose.yml 文件：

```bash
$ echo "services:
  memos:
    image: neosmemo/memos:stable
    container_name: memos
    volumes:
      - ~/.memos/:/var/opt/memos
    ports:
      - \"5230:5230\"" | sudo tee docker-compose.yml > /dev/null
```

因为用的是腾讯云服务器，所以我们用腾讯云的 Docker 镜像源来加速镜像下载：

```bash
$ echo "{
  \"registry-mirrors\": [\"https://mirror.ccs.tencentyun.com\"]
}" | sudo tee /etc/docker/daemon.json > /dev/null
```

> 为了使 Docker 镜像源实时生效，我们使用 `sudo systemctl restart docker` 命令重启下 Docker 服务
{: .prompt-tip }

接着，拉取并启动 memos 容器：

```bash
$ docker compose up -d
```

### Nginx 安装

安装 Nginx：

```bash
$ sudo apt install nginx
```

添加 memos 的反向代理配置：

```bash
$ echo "server {
    listen 80;
    listen [::]:80;
    server_name memos.wss.so;

    location / {
        proxy_pass http://localhost:5230;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/conf.d/memos.wss.so.conf > /dev/null
```

重启 Nginx，使配置生效：

```bash
$ sudo systemctl restart nginx
```

### cloudflared 安装

> 请切换至 root 用户使用：`su - root`。
{: .prompt-info }

1.安装

```bash
$ curl -L 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' -o cloudflared && chmod +x cloudflared
```

> 若网络无法访问，可更换国内 GitHub 加速地址 `https://hub.gitmirror.com/https://github.com/cloudflare/cloudflared/releases/download/2024.3.0/cloudflared-linux-amd64`
{: .prompt-tip }

2.登录

```bash
$ ./cloudflared tunnel login
```

执行命令后，会提供一个 URL，通过浏览器访问这个 URL，选择需要授权的域名，完成后将生成一个证书文件 `~/.cloudflared/cert.pem`。

3.创建 tunnel

```bash
$ ./cloudflared tunnel create memos
```

创建成功后，会返回一个 Tunnel ID，记录好它。

4.创建 DNS 记录

```bash
$ ./cloudflared tunnel route dns memos memos.wss.so
```

5.cloudflared 配置

```bash
$ echo "tunnel: <tunnel_id>
credentials-file: /root/.cloudflared/<tunnel_id>.json

ingress:
  - hostname: memos.wss.so
    service: http://localhost:80
  - service: http_status:404" | sudo tee ~/.cloudflared/config.yml > /dev/null
```

6.验证配置

```bash
$ ./cloudflared tunnel ingress validate
```

7.测试 tunnel

```bash
$ ./cloudflared --loglevel debug --transport-loglevel warn --config ~/.cloudflared/config.yml tunnel run <tunnel_id>
```

8.配置为系统服务

```bash
$ ./cloudflared service install
```

> 创建系统服务后，配置文件会被拷贝到 `/etc/cloudflared/config.yml`。
{: .prompt-tip }

### 访问站点

打开网址 [memos.wss.so]( https://memos.wss.so)，可看到我们已能成功访问到搭建的 memos 站点：

![image-20240402081046375](/img/image-20240402081046375.webp){: .shadow }
