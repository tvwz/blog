---
categories: [人工智能, LLM]
date: 2024-08-10 14:37:00 +0800
last_modified_at: 2024-08-10 16:02:00 +0800
tags:
- OpenAI
- GPT
- function calling
- 函数调用
- Next.js
title: Next.js 快速集成 OpenAI Function Calling 实践
---

**OpenAI 的 function calling 是什么？**

`function calling` 即函数调用，是 OpenAI 引入的一项功能，可以增强模型在执行特定任务时的能力。这项功能允许模型在对话过程中调用预定义的函数，完成特定的任务或获取外部系统的信息。这种功能使模型不仅能生成文本，还能通过调用外部函数执行操作，扩展其能力。

**OpenAI 的模型在无 function calling 时存在的不足？**

1. 无法自动执行某些变成或者工具调用，例如自动化的数据处理、API 调用、数据库查询等，导致需要手动执行操作，增加了工作量。
2. 无法获取实时信息，如当前的天气、股票价格、最近的新闻等，导致提供了过时的信息。
3. 无法获取特定领域的知识，如专业领域的医学知识、金融知识、法律知识，导致无法准确地回答一些专业性很强的问题。

总的来说，`function calling` 增强了模型在处理复杂任务、精确性、实时性和用户交互等方面的能力，缺乏这一功能将限制模型在这些领域的表现。

## 1. 无函数调用时对话处理过程

![对话处理过程](/img/chat-process.drawio.svg)

无函数调用的时候，对话处理过程如下：

1. 客户端发送请求到聊天服务器
2. 聊天服务器发送 user 提示词给 GPT API
3. GPT API 将 assistant 提示词返回聊天服务器
4. 聊天服务器将 assistant 提示词返回给用户
5. 重复执行

首次请求如下：

```json
{
  "messages": [
    { "role": "user", "content": "今天天气怎么样？" }
  ],
  "model": "gpt-4o",
  "stream": false
}
```

再次请求如下：

```json
{
  "messages": [
    { "role": "user", "content": "今天天气怎么样？" },
    { "role": "assistant", "content": "很抱歉，我无法实时获取天气信息。" },
    { "role": "user", "content": "北京今天天气怎么样？" }
  ],
  "model": "gpt-4o",
  "stream": false
}
```

实现的 nextjs 代码如下：

