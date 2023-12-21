---
categories:
- 云盘
date: 2023-10-29 20:22:00 +0800
last_modified_at: 2023-10-29 20:42:03 +0800
tags:
- 云盘
- ownCloud
title: 如何使用 ownCloud 搭建私有云盘
---

## 1.OwnCloud 介绍

OwnCloud 是一款用于数据同步和文件共享的开源服务器软件，提供易用的 Web 前端。OwnCloud 可以安装在 Linux 或 Windows 服务器上，易于配置并提供完整的在线文档。客户端支持 Windows、MacOS、Linux、Android 和 iOS。
本文将详细描述如何在 CentOS 7 服务器上安装和配置 ownCloud 10.13，向您展示如何使用 Nginx 和 PHP 7（FPM）以及 MySQL 来配置 ownCloud。

ownCloud 特性：

- 支持 Android、iOS 和桌面端访问文件。
- 支持 Dropbox、S3 和 Google Docs 等外部存储。
- 提供历史版本支持，可以恢复意外删除的文件。

## 2.安装前提

- CentOS 7 服务器
- root 用户权限

## 3.安装步骤

### 3.1.安装 Nginx

在开始安装 Nginx 和 php7-fpm 之前，需要添加 EPEL 库，其中包含 CentOS 基础库中未提供的其他软件。首先，使用以下 yum 命令安装 EPEL：
```shell
$ yum -y install epel-release
```
然后，基于 EPEL 库安装 Nginx：
```shell
$ yum -y install nginx
```
### 3.2.安装和配置 php7-fpm

1.添加 php7-fpm 库

添加 php7-fpm 库，网上有很多 PHP7 库，我们这里使用 webtatic 库：

```shell
$ rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
```
2.安装 php7-fpm 和 ownCloud 依赖包

紧接着，安装 php7-fpm 和一些用于 ownCloud 安装的依赖软件包：

```shell
$ yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-intl php-pecl-zip
```
> 若提示 “失败的软件包是：mysql-community-libs-compat-5.7.43-1.el7.x86_64”，请使用`rpm --import [https://repo.mysql.com/RPM-GPG-KEY-mysql-2022](https://repo.mysql.com/RPM-GPG-KEY-mysql-2022)`命令解决。
{: .prompt-tip }

检查 PHP 版本确保安装成功：
```shell
$ php -v
PHP 7.4.33 (cli) (built: Aug  1 2023 09:00:17) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
```
3.配置 php7-fpm

当前步骤中，我们将配置 php-fpm 与 nginx 一块运行。php7-fpm 将在 nginx 用户下运行，并监听 9000 端口。
使用 vim 编辑默认的 php7-fpm 配置：

```shell
$ vim /etc/php-fpm.d/www.conf
```
在第 24 行和第 26 行中，将 user 和 group 更改为 `nginx`。
```nginx
user = nginx
group = nginx
```
查看第 38 行，确保 php-fpm 在 9000 端口运行。
```nginx
listen = 127.0.0.1:9000
```
取消第 396-400 行的注释，开启 php-fpm 系统环境变量。
```nginx
env[HOSTNAME] = $HOSTNAME 
env[PATH] = /usr/local/bin:/usr/bin:/bin 
env[TMP] = /tmp 
env[TMPDIR] = /tmp 
env[TEMP] = /tmp
```
保存文件并推出编辑器。

接下来，在 /var/lib/ 目录中为 session 创建一个新目录，并将目录所有者更改为 nginx 用户。

```shell
$ mkdir -p /var/lib/php/session 
$ chown nginx:nginx -R /var/lib/php/session/
```
4.启动 php-fpm 和 nginx

启动 php-fpm 和 nginx，然后将其添加到开机自启动。

```shell
$ systemctl start php-fpm
$ systemctl start nginx
 
$ systemctl enable php-fpm
$ systemctl enable nginx
```
至此，php7-fpm 配置已完成。
### 3.3.安装和配置 MySQL

1.下载MySQL

下载 MySQL rpm 包，使用本地安装方式下载安装包及依赖包：

```bash
$ yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
```

2.安装 MySQL

在安装 MySQL 前，建议升级操作系统内核和软件：

```bash
$ yum update
```

完成升级后，使用以下命令重启操作系统：

```bash
$ reboot
```

然后，安装 mysql-community-server 软件包，它将同时安装所需的所有依赖项和工具。

```bash
$ yum install mysql-community-server
```

3.启动 MySQL 

```bash
$ systemctl start mysqld
```

当服务启动后 MySQL 将生成一个随机密码，我们可以输入以下命令找到随机密码：

```bash
$ grep -i password /var/log/mysqld.log
2023-09-03T07:04:16.666834Z 1 [Note] A temporary password is generated for root@localhost: aiwfrtTl7-=2
```

4.检查 MySQL 状态

我们检查 MySQL 状态，注意 Active: active (running) 这一行：

