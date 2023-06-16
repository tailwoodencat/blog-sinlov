---
title: "单页应用HATEOAS 和 RESTful 成熟度模型 与 API治理"
date: 2018-08-30T10:07:06+08:00
description: "HATEOAS 介绍，RESTful 成熟度模型 用于 API治理"
draft: false
categories: ['basics']
tags: ['basics', 'govern', 'optimize']
toc:
  enable: true
  auto: false
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

[TOC]

# HATEOAS 介绍

HATEOAS是Hypertext As The Engine Of Application State的缩写

按 [Richardson Maturity Model Richardson成熟度模型](https://martinfowler.com/articles/richardsonMaturityModel.html) 这是REST的最高级形态

采用 Hypermedia 的API

- 在响应（response）中除了返回资源（resource）本身
- 还会额外返回一组 Link

`Link` 描述了对于该资源，消费者（consumer）接下来可以做什么以及怎么做

例如

```sh
HTTP/1.1 200 OK
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Transfer-Encoding: chunked

{
    "tracking_id": "CM_123456",
    "status": "WAIT_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "_Links": {
        "self": {
            "href": "http://localhost:18080/orders/CM_123456",
            "method": "GET",
            "doc": "http://localhost:18080/v1/swagger/#!/orders/get_order_by_id"
        },
        "cancel": {
            "href": "http://localhost:18080/orders/CM_123456",
            "method": "DELETE",
            "doc": "http://localhost:18080/v1/swagger/#!/orders/cancel_order"
        },
        "pay": {
            "href": "http://localhost:18080/orders/CM_123456/pay",
            "method": "POST",
            "doc": "http://localhost:18080/v1/swagger/#!/orders/pay"
        }
    }
}
```

`_Links` 中，消费者，可以知道的行为有

- self 可以使用 GET 方法，访问 href 获取订单详情
- cancel 可以使用 DELETE 方法，访问 href 取消这个订单
- pay 可以使用 POST 方法，访问 href 支付这个订单

> 技巧提示： 如果是线上代码，只需要返回  href 即可，开发或者测试代码，开启 method 和 doc 字段来对接联调

- 开发者可以通过，获取到返回行为连接来消除重复的行为
- RESTful 风格接口有四个层次，HATEOAS 就是可以达到最高层次都架构准则都一种方案

# Richardson成熟度模型

由 [Leonard Richardson](https://www.crummy.com/) 发明的RESTful成熟度模型
一共有三个层次，逐渐达到成熟

## LEVEL 0

使用HTTP作为远程交互的传输系统，但是不会使用Web中的任何机制
通常是基于[远程过程调用(Remote Procedure Invocation)](http://www.eaipatterns.com/EncapsulatedSynchronousIntegration.html)

例子:

- 创建一个订单

```sh
POST /order/service HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ]
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "WAIT_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay_way": [
        {
            "name": "bank",
            "params": []
        },
        {
            "name": "cash",
            "params": [
                "op_auth",
                "auth"
            ]
        }
    ]
}
```

- 然后尝试支付它

```sh
POST /pay/service HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank",
    "tracking_id": "CM_123456"
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "PAYING_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

- 以查询支付结果为最终支付成功的标识

```sh
POST /order/service HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "tracking_id": "CM_123456"
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "SUCCESS_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

## LEVEL 1 - Resource 资源

通往真正REST的第一步是引入 `资源(Resource)` 这一概念
在 LEVEL0 基础上会和单独的资源进行交互

例如

```sh
POST /order/service HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ]
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "WAIT_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay_way": [
        {
            "name": "bank",
            "params": []
        },
        {
            "name": "cash",
            "params": [
                "op_auth",
                "auth"
            ]
        }
    ]
}
```

- 支付时，通过资源ID CM_123456，直接就可以传入 支付代理即可

```sh
POST /pay/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "pay-proxy": "bank"
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "PAYING_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

- 支付后，查询

以查询支付结果为最终支付成功的标识，查询只需要资源ID即可

```sh
POST /order/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "SUCCESS_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

## LEVEL 2 - HTTP Verbs 动词

在LEVEL 0和LEVEL 1中一直使用的是HTTP POST来完成所有的交互
但是有些人会使用 GET PUT DELETE 替代资源

LEVEL 2 它会尽可能根据HTTP协议定义的那样来合理使用HTTP动词，同时在API定义时，使用更多描述，而不是祈使

例如 POST 下单

```sh
POST /order/service HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ]
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "WAIT_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay_way": [
        {
            "name": "bank",
            "params": []
        },
        {
            "name": "cash",
            "params": [
                "op_auth",
                "auth"
            ]
        }
    ]
}
```

- 支付时，通过资源ID CM_123456，POST 支付参数发起支付

```sh
POST /pay/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe
{
    "pay-proxy": "bank"
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "PAYING_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

- 支付后，查询 GET

```sh
GET /order/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "SUCCESS_PAYMENT",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "pay-proxy": "bank"
}
```

- 如果想退款 PUT 行为修改这笔支付

```sh
PUT /pay/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe

{
    "refund": [
        {
            "quantity": 1
            "proxy": "bank"
        }
    ],
}

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "DO_REFUND",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "refund_item":[
        {
            "quantity": 1
            "proxy": "bank"
            "status": "DO_REFUND"
        }
    ]
}
```

- 退款后，查询 GET

```sh
GET /order/service/CM_123456 HTTP/1.1
Server: nginx/1.4.3
Content-Type: application/hal+json;charset=UTF-8
Authorization: 8c0bbc15d91de05aa0a56a465d40d5fe

HTTP/1.1 200 OK
{
    "tracking_id": "CM_123456",
    "status": "SUCCESS_REFUND",
    "items": [
        {
            "name": "goods_name",
            "quantity": 1
        }
    ],
    "refund_item":[
        {
            "quantity": 1
            "proxy": "bank"
            "status": "DO_REFUND"
        }
    ]
}
```

## LEVEL 3  Hypermedia Controls 超媒体控制

例子就不再展现，Hypermedia Controls 能够在保证客户端不受影响的条件下，改变服务器返回的URI，和通知到可用行为

- 只要客户端查询 `_Link` 中  href 的URI，就可以知道后面可以进行的操作
- 后台开发团队可以根据需要随意修改与之对应的URI，来治理 API
- 注意，`超媒体控制最初的入口URI不能被修改`

# RESTful 成熟度模型总结

- Level 1 通过分治法(Divide and Conquer)来处理复杂问题，将一个大型的服务端点(Service Endpoint)分解成多个资源
- Level 2 引入了一套标准的动词，用来以相同的方式应对类似的场景，移除不要的变化
- Level 3 引入了可发现行为(Discoverability)，它可以使协议拥有自我描述(Self-documenting)的能力，用于降低重复

-----------------
[Richardson Maturity Model 作者原文](https://martinfowler.com/articles/richardsonMaturityModel.html)