---
categories: [计算机网络]
date: 2024-03-17 09:38:00 +0800
last_modified_at: 2024-04-12 23:21:00 +0800
tags:
- Cloudflare
- Workers
- V2RayN
- 科学上网
title: 使用 Cloudflare Workers 自建节点科学上网
image:
  path: /img/cloudflare-workers.png
---

## 简介

此前我有两篇文章，分别介绍了[《如何使用 V2Ray 科学上网？》](https://xiaowangye.org/posts/how-to-use-v2ray-to-access-the-internet-friendly/)和[《利用 V2Ray 结合 WS 和 TLS 进行高效上网》](https://xiaowangye.org/posts/v2ray-combined-with-ws-and-tls-for-internet-access/)，但这种方式需要购买 VPS 服务器。

本文将介绍另外一种无需使用 VPS 服务器科学上网的方法，文章将一步步指导你配置 Cloudflare Workers 和设置 V2RayN。通过阅读本文，你将学会如何利用现代云服务，创建一个既快速又安全的个人网络节点。无论你是网络安全的新手还是有经验的专家，这篇文章都将为你提供宝贵的信息和技巧。这篇文章将探讨如何利用 Cloudflare Workers 结合 V2RayN，自建一个高效、安全的网络代理节点。

前提条件：

- 一个自定义域名

- 一个 Cloudflare 账号

## 创建 Cloudflare Workers

1. 登录 Cloudflare 账户，转到 Workers 选项卡

2. 创建 Worker

    - 输入 Worker 名称 **tunnel** 点击<kbd>部署</kbd>

    - 点击打开 [Worker 脚本地址](https://raw.githubusercontent.com/harrisonwang/edgetunnel/main/_worker.js) 并复制

    - 编辑 Worker 脚本，粘贴复制的脚本内容

    - 替换脚本中的 UUID，可通过 V2RayN 客户端或者 PowerShell 命令生成 UUID

> 使用 `Powershell -NoExit -Command "[guid]::NewGuid()"` 命令生成 UUID
{: .prompt-tip }

3. 设置自定义域名

    依次点击 <kbd>Workers 和 Pages</kbd> → <kbd>tunnel</kbd> → <kbd>设置</kbd> → <kbd>触发器</kbd> → <kbd>添加自定义域</kbd>，输入自定义域名 **tunnel.wss.so** 进行绑定。

4. 验证 Worker

    输入 [tunnel.wss.so](https://tunnel.wss.so) 验证 Worker 服务，然后输入 **https://tunnel.wss.so/{UUID}** 验证节点是否正常，若无问题则显示如下：

    ![验证节点服务](/img/image-20240317103458169.png){: .shadow }

> 请将域名和 UUID 替换为自己的
{: .prompt-tip }

## V2RayN 的设置

### 1.下载和安装 V2RayN

- 访问 V2RayN 的官方 GitHub 页面下载最新版本的 V2RayN。

- 解压下载的文件包，并运行 V2RayN.exe 文件启动客户端。

### 2.配置 V2RayN 客户端

- 在 V2RayN 界面中，选择<kbd>订阅分组</kbd>→<kbd>订阅分组设置</kbd>→<kbd>添加</kbd>。

- 输入别名如 **Cloudflare**，粘贴地址 **https://tunnel.wss.so/{UUID}** 后点击<kbd>确认</kbd>

- 然后选择<kbd>订阅分组</kbd>→<kbd>更新当前订阅(不通过代理)</kbd>

- 接着切换到 Cloudflare 分组，右键<kbd>一键多线程测试延迟和速度测试</kbd>，等待测试完成。

- 最后，我们选择一个延迟低和速度快并<kbd>设为活动服务器</kbd>

    ![节点服务器列表](/img/image-20240317104100726.png){: .shadow }

### 3.测试

我们访问测试网站 [google.com](https://www.google.com) 验证连接的有效性，如果失败则切换至别的服务器后重新测试。

## Cloudflare 自建节点的优势

1. 通过 Cloudflare Workers 自建节点，可以让我们替代传统的 VPS 翻墙代理繁琐的搭建过程。

2. 使用 Cloud Workers 提供的免费套餐，可以在不产生额外费用的情况下使用其服务。虽然存在 **10 万/天**的请求次数限制，但对于个人用户或小型项目来说，这通常是足够的。

3. 使用 Cloudflare 将其服务作为代理可以减少被封锁的风险，且可随时切换到未被封锁的节点。

4. 得益于 Cloudflare 的全球网络基础设施，与自建 VPS 相比，Cloudflare Workers 能够利用 Cloudflare 的边缘计算资源，让用户的请求在离他们最近的数据中心处理，从而实现更快的内容加载速度和更低的响应时间。
 