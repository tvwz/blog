---
categories: [计算机网络, 建站]
date: 2024-02-18 09:38:00 +0800
last_modified_at: 2024-02-22 13:24:00 +0800
tags:
- Cloudflare
- Worker
- GitHub
title: 使用 Cloudflare Worker 镜像 GitHub 站点
image:
  path: /img/cloudflare-workers.webp
---

## Cloudflare Worker 简介

Cloudflare Worker 是 Cloudflare 公司提供的一项服务，它允许开发者在 Cloudflare 的边缘服务器上运行自定义的 JavaScript 代码。通俗地说，它就像是一个小型的服务器，可以在互联网上的不同地点快速执行你编写的代码。

Cloudflare Worker 的主要用途包括网站加速和优化、路由请求、访问控制、CDN 功能增强、网站镜像与转发等。

本文将使用其网站镜像和访问控制的能力，实现 GitHub 站点的镜像，并通过自有域名实现在墙内的访问。

## 镜像 GitHub 站点

### 1.创建 Worker

首先，登录 Cloudflare，切换至<kbd>Workers & Pages</kbd>菜单，点击<kbd>Create Application</kbd>按钮：

![Create Application](/img/image-20240218103029571.webp){: .shadow }

然后，点击<kbd>Create Worker</kbd>按钮新建一个 Worker：

![Create Worker](/img/image-20240218103511253.webp){: .shadow }

接着，设置一个三级域名 [gh.harrisonwang.workers.dev](https://gh.harrisonwang.workers.dev)，点击<kbd>Deploy</kbd>按钮：

![Deploy](/img/image-20240218103833961.webp){: .shadow }

再接着，我们点击<kbd>Edit code</kbd>按钮编辑代码：

![Edit code](/img/image-20240218104251119.webp){: .shadow }

最后，粘贴以下代码片段后，点击<kbd>Save and Deploy</kbd>完成部署，然后通过域名 [gh.harrisonwang.workers.dev](https://gh.harrisonwang.workers.dev) 访问镜像站：

```javascript
// 你要镜像的网站.
const upstream = 'github.com'

// 镜像网站的目录，比如你想镜像某个网站的二级目录则填写二级目录的目录名，镜像 google 用不到，默认即可.
const upstream_path = '/'

// 镜像站是否有手机访问专用网址，没有则填一样的.
const upstream_mobile = 'github.com'

// 屏蔽国家和地区.
const blocked_region = ['KP', 'SY', 'PK', 'CU']

// 屏蔽 IP 地址.
const blocked_ip_address = ['0.0.0.0', '127.0.0.1']

// 镜像站是否开启 HTTPS.
const https = true

// 文本替换.
const replace_dict = {'$upstream': '$custom_domain', '//github.com': ''}

// 以下保持默认，不要动
addEventListener('fetch', event => {
  event.respondWith(fetchAndApply(event.request))
})

async function fetchAndApply(request) {
  const region = request.headers.get('cf-ipcountry').toUpperCase()
  const ip_address = request.headers.get('cf-connecting-ip')
  const user_agent = request.headers.get('user-agent')

  let response = null
  let url = new URL(request.url)
  let url_hostname = url.hostname

  if (https == true) {
    url.protocol = 'https:'
  } else {
    url.protocol = 'http:'
  }

  if (await device_status(user_agent)) {
    var upstream_domain = upstream
  } else {
    var upstream_domain = upstream_mobile
  }

  url.host = upstream_domain
  if (url.pathname == '/') {
    url.pathname = upstream_path
  } else {
    url.pathname = upstream_path + url.pathname
  }

  if (blocked_region.includes(region)) {
    response = new Response('Access denied: WorkersProxy is not available in your region yet.', {
      status: 403
    })
  } else if (blocked_ip_address.includes(ip_address)) {
    response = new Response('Access denied: Your IP address is blocked by WorkersProxy.', {
      status: 403
    })
  } else {
    let method = request.method
    let request_headers = request.headers
    let new_request_headers = new Headers(request_headers)

    new_request_headers.set('Host', url.hostname)
    new_request_headers.set('Referer', url.hostname)

    let original_response = await fetch(url.href, {
            method: method,
            headers: new_request_headers
    })

    let original_response_clone = original_response.clone()
    let original_text = null
    let response_headers = original_response.headers
    let new_response_headers = new Headers(response_headers)
    let status = original_response.status

    new_response_headers.set('access-control-allow-origin', '*')
    new_response_headers.set('access-control-allow-credentials', true)
    new_response_headers.delete('content-security-policy')
    new_response_headers.delete('content-security-policy-report-only')
    new_response_headers.delete('clear-site-data')
    
    const content_type = new_response_headers.get('content-type')
    if (content_type.includes('text/html') && content_type.includes('UTF-8')) {
      original_text = await replace_response_text(original_response_clone, upstream_domain, url_hostname)
    } else {
      original_text = original_response_clone.body
    }

    response = new Response(original_text, {
      status,
      headers: new_response_headers
    })
  }
  return response
}

async function replace_response_text(response, upstream_domain, host_name) {
  let text = await response.text()

  var i, j
  for (i in replace_dict) {
    j = replace_dict[i]

    if (i == '$upstream') {
      i = upstream_domain
    } else if (i == '$custom_domain') {
      i = host_name
    }

    if (j == '$upstream') {
      j = upstream_domain
    } else if (j == '$custom_domain') {
      j = host_name
    }

    let re = new RegExp(i, 'g')
    text = text.replace(re, j)
  }
  return text
}

async function device_status(user_agent_info) {
  var agents = ["Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod"]
  var flag = true
  for (var v = 0; v < agents.length; v++) {
    if (user_agent_info.indexOf(agents[v]) > 0) {
      flag = false
      break
    }
  }
  return flag
}
```

至此，镜像 GitHub 站点已完成，我们任意搜索一个 `strapi` 的开源库，搜索结果如下图图所示。但是由于国内 `workers.dev` 域名的 DNS 已污染导致无法访问，所以需要绑定一个自定义域名来绕过该问题。

![访问镜像站](/img/image-20240218105000144.webp){: .shadow }

### 2.绑定自定义域名

首先，点击<kbd>Add Custom Domain</kbd>添加一个自定义域名：

![添加自定义域名](/img/image-20240218110021092.webp){: .shadow }

然后，输入要绑定自定义域名如 [gh.wss.so](https://gh.wss.so)，点击<kbd>Add Custom Domain</kbd>绑定：

![绑定自定义域名](/img/image-20240218110354890.webp){: .shadow }

最后，等待 DNS 解析生效，然后使用 [gh.wss.so](https://gh.wss.so) 域名访问：

![访问镜像站](/img/image-20240218111050210.webp){: .shadow }