```bash
$ systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-09-03 15:04:20 CST; 1h 9min ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
 Main PID: 10547 (mysqld)
   CGroup: /system.slice/mysqld.service
           └─10547 /usr/sbin/mysqld --daemonize --pid-file=/var/run/mysqld/mysqld.pid

Sep 03 15:04:12 owncloud systemd[1]: Starting MySQL Server...
Sep 03 15:04:20 owncloud systemd[1]: Started MySQL Server.
```

5.自动启动

使用以下命令可以将 MySQL 服务与操作系统一起启动：

```bash
$ systemctl enable mysqld
```

可以使用以下命令检查 MySQL 服务是否与操作系统一块启动：

```bash
$ systemctl is-enabled mysqld
```

当然，也可以使用以下命令禁用 MySQL 服务自启动：

```bash
$ systemctl disable mysqld
```

6.创建 owncloud 库

在创建 owncloud 库之前，为了方便记忆，我们先修改 root 用户密码，我们使用以下命令和上面步骤生成的临时密码连接到 MySQL 服务：

```bash
$ mysql -uroot -p
```

为了方便记忆密码，我们将默认中级的密码验证策略修改为低级：

```mysql
mysql> set global validate_password_policy=LOW;
Query OK, 0 rows affected (0.00 sec)
```

查看当前密码验证策略，可以看到已经 `validate_password_policy` 修改为 `LOW`：

```mysql
mysql> show variables like 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password_check_user_name    | OFF   |
| validate_password_dictionary_file    |       |
| validate_password_length             | 8     |
| validate_password_mixed_case_count   | 1     |
| validate_password_number_count       | 1     |
| validate_password_policy             | LOW   |
| validate_password_special_char_count | 1     |
+--------------------------------------+-------+
7 rows in set (0.01 sec)
```

然后，修改 root 密码：

```mysql
mysql> set password = password('root@2023');
```

root 密码修改完成后，创建 owncloud 库和 owncloud 用户

```mysql
mysql> CREATE DATABASE owncloud DEFAULT CHARACTER SET utf8mb4;
```

```mysql
mysql> create user owncloud@'%' identified by 'owncloud';
```

授权 owncloud 用户的 owncloud 库权限：

```mysql
mysql> grant all privileges on owncloud.* to owncloud@'%' identified by 'owncloud';
```

刷新授权，使之立即生效：

```mysql
mysql> flush privileges;
```

### 3.4.安装和配置 ownCloud

1.下载 OwnCloud

我们将使用 wget 命令下载 ownCloud，因此需要先安装 wget 包。另外，我们还需要安装 unzip 包解压缩。
```bash
$ yum -y install wget unzip
```
进入 tmp 目录并使用 wget 从 ownCloud 站点下载最新稳定的 ownCloud 10.13 压缩包：
```bash
$ cd /tmp
$ wget --no-check-certificate https://download.owncloud.com/server/stable/owncloud-10.13.0.zip
```
解压 owncloud-10.13.0.zip 文件并将其移动到 /usr/share/nginx/html/ 目录：
```bash
$ unzip owncloud-10.13.0.zip
$ mv owncloud/ /usr/share/nginx/html/
```
接下来，转到 nginx Web 根目录并为 owncloud 创建一个新的 data 目录。
```bash
$ cd /usr/share/nginx/html/ 
$ mkdir -p owncloud/data/
```
将 owncloud 目录的所有者更改为 nginx 用户和组。
```bash
$ chown nginx:nginx -R owncloud/
```

2.配置 OwnCloud

1). 生成自签名 SSL 证书

在本教程中，我们将在客户端的 https 连接下运行 owncloud。您可以使用免费的 SSL 证书，例如 let's encrypt。在本教程中，我将使用 OpenSSL 命令创建我自己的 SSL 证书文件。为 SSL 文件创建一个新目录：
```shell
$ mkdir -p /etc/nginx/cert/
```
然后使用下面的 OpenSSL 命令生成新的 SSL 证书文件：
```shell
$ openssl req -new -x509 -days 365 -nodes -out /etc/nginx/cert/owncloud.crt -keyout /etc/nginx/cert/owncloud.key
```
按照 OpenSSL 命令的要求输入 SSL 证书的详细信息。然后用 `chmod` 命令将所有证书文件的权限改为 600。
```shell
$ chmod 600 /etc/nginx/cert/*
```
2). 在 Nginx 中配置 ownCloud 虚拟主机

在步骤5中，我们下载了 ownCloud 源代码并将其配置为在 Nginx Web 服务器下运行。但我们仍然需要为ownCloud 配置虚拟主机。
在 `/etc/nginx/conf.d/` 目录中创建一个新的虚拟主机配置文件 `owncloud.conf`：

