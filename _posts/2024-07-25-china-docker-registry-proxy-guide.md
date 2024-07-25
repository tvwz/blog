---
categories: [计算机网络]
date: 2024-07-25 14:14:00 +0800
last_modified_at: 2024-07-25 14:40:00 +0800
tags:
- Docker
- Cloudflare
- Worker
- Nginx
- OpenResty
- 代理
title: 解决国内无法下载 Docker 镜像的问题
---

由于 Docker Hub 被国内封锁，如果需要拉取 Docker 官方镜像，目前有两种方式，自建镜像代理站和直接使用代理来解决。

## 一、Docker 拉取镜像请求分析

目前网上流传的 Docker 镜像代理方式主要分为 Nginx 和 Cloudflare Worker 两种方式，本着对技术的好奇心，让我们来分析其原理，然后分别通过 Nginx、OpenResty、Cloudflare Worker 实现 Docker 镜像代理。

为了分析其原理，我们需要先了解 docker pull 命令执行时的网络请求，这里我们首先在 Docker 客户端安装好 mitmproxy 工具。

### 1.mitmproxy 安装和 Docker 客户端配置

#### 1.1.mitmproxy 安装

```bash
# 安装 mitmproxy
$ pip install mitmproxy

# 将 mitmproxy 默认生成的证书添加到信任证书列表
$ cp ~/.mitmproxy/mitmproxy-ca-cert.pem /usr/local/share/ca-certificates/mitmproxy-ca-cert.crt

# 更新系统 CA 证书列表
$ update-ca-certificates

# 启动监听
$ mitmproxy --listen-port 8080
```

#### 1.2.Docker 客户端代理配置

```bash
# 创建目录
$ mkdir -p /etc/systemd/system/docker.service.d

# 编辑 /etc/systemd/system/docker.service.d/http-proxy.conf 文件，添加以下内容：
[Service]
Environment="HTTP_PROXY=http://localhost:8080"
Environment="HTTPS_PROXY=http://localhost:8080"

# 重启 Docker 服务
$ systemctl daemon-reload
$ systemctl restart docker
```

### 2.原理分析

借助 mitmproxy 工具，来抓取 `docker pull hello-world` 时发起的 HTTP 请求，如下图：

![docker pull 请求抓包](/img/image-20240724092538691.png){: .shadow}

Docker 镜像拉取过程中的网络请求主要包含认证、镜像元数据获取、配置文件获取和镜像层下载四个阶段，具体的过程如下：

1. 认证过程：
   - Docker Client 首先向 Docker Registry 发送请求。
   - 收到 401 Unauthorized 响应后，Client 转向 Docker Authentication Server 获取令牌。
   - 获取令牌成功后，后续请求都会带上这个令牌。

2. 镜像元数据获取：
   - Client 先获取镜像的最新摘要（digest）。
   - 然后获取完整的 manifest 数据。
   - 再获取第一个 manifest 的详细信息，包括配置和层信息。

3. 配置文件获取：
   - Client 请求配置文件时，Registry 返回一个 307 重定向。
   - 重定向指向 Cloudflare Docker Registry。

4. 镜像层下载：
   - 对每一层重复类似的过程：
     1. 向 Docker Registry 请求。
     2. 收到 307 重定向。
     3. 从 Cloudflare Docker Registry 下载实际数据。

为了便于理解，我们绘制出 Docker 拉取镜像的网络请求时序图：

![网络请求](/img/image-20240725141732138.svg){: .shadow}

完整的请求和响应参数如下：

#### 2.1.质询请求

客户端请求：

```http
GET https://registry-1.docker.io/v2/ HTTP/1.1
```

服务端响应：

```http
HTTP/1.1 401 Unauthorized
WWW-authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io"

{
  "errors": [
    {
      "code": "UNAUTHORIZED",
      "message": "authentication required",
      "detail": null
    }
  ]
}
```

