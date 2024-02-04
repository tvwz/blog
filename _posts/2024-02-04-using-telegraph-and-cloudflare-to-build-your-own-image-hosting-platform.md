---
categories: [建站]
date: 2024-02-04 17:50:00 +0800
last_modified_at: 2024-02-04 17:50:00 +0800
tags:
- 图床
- Telegraph
- Cloudflare
title: 使用 Telegraph 和 Cloudflare 自建图床
---

在网站、博客和电商平台上，图片是必不可少的元素。这些图片需要存储空间和带宽来支持。对于流量小的站点来说，这还好。但如果是大流量的站点，将产生一些额外的存储和带宽费用，不太划算。针对这种情况，我们往往可以采取外链图片的方式。

但是，外链图片会占用大量的带宽和服务器资源。因此，大部分站点只供站内观看，不允许外链。而一般可外链图片的站点会给免费用户提供比较少的月流量，使用比较受限，只有成为付费用户之后才能提升外链流量。当然，也有网站专门提供免费外链图片服务。此类网站通常称之为图床，不限流量。

自建图床的常用方式有阿里云 OSS、GitHub、Google Drive 等。本文并不使用这些常用的自建图床方式，而是使用 Telegraph 和 Cloudflare 来自建图床。

## Telegraph 简介

[Telegraph](https://telegra.ph) 是一个免费开源的平台，通过它可以创建和共享图像、视频与文本。

## Cloudflare 简介

[Cloudflare](https://www.cloudflare.com) 是一家全球 CDN 和安全提供商，可以提高网站的性能和安全性。

## 前提条件

- 一个域名
- 一个 Cloudflare 账号
- 一个 GitHub 账号

## 步骤

### 1.Fork Telegraph-Image 仓库

访问 [Telegraph-Image](https://github.com/cf-pages/Telegraph-Image) 仓库地址，fork 到个人仓库：

![Snipaste_2024-02-04_14-54-35](/img/Snipaste_2024-02-04_14-54-35.png){: .shadow }

### 2.创建应用并关联 Fork 的仓库

在 Cloudflare 创建一个应用：

![Snipaste_2024-02-04_14-57-45.png](/img/Snipaste_2024-02-04_14-57-45.png){: .shadow }

然后切换到 Pages 页，点击 <kbd>Connect to Git</kbd> 按钮，选择指定仓库开始安装安装：

![Snipaste_2024-02-04_14-57-45](/img/Snipaste_2024-02-04_14-57-45.png){: .shadow }

安装完成后，可通过 Cloudflare 自动分配的域名访问：

![Snipaste_2024-02-04_15-40-56.png](/img/Snipaste_2024-02-04_15-40-56.png){: .shadow }

### 3.绑定自定义域名

因特殊原因，Cloudflare 分配的域名 *.pages.dev 在国内无法访问，我们可通过绑定自定义域名绕开这个限制：

![Snipaste_2024-02-04_15-38-00.png](/img/Snipaste_2024-02-04_15-38-00.png){: .shadow }

完成绑定后，可通过 [img.xiaowangye.org](https://img.xiaowangye.org) 访问，访问页面如下图：

![Snipaste_2024-02-04_14-40-04.png](/img/Snipaste_2024-02-04_14-40-04.png){: .shadow }

我们测试下图片上传：

![Snipaste_2024-02-04_14-44-30.png](/img/Snipaste_2024-02-04_14-44-30.png){: .shadow }

复制上传后的文件访问地址，可通过浏览器正常打开。

> 因为使用 Cloudflare 的网络，图片的加载速度在某些地区可能得不到保证！
{: .prompt-warning }

### 4.高级配置

#### 4.1.开启图片管理后台

Telegraph-Image 的图片管理功能默认是关闭的，我们需要绑定 KV 命名空间才能使用。

首先，依次点击 <kbd>Workers 和 Pages</kbd> > <kbd>KV</kbd> > <kbd>创建命名空间</kbd>，添加一个名为 `image-hosting` 的命名空间：

![Snipaste_2024-02-04_16-55-48.png](/img/Snipaste_2024-02-04_16-55-48.png){: .shadow }

然后，依次点击 <kbd>Workers 和 Pages</kbd> > <kbd>telegraph-image</kbd> 进入 Pages 设置页面：

![Snipaste_2024-02-04_17-02-52.png](/img/Snipaste_2024-02-04_17-02-52.png){: .shadow }

接着，切换至<kbd>设置</kbd>页签，点击<kbd>函数</kbd>子菜单：

![Snipaste_2024-02-04_16-54-11.png](/img/Snipaste_2024-02-04_16-54-11.png){: .shadow }

绑定我们刚刚创建的命名空间 `image-hosting`：

![Snipaste_2024-02-04_16-54-51.png](/img/Snipaste_2024-02-04_16-54-51.png){: .shadow }

变量名称设置为 `img_url`，KV 命名空间设置为 `image-hosting`。

> 需在部署页面点击 <kbd>重试部署</kbd>才能生效。
{: .prompt-tip }

#### 4.2.开启图片审查

首先，前往 [moderatecontent.com](https://moderatecontent.com) 注册并获得一个免费的用于审查图像内容的 API key：

2.然后，打开 <kbd>Workers 和 Pages</kbd> 的管理页面，依次点击<kbd>设置</kbd> > <kbd>环境变量</kbd> > <kbd>添加环境变量</kbd>

3.添加一个变量名称为 ModerateContentApiKey，值为第 1 步获得的 API key，点击保存即可。

![Snipaste_2024-02-04_17-19-11.png](/img/Snipaste_2024-02-04_17-19-11.png){: .shadow }

> 需在部署页面点击 <kbd>重试部署</kbd>才能生效。
{: .prompt-tip }

#### 4.3.启用后台登录验证

后台登录验证默认也是关闭的，要开启它，需要新增 `BASIC_USER` 和 `BASIC_PASS` 环境变量：

![Snipaste_2024-02-04_17-27-06.png](/img/Snipaste_2024-02-04_17-27-06.png){: .shadow }
