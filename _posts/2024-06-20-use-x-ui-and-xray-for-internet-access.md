---
categories: [计算机网络]
date: 2024-06-20 22:00:00 +0800
last_modified_at: 2024-06-20 23:01:00 +0800
tags:
- 科学上网
- x-ui
- xray
- Cloudflare
- SSL/TLS
- acme.sh
title: 如何使用 x-ui 和 xray 自建节点科学上网
---

## 简介

在国内，想要自由访问互联网资源，科学上网已成为必备技能。在这篇文章中，我将亲自带你一步步配置和使用 x-ui 和 xray，自主搭建属于你自己的科学上网节点，让你在任何地方都能畅享自由的互联网世界。

## 前提条件

在开始之前，你需要准备一台可翻墙的 VPS、一个域名和一个 Cloudflare 账号。

## 操作步骤

### Step 1: 配置 Cloudflare

添加 DNS 配置，确保域名能正常解析到 VPS 服务器。

#### 1.配置 DNS 解析

在 Cloudflare 仪表板中，导航到 **DNS** 选项卡，并添加以下记录：

- **一级域名解析**：添加一个 A 记录，不开启代理，例如：

  ```
  类型：A
  名称：@
  内容：VPS 的 IP 地址
  代理状态：仅 DNS
  ```

- **二级域名解析**：添加一个 A 记录，开启代理，例如：

  ```
  类型：A
  名称：dash
  内容：VPS 的 IP 地址
  代理状态：代理（橙色云图标）
  ```

参考配置如下图所示：

![DNS 设置](/img/image-20240620192809616.png){: .shadow}

> **为什么不使用一个域名？**有两个原因，一是 Cloudflare 开启 DNS 代理后，仅支持代理固定的几个端口，而我希望使用不同的 VPS 端口建立节点；二是 Cloudflare 开启 DNS 代理后，国内访问速度很慢，尤其是对于优质线路的服务器，如搬瓦工 CN2GIA 线路的 VPS，这种速度慢尤其浪费。
{: .prompt-tip }

#### 2. 添加 Origin Rules 规则

为了使用域名 dash.xxx.org 访问节点面板，我们需要添加一条 Origin Rules 规则：

1. 在 Cloudflare 仪表板中，导航到 **规则** > **Origin Rules**。
2. 添加新规则，规则设置如下：
   - **规则名称**：例如 `dash.xxx.org`
   - **主机模式**：`dash.xxx.org`
   - **规则设置**：重写到 VPS 的 `7000` 端口。

#### 3. 设置 SSL/TLS

为了面板能通过 HTTPS 访问，设置 SSL/TLS 加密模式：

1. 在 Cloudflare 仪表板中，导航到 **SSL/TLS** 选项卡。
2. 将 SSL/TLS 加密模式设置为 **灵活**。

### Step 2: 申请免费证书

使用 [acme.sh](https://github.com/acmesh-official/acme.sh) 来申请免费的 SSL 证书。

#### 1.安装 acme.sh

首先，安装 acme.sh：

```bash
$ curl https://get.acme.sh | sh -s email=hi@example.org
```

#### 2.申请证书

接下来，使用以下命令申请证书：

```bash
$ acme.sh --issue -d example.org --standalone
```

> **注意**：此过程依赖于 `socat`，因此需要先安装，使用 `apt install socat` 命令安装。
{: .prompt-tip }

### Step 3: 安装和配置 x-ui

在这一步，我们将安装并配置 x-ui 以便更好地管理你的节点。

#### 1. 安装 x-ui

使用以下命令安装 x-ui：

```bash
$ bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
```

#### 2. 切换 xray 版本

访问你的 x-ui 面板地址 `dash.xxx.com`，并选择最新的 xray 版本。具体步骤如下：

1. 登录 x-ui 面板。
2. 导航到 **系统状态**菜单，点击<kbd>切换版本</kbd>按钮。
3. 选择最新的 xray 版本并应用更改。

#### 3. 新增入站

在 x-ui 中新增一个节点，导航到**入站列表**，点击 <kbd>+</kbd> 按钮添加入站，配置入站信息，如下图：

![入站配置](/img/image-20240620225430694.png){: .shadow}


### Step 4: 客户端使用

服务器已经配置完成，接下来需要在客户端进行配置，以连接到你的服务器。

#### 1. 电脑端使用 V2RayN

1. 下载并安装 [V2RayN](https://github.com/2dust/v2rayN/releases)。
2. 打开 V2RayN，点击 **服务器** > **添加服务器**。
3. 选择 **导入 URL**，并粘贴从 x-ui 面板复制的节点链接地址。
4. 点击 **确定** 保存配置。

#### 2. 移动端使用 V2RayNG

1. 在移动设备上下载并安装 [V2RayNG](https://github.com/2dust/v2rayNG/releases)。
2. 打开 V2RayNG，点击右上角的 **+** 号。
3. 选择 **导入配置**，并粘贴从 x-ui 面板复制的节点链接地址。
4. 保存配置并连接。

## 总结

通过以上步骤，我们成功地利用 x-ui 在 VPS 上自建了一个科学上网的节点。从 Cloudflare 设置到申请免费证书，再到安装配置 x-ui 以及客户端配置，每一步都详细讲解，确保你能快速完成节点搭建并正常使用。希望这篇文章对你有所帮助，祝你使用愉快！