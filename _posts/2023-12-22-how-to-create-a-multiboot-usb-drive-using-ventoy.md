---
categories: [操作系统, 启动盘]
date: 2023-12-22 14:10:10 +0800
last_modified_at: 2024-03-11 13:01:00 +0800
tags:
- 启动盘
- 操作系统
- Windows
- Ubuntu
- CentOS
title: 如何使用 Ventoy 制作多合一启动盘？
image:
  path: /img/ventoy.png
---

Ventoy 是一个制作可启动 U 盘的开源工具，它可以让你在 U 盘上创建多合一启动盘，以便轻松地安装或测试不同的操作系统。它支持多种操作系统，包括 Windows、Linux 和 Unix 等。

## 操作步骤

### 1.下载并安装 Ventoy

从[Ventoy 的官方仓库](https://github.com/ventoy/Ventoy)下载适用于您系统的 Ventoy：

![image-20231222143822816](/img/image-20231222143822816.png){: .shadow }

我们选择 Windows 版本下载到本地：

![image-20231222143950011](/img/image-20231222143950011.png){: .shadow }

然后，将其解压安装到指定目录，例如：我将其装到 `D:\Program Files` 目录下：

![image-20231222144306544](/img/image-20231222144306544.png){: .shadow }

### 2.配置 U 盘

我们插入 U 盘后运行 Ventoy，选择目标 U 盘，然后点击<kbd>安装</kbd>将 Ventoy 安装到 U 盘：

  ![image-20231222145305196](/img/image-20231222145305196.png){: .shadow }

> Ventoy 安装的 U 盘文件系统默认为 exFAT，exFAT 文件系统原生支持 Windows、Linux 和 macOS 等系统。
{: .prompt-tip }

安装过程中，Ventoy 会提示让我们格式化 U 盘，按照提示操作即可，安装完成后，可以看到有一个 U 盘的系统分区：

![image-20231222150021573](/img/image-20231222150021573.png){: .shadow }

### 3.将 ISO 文件复制到 U 盘

将要安装到 U 盘的操作系统 ISO 文件复制到 U 盘的根目录，例如我将 Windows、Ubuntu 和 CentOS 拷贝到 U 盘：

![image-20231222150604628](/img/image-20231222150604628.png){: .shadow }

### 4.重启电脑并选择从 U 盘启动

在电脑启动时，按住启动菜单键（通常是 F12 或 Esc），选择从 U 盘启动。

### 5.选择要安装的操作系统

在 Ventoy 启动菜单中，选择要安装的操作系统，如下图我选择 Windows 11：

![img](/img/screen_uefi_cn.png){: .shadow }

### 6.按照安装向导完成安装

## FAQ

**1.为什么华为笔记本无法识别该 U 盘启动盘？**

因为华为笔记本只能识别 UEFI 模式的 U 盘启动盘，用 Ventoy 制作的启动盘是 exFAT 格式的， 而 exFAT 不是 UEFI 模式的。

> FAT32 和 NTFS 为 UEFI 模式，FAT、exFAT、ext2、ext3 不是 UEFI 模式。
{: .prompt-tip }

**2.电脑如何从 U 盘启动？**

- **品牌笔记本** U 盘启动快捷键：

  | 笔记本品牌       | 启动按键       |
  | :---------------: | :-------------: |
  | 联想笔记本       | <kbd>F12</kbd>            |
  | 宏基笔记本       | <kbd>F12</kbd>            |
  | 华硕笔记本       | <kbd>ESC</kbd>            |
  | 惠普笔记本       | <kbd>F9</kbd>              |
  | 联想 Thinkpad    | <kbd>F12</kbd>            |
  | 戴尔笔记本       | <kbd>F12</kbd>            |
  | 神州笔记本       | <kbd>F12</kbd>            |
  | 东芝笔记本       | <kbd>F12</kbd>            |
  | 三星笔记本       | <kbd>F12</kbd>            |
  | IBM 笔记本       | <kbd>F12</kbd>            |
  | 富士通笔记本     | <kbd>F12</kbd>            |
  | 海尔笔记本       | <kbd>F12</kbd>            |
  | 方正笔记本       | <kbd>F12</kbd>            |
  | 清华同方笔记本   | <kbd>F12</kbd>            |
  | 微星笔记本       | <kbd>F11</kbd>            |
  | 明基笔记本       | <kbd>F9</kbd>             |
  | 技嘉笔记本       | <kbd>F12</kbd>            |
  | Gateway 笔记本   | <kbd>F12</kbd>            |
  | eMachines 笔记本 | <kbd>F12</kbd>            |
  | 索尼笔记本       | <kbd>ESC</kbd>            |
  | 苹果笔记本       | 长按 <kbd>option</kbd> 键 |

- **品牌台式机** U 盘启动快捷键：

  | 台式机品牌       | 启动按键 |
  | :-------------: | :-----: |
  | 联想台式电脑     | <kbd>F12</kbd>      |
  | 惠普台式电脑     | <kbd>F12</kbd>      |
  | 宏基台式电脑     | <kbd>F12</kbd>      |
  | 戴尔台式电脑     | <kbd>ESC</kbd>      |
  | 神舟台式电脑     | <kbd>F12</kbd>      |
  | 华硕台式电脑     | <kbd>F8</kbd>       |
  | 方正台式电脑     | <kbd>F12</kbd>      |
  | 清华同方台式电脑 | <kbd>F12</kbd>      |
  | 海尔台式电脑     | <kbd>F12</kbd>      |
  | 明基台式电脑     | <kbd>F8</kbd>       |

- **组装电脑** U 盘启动热键：

  | 主板品牌     | 启动按键   |
  | :---------: | :--------: |
  | 华硕主板     | <kbd>F8</kbd>         |
  | 技嘉主板     | <kbd>F12</kbd>        |
  | 微星主板     | <kbd>F11</kbd>        |
  | 映泰主板     | <kbd>F9</kbd>         |
  | 梅捷主板     | <kbd>ESC</kbd> 或 <kbd>F12</kbd> |
  | 七彩虹主板   | <kbd>ESC</kbd> 或 <kbd>F12</kbd> |
  | 华擎主板     | <kbd>F11</kbd>        |
  | 斯巴达卡主板 | <kbd>ESC</kbd>        |
