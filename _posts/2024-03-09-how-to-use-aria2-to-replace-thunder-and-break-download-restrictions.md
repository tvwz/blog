---
categories: [计算机网络]
date: 2024-03-09 12:04:00 +0800
last_modified_at: 2024-03-09 20:09:00 +0800
tags:
- Aria2
- 迅雷
- Ar­i­aNg
- Docker
title: 使用 Aria2 替代迅雷，突破迅雷文件无法下载限制
---

在日常生活中，我们经常需要下载一些电影资源以进行娱乐休闲，而迅雷作为一个常用的下载工具，却会因为版权问题而导致部分资源无法下载，给我们带来不小的麻烦。为了解决这个问题，我们需要寻找替代迅雷的方法，以完成受限制资源的下载。在本文中，我们将为大家介绍如何使用 Aria2 等工具，来突破迅雷的限制，实现资源的自由下载。

前提条件：

- 一台 Windows 11 电脑
- Windows 11 已通过 WSL 2 安装 Ubuntu 22.04

## Aria2 是什么？

Aria2 是一款下载工具，它支持 BT、磁力、HTTP、FTP 等下载协议，常用做离线下载的服务端。

## 使用本地方式安装 Aria2

1.下载安装脚本：

```bash
$ wget git.io/aria2.sh
```

2.添加可执行权限：

```bash
$ chmod +x aria2.sh
```

3.执行脚本：

```bash
$ ./aria2.sh
```

4.选择你要执行的选项：

```bash
 Aria2 一键安装管理脚本 增强版 [v2.7.4] by P3TERX.COM
 
  0. 升级脚本
 ———————————————————————
  1. 安装 Aria2
  2. 更新 Aria2
  3. 卸载 Aria2
 ———————————————————————
  4. 启动 Aria2
  5. 停止 Aria2
  6. 重启 Aria2
 ———————————————————————
  7. 修改 配置
  8. 查看 配置
  9. 查看 日志
 10. 清空 日志
 ———————————————————————
 11. 手动更新 BT-Tracker
 12. 自动更新 BT-Tracker
 ———————————————————————

 Aria2 状态: 已安装 | 已启动

 自动更新 BT-Tracker: 已开启

 请输入数字 [0-12]:1
```

5.输入1安装，安装后的提示信息如下：

```bash
Aria2 简单配置信息：

 IPv4 地址      : 158.247.205.221
 IPv6 地址      : IPv6 地址检测失败
 RPC 端口       : 6800
 RPC 密钥       : 4b3909484fa9394c79cb
 下载目录       : /root/downloads
 AriaNg 链接    : https://ariang.js.org/#!/settings/rpc/set/ws/158.247.205.221/6800/jsonrpc/NGIzOTA5NDg0ZmE5Mzk0Yzc5Y2I=

[信息] Aria2 启动成功 !
```

我们使用其提供的[公共 AriaNg 链接](https://ariang.js.org/#!/settings/rpc/set/ws/158.247.205.221/6800/jsonrpc/NGIzOTA5NDg0ZmE5Mzk0Yzc5Y2I=)，当作前端面板使用。

![公共 AriaNg 面板界面](/img/image-20240309204459795.png){: .shadow }

> Ar­i­aNg 只是一个静态网页，只负责发送指令给 Aria2 服务端，所填写的 RPC 地址和 RPC 密钥等设置数据只会储存在本地浏览器中，不管是在本地直接打开使用，还是访问在线网页使用，都只是本地浏览器到远端 Aria2 服务的 RPC 协议通讯。
{: .prompt-tip }

## 使用 Docker 方式安装 Aria2

### 1.Docker 安装

安装所需的软件包：

```bash
$ sudo apt update
$ sudo apt install ca-certificates curl gnupg lsb-release
```

获取 Docker 的官方 GPG 密钥：

```bash
$ sudo mkdir -p /etc/apt/keyrings
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

添加 Docker 官方软件源：

```bash
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

安装 Docker：

```bash
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

检查版本：

```bash
$ docker -v
Docker version 24.0.7, build afdd53b
```

### 2.使用 Docker 安装 Aria2

后端安装：

```bash
docker run -d \
--name aria2-pro \
--restart unless-stopped \
--log-opt max-size=1m \
-e PUID=$UID \
-e PGID=$GID \
-e UMASK_SET=022 \
-e RPC_SECRET=<TOKEN> \
-e RPC_PORT=6800 \
-e LISTEN_PORT=6888 \
-p 6800:6800 \
-p 6888:6888 \
-p 6888:6888/udp \
-v $PWD/aria2-config:/config \
-v $PWD/aria2-downloads:/downloads \
p3terx/aria2-pro
```

> 请记得替换 **TOKEN** 值
{: .prompt-tip }

### 3.使用 Docker 安装 Ar­i­aNg

AriaNg 的一款热门的前端面板，用做下载的前端页面。我们使用以下 docker 命令安装 AriaNg：

```bash
docker run -d \
--name ariang \
--log-opt max-size=1m \
--restart unless-stopped \
-p 6880:6880 \
p3terx/ariang
```

最后，打开 [https://158.247.205.221:6880](https://158.247.205.221:6880) 地址后显示如下：

![Docker 搭建的 AriaNg 面板](/img/image-20240309203827922.png){: .shadow }
