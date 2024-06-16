---
categories: [人工智能, LLM]
date: 2024-06-16 01:00:00 +0800
last_modified_at: 2024-06-16 11:44:00 +0800
tags:
- ChatGPT
- ChatGPT Plus
- ChatGPT 4
- Google
- Google Play
- 科学上网
title: 手机端 ChatGPT APP 如何在国内使用
---

## ChatGPT 介绍

ChatGPT 是 OpenAI 公司的开发的一款人工智能聊天机器人程序，而 ChatGPT APP 是其移动端的应用程序。由于 OpenAI 的限制，国内仅台湾地区可正常使用，所以在国内安装和使用 ChatGPT 是一件很麻烦的事情。本文以安卓手机为例，带大家一起完成 ChatGPT APP 的安装和使用，本文主要内容如下：

- 安装 Google Play 商店
  - 实现科学上网
  - 下载并安装 Google Play
- 注册美区 Google 账号
- 注册 ChatGPT 账号
- 安装 ChatGPT APP
- 订阅 ChatGPT Plus
  - Google Play 添加付款方式
  - Google Play 设置美国免税州地址
  - ChatGPT APP 完成订阅
  - 解锁 ChatGPT APP 的使用限制

## 操作步骤

### 1.安装 Google Play 商店

**为什么国内无法正常使用 Google Play 商店？**

自 2010 年以来，由于受“[谷歌退出中国大陆事件](https://zh.wikipedia.org/wiki/%E8%B0%B7%E6%AD%8C%E9%80%80%E5%87%BA%E4%B8%AD%E5%9B%BD%E5%A4%A7%E9%99%86%E4%BA%8B%E4%BB%B6#:~:text=%E8%B0%B7%E6%AD%8C%E9%80%80%E5%87%BA%E4%B8%AD%E5%9B%BD%E5%A4%A7%E9%99%86%E4%BA%8B%E4%BB%B6%E6%98%AF,%E5%A2%83%E5%A4%96%E4%BD%BF%E7%94%A8%E5%85%B6%E4%BA%A7%E5%93%81%5B3%5D%E3%80%82)”的影响，国内销售的手机均无法下载和安装 Google Play 商店，且 Google 旗下产品，无论网站还是应用，基本都被国内[防火长城](https://zh.wikipedia.org/wiki/%E9%98%B2%E7%81%AB%E9%95%BF%E5%9F%8E#:~:text=%E9%98%B2%E7%81%AB%E9%95%BF%E5%9F%8E%5B1,%E6%9C%8D%E5%8A%A1%E7%9A%84%E8%A1%8C%E4%B8%BA%E3%80%82)所屏蔽。因此，要正常使用 Google Play，需使用翻墙工具来突破网络限制，翻墙工具的使用，请参考以下文章：

- [如何使用 V2Ray 科学上网？](https://xiaowangye.org/posts/how-to-use-v2ray-to-access-the-internet-friendly/)
- [利用 V2Ray 结合 WS 和 TLS 进行高效上网](https://xiaowangye.org/posts/v2ray-combined-with-ws-and-tls-for-internet-access/)
- [使用 Cloudflare Workers 自建节点科学上网](https://xiaowangye.org/posts/using-cloudflare-workers-build-proxy-for-internet-access/)
- [使用 Hysteria 自建节点科学上网](https://xiaowangye.org/posts/using-hysteria-build-proxy-for-internet-access/)

> 请选用美国 VPS 来搭建代理工具。
{: .prompt-tip }

**如何下载并安装 Google Play？**

科学上网后，手机浏览器打开 [google.com](https://google.com) 站点，搜索“Google Play 下载”，点击 Google Play 服务下载 Google Play 完成安装，如下图所示：

![Google Play 下载](/img/image-20240615225334997.png){: w="300" h="400" .shadow}

或者使用 [APKPure](https://apkpure.com/) 和 [softonic](https://softonic.com/) 等第三方平台下载 Google Play ，下载地址如下：

- [https://m.apkpure.com/google-play-store/com.android.vending/download](https://m.apkpure.com/google-play-store/com.android.vending/download)
- [https://google-play-store.en.softonic.com/android/download](https://google-play-store.en.softonic.com/android/download)

### 2.注册美区 Google 账号

**如何注册美区 Google 账号？**

科学上网后，打开 [google.com](https://www.google.com) 主页，点击右上角的 <kbd>Sign in</kbd> 按钮，跳转到登录页面，接着点击 <kbd>Create account</kbd> 按钮，选择 For my personal use 切换到创建账号页面，然后依次填入姓名、生日、性别、邮箱和密码等信息创建 Google 账号，最后进入 Gmail 邮箱点击 Google 发送的验证邮件完成注册。

> 如果需要手机验证码验证，可到接码平台 [sms-activate.io](https://sms-activate.io/) 购买短信激活服务，尽量选便宜价格便宜的国家，注册时填入接码平台提供的手机号，然后将接码平台收到的验证码填入，完成 Google 账号注册的验证。
{: .prompt-tip }

### 3.注册 ChatGPT 账号

**如何注册 ChatGPT 账号？**

科学上网后，打开 [chatgpt.com](https://chatgpt.com/) 主页，点击 <kbd>注册</kbd> 按钮到注册页面，接着点击 <kbd>继续使用 Google 登录</kbd> 按钮跳转到 Google 登录页面完成登录，登录成功后将跳转到 [ChatGPT](https://chatgpt.com/) 首页。

### 4.安装 ChatGPT APP

使用刚刚注册的美区 Google 账号登录 Google Play 商店，然后商店中搜索 ChatGPT，点击 <kbd>安装</kbd> 完成 ChatGPT APP 的安装。

> 不要使用中国区 Google 账号登录 Google Play 商店，因为 OpenAI 对中国区没有开放服务，所以中国区 Google Play 搜索不到 ChatGPT APP。
{: .prompt-warning }

### 5.订阅 ChatGPT Plus

因为 ChatGPT 4 的多模态能力、数据分析能力、个性化定制以及在性能、理解能力和知识更新等方面的提升，所以我们需要升级为 ChatGPT Plus 账号来使用 ChatGPT 4。

**如何订阅 ChatGPT Plus？**

当我们想要订阅 ChatGPT Plus 服务时，尽管科学上网后可以正常使用，但因为 OpenAI 对中国不提供服务，我们无法通过官方渠道，用国内的 VISA 卡直接订阅。所以我选择了 Google Play，因为它支持国内 VISA 卡支付，这样就能方便地订阅 ChatGPT Plus。

> 苹果手机用户可注册一个美区的 Apple ID，然后在支付宝购买苹果礼品卡来订阅 ChatGPT Plus。
{: .prompt-tip }

**添加 Google Play 付款方式：**

打开 [Google Play](https://play.google.com/) 主页，点击右上角个人头像图标，接着点击 <kbd>付款和订阅</kbd> 按钮，然后点击添加信用卡或借记卡。最后我们点击 <kbd>设置</kbd> 选项卡，把地址改为美国的免税州地址。

**订阅 ChatGPT Plus 服务：**

在手机端，通过 Google Play 商店安装好 ChatGPT APP 后，使用刚刚注册的 ChatGPT 账号完成登录，接着点击 <kbd>...</kbd> 按钮进入设置界面，然后点击 <kbd>订阅</kbd> 按钮进入订阅界面，最后点击 <kbd>订阅</kbd> 按钮完成 ChatGPT Plus 的订阅。设置页面如下图所示：

![ChatGPT 设置](/img/image-20240616001513916.png){: w="300" h="400" .shadow}

**为什么科学上网后无法正常使用 ChatGPT APP？**

虽然我们开启了科学上网，可正常使用网页版的 ChatGPT，但 ChatGPT APP 还是无法使用，因为我们 VPS 服务器的 IP 地址和机房的 IP 地址不一致触发了 ChatGPT APP 的限制。

**那为什么购买的 VPS 服务器 IP 和机房的 IP 不一致呢？**

这是因为很多 IDC 提供商的 IP 地址，都是从其它国家调配来的，所以就算是翻墙了，也使用了美国的 VPS，但是还是访问不了 ChatGPT APP 服务。为了解决这个问题，我们可通过[在 VPS 服务器上安装 Cloudflare Warp](https://github.com/HarrisonWang/haoel.github.io#104-cloudflare-warp-%E5%8E%9F%E7%94%9F-ip:~:text=%E4%B8%8B%E8%BD%BD%E8%84%9A%E6%9C%AC,%E6%A0%88%E5%85%A8%E5%B1%80%E7%BD%91%E7%BB%9C) 来解锁 ChatGPT APP 的使用限制。