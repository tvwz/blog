---
categories: [操作系统, Linux, Shell]
date: 2023-12-27 14:20:00 +0800
last_modified_at: 2023-12-27 16:48:00 +0800
tags:
- HTTP
- SSL/TLS
- HTTPS
- acme.sh
- Let’s Encrypt
title: 如何给网站添加免费的 SSL/TLS 证书？
image:
  path: /img/letsencrypt.png
---

2017 年 1 月，Google 和 Mozilla 发布公告，为了帮助用户安全的浏览网页，统一将非 HTTPS 连接的站点标记为不安全，并且会在地址栏显示不安全网站的警告。为建立用户对网站的信任，提升网站的专业形象，同时为了加强用户和网站的数据安全，防止敏感信息的泄露，我们给网站添加 SSL/TLS 证书是很有必要的。

本文使用 [acme.sh](https://github.com/acmesh-official/acme.sh) 脚本创建和使用了一个 [Let's Encrypt](https://letsencrypt.org/) 颁布的免费 SSL/TLS 证书。

## 1.基本概念和术语

要详细了解 SSL/TLS ，参见 [互联网是如何工作的？](https://xiaowangye.org/posts/how-does-internet-work/#8使用-ssltls-确保互联网通信安全) 介绍。以下是一些关键术语和概念 ：

- HTTP：超文本传输协议用于在客户端（如网络浏览器）和服务器（如网站）之间传输数据。

- SSL/TLS：安全套接字层和传输层安全协议用于在互联网上提供安全通信。

- HTTPS：HTTP 的加密版本，用于提供客户端和服务器之间的安全通信。

- Let's Encrypt：开放和自动化的证书颁发机构。由非盈利组织[互联网安全研究小组（ISRG）](https://www.abetterinternet.org/)运营。

- ACME：全称 Automated Certificate Management Environment（自动证书管理环境），是一个由[互联网安全研究小组（ISRG）](https://www.abetterinternet.org/)创建的协议，旨在自动化和简化公共密钥基础设施（PKI）证书的管理过程。

## 2.操作步骤

### 2.1.安装 acme.sh

acme.sh 安装特别简单，只需运行以下的命令：

```bash
$ curl https://get.acme.sh | sh -s email=my@xiaowangye.org
```

> 普通用户和 root 用户均可安装使用。
{: .prompt-tip }

安装过程如下：

1. 执行 acme.sh 脚本后将安装到目录 `~/.acme.sh/`。
2. 自动创建 cronjob，每天凌晨自动检测所有证书，若检测到快过期，则自动更新证书。

### 2.2.生成证书

acme.sh 实现了 ACME 支持的所有验证协议，包括 HTTP 和 DNS 验证。

1).HTTP 验证

```bash
$ acme.sh --issue -d xiaowangye.org -d www.xiaowangye.org --webroot /usr/share/nginx/html/
```

- `--issue`：表示发起签发证书请求
- `-d xiaowangye.org`：指定要签发证书的域名
- `--webroot /usr/share/nginx/html/`：指定用于 ACME 验证的网站根目录，以证明域名的所有权。

对于 Apache 和 Nginx 服务器，支持以下智能方式完成验证（**无需手动指定网站根目录**）

Apache 服务器：

```bash
$ acme.sh --issue -d xiaowangye.org --apache
```

Nginx 服务器：

```bash
$ acme.sh --issue -d xiaowangye.org --nginx
```

> acme.sh 完成验证后，会恢复原有的 Nginx 或 Apache 配置（为了配置安全），需要手动添加 SSL 的配置。
{: .prompt-warning }

若无任何 Web 服务器，且 80 端口空闲，acme.sh 还支持假装一个 Web 服务器完成验证：

```bash
$ acme.sh --issue -d xiaowangye.org --standalone
```

2).DNS 验证

手动在域名上添加一条 txt 解析记录，以验证域名所有权。然后执行以下命令请求 Let's Encrypt 的证书：

```bash
$ acme.sh --issue --dns -d xiaowangye.org \
 --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

- `--dns`: 指定使用 DNS 验证，即通过在 DNS 中添加 txt 的记录来完成域名所有权验证。

- `--yes-I-know-dns-manual-mode-enough-go-ahead-please`：这是在 DNS 验证方式下的手动模式，表示你已经了解并确认使用手动方式进行 DNS 验证，而不是自动配置 DNS API。这个选项的使用是为了确认你了解正在进行的操作，并防止误操作。

命令执行完成后，acme.sh 将显示解析记录，我们将该 txt 解析记录添加到 DNS，DNS 解析完成后，执行以下命令重新生成证书：

```bash
$ acme.sh --renew -d xiaowangye \
  --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

> acme.sh 目前支持 cloudflare, dnspod, cloudxns, godaddy 以及 ovh 等数十种 DNS 提供商的自动集成。
{: .prompt-tip }

### 2.3.安装证书

将证书安装到 /etc/certs 目录：

```bash
$ acme.sh --install-cert -d xiaowangye.org \
         --key-file /etc/certs/xiaowangye.org.key \
         --fullchain-file /etc/certs/xiaowangye.org.pem \
         --reloadcmd "systemctl force-reload nginx"
```

安装完成后，使用以下命令查看安装的证书信息：

```bash
$ acme.sh --info -d xiaowangye.com
```

### 2.4.Nginx SSL 证书设置

```nginx
server {
...
    ssl_certificate /etc/certs/xiaowangye.org.pem;
    ssl_certificate_key /etc/certs/xiaowangye.org.key;
}
```

完成后，重启 Nginx 使证书设置生效：

```bash
$ systemctl restart nginx
```

## 参考

- An ACME Shell script：<https://github.com/acmesh-official/acme.sh>
