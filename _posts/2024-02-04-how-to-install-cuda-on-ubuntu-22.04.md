---
categories: [操作系统, Linux]
date: 2024-02-05 14:45:00 +0800
last_modified_at: 2024-02-05 14:45:00 +0800
tags:
- Ubuntu
- CUDA
title: 如何在 Ubuntu 22.04 上安装 CUDA？
---

## 什么是 CUDA？

CUDA（Compute Unified Device Architecture）是由 NVIDIA 开发的并行计算平台。它提供了一个应用程序编程接口（API），使开发人员能够利用 NVIDIA 图形处理单元 （GPU）的强大处理能力进行通用计算。

CUDA 核心是 GPU 内部的专门处理单元，针对并行计算任务进行了优化。它们能够同时执行多个线程。

## CUDA 有什么用？

凭借其并行计算功能和不断增长的 GPU 能力，CUDA 可用于机器学习和 AI 应用、涉及复杂计算的科学模拟、财务建模、网络安全、加密货币挖掘和其他计算密集型任务。

## 安装 CUDA

### 1.升级 Ubuntu

更新所有软件源的软件包列表：

```bash
$ sudo apt update
```

> `sudo apt update` 命令用于从软件源下载最新的软件包信息，并将其存储在本地软件包缓存中，便于后续的升级或安装。

升级已安装的软件包：

```bash
$ sudo apt upgrade
```

> 运行 `sudo apt upgrade` 命令之前，首先运行 `sudo apt update` 命令来更新软件包列表，避免在升级过程中出现问题。

### 2.查找驱动程序

安装 Ubuntu 的驱动程序通用包：

```bash
$ sudo apt install ubuntu-drivers-common
```

获取推荐的英伟达驱动程序列表，将列出显卡型号等信息：

```bash
$ ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
modalias : pci:v000010DEd00002489sv00007377sd00002000bc03sc00i00
vendor   : NVIDIA Corporation
model    : GA104 [GeForce RTX 3060 Ti Lite Hash Rate]
driver   : nvidia-driver-525-open - distro non-free
driver   : nvidia-driver-535 - distro non-free recommended
driver   : nvidia-driver-470 - distro non-free
driver   : nvidia-driver-545 - distro non-free
driver   : nvidia-driver-525 - distro non-free
driver   : nvidia-driver-470-server - distro non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-525-server - distro non-free
driver   : nvidia-driver-535-open - distro non-free
driver   : nvidia-driver-545-open - distro non-free
driver   : nvidia-driver-535-server-open - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
```

它推荐了 nvidia-driver-535 的驱动程序：

```bash
driver   : nvidia-driver-535 - distro non-free recommended
```

### 3.安装驱动

```bash
$ sudo apt install nvidia-driver-535
```

### 4.重启操作系统

```bash
$ sudo reboot now
```

### 5.验证驱动

```bash
$ nvidia-smi 
Wed Jan 31 17:31:38 2024       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.154.05             Driver Version: 535.154.05   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA GeForce RTX 3060 Ti     Off | 00000000:01:00.0 Off |                  N/A |
| 32%   41C    P8              17W / 200W |   5642MiB /  8192MiB |      0%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|    0   N/A  N/A      1797      G   /usr/lib/xorg/Xorg                           88MiB |
|    0   N/A  N/A      2002      G   /usr/bin/gnome-shell                         56MiB |
|    0   N/A  N/A     23468      G   ...irefox/1635/usr/lib/firefox/firefox       10MiB |
|    0   N/A  N/A     83967      C   /bin/ollama                                5472MiB |
+---------------------------------------------------------------------------------------+
```