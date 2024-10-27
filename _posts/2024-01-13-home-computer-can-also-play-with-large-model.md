---
categories: [人工智能, LLM]
date: 2024-01-13 09:55:00 +0800
last_modified_at: 2024-01-13 10:20:00 +0800
tags:
- OpenAI
- ChatGPT
- Ollama
- Llama
- Phi
title: 家用电脑也能轻松玩转大模型
---

2022 年底 OpenAI 发布 ChatGPT，随后 2023 年大模型进入了有史以来发展最快速的时候，在这一年中，相继涌现了很多商业闭源或开源的大模型，本文就是通过 [Ollama](https://github.com/jmorganca/ollama) 开源应用程序将开源的大模型运行在家用电脑之上。

## Ollama 简介

Ollama 是一款开源应用程序，可让你通过命令行界面运行、创建和共享大型语言模型。

## 支持的模型

Ollama 支持的可用开源模型列表网址：[ollama.ai/library](https://ollama.ai/library 'ollama model library')

下面是一些可下载的示例开源模型：

| Model              | Parameters | Size  | Download                       |
| ------------------ | ---------- | ----- | ------------------------------ |
| Llama 2            | 7B         | 3.8GB | `ollama run llama2`            |
| Mistral            | 7B         | 4.1GB | `ollama run mistral`           |
| Dolphin Phi        | 2.7B       | 1.6GB | `ollama run dolphin-phi`       |
| Phi-2              | 2.7B       | 1.7GB | `ollama run phi`               |
| Neural Chat        | 7B         | 4.1GB | `ollama run neural-chat`       |
| Starling           | 7B         | 4.1GB | `ollama run starling-lm`       |
| Code Llama         | 7B         | 3.8GB | `ollama run codellama`         |
| Llama 2 Uncensored | 7B         | 3.8GB | `ollama run llama2-uncensored` |
| Llama 2 13B        | 13B        | 7.3GB | `ollama run llama2:13b`        |
| Llama 2 70B        | 70B        | 39GB  | `ollama run llama2:70b`        |
| Orca Mini          | 3B         | 1.9GB | `ollama run orca-mini`         |
| Vicuna             | 7B         | 3.8GB | `ollama run vicuna`            |
| LLaVA              | 7B         | 4.5GB | `ollama run llava`             |

> 注意：本地运行 7B 模型至少需要 8GB 的 RAM，运行 13B 模型至少需要 16GB 的 RAM，如果运行 33B 模型，则至少需要 32GB 的 RAM。
{: .prompt-tip }

## 安装和使用

### 1.本地方式安装

使用一键安装脚本进行安装：

```bash
$ curl https://ollama.ai/install.sh | sh
```

以服务方式重启：

```bash
$ systemctl restart ollama
```

查看服务状态：

```bash
$ systemctl status ollama
```

查看服务日志：

```bash
$ journalctl -u ollama
```

使用脚本更新：
```bash
$ curl https://ollama.ai/install.sh | sh
```

运行大模型：

```bash
$ ollama run codellama:7b-instruct
pulling manifest 
pulling 3a43f93b78ec... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏ 3.8 GB                         
pulling 8c17c2ebb0ea... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏ 7.0 KB                         
pulling 590d74a5569b... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏ 4.8 KB                         
pulling 2e0493f67d0c... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏   59 B                         
pulling 7f6a57943a88... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏  120 B                         
pulling 316526ac7323... 100% ▕████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████▏  529 B                         
verifying sha256 digest 
writing manifest 
removing any unused layers 
success 
>>> Send a message (/? for help)
```

> Ollama 会判别正在运行的硬件并在可行的情况下调用 GPU 加速，不妨在推理时打开活动监视器或任务管理器观察以验证。
{: .prompt-tip }

运行到这里，你本地的模型已经运行成功了，下面来简单使用下这个模型，输入“请使用Java编写一个冒泡排序方法”，让其写一个冒泡排序：

![image-20240113093526](/img/image-20240113093526.webp){: .shadow }

### 2.Docker 方式安装

安装 docker 后，我们可通过 CPU 和 GPU 两种方式运行 ollama 容器。

#### CPU（默认）方式运行 ollama 容器

```bash
$ docker run -d -v ollama:/root/.ollama -p 11434:11434 \
    --name ollama ollama/ollama
```

#### GPU 方式运行 ollama 容器

```bash
$ docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 \
    --name ollama ollama/ollama
```

运行大模型：

 ```bash
 $ docker exec -it ollama ollama run llama2
 ```