#### 2.2.获取令牌请求

客户端请求：

```http
GET https://auth.docker.io/token?scope=repository%3Alibrary%2Fhello-world%3Apull&service=registry.docker.io HTTP/1.1
```

服务端响应：

```http
HTTP/1.1 200 OK
content-type: application/json

{
  "token": "<token>",
  "access_token": "<token>",
  "expires_in": 300,
  "issued_at": "2024-07-23T01:04:08.98927365Z"
}
```

#### 2.3.获取镜像摘要

客户端请求：

```http
HEAD https://registry-1.docker.io/v2/library/hello-world/manifests/latest HTTP/1.1
Accept: application/json
Accept: application/vnd.docker.distribution.manifest.v2+json
Accept: application/vnd.docker.distribution.manifest.list.v2+json
Accept: application/vnd.oci.image.index.v1+json
Accept: application/vnd.oci.image.manifest.v1+json
Accept: application/vnd.docker.distribution.manifest.v1+prettyjws
Authorization: Bearer <token>
```

服务端响应：

```http
HTTP/1.1 200 OK
docker-content-digest: <digest>
```

#### 2.4.获取镜像清单

客户端请求：

```http
GET https://registry-1.docker.io/v2/library/hello-world/manifests/<digest> HTTP/1.1
Accept: application/json
Accept: application/vnd.docker.distribution.manifest.v2+json
Accept: application/vnd.docker.distribution.manifest.list.v2+json
Accept: application/vnd.oci.image.index.v1+json
Accept: application/vnd.oci.image.manifest.v1+json
Accept: application/vnd.docker.distribution.manifest.v1+prettyjws
Authorization: Bearer <token>
```

服务端响应：
```http
HTTP/1.1 200 OK
docker-content-digest: <digest>

{
	"manifests": [{
		"annotations": {},
		"digest": "sha256:e2fc4e5012d16e7fe466f5291c476431beaa1f9b90a5c2125b493ed28e2aba57",
		"mediaType": "application/vnd.oci.image.manifest.v1+json",
		"platform": {
			"architecture": "amd64",
			"os": "linux"
		},
		"size": 861
	},{},{},{}],
	"mediaType": "application/vnd.oci.image.index.v1+json",
	"schemaVersion": 2
}
```

#### 2.5.获取首层镜像清单

客户端请求：

```http
GET https://registry-1.docker.io/v2/library/hello-world/manifests/<first_manifest_digest> HTTP/1.1
Accept: application/vnd.docker.distribution.manifest.v1+prettyjws
Accept: application/json
Accept: application/vnd.docker.distribution.manifest.v2+json
Accept: application/vnd.docker.distribution.manifest.list.v2+json
Accept: application/vnd.oci.image.index.v1+json
Accept: application/vnd.oci.image.manifest.v1+json
Authorization: Bearer <token>
```

服务端响应：

```http
HTTP/1.1 200 OK
docker-content-digest: <digest>

{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.image.config.v1+json",
    "digest": "sha256:d2c94e258dcb3c5ac2798d32e1249e42ef01cba4841c2234249495f87264ac5a",
    "size": 581
  },
  "layers": [
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "digest": "sha256:c1ec31eb59444d78df06a974d155e597c894ab4cda84f08294145e845394988e",
      "size": 2459
    },
    {},
    {},
    {}
  ],
  "annotations": {}
}
```

#### 2.6.重定向到获取镜像配置信息地址

客户端请求：

```http
GET https://registry-1.docker.io/v2/library/hello-world/blobs/<config.digest> HTTP/1.1
Authorization: Bearer <token>
```

> `<config.noPrefixDigest>`：包含前缀 `sha256:` 的配置信息摘要
{: .prompt-tip }

服务端响应：

```http
HTTP/1.1 307 Temporary Redirect
Location: https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/d2/<config.noPrefixDigest>/data?verify=<verify>
```

> - `<config.noPrefixDigest>`：去除前缀 `sha256:` 后的配置信息摘要
> - `<verify>`：Docker Registry 生成的验证参数
{: .prompt-tip }

#### 2.7.获取镜像配置信息

客户端请求：

```http
GET https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/d2/<config.noPrefixDigest>/data?verify=<verify> HTTP/1.1
```

> - `<config.noPrefixDigest>` ：去除前缀 `sha256:` 后的配置信息摘要
> - `<verify>`：Docker Registry 生成的验证参数
{: .prompt-tip }

服务端响应：

```http
HTTP/1.1 200 OK
Content-Type: application/ostet-stream
```

#### 2.8.重定向到获取所有镜像层数据地址

> 遍历镜像层所有 digest，循环重定向到获取镜像层数据地址。
{: .prompt-tip }

客户端请求：

```http
GET https://registry-1.docker.io/v2/library/hello-world/blobs/<layers[x].digest> HTTP/1.1
Authorization: Bearer <token>
```

> `layers[x].digest`：包含前缀 `sha256:` 的镜像层摘要
{: .prompt-tip }

服务端响应：

```http
HTTP/1.1 307 Temporary Redirect
Location: https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/c1/<layers[x].noPrefixDigest>/data?verify=<verify>
```

> - `<layers[x].noPrefixDigest>`：去除前缀 `sha256:` 后的镜像层摘要
> - `<verify>`：Docker Registry 生成的验证参数
{: .prompt-tip }

#### 2.9.循环获取所有镜像层数据

客户端请求：

```http
GET https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/c1/<layers[x].noPrefixDigest>/data?verify=<verify> HTTP/1.1
```

> - `<layers[x].noPrefixDigest>`：去除前缀 `sha256:` 后的镜像层摘要
> - `<verify>`：Docker Registry 生成的验证参数
{: .prompt-tip }

服务端响应：

```http
HTTP/1.1 200 OK
Content-Type: application/ostet-stream
```

## 二、自建镜像代理站

### 1.使用 Nginx 自建 Docker 镜像代理

了解完网络请求后，下面我们来分析下 Nginx 实现 Docker 镜像站的原理，Nginx 的配置如下：

```nginx
worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;
  sendfile on;
  keepalive_timeout 65;

  server {
    listen 80;
    listen 443 ssl;
    server_name 410006.xyz;

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/410006.xyz.cer;
    ssl_certificate_key /etc/nginx/ssl/410006.xyz.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Serve the home page
    location / {
      # Docker Hub 的官方镜像仓库地址
      proxy_pass https://registry-1.docker.io;
      proxy_set_header Host registry-1.docker.io;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      # 关闭缓存
      proxy_buffering off;

      # 转发认证相关的头部
      proxy_set_header Authorization $http_authorization;
      proxy_pass_header Authorization;

      # 对 upstream 状态码检查，实现 error_page 错误重定向
      proxy_intercept_errors on;

      # error_page 指令默认只检查了第一次后端返回的状态码，开启后可以跟随多次重定向
      recursive_error_pages on;

      # 根据状态码执行对应操作，以下为 301、302 和 307 状态码都会触发
      error_page 301 302 307 = @handle_redirect;
    }
    
    location @handle_redirect {
      resolver 1.1.1.1;
      set $saved_redirect_location '$upstream_http_location';
      proxy_pass $saved_redirect_location;
    }
  }
}
```

以上配置主要包括：

- 代理所有请求到上游服务器
- 设置上游服务器请求头 Host
- 传递请求头 Authorization 到上游服务器
- 上游服务器 Authorization 响应头传回客户端
- 跟随重定向：Nginx 内部重定向

> 上游服务器：这里指 Docker Registry。
{: .prompt-tip }

同样的，我们还是借助 mitmproxy 工具来抓取使用 Nginx 代理后，Docker 客户端发起的网络请求，以 `docker pull 410006.xyz/library/hello-world` 为例，发起的网络请求如下：

