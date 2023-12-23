---
categories: [操作系统, Windows, 办公]
date: 2023-10-31 19:22:00 +0800
last_modified_at: 2023-12-23 10:15:03 +0800
tags:
- 办公
- Office
- OnlyOffice
title: 何使用 OnlyOffice 搭建在线 Office
---

## 1.OnlyOffice 介绍

社区版允许您在本地服务器上安装 OnlyOffice Docs，并将在线编辑器与 OnlyOffice 协作平台或其他流行系统集成。

OnlyOffice Docs是一个在线办公套件，包括文本、电子表格和演示文稿的查看器和编辑器，与 Office Open XML 格式完全兼容：.docx、.xlsx、.pptx，并支持实时协作编辑。OnlyOffice 包含以下功能特性：

- 文档编辑器
- 电子表格编辑器
- 演示文稿编辑器
- 移动端 Web 方式浏览
- 协同编辑
- 支持的流行格式：DOC, DOCX, TXT, ODT, RTF, ODP, EPUB, ODS, XLS, XLSX, CSV, PPTX, HTML

## 2.安装前提

- Nginx
- MySQL
- RabbbitMQ

## 3.安装步骤

### 3.1.安装 Nginx

- 添加 yum 源

`/etc/yum.repos.d/nginx.repo`{: .filepath} 文件中添加以下内容，设置 nginx yum 官方库：

```bash
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
```

- 安装 Nginx

```bash
$ yum install -y nginx
```

安装 EPEL yum 库：

```bash
$ yum install epel-release
```

- 启动 Nginx

```bash
$ systemctl start nginx
```

### 3.2.安装 MySQL

- 下载本地安装包及其依赖包

```bash
$ yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm 
```

- 安装 MySQL

```bash
$ yum install mysql-community-server
```

- 启动 MySQL

```bash
$ systemctl start mysqld
```

当 MySQL 启动后将生成一个随机密码，输入以下命令可以查找到随机密码：

```bash
$ grep -i password /var/log/mysqld.log
2023-09-03T07:04:16.666834Z 1 [Note] A temporary password is generated for root@localhost: aiwfrtTl7-=2
```

### 3.3.安装 RabbitMQ

- 设置主机名

RabbitMQ 是通过主机名进行访问的，必须指定能访问的主机名：

```bash
# 设置主机名
$ hostnamectl set-hostname onlyoffice
```

- 安装 RabbitMQ

```bash
$ yum install -y rabbitmq-server
```

- 启动 RabbitMQ

```bash
$ systemctl start rabbitmq-server
```

### 3.4.安装 OnlyOffice

- 添加 OnlyOffice yum 库

使用以下命令安装 OnlyOffice yum 库：

```bash
$ yum install https://download.onlyoffice.com/repo/centos/main/noarch/onlyoffice-repo.noarch.rpm
```

- 安装 mscorefonts

安装 `cabextract` 和 `xorg-x11-font-utils` 软件包：

```bash
$ yum install cabextract xorg-x11-font-utils
```

对于 CentOS 7.8(2003)，还需要安装 `fontconfig`：

```bash
yum install fontconfig
```

安装 msttcore 字体包：

```bash
$ rpm -i https://sourceforge.net/projects/mscorefonts2/files/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
```

- 安装 OnlyOffice Docs

执行以下命令安装：

```bash
$ yum install onlyoffice-documentserver
```

onlyoffice-documentserver 软件包比较大，请耐心等待安装完成，安装完成后使用以下命令查看 ds 相关的服务是否已安装好：

```bash
$ systemctl list-units | grep ds
ds-converter.service                                                                                                                                    loaded active running   Docs Converter
ds-docservice.service                                                                                                                                   loaded active running   Docs Docservice
ds-metrics.service                                                                                                                                      loaded active running   Docs Metrics
```

onlyoffice 包含以下几个服务：

- systemctl start ds-converter
- systemctl start ds-docservice
- systemctl start ds-metrics
- systemctl start ds-example

其中，ds-example 为示例服务，可用来验证 onlyoffice-documentserver 是否安装成功，默认不启动，我们可以使用命令 `systemctl start ds-example` 手动启动。

4. 配置 OnlyOffice Docs

OnlyOffice Docs 默认在 80 端口侦听，运行以下命令可以修改端口：

```bash
$ export DS_PORT=<PORT_NUMBER>
```

OnlyOffice 默认使用 PostgreSQL 作为数据库，由于我们使用 MySQL，可以执行以下两命令修改为 MySQL：

```bash
$ export DB_TYPE=mysql
$ export DB_PORT=3306
```

然后，运行`documentserver-configure.sh` 脚本：

```bash
$ ./documentserver-configure.sh
```

系统将要求您指定 PostgreSQL和 RabbitMQ 连接参数。使用以下数据：

对于 MySQL：

- Host: localhost

- Database: onlyoffice

- User: onlyoffice

- Password: onlyoffice

对于 RabbitMQ：

- Host: localhost

- User: guest

- Password: guest

开放防火墙端口：

```bash
$ firewall-cmd --zone=public --add-port=80/tcp --permanent
$ firewall-cmd --reload
```

禁用 SELinux：

编辑 `/etc/selinux/config`{: .filepath} 文件，将 `SELINUX=enforcing` 修改为 `SELINUX=disabled` 后保存，然后重启服务器使之生效。

然后我们通过 http://{ip}:{port}/example 访问测试示例。

> 如：运行 OnlyOffice Docs 服务的主机 IP 为 192.168.1.4，服务端口为 80，这时我们可以通过 http://192.168.1.4/example 地址访问。
{: .prompt-tip }

OnlyOffice 默认 JWT 密钥存储在 `/etc/onlyoffice/documentserver/local.json`{: .filepath} 配置文件的 `services.CoAuthoring.secret.inbox.string` 配置项中。

```json
{
  "services": {
    "CoAuthoring": {
  ...
      "secret": {
        "inbox": {
          "string": "oKgZCFLsmBWnTCyEvVrKYYwlxVU118zO"
        },
        "outbox": {
          "string": "oKgZCFLsmBWnTCyEvVrKYYwlxVU118zO"
        },
        "session": {
          "string": "oKgZCFLsmBWnTCyEvVrKYYwlxVU118zO"
        }
      }
    }
  },
  ...
}
```
