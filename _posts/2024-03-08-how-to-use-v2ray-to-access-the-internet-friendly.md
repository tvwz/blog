---
categories: [计算机网络]
date: 2024-03-08 12:04:00 +0800
last_modified_at: 2024-03-08 14:21:00 +0800
tags:
- VPS
- V2Ray
- 科学上网
title: 如何使用 V2Ray 科学上网？
---

## V2Ray 是什么？

V2Ray 是一个多协议、多平台的代理软件，支持多种代理协议如 Shadowsocks、VMess、VLess 等，可以帮助用户实现对网络数据的转发和加密，从而达到访问受限网站、保护个人隐私等目的。V2Ray 支持多种平台，包括 Windows、macOS、Linux、Android、iOS 等，并提供了丰富的配置选项和插件，用户可以根据自己的需求进行个性化定制。[V2Ray](https://github.com/v2fly/v2ray-core) 是一个开源的项目，由 Project V 团队开发维护。

## V2Ray 如何安装？

前提条件：

- 一台可科学上网的 VPS 服务器
- VPS 服务器安装 Ubuntu 22.04 操作系统

### 服务端安装步骤

1.下载一键安装脚本：

```bash
$ wget https://git.io/v2ray.sh
```

2.赋予脚本可执行权限：

```bash
$ chmod +x v2ray.sh
```

3.执行脚本安装 v2ray：

```bash
$ ./v2ray.sh
```

4.记录 v2ray 提供的 vmess 链接和端口号：

```bash
-------------- VMess-TCP-1145.json -------------
协议 (protocol)         = vmess
地址 (address)          = 149.28.237.232
端口 (port)             = 1145
用户ID (id)             = 13cfd085-a761-46fc-8070-5bc92621746e
传输协议 (network)      = tcp
伪装类型 (type)         = none
------------- 链接 (URL) -------------
vmess://eyJ2IjoyLCJwcyI6IjIzM2JveS10Y3AtMTQ5LjI4LjIzNy4yMzIiLCJhZGQiOiIxNDkuMjguMjM3LjIzMiIsInBvcnQiOiIxMTQ1IiwiaWQiOiIxM2NmZDA4NS1hNzYxLTQ2ZmMtODA3MC01YmM5MjYyMTc0NmUiLCJhaWQiOiIwIiwibmV0IjoidGNwIiwidHlwZSI6Im5vbmUiLCJwYXRoIjoiIn0=
------------- END -------------
```

5.最后，需要防火墙开放 1145 端口，命令如下：

```bash
$ sudo ufw allow 1145
success
```

### 客户端安装步骤

v2ray 支持 Windows、macOS、Android 等客户端。v2rayN 为 Windows 客户端，v2rayNG 为 Android 客户端，本文以安装 v2rayN 为例。

1.下载 V2RayN 客户端：

![V2RayN 客户端下载](/img/image-20240308140228803.png){: .shadow }

> v2rayN 运行依赖 Microsoft .NET 8.0 Desktop Runtime，需要提前安装，或者直接安装含运行时依赖安装包 [zz_v2rayN-With-Core-SelfContained.7z](https://github.com/2dust/v2rayN/releases/download/6.28/zz_v2rayN-With-Core-SelfContained.7z)
{: .prompt-tip }

2.解压安装到 D 盘，双击 v2rayN.exe 运行：

![解压安装客户端](/img/image-20240308140415265.png){: .shadow }

3.复制 vmess 链接点击<kbd>导入</kbd>：

![导入 vmess 链接](/img/image-20240308141338997.png){: .shadow }

选中后按 <kbd>Enter</kbd> 键设为活动服务器。

4.访问 [google.com](https://www.google.com)：

![访问 Google](/img/image-20240308141706769.png){: .shadow }

可以看到，我们已成功实现科学上网。

> 互联网不是法外之地，科学上网的目的主要是为了学习、工作和查资料等，请遵守国家法律，谨言慎行！
{: .prompt-warning }