```typescript
import { NextApiRequest, NextApiResponse } from 'next'

export default async function createMessage(req: NextApiRequest, res: NextApiResponse) {
  const { messages } = req.body
  const apiKey = process.env.OPENAI_API_KEY // https://api.openai.com/v1
  const baseUrl = process.env.OPENAI_BASE_URL // sk-xxx
  const body = JSON.stringify({
    messages,
    model: 'gpt-4o',
    stream: false
  })
  try {
    const response = await fetch(`${baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body
    })
    const data = await response.json()
    res.status(200).json({ data })
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}
```

## 2. 有函数调用时对话处理过程

![函数调用对话处理过程](/img/function-calling-chat-process.drawio.svg)

有函数调用的时候，对话处理过程如下：

1. 客户端发送用户提示词到 Chat Server
2. Chat Server 将用户提示词和可调用的函数一并发送给 GPT
3. GPT 模型根据用户的提示词，判断是用普通文本响应还是函数调用的格式响应
4. 如果是函数调用格式，那么 Chat Server 就会执行这个函数，并将结果再次发送给 GPT
5. GPT 模型根据提供的数据，使用普通文本响应
6. 重复执行

首次请求如下：

```json
{
  "messages": [
    { "role": "user", "content": "今天天气怎么样？" }
  ],
  "model": "gpt-4o",
  "stream": false,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "getLocation",
        "description": "Get the user's current location",
        "parameters": { "type": "object", "properties": {}, "required": [] }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "getCurrentWeather",
        "description": "Get the current weather for a location",
        "parameters": {
          "type": "object",
          "properties": { "latitude": { "type": "number" }, "longitude": { "type": "number" } },
          "required": ["latitude", "longitude"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

再次请求如下（携带位置信息）：

```json
{
  "messages": [
    { "role": "user", "content": "今天天气怎么样？" },
    {
      "role": "function",
      "name": "getLocation",
      "content": "{\n  \"latitude\": 40.7128,\n  \"longitude\": -74.006\n}"
    }
  ],
  "model": "gpt-4o",
  "stream": false,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "getLocation",
        "description": "Get the user's current location",
        "parameters": { "type": "object", "properties": {}, "required": [] }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "getCurrentWeather",
        "description": "Get the current weather for a location",
        "parameters": {
          "type": "object",
          "properties": { "latitude": { "type": "number" }, "longitude": { "type": "number" } },
          "required": ["latitude", "longitude"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

最后一次请求如下（携带位置和天气信息）：

```json
{
  "messages": [
    { "role": "user", "content": "今天天气怎么样？" },
    {
      "role": "function",
      "name": "getLocation",
      "content": "{\n  \"latitude\": 40.7128,\n  \"longitude\": -74.006\n}"
    },
    {
      "role": "function",
      "name": "getCurrentWeather",
      "content": "{\n  \"temperature\": 22,\n  \"condition\": \"sunny\"\n}"
    }
  ],
  "model": "gpt-4o",
  "stream": false,
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "getLocation",
        "description": "Get the user's current location",
        "parameters": { "type": "object", "properties": {}, "required": [] }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "getCurrentWeather",
        "description": "Get the current weather for a location",
        "parameters": {
          "type": "object",
          "properties": { "latitude": { "type": "number" }, "longitude": { "type": "number" } },
          "required": ["latitude", "longitude"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

实现的 nextjs 代码如下：

```typescript
import { NextApiRequest, NextApiResponse } from 'next'

export default async function createMessage(req: NextApiRequest, res: NextApiResponse) {
  const { messages } = req.body
  const apiKey = process.env.OPENAI_API_KEY
  const baseUrl = process.env.OPENAI_BASE_URL
  try {
    while (true) {
      const body = JSON.stringify({
        messages,
        model: 'openai/gpt-4o-2024-08-06',
        stream: false,
        tools: functions,
        tool_choice: 'auto'
      })
      const response = await fetch(`${baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`
        },
        body
      })
      const data = await response.json()
      const { finish_reason, message } = data.choices[0]
      if (finish_reason === 'tool_calls') {
        const functionName = message.tool_calls[0].function.name
        const fucntionArguments = message.tool_calls[0].function.arguments
        const functionArgsArr = Object.values(fucntionArguments)
        const functionToCall = availableFunctions[functionName]
        const functionResponse = await functionToCall.apply(null, functionArgsArr)
        messages.push({
          role: 'function',
          name: functionName,
          content: `${JSON.stringify(functionResponse, null, 2)}`
        })
      } else if (finish_reason === 'stop') {
        res.status(200).json({ data })
        return
      }
    }
  } catch (error: any) {
    res.status(500).json({ error: error.message })
  }
}

async function getLocation() {
  return { latitude: 40.7128, longitude: -74.0060 }
}

async function getCurrentWeather(latitude: any, longitude: any) {
  return { temperature: 22, condition: "sunny" }
}

const functions = [
  {
    type: 'function',
    function: {
      name: 'getLocation',
      description: "Get the user's current location",
      parameters: {
        type: 'object',
        properties: {},
        required: []
      }
    }
  },
  {
    type: 'function',
    function: {
      name: 'getCurrentWeather',
      description: 'Get the current weather for a location',
      parameters: {
        type: 'object',
        properties: {
          latitude: { type: 'number' },
          longitude: { type: 'number' }
        },
        required: ['latitude', 'longitude']
      }
    }
  }
]

const availableFunctions = {
  getCurrentWeather,
  getLocation
}
```

完整的代码：[nextjs-chatgpt-tutorial](https://github.com/HarrisonWang/nextjs-chatgpt-tutorial.git)

## 3.问题

**GPT 大模型如何知道获取天气需要调用 `getLocation()` 和 `getCurrentWeather()` 函数的？**

1. 自然语言理解能力：通过对用户输入“今天天气怎么样？”的理解，知道用户想要获取天气信息。
2. 上下文分析：模型分析了所有的请求上下文，包括可用的工具函数。它理解了 `getLocation()` 和 `getCurrentWeather()` 函数的功能和参数。
3. 任务分解：模型将“获取天气”任务分解为两个步骤：首先获取位置，然后根据位置获取天气。
4. 工具选择能力：模型基于对任务的理解，选择了最适合的工具组合来完成任务。
5. 参数依赖分析：模型分析到 `getCurrentWeather()` 函数需要经度和纬度作为输入，而 `getLocation` 函数刚好可以提供。因此，它推断出需要现调用 `getLocation()`，再调用 `getCurrentWeather()`。
6. 训练数据中的模式：模型训练过类似的场景，学习到了处理天气查询时常用的步骤和工具组合。
7. 推理能力：基于以上所有信息，模型推理后得出需要依次调用这两个函数才能回答用户的问题。

GPT 模型的上下文理解、任务分解、工具选择和逻辑推理能力，通过深入理解任务需求和可用工具的功能，从而做出智能决策。
