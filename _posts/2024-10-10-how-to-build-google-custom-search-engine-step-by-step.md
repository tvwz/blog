---
categories: [计算机网络, 建站]
date: 2024-10-10 08:09:00 +0800
last_modified_at: 2024-10-10 08:40:00 +0800
tags:
- Search
- Google CSE
- Cloudflare Pages
title: 如何使用 Google CSE 快速搭建一个搜索引擎
---

Google CSE 的全称是 **Google Custom Search Engine**，即 Google 自定义搜索引擎。它允许用户创建一个自定义的搜索引擎，专门搜索特定的网站或网页集合。通过 Google CSE，用户可以定义特定的搜索范围、调整搜索结果的呈现方式，并嵌入到网站或应用中使用。

## 一、创建自定义搜索引擎

访问 [Google CSE](https://programmablesearchengine.google.com/controlpanel/all)，点击创建自定义搜索引擎，命名为 `Seekr`，勾选`在整个网络中搜索`，点击完成创建。点击打开 `Seekr` 搜索引擎概览页面，复制搜索引擎 ID。

## 二、Fork 仓库

打开 [luxirty-search](https://github.com/harrisonwang/luxify-search) 项目，点击 `Fork` 按钮，将项目 Fork 到自己的仓库。

## 三、部署到 Cloudflare Pages

创建一个 Cloudflare Pages 项目，将上一步 Fork 的仓库部署到 Cloudflare Pages。构建配置设置如下：

- 构建命令：`npm run build`
- 构建输出：`dist`

接着设置变量和机密，添加一个名为 `VITE_GOOGLE_CSE_CX` 的变量，值为第一步复制的搜索引擎 ID。

点击 `重试部署` 重新部署项目。部署完成后，访问 `https://<your-username>.pages.dev` 即可看到自定义搜索引擎。

为了方便记忆，绑定一个自定义域名，比如 [s.xiaowangye.org](https://s.xiaowangye.org)。

## 四、屏蔽低质量站点

排除低质量站点，增强搜索结果，依次点击 `概览` > `搜索功能` > `添加要排除的站点`，添加以下站点：

- *.51cto.com
- developer.huaweicloud.com
- developer.aliyun.com
- cloud.baidu.com
- cloud.tencent.com
- blog.csdn.net

## 五、添加单站点搜索

依次点击 `搜索功能` > `优化` > `添加优化标签`，比如 `V2EX`：

- `优化标签名称：V2EX`
- 勾选 `更改具有次优化标签的网站的优先级`
- 展开高级设置，设置重写查询字词 `site:v2ex.com`，点击保存

## 六、添加多站点搜索

依次点击 `搜索功能` > `优化` > `添加优化标签`，比如 `V2EX` 和 `Linux.do`：

- `优化标签名称：V2EX`
- 勾选 `更改具有次优化标签的网站的优先级`
- 展开高级设置，设置重写查询字词 `(site:v2ex.com OR site:linux.do)`，点击保存

## 七、添加专用搜索

比如对于程序员而言，我们可以排除多个低质量站点，设置重写查询字词：

- `优化标签名称：V2EX`
- 勾选 `更改具有次优化标签的网站的优先级`
- 展开高级设置，设置重写查询字词 `-site:51cto.com -site:developer.huaweicloud.com -site:cloud.baidu.com -site:developer.aliyun.com -site:cloud.tencent.com -site:blog.csdn.net`，点击保存

## 结语

通过以上步骤，我们就可以快速搭建一个自定义搜索引擎，并且可以方便地添加单站点搜索、多站点搜索和专用搜索。与 Google 搜索相比，自定义搜索引擎可以更好地提高搜索质量，提升搜索体验。

## 参考

- [v2ex 论坛](https://www.v2ex.com/t/1078147)
- [Google Custom Search Engine](https://programmablesearchengine.google.com/controlpanel/all)
- [luxify-search](https://github.com/KoriIku/luxirty-search)