![docker pull 代理请求抓包](/img/image-20240725123159291.png){: .shadow}

使用 Nginx 代理后，通过分析客户端发起的网络请求，得到 Docker 拉取镜像的网络请求时序图如下：

![网络请求时序图](/img/image-20240725141956371.svg){: .shadow}

总结来看，使用 Nginx 可以方便快速的搭建 Docker 镜像代理站，但存在两点不足：

- 一是无法使用 `docker pull redis` 这样的命令拉取镜像，需要携带默认命名空间 library，如：`docker pull library/redis`，这不符合我们日常 docker 命令的使用习惯。

- 二是存在客户端直接发往 docker 认证服务器的请求，一旦 `auth.docker.io` 也被封锁，会导致代理站无法正常使用。

为了解决上面的两个问题，下面我们将 Nginx 换成 OpenResty 或者 Cloudflare Worker 来实现镜像代理。

### 2.使用 OpenResty 自建 Docker 镜像代理

TODO.

### 3.使用 Cloudflare Worker 自建 Docker 镜像代理

使用 Cloudflare Worker 代理后，Docker 拉取镜像的网络请求时序图如下：

![网络请求时序图](/img/image-20240725142757439.svg){: .shadow}

完整的 Worker 脚本内容如下：

```js
const DOCKER_REGISTRY = 'https://registry-1.docker.io'
const PROXY_REGISTRY = 'https://docker.410006.xyz'
const HTML = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" href="https://xiaowangye.org/assets/img/favicons/favicon.ico">
    <title>镜像代理使用说明</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff;
            padding: 20px 0;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }
        .content {
            margin-bottom: 20px;
        }
        .footer {
            text-align: center;
            padding: 20px 0;
            background-color: #333;
            color: #fff;
        }
        pre {
            background-color: #272822;
            color: #f8f8f2;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        code {
            font-family: 'Source Code Pro', monospace;
        }
        a {
            font-weight: bold;
            color: #ffffff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        @media (max-width: 600px) {
            .container {
                margin: 20px;
                padding: 15px;
            }
            .header {
                padding: 15px 0;
            }
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Source+Code+Pro:wght@400;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="header">
        <h1>Docker 镜像代理使用说明</h1>
    </div>
    <div class="container">
        <div class="content">
          <p>拉取镜像</p>
          <pre><code># 拉取 redis 镜像（不带命名空间）
docker pull {:host}/redis

# 拉取 rabbitmq 镜像
docker pull {:host}/library/rabbitmq

# 拉取 postgresql 镜像
docker pull {:host}/bitnami/postgresql</code></pre><p>重命名镜像</p>
          <pre><code># 重命名 redis 镜像
docker tag {:host}/library/redis redis 

# 重命名 postgresql 镜像
docker tag {:host}/bitnami/postgresql bitnami/postgresql</code></pre><p>添加镜像源</p>
          <pre><code># 添加镜像代理到 Docker 镜像源
sudo tee /etc/docker/daemon.json &lt;&lt; EOF
{
  "registry-mirrors": ["https://{:host}"]
}
EOF</code></pre>
        </div>
    </div>
    <div class="footer">
        <p>©2024 <a href="https://xiaowangye.org">xiaowangye.org</a>. All rights reserved. Powered by <a href="https://cloudflare.com">Cloudflare</a>.</p>
    </div>
</body>
</html>
`
addEventListener('fetch', (event) => {
    event.passThroughOnException()
    event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
    const url = new URL(request.url)
    const path = url.pathname
    if (path === '/v2/') {
        return challenge(DOCKER_REGISTRY, url.host)
    } else if (path === '/auth/token') {
        return getToken(url)
    } else if (url.pathname === '/') {
        return home(url.host);
    }

    const parts = path.split('/')
    if (parts.length === 5) {
        parts.splice(2, 0, 'library')
        const newUrl = new URL(PROXY_REGISTRY)
        newUrl.pathname = parts.join('/')
        return Response.redirect(newUrl.toString(), 301)
    }

    return getData(DOCKER_REGISTRY, request)
}

async function challenge(upstream, host) {
    const url = new URL(upstream + '/v2/')
    const response = await fetch(url)
    const responseBody = await response.text()
    const headers = new Headers()
    headers.set('WWW-Authenticate', `Bearer realm="https://${host}/auth/token",service="docker-proxy-worker"`)
    return new Response(responseBody, { 
        status: response.status,
        statusText: response.statusText,
        headers
    })
}

async function getToken(originUrl) {
    let scope = processScope(originUrl)
    const url = new URL('https://auth.docker.io/token')
    url.searchParams.set('service', 'registry.docker.io')
    url.searchParams.set('scope', scope)
    const response = await fetch(url)
    return response
}

async function getData(upstream, req) {
    const originUrl = new URL(req.url)
    const url = new URL(upstream + originUrl.pathname)
    const request = new Request(url, {
        method: req.method,
        headers: req.headers,
        redirect: 'follow'
    })

    const response = await fetch(request)
    return response
}

function processScope(url) {
    let scope = url.searchParams.get('scope')
    let parts = scope.split(':')
    if (parts.length === 3 && !parts[1].includes('/')) {
        parts[1] = 'library/' + parts[1]
        scope = parts.join(':')
    }
    return scope
}

function home(host) {
    return new Response(HTML.replace(/{:host}/g, host), {
        status: 200,
        headers: {
            "Content-Type": "text/html",
        }
    })
}
```

总体实现过程如下：

1. 处理质询请求，并修改 WWW-Authenticate 头以使用代理服务。
2. 处理获取令牌请求，对于 scope 参数，为没有命名空间的镜像添加 library/ 前缀，然后将请求转发到 Docker 的获取令牌服务。
3. 对于没有命名空间的镜像请求，会自动添加 library 命名空间，将请求转发到 Docker Registry 并返回响应或跟随重定向（Worker 内部重定向）后返回响应。


## 三、直接使用代理

#### 1.搭建 Trojan 服务端

```bash
# 下载一键安装脚本
$ wget https://raw.githubusercontent.com/HarrisonWang/v2ray/main/install_v2ray.sh

# 添加可执行权限
$ chmod +x install_v2ray.sh

# 安装
$ ./install_v2ray.sh
```

#### 2.安装 Trojan 客户端

```bash
# 安装 Trojan
$ sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

# 客户端配置
# 编辑配置，替换 your_vps_ip、your_password 和 your_domain.com 为您的实际值。
$ vim /usr/local/etc/trojan/config.json

# 启动
$ systemctl start trojan
```

#### 3.Docker 客户端代理配置

```bash
$ tee /etc/docker/daemon.json << EOF
{
  "proxies": {
    "http-proxy": "socks5://192.168.208.55:1080",
    "https-proxy": "socks5://192.168.208.55:1080",
    "no-proxy": "127.0.0.0/8"
  }
}

$ systemctl restart docker
```

#### 4.测试拉取镜像

```bash
$ docker pull hello-world
Using default tag: latest
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:1408fec50309afee38f3535383f5b09419e6dc0925bc69891e79d84cc4cdcec6
Status: Downloaded newer image for hello-world:latest
docker.io/library/hello-world:latest
```

## 四、附录

1. [Nginx 代理配置](https://gist.github.com/harrisonwang/23f253bfd9dba388e4d84ee5fdc3ab46)

2. TODO：OpenResty 代理脚本

3. [Cloudflare Worker 脚本](https://gist.github.com/harrisonwang/1f0583e65277203364c9c22a44c2ba44)

4. [HTTP 测试脚本](https://gist.github.com/harrisonwang/c735b089c75857aa96e51596e408509b)