---
title: 基于Vaultwarden自托管Bitwarden密码管理器及备份方案
date: 2024-06-20 11:30:09
tags:
- Bitwarden
- Tools
categories:
- IT Notes

---

# 前言


本文正在等待补充。

<!-- more -->

Bitwarden是一款密码管理器产品，目前市面上有多款密码管理器产品可供选择，例如：1Password、Microsoft Authenticator、LetPass等。

各个产品的对比可以参考：[2024 年最好密码管理工具：哪一个好用？](https://adguard.com/zh_cn/blog/best-password-managers.html)

前面的几款产品，基本上都需要付费订阅，年费几十美元不等且家庭用户随着成员增多收费增加。

经过一番对比，Bitwarden基本满足我目前的需求。

开源、支持云服务+自托管部署两种方案，客户端支持多平台，且文档、开发资源也都较丰富，方便我其他的一些折腾可能性。

因此我打算使用[Bitwarden](https://bitwarden.com/)作为我的密码管理器。

部署Bitwarden服务器可以使用官方的服务，也可以使用第三方服务，
我在这里用的是第三方的开源实现：[vaultwarden](https://github.com/dani-garcia/vaultwarden) 

vaultwarden介绍，参考vaultwarden的github页面了解更多信息。
> 用 Rust 编写的 Bitwarden 服务器 API 的替代实现，兼容上游 Bitwarden 客户端*，
> 非常适合在运行官方资源繁重的服务可能并不理想的情况下进行自托管部署。
> 📢注：本项目原名 Bitwarden_RS，已更名为 Bitwarden_RS，与官方 Bitwarden 服务器区分开来，希望能避免混淆和商标/品牌问题。



本文其余部分介绍搭建步骤、配置信息以及Bitwarden数据的自动备份方案，更多关于bitwarden、valuewarden方面的信息本文不作过多描述，请自行查阅官方文档。


# 前置准备
需要准备以下环境：
1. 个人域名
2. SSL证书
3. 一台具有公网IP的云服务器

# 环境搭建
## 镜像拉取及容器启动
## 配置Nginx
## 配置SSL证书
## 配置邮箱

# 开始使用

<hr/>

# 备份方案

- vaultwarden的官方wiki页面：https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault

## 使用阿里云WebDAV
## 获取token
## 备份脚本结合Crontab
## 同步到Nas
