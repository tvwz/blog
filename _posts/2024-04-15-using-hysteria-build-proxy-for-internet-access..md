---
categories: [计算机网络]
date: 2024-04-15 14:00:00 +0800
last_modified_at: 2024-04-15 17:40:00 +0800
tags:
- Hysteria
- V2RayN
- 科学上网
title: 使用 Hysteria 自建节点科学上网
---

## Hysteria 2 简介

Hysteria 2 是一个开源的网络加速工具，它是 Hysteria 的第二个版本。Hysteria 是一个基于 UDP 的网络加速工具，旨在提高网络连接的速度和稳定性。Hysteria 2 在原有的基础上进行了一些改进和优化，以提供更好的性能和用户体验。

Hysteria 2 的主要特点包括：

- 高性能：通过使用更高效的算法和技术，Hysteria 2 能够提供更快的网络速度和更稳定的连接。
- 易用性：Hysteria 2 提供了简单易用的命令行界面和配置选项，使得用户可以轻松地设置和使用。
- 跨平台支持：Hysteria 2 支持多种操作系统，包括 Windows、macOS、Linux 等，使得用户可以在不同的平台上使用。
- 开源：Hysteria 2 是开源的，这意味着用户可以查看其源代码，并根据需要进行修改和定制。

Hysteria 2 的开发目标是为用户提供一个高效、稳定、易用的网络加速工具，以满足不同的网络需求。

此前我已经有三篇文章分别介绍了[《如何使用 V2Ray 科学上网？》](https://voxsay.com/posts/how-to-use-v2ray-to-access-the-internet-friendly/)、[《利用 V2Ray 结合 WS 和 TLS 进行高效上网》](https://voxsay.com/posts/v2ray-combined-with-ws-and-tls-for-internet-access/)和[《使用 Cloudflare Workers 自建节点科学上网》](https://voxsay.com/posts/using-cloudflare-workers-build-proxy-for-internet-access/)，本文将使用另一个无需自定义域名的工具 [Hysteria 2](https://github.com/apernet/hysteria) 进行科学上网。前提条件：

- 一台可“上网”的 VPS 服务器

### 服务端安装

1.一键脚本安装：

更新所有软件源的软件包列表，然后使用一键脚本进行安装：

```bash
$ apt update
$ bash <(curl -fsSL https://get.hy2.sh/)

# 卸载 Hysteria
$ bash <(curl -fsSL https://get.hy2.sh/) --remove
```

2.启动：

```bash
$ systemctl start hysteria-server
```

设置为开机自动启动：

```bash
$ systemctl enable hysteria-server
```

3.服务端配置：

```yaml
listen: :443

#acme:
#  domains:
#    - your.domain.net
#  email: your@email.com

tls:
  cert: /etc/hysteria/cert.pem
  key: /etc/hysteria/private.key

auth:
  type: password
  password: <password>

masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
```
{: file="/etc/hysteria/config.yaml" }

> 1. 使用 `openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout /etc/hysteria/private.key -out /etc/hysteria/cert.pem -subj "/CN=bing.com" -days 36500` 命令生成自签名证书。
> 2. 然后使用 `chmod 777 /etc/hysteria/private.key` 命令添加权限。
{: .prompt-info }

4.重启服务：

```bash
$ systemctl restart hysteria-server
```

5.开放 HTTP 和 HTTPS 默认端口：

```bash
$ ufw allow 80/tcp
$ ufw allow 443/tcp
```

### 客户端安装

#### 1.下载 V2RayN 客户端

下载 [V2RayN](https://github.com/2dust/v2rayN/releases) 最新版本，解压安装到 D 盘：

![V2RayN 下载](/img/image-20240415171200377.webp){: .shadow }

#### 2.下载 Hysteria 2 最新版本

下载 [Hysteria](https://github.com/apernet/hysteria/releases)，并替换 `D:\v2rayN-With-Core\bin\hysteria2`{: .filepath} 目录下的文件：

![Hysteria 下载](/img/image-20240415171310564.webp){: .shadow }

#### 3.配置 Hysteria 2

在 `D:\v2rayN-With-Core\bin\hysteria2`{: .filepath} 目录下新增配置文件：

```yaml
server: <IP>:443
auth: <password>

tls:
  sni: bing.com
  insecure: true 

socks5:
  listen: 127.0.0.1:1080

http:
  listen: 127.0.0.1:8080
```
{: file="D:\v2rayN-With-Core\bin\hysteria2\config.yaml" }

> 将 `<IP>` 和 `<password>` 替换为 VPS 服务器的 IP 和上面服务端设置的认证密码。
{: .prompt-tip }

#### 4.配置自定义服务器

打开 V2RayN 客户端，依次点击 <kbd>服务器</kbd> → <kbd>添加自定义配置服务器</kbd>，分别设置别名、地址、core 类型和 Socks 端口：

![自定义服务器配置](/img/image-20240415171949015.webp){: .shadow }

配置完成后，将该节点设置为活动服务器。

#### 5.访问 Youtube 站点

打开 [youtube.com](https://www.youtube.com) 可看到，我们已成功突破 Great Firewall 限制，实现了科学上网。

![访问 Youtube](/img/image-20240415172420933.webp){: .shadow }
