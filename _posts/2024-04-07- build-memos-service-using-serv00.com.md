---
categories: [计算机网络, 建站]
date: 2024-04-07 14:00:00 +0800
last_modified_at: 2024-04-07 15:05:00 +0800
tags:
- Serv00
- memos
- Cloudflare
- cloudflared
- FreeBSD
title: 使用 Serv00.com 搭建 memos 服务
---

## memos 简介

memos 是一项开源、免费且隐私优先的笔记服务，提供 Docker 一键安装，支持纯文本和 Markdown，并提供自定义共享和 RESTful API 集成功能。memos 的使命是通过简单、轻量、安全的方式，帮助用户记录和分享他们的想法。

## Serv00.com 简介

Serv00.com 是一家提供免费虚拟主机服务的平台，使用 FreeBSD 的系统，提供 512MB 内存、3G 磁盘和最大 20 个进程，对于我们搭建一个 memos 服务配置已足够。

本文将使用 Serv00 提供的虚拟主机，通过本地方式搭建 memos 服务，并使用浏览器插件和电报机器人的方式集成 memo 服务，方便我们的日常使用。

前提条件：

- 一个自定义域名
- 一台 Serv00.com 账号
- 一个 Cloudflare 账号
- 一张双币信用卡，用于开通 Cloudflare Zero Trust 的免费计划
- 域名托管到 Cloudflare

### Serv00 配置

首先，将 Run your own applications 设置为 Enabled。

![image-20240407143620216.png](/img/image-20240407143620216.png){: .shadow }

> 若不开启，则用户目录下的所有文件都无法添加可执行权限。
{: .prompt-info }

然后，申请开放端口 5230 和 5231。

![开放端口](/img/image-20240407143900008.png){: .shadow }

> 5230 为 memos 默认端口，5231 为 memos 的 gRPC 端口（监听端口+1）
{: .prompt-info }

接着，添加一个新站点，如下图示例：

![添加新站点](/img/image-20240407144549305.png){: .shadow }

> 站点类型选择为 Proxy，并选择 5230 服务端口。
{: .prompt-info }

### memos 部署

```bash
# 切换至目标目录
$ cd /home/harrisonwang/domains/memos.harrisonwang.serv00.net/public_html

# 创建用于存放 SQLite 的数据文件目录
$ mkdir data

# 配置下载地址环境变量
$ API_URL="https://api.github.com/repos/k0baya/memos-binary/releases/latest"
DOWNLOAD_URL=$(curl -s $API_URL | jq -r ".assets[] | select(.name == \"memos-freebsd-amd64.tar.gz\") | .browser_download_url")

# 下载 FreeBSD 版的 memos
$ curl -L $DOWNLOAD_URL -o memos-freebsd-amd64.tar.gz

# 解压安装并添加可执行权限
$ tar -xzvf memos-freebsd-amd64.tar.gz && rm memos-freebsd-amd64.tar.gz && chmod +x memos

# 运行 memos
$ ./memos --mode prod -p 5230 --data /home/harrisonwang/domains/memos.harrisonwang.serv00.net/public_html/data
```

### Cloudflare Tunnel 安装及配置

首先，在 Zero Trust 控制台创建 memos 隧道：

![1.创建隧道](/img/image-20240407145208819.png){: .shadow }

然后，配置好 Public Hostname Page：

![2.配置 Hostname](/img/image-20240407145329774.png){: .shadow }

接着，拷贝 ARGO_TOKEN 并记录好：

![3.拷贝 ARGO_TOKEN](/img/image-20240407145431752.png){: .shadow }

最后，我们登录 Serv00 服务器安装 cloudflared，登录信息可到注册邮箱中查看：

![4.查看登录信息](/img/image-20240407150316147.png){: .shadow }

依次执行以下命令进行安装和测试：

```bash
# 创建 cloudflared 目录
$ mkdir -p ~/domains/cloudflared && cd ~/domains/cloudflared

# 下载 cloudflared
$ wget https://cloudflared.bowring.uk/binaries/cloudflared-freebsd-latest.7z && 7z x cloudflared-freebsd-latest.7z && rm cloudflared-freebsd-latest.7z && mv -f ./temp/* ./cloudflared && rm -rf temp

# 测试运行 cloudflared
$ ./cloudflared tunnel --edge-ip-version auto --protocol http2 --heartbeat-interval 10s run --token <ARGO_TOKEN>
```

### 访问 memos 站点

![访问 memos 站点](/img/image-20240407152118202.png){: .shadow }

我们登录后创建一个 Token，提供 chrome 浏览器扩展程序使用。

![创建 Token](/img/image-20240407152050137.png){: .shadow }

### 安装 memos 的 chrome 浏览器扩展程序

谷歌应用商店搜索 memos 扩展程序：

![搜索 Memos](/img/image-20240407151821852.png){: .shadow }

然后，配置对应的域名和 Token：

![配置](/img/image-20240407152803280.png){: .shadow }

> 注意：域名必须包含 / 结束符，如：https://memos.voxsay.com/
{: .prompt-info }

配置完成后，我们可以很方便的使用浏览器插件发布 memos 了：

![发布 memos](/img/image-20240407153314648.png){: .shadow }

### 集成到 Telegram

memos 官方提供了支持，参阅官方文档配置即可。

## 参考文档

1. Saika's Blog: [Serv00搭建各种服务](https://blog.rappit.site/2024/01/27/serv00_logs)
2. Linux DO: [【serv00系列教程】汇总帖](https://linux.do/t/topic/43121)
3. memos: [Bind Memos user to Telegram user](https://www.usememos.com/docs/integration/telegram-bot)
