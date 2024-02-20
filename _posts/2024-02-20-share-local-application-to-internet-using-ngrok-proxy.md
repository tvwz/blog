---
categories: [计算机网络]
date: 2024-02-20 08:57:00 +0800
last_modified_at: 2024-02-20 09:00:00 +0800
tags:
- Ngrok
- 代理
title: 使用 Ngrok 代理将本地应用程序分享到互联网
---

## Ngrok 是什么？

Ngrok 是一款能够将本地端口暴露到公网上的工具，它为开发者提供了实时的网络隧道服务。使用 Ngrok，你可以在没有公网 IP 或者在内网环境下进行网络开发，例如在本地运行的 Web 服务器、数据库、API 等。

## Ngrok 可以做什么？

- **提供公网访问本地服务的能力**：Ngrok 可以将你的本地服务（如在本地运行的 web 服务器）通过一个公网的 URL 来访问。这对于测试和分享本地开发的应用非常有用，可向客户演示在本地计算机上运行的网站，而无需部署到临时站点。
- **Webhook 测试**：在本地计算机上运行 Ngrok 以获取 URL，以便直接在您正在开发的应用程序中接收 webhook。[检查并重放请求](https://ngrok.com/docs/agent/web-inspection-interface/)以实现快速开发。
- **移动后端测试**：针对您在本地计算机上开发的后端测试您的移动应用程序。例如可以使用 Ngrok 本地调试微信接口等。

## 使用 Ngrok 代理本地应用到互联网

### 安装

Windows 上通过 Chocolatey 安装 ngrok：

```bash
$ choco install ngrok
```

查看 ngrok 命令的使用：

```bash
$ ngrok help
```

### 连接 ngrok 账号

运行以下命令将您的 authtoken 添加到默认的 **ngrok.yml** 配置文件中：

```bash
$ ngrok config add-authtoken <authtoken>
```

### 运行应用

使用临时域名运行本地应用，如我的博客站点在本地的运行端口为 4000：

```bash
$ ngrok http 4000
```

### 始终使用同一个域名

使用 ngrok 分配的固定域名运行本地应用：

```bash
$ ngrok http --domain=kind-grubworm-fleet.ngrok-free.app 4000
```

### 保护应用安全

#### 使用 Google 第三方认证

```bash
$ ngrok http --oauth=google --oauth-allow-email=harrisonwang.dev@gmail.com 4000
```

#### 使用账号和密码认证

设置使用账号和密码访问：

```bash
$ ngrok http 4000 --basic-auth 'test:test2024'
```