```bash
$ cd /etc/nginx/conf.d/ 
$ vim owncloud.conf
```
添加以下虚拟主机配置：
```nginx
upstream php-handler {
    server 127.0.0.1:9000;
    #server unix:/var/run/php5-fpm.sock;
}
 
server {
    listen 80;
    server_name data.owncloud.co;
    # enforce https
    return 301 https://$server_name$request_uri;
}
 
server {
    listen 443 ssl;
    server_name data.owncloud.co;
 
    ssl_certificate /etc/nginx/cert/owncloud.crt;
    ssl_certificate_key /etc/nginx/cert/owncloud.key;
 
    # Add headers to serve security related headers
    # Before enabling Strict-Transport-Security headers please read into this topic first.
    add_header Strict-Transport-Security "max-age=15552000; includeSubDomains";
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
 
    # Path to the root of your installation
    root /usr/share/nginx/html/owncloud/;
 
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
 
    # The following 2 rules are only needed for the user_webfinger app.
    # Uncomment it if you're planning to use this app.
    #rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
    #rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
 
    location = /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
    }
    location = /.well-known/caldav {
        return 301 $scheme://$host/remote.php/dav;
    }
 
    location /.well-known/acme-challenge { }
 
    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;
 
    # Disable gzip to avoid the removal of the ETag header
    gzip off;
 
    # Uncomment if your server is build with the ngx_pagespeed module
    # This module is currently not supported.
    #pagespeed off;
 
    error_page 403 /core/templates/403.php;
    error_page 404 /core/templates/404.php;
 
    location / {
        rewrite ^ /index.php$uri;
    }
 
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
        return 404;
    }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
        return 404;
    }
 
    location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+|core/templates/40[34])\.php(?:$|/) {
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
        fastcgi_param front_controller_active true;
        fastcgi_pass php-handler;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
    }
 
    location ~ ^/(?:updater|ocs-provider)(?:$|/) {
        try_files $uri $uri/ =404;
        index index.php;
    }
 
    # Adding the cache control header for js and css files
    # Make sure it is BELOW the PHP block
    location ~* \.(?:css|js)$ {
        try_files $uri /index.php$uri$is_args$args;
        add_header Cache-Control "public, max-age=7200";
        # Add headers to serve security related headers (It is intended to have those duplicated to the ones above)
        # Before enabling Strict-Transport-Security headers please read into this topic first.
        #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains";
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        # Optional: Don't log access to assets
        access_log off;
    }
 
    location ~* \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg)$ {
        try_files $uri /index.php$uri$is_args$args;
        # Optional: Don't log access to other assets
        access_log off;
    }
}
```

保存文件并退出编辑器。

最后，测试 nginx 配置无误，然后重新启动 nginx。

```bash
# 验证 nginx 配置是否有误
$ nginx -t

# 重新启动 nginx
$ systemctl restart nginx
```

### 3.5.配置 SELinux 和 firewalld

我们将使 SELinux 保持在强制模式下，因此我们需要 SELinux 管理工具包来配置它。使用 yum 命令安装 SELinux 管理工具：

```bash
$ yum -y install policycoreutils-python
```

然后以 root 身份执行以下命令，以允许 ownCloud 在 SELinux 下运行。请记住更改 ownCloud 目录，以防您使用不同的目录进行 ownCloud 安装：

```bash
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/data(/.*)?' 
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/config(/.*)?' 
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/apps(/.*)?' 
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/assets(/.*)?' 
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/.htaccess' 
$ semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/owncloud/.user.ini' 

$ restorecon -Rv '/usr/share/nginx/html/owncloud/'
```

接下来，启动 firewalld 服务并打开 owncloud 的 HTTP 和 HTTPS 端口。

```bash
# 启动 firewalld 服务
$ systemctl start firewalld

# 开启 firewalld 服务自启动
$ systemctl enable firewalld
```

使用 firewall-cmd 命令打开 HTTP 和 HTTPS 端口，然后重新加载防火墙使之立即生效。

```bash
$ firewall-cmd --permanent --add-service=http
$ firewall-cmd --permanent --add-service=https
$ firewall-cmd --reload
```

至此，服务器配置部分已完成。

### 3.6.ownCloud 安装向导

现在，打开您的网络浏览器并输入 ownCloud 公网IP，我的IP是：xxx.xxx.xxx.xxx，您将被重定向到安全的 HTTPS 连接。设置管理员的用户名和密码，然后输入数据库信息并单击完成设置，等待 OwnCloud 安装完成。

至此，Owncloud 已在 CentOS 7 服务器上成功安装 Nginx、php7-fpm 和 MySQL。

> 若提示 php zip 模块没有安装或者 intl 模块没有安装，请运行 `yum -y install php-intl php-pecl-zip` 命令安装
{: .prompt-tip }

## 4.FAQ
1. ownCloud 支持多语言吗？

    答：支持多语言，包含中文的支持。

2. ownCloud 是否提供客户端？

    答：提供客户端，支持桌面端、Android 端和 iOS 端。

3. ownCloud 自身能够预览和编辑 Office 文档吗？

    答：不可以，需要连接第三方的文档编辑和服务才可以。

4. ownCloud 支持集成外部存储吗？

    答：支持多种主流外部存储服务。

5. 如果没有域名是否可以部署 ownCloud？

    答：可以，通过 `http://服务器公网IP` 访问即可。

6. 是否可以修改 ownCloud 的源码路径？

    答：可以，通过修改虚拟主机配置文件中相关参数。

7. ownCloud 数据库连接配置信息在哪里？ 

    答：数据库配置信息 ownCloud 配置文件中。
