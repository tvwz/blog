---
categories: [计算机网络]
date: 2024-03-11 08:30:00 +0800
last_modified_at: 2024-03-11 09:21:00 +0800
tags:
- VPS
- V2Ray
- 科学上网
- TLS
- Cloudflare
title: 如何使用 V2Ray 和 TLS 科学上网？
---

上一篇文章《如何使用 V2Ray 科学上网？》(https://xiaowangye.org/posts/how-to-use-v2ray-to-access-the-internet-friendly/)，我介绍了如何使用 V2Ray 进行科学上网，但是在强大的 GFW 下，很容易被墙，本文将使用更加隐蔽的方式，使用 HTTPS 服务，进行流量伪装，突破网络限制。

前提条件：

- 一台可科学上网的 VPS 服务器
- 一个域名
- 域名托管到 Cloudflare 并做好服务器的 DNS 解析

## 操作步骤

### 1.下载脚本

```bash
$ wget https://raw.githubusercontent.com/HarrisonWang/v2ray/main/install_v2ray.sh
```

### 2.添加可执行权限

```bash
$ chmod +x install_v2ray.sh
```

### 3.执行安装脚本

```bash
$ ./install_v2ray.sh
```

选择**安装V2ray-VMESS+WS+TLS(推荐)**选项：

```bash
#############################################################
#                   v2ray一键安装脚本                       #
# 作者: 网络跳越(hijk)                                      #
# 维护: ifeng                                               #
# 网址: https://www.hicairo.com                             #
# TG群: https://t.me/HiaiFeng                               #
#                                                           #
#  向网络跳越致敬！！！                                     #
#  该脚本原作者为网络跳越，好像已经停止维护。该脚本默认     #
#  支持BBR加速，支持ipv6连接。目前由ifeng修改Bug进行维护。  #
#                                                           #
#############################################################
  1.   安装V2ray-VMESS
  2.   安装V2ray-VMESS+mKCP
  3.   安装V2ray-VMESS+TCP+TLS
  4.   安装V2ray-VMESS+WS+TLS(推荐)
  5.   安装V2ray-VLESS+mKCP
  6.   安装V2ray-VLESS+TCP+TLS
  7.   安装V2ray-VLESS+WS+TLS(可过cdn)
  8.   安装V2ray-VLESS+TCP+XTLS(推荐)
  9.   安装trojan(推荐)
  10.  安装trojan+XTLS(推荐)
 -------------
  11.  更新V2ray
  12.  卸载V2ray
 -------------
  13.  启动V2ray
  14.  重启V2ray
  15.  停止V2ray
 -------------
  16.  查看V2ray配置
  17.  查看V2ray日志
 -------------
  0.   退出
 当前状态：未安装

 请选择操作[0-17]：4
```

然后，依次依次输入 **y**、伪装域名**discover.wss.so**和 Nginx 监听端口**443**：

```bash
V2ray一键脚本，运行之前请确认如下条件已经具备：
  1. 一个伪装域名
  2. 伪装域名DNS解析指向当前服务器ip（149.28.237.232）
  3. 如果/root目录下有 v2ray.pem 和 v2ray.key 证书密钥文件，无需理会条件2

 确认满足按y，按其他退出脚本：y

 请输入伪装域名：discover.wss.so
 伪装域名(host)：discover.wss.so

 请输入Nginx监听端口[100-65535的一个数字，默认443]：
 Nginx端口：443
```

接着，选择输入伪装路径**/discover**，选择伪装站类型 **1**，允许搜索引擎 **y**，并安装 BBR 加速 **y**：

```bash
请输入伪装路径，以/开头(不懂请直接回车)：/discover
 ws路径：/discover

 请选择伪装站类型:
   1) 静态网站(位于/usr/share/nginx/html)
   2) 小说站(随机选择)
   3) 美女站(http://www.kimiss.com)
   4) 高清壁纸站(https://www.wallpaperstock.net)
   5) 自定义反代站点(需以http或者https开头)
  请选择伪装网站类型[默认:高清壁纸站]1
 伪装网站：

  是否允许搜索引擎爬取网站？[默认：不允许]
    y)允许，会有更多ip请求网站，但会消耗一些流量，vps流量充足情况下推荐使用
    n)不允许，爬虫不会访问网站，访问ip比较单一，但能节省vps流量
  请选择：[y/n]y
 允许搜索引擎：y

 是否安装BBR(默认安装)?[y/n]:y
 安装BBR：y
```

安装完成后，将输出 V2Ray 配置信息：

```bash
 V2ray运行状态：已安装 V2ray正在运行, Nginx正在运行
 V2ray配置文件:  /etc/v2ray/config.json
 V2ray配置信息：
   协议:  VMess
   IP(address):  149.28.237.232
   端口(port)：443
   id(uuid)：4617d833-30c8-4669-8cae-2b43ca848328
   额外id(alterid)： 0
   加密方式(security)： none
   传输协议(network)： ws
   伪装类型(type)：none
   伪装域名/主机名(host)/SNI/peer名称：discover.wss.so
   路径(path)：/discover
   底层安全传输(tls)：TLS

   vmess链接: vmess://eyAidiI6IjIiLCAicHMiOiIiLCAiYWRkIjoiMTQ5LjI4LjIzNy4yMzIiLCAicG9ydCI6IjQ0MyIsICJpZCI6IjQ2MTdkODMzLTMwYzgtNDY2OS04Y2FlLTJiNDNjYTg0ODMyOCIsICJhaWQiOiIwIiwgIm5ldCI6IndzIiwgInR5cGUiOiJub25lIiwgImhvc3QiOiJkaXNjb3Zlci53c3Muc28iLCAicGF0aCI6Ii9kaXNjb3ZlciIsICJ0bHMiOiJ0bHMiIH0=
```

### 4.使用 V2RayN 客户端

我们将上面的**vmess连接**复制后导入到 V2RayN 客户端：

![导入 V2RayN 客户端](/img/image-20240311084835248.png){: .shadow }

依次点击<kbd>服务器</kbd> > <kbd>从剪贴板导入批量URL</kbd>，导入完成后将其设置为活动服务器：

![设置为活动服务器](/img/image-20240311085300325.png){: .shadow }

### 5.加速 VPS 的访问速度

首先，我们加入**CF中IP发布**的 Telegram 频道 [cf_push](https://t.me/cf_push)，来获取最新（代理了 Cloudflare IP的）优选 IP 列表。

> 替换 CloudflareSpeedTest 安装目录下的 ip.txt 文件内容，记得删除结尾的空行！
{: .prompt-tip }

然后，使用工具[CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest/releases/latest)筛选延迟低和下载速度快的优选 IP，执行以下命令：

```powershell
# 进行 CloudflareSpeedTest 主目录
cd E:\Downloads\CloudflareST_windows_amd64

# 然后执行命令测试优选IP列表，记得关闭 V2RayN 代理
CloudflareST.exe -url https://download.parallels.com/desktop/v17/17.1.1-51537/ParallelsDesktop-17.1.1-51537.dmg
```

刷选优选 IP 的结果如下：

```powershell
# XIU2/CloudflareSpeedTest v2.2.5

开始延迟测速（模式：TCP, 端口：443, 范围：0 ~ 9999 ms, 丢包：1.00)
362 / 362 [------------------------------------------------------------------------------------------------] 可用: 67
开始下载测速（下限：0.00 MB/s, 数量：10, 队列：10）
10 / 10 [--------------------------------------------------------------------------------------------------]
IP 地址           已发送  已接收  丢包率  平均延迟  下载速度 (MB/s)
8.212.64.214      4       4       0.00    42.36     0.45
47.57.14.118      4       4       0.00    45.66     0.25
8.217.147.230     4       4       0.00    29.33     0.00
8.212.41.98       4       4       0.00    42.30     0.00
47.245.42.162     4       4       0.00    119.22    0.00
47.245.9.228      4       4       0.00    122.34    0.00
47.245.30.144     4       4       0.00    126.27    0.00
47.74.6.55        4       4       0.00    135.25    0.00
8.222.164.44      4       4       0.00    197.03    0.00
8.222.154.50      4       4       0.00    201.51    0.00

完整测速结果已写入 result.csv 文件，可使用记事本/表格软件查看。
按下 回车键 或 Ctrl+C 退出。
```

最后，将优选出来的IP **8.212.64.214** 配置到 V2RayN 客户端：

![配置优选IP](/img/image-20240311091949284.png){: .shadow }

> 如何确定 IP 有没有代理 Cloudflare IP？访问 `http://<ip>/cdn-cgi/trace` 即可。
