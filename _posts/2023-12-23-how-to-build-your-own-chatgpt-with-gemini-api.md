---
categories: [编程语言, Node.js]
date: 2023-12-23 10:31:00 +0800
last_modified_at: 2023-12-23 12:28:00 +0800
tags:
- Gemini
- ChatGPT
- Vercel
- GitHub
- Google
title: 如何基于 Gemini API 搭建专属 ChatGPT？
---

Gemini 是一个由 Google 开发的大型语言模型，支持多模态（文字，图片，音频，视频等等）处理。美国时间 2023 年 12 月 13 日，Gemini API 对公众开放，免费版每秒支持最多 60 次 API 调用，足以满足个人学习和使用。本文所搭建的 ChatGPT 网站就是基于 Gemini API 完成的。 关于 Gemini 的详细信息见官方介绍：[https://blog.google/technology/ai/google-gemini-ai](https://blog.google/technology/ai/google-gemini-ai)。

## 前提条件

- 一个科学上网工具
- 一个 Google 账号
- 一个 GitHub 账号
- 一个 Vercel 账号
- 一个专属域名

## 操作步骤

### 1.创建 Gemini API key

![image-20231223105302998](/img/image-20231223105302998.png){: .shadow }

打开 [https://makersuite.google.com](https://makersuite.google.com) 站点，依次点击 <kbd>Get API Key</kbd> > <kbd>Create API key in new project</kbd> 按钮创建并记录 API key。

> Google 的站点国内无法直接访问，需要搭梯子，请自行解决。
{: .prompt-tip }

### 2.部署到 Vercel

首先，打开 GitHub 上开源的 [GeminiProChat 仓库](https://github.com/babaohuang/GeminiProChat)，仓库首页下拉到部署章节，点击 <kbd>Deploy</kbd> 按钮跳转到 Vercel 部署页面：

> 备用仓库：https://github.com/HarrisonWang/gemini-pro-chat
{: .prompt-info }

![image-20231223110856849](/img/image-20231223110856849.png){: .shadow }

然后，依次点击 <kbd>Create</kbd> > <kbd>Deploy</kbd> 进行部署：

![image-20231223110737533](/img/image-20231223110737533.png){: .shadow }

部署页面将提示输入 Gemini API Key，完成部署后，Vercel 会生成一个域名：

![image-20231223111712224](/img/image-20231223111712224.png){: .shadow }

通过该域名可访问到应用，如下图所示：

![image-20231223111922357](/img/image-20231223111922357.png){: .shadow }

然而，很不幸的是 Google PaLM API 在我国境内是无法直接使用的，我们输入内容后点击发送，系统将提示 `User location is not supported for the API use.`。

不过没关系，已经有非常热心的开发者开源了解决方案 [palm-proxy](https://github.com/antergone/palm-proxy)，其原理就是使用 Vercel Edge 进行反向代理。 我们通过以下步骤来解决这个问题：

1. 打开 https://github.com/antergone/palm-proxy 仓库地址并点击 <kbd>Deloy With Vercel</kbd>

2. 完成部署后，记录 Vercel 分配的访问域名（如：`https://xxx.vercel.app`）

3. 设置 `API_BASE_URL` 环境变量（变量值为上一步分配的域名）

   ![image-20231223114222366](/img/image-20231223114222366.png){: .shadow }

4. 重新部署 Gemini Pro Chat 应用

   ![image-20231223114730529](/img/image-20231223114730529.png){: .shadow }

至此，我们的专属 ChatGPT 就搭建完成了，如下图所示，我们可以像和 ChatGPT 一样进行聊天：

![image-20231223115303158](/img/image-20231223115303158.png){: .shadow }

是不是很简单，不过还有个问题，国内由于某些特殊原因，无法访问 `*.vercel.app` 的域名，如果你需要在国内就能使用，这就需要准备一个专属域名了。

### 3.绑定专属域名

首先，我们回到 Vercel 首页，配置应用专属域名：

![image-20231223120146151](/img/image-20231223120146151.png){: .shadow }

然后，点击 <kbd>Manage Domains</kbd> 进入页面绑定专属域名，如下图所示我添加的是 gemini.xiaowangye.org 专属域名：

![image-20231223120338084](/img/image-20231223120338084.png){: .shadow }

最后，在 DNS 服务提供商处添加专属域名的 CNAME 记录：

![image-20231223121023832](/img/image-20231223121023832.png){: .shadow }

DNS 生效后，可通过 [https://gemini.xiaowangye.org](https://gemini.xiaowangye.org) 专属域名访问：

![image-20231223121358809](/img/image-20231223121358809.png){: .shadow }

>  访问域名出现 **DNS_PROBE_FINISHED_NXDOMAIN** ，是因为国内 DNS 同步需要点时间，请耐心等待。
{: .prompt-tip }
