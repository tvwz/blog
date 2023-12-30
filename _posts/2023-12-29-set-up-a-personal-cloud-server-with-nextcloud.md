---
categories: [操作系统, 云盘]
date: 2023-12-29 14:03:00 +0800
last_modified_at: 2023-12-30 14:55:00 +0800
tags:
- Nextcloud
- 云盘
- Nginx
- MySQL
- PHP
title: 使用 Nextcloud 搭建个人云盘服务
---

为了充分利用 VPS 服务器的资源，我决定在个人博客 Jekyll 的基础之上，搭建一个基于 Nextcloud 的个人云盘服务。本站此前发布过一篇[《如何使用 ownCloud 搭建私有云盘》](https://xiaowangye.org/posts/how-to-install-and-configure-owncloud-on-centos-7/)的文章。

Nextcloud 是由 ownCloud 创始人 Frank Karlitschek 于 2016 年创建。 Nextcloud 使用 PHP 和 JavaScript 编写，可帮助您通过桌面和移动设备同步、共享、访问您的数据并进行协作，它基于 Linux 系统构建。

本文在 Ubuntu 22.04 上使用 MySQL 8、PHP 8 和 Nginx 完成 Nextcloud 28.0.1 版本的云盘搭建。

> Nextcloud 28.0.1 版本要求 PHP 8.1，官方建议使用 MySQL 8。
{: .prompt-warning }

前提条件：

- MySQL 8
- PHP 8
- Nginx

## 1.安装 MySQL 8

### 1.1. 安装 MySQL

```bash
$ sudo apt install mysql-server
```

查看 MySQL 服务状态：

```bash
$ sudo systemctl status mysql
```

### 1.2.配置 MySQL

创建 nextcloud 库：

```mysql
mysql> CREATE DATABASE nextcloud DEFAULT CHARACTER SET utf8mb4;
```

创建 nextcloud 专用用户，并分配 nextcloud 库的权限：

```mysql
mysql> CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'nextcloud';
mysql> GRANT ALL PRIVILEGES ON nextcloud.* TO nextcloud@'localhost';
```

刷新权限，使之立即生效：

```mysql
mysql> FLUSH PRIVILEGES;
```

## 2.安装 PHP 8

安装 php8.1：

```bash
$ sudo apt install --no-install-recommends php8.1
```

> `--no-install-recommends` 表示只安装必须的软件包。
{: .prompt-tip }

安装 php8.1-fpm：

```bash
$ sudo apt install --no-install-recommends php8.1-fpm
```

> PHP-FPM（FastCGI Process Manager）是一个 FastCGI 进程管理器，用于管理 PHP 进程。
{: .prompt-tip }

安装 Nextcloud 需要用到的 php 扩展：

```bash
$ sudo apt install php8.1 php8.1-cli php8.1-common php8.1-json php8.1-fpm php8.1-curl \
    php8.1-mysql php8.1-gd php8.1-opcache php8.1-xml php8.1-zip php8.1-mbstring
```

## 3.安装 SSL 证书

使用 acme.sh 脚本生成免费的 SSL 证书，acme.sh 安装详见 [《如何给网站添加免费的 SSL/TLS 证书？》](https://xiaowangye.org/posts/how-to-apply-for-a-free-ssl-certificate-using-acme.sh/#21%E5%AE%89%E8%A3%85-acmesh:~:text=2.1.%E5%AE%89%E8%A3%85%20acme,%E4%BB%A5%E4%B8%8B%E7%9A%84%E5%91%BD%E4%BB%A4%EF%BC%9A)文章。

**1.生成证书**

   ```bash
   $ acme.sh --issue -d drive.xiaowangye.org \
   	--webroot /var/www/nextcloud --force
   ```

> `--force`: 表示强制颁发新的证书
{: .prompt-tip }

**2.安装证书**

新建证书安装目录：

```bash
$ mkdir -p /etc/certs
```

安装证书并重启 Nginx，使证书生效：

```bash
$ acme.sh --install-cert -d drive.xiaowangye.org \
         --key-file /etc/certs/drive.xiaowangye.org.key \
         --fullchain-file /etc/certs/drive.xiaowangye.org.pem \
         --reloadcmd "systemctl restart nginx"
```

查看已安装的证书：

```bash
$ acme.sh --info -d drive.xiaowangye.org
```

## 4.安装和配置 Nextcloud

下载 Nextcloud

```bash
$ wget https://download.nextcloud.com/server/releases/nextcloud-28.0.1.zip
```

解压包到指定目录：

```bash
$ unzip nextcloud-28.0.1.zip -d /var/www/
```

然后，创建存放数据的目录：

```bash
$ mkdir -p /var/www/nextcloud/data
```

修改目录权限：

```bash
$ chown -R www-data:www-data /var/www/nextcloud/config
$ chown -R www-data:www-data /var/www/nextcloud/apps
$ chown -R www-data:www-data /var/www/nextcloud/data
```

## 5.安装和配置 Nginx

1).安装 Nginx：

```bash
$ sudo apt install nginx
```

2).添加 Nextcloud 的 Nginx 配置：

使用 `vim /etc/nginx/conf.d/drive.xiaowangye.org.conf` 命令编辑配置：

```nginx
upstream php-handler {
    server unix:/var/run/php/php8.1-fpm.sock;
}
server {
    listen 80;
    listen [::]:80;
    server_name drive.xiaowangye.org;
    return 301 https://$server_name:443$request_uri;
}

server {
    listen       443 ssl http2;
    listen       [::]:443 ssl http2;
    server_name drive.xiaowangye.org;
    charset utf-8;
    ssl_certificate /etc/certs/drive.xiaowangye.org.pem;
    ssl_certificate_key /etc/certs/drive.xiaowangye.org.key;

    root /var/www/nextcloud;
    index index.php index.html /index.php$request_uri;

    # 省略其它配置 ...
}
```

3.重启 Nginx 服务

```bash
$ systemctl restart nginx
```

然后，打开 [https://drive.xiaowangye.org](https://drive.xiaowangye.org) 网页根据安装向导完成 Nextcloud 的安装，安装成功的截图如下：

![image-20231230150233708](/img/image-20231230150233708.png){: .shadow }

当然，我们也可以通过手机 APP 访问：

![img](/img/image-20231230151533701.jpg){: w="300" h="400" .shadow}
