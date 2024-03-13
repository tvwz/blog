---
categories: [计算机网络, 建站]
date: 2024-03-13 12:30:00 +0800
last_modified_at: 2024-03-13 14:10:00 +0800
tags:
- Cloudflare
- Pages
- D1
title: 如何使用 Cloudflare Pages 自建短链接服务？
---

## 短链接是什么？

短链接又称短网址，意思就是比较短的网址。短链接服务通过将一个冗长的网址转换成一个短网址。

短链接服务通常会提供以下功能：

- 生成短链接：用户可以输入长 URL 地址，短链接服务会自动生成相应的短链接。
- 跳转到原始URL：当用户访问短链接时，短链接服务会将其重定向到原始URL。
- 统计访问数据：短链接服务通常会提供访问短链接的次数等统计数据。

## 短链接有什么优点和缺点？

短链接通常由以下优点：

- 易于记忆和传播：短链接通常只包含几个字符，因此很容易记忆和传播。
- 美观：短链接通常更加美观，尤其是在社交媒体上发布时。
- 节省空间和流量：在推特、微博、微信公众号、短信等限制字数的应用中，短网址可以缩短字符，规避掉这些限制，节省空间和流量。

但是，使用短链接也存在一些风险，比如可能被用于欺骗或钓鱼，因为用户无法直接看出短链接的目标网站是什么。

## 自建短链接服务

本文使用 Cloudflare Pages 提供的免费服务，自建短链接服务。免费版本支持每天 10 万次请求，日常使用已足够。

前提条件：

- 一个 Cloudflare 账号
- 一个短域名托管到 Cloudflare

### Step 1: Fork linklet 仓库

### Step 2: Cloudflare 控制台配置

1.创建并部署 Pages 应用

登录 Cloudflare 控制台，依次点击 <kbd>Workers & Pages</kbd> > <kbd>Create application</kbd> > <kbd>Pages</kbd> > <kbd>Connect to Git</kbd>，选中 Fork 的仓库完成部署。

2.创建 D1 数据库

依次点击 <kbd>Workers & Pages</kbd> > <kbd>D1</kbd> > <kbd>Create database</kbd> > <kbd>Dashboard</kbd> 进入 D1 控制台页面，输入 Database name 点击 <kbd>Create</kbd> 完成数据库的创建。

然后，点击 <kbd>Console</kbd>输入以下命令完成表的创建：

```sql
DROP TABLE IF EXISTS links;
CREATE TABLE IF NOT EXISTS links (
  `id` integer PRIMARY KEY NOT NULL,
  `url` text,
  `slug` text,
  `ua` text,
  `ip` text,
  `status` int,
  `create_time` DATE
);
DROP TABLE IF EXISTS logs;
CREATE TABLE IF NOT EXISTS logs (
  `id` integer PRIMARY KEY NOT NULL,
  `url` text ,
  `slug` text,
  `referer` text,
  `ua` text ,
  `ip` text ,
  `create_time` DATE
);
```

3.配置 Pages 应用

接着点击进入部署完成的 linklet 项目，在 Cloudflare 控制台依次点击<kbd>Settings</kbd> > <kbd>Functions</kbd> > <kbd>Add bindings</kbd>，并输入 Variable name 值，选择 D1 Database，点击 <kbd>Save</kbd> 保存，设置如下表：

    | Variable name | D1 database |
    | :------------ | :---------- |
    | DB            | linklet     |

为了生效 D1 数据库配置，需 Cloudflare 控制台重新部署 Pages 应用。

### Step 3: 绑定短域名

在 Cloudflare 控制台依次点击 <kbd>Workers & Pages</kbd> > <kbd>linklet</kbd> > <kbd>Custom domains</kbd> > <kbd>Set up a custom domain</kbd>，输入要绑定的短域名点击提交完成域名绑定。

### Step 4: 网页方式使用

打开 [wss.so](https://wss.so) 页面，输入要转换的长网址，点击 <kbd>生成</kbd> 后的短链接如下图所示：

![生成的短链接](/img/image-20240313140439336.png){: .shadow }

### Step 5: API 方式使用

请求：

```http
### 生成随机短链接
POST https://wss.so/create
Content-Type: application/json

{
  "url": "https://ollama.com/blog/how-to-prompt-code-llama"
}

### 生成指定 slug 短链接
POST https://wss.so/create
Content-Type: application/json

{
  "url": "https://ollama.com/blog/how-to-prompt-code-llama",
  "slug": "llama"
}
```

响应：

```json
{
  "slug": "<slug>",
  "link": "http://wss.so/<slug>"
}
```
