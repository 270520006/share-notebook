# Nginx简介

## 什么是Nginx

> Nginx是一个**高性能的HTTP和反向代理服务器**，也是一个IMAP/POP3/SMTP代理服务器。
Nginx是一款轻量级的Web服务器/反向代理服务器以及电子邮件代理服务器，并在一个BSD-like协议下发行。由俄罗斯的程序设计师lgor Sysoev所开发，供俄国大型的入口网站及搜索引擎Rambler使用。其特点是占有内存少，并发能力强，事实上nginx的并发能力确实在同类型的网页服务器中表现较好。
Nginx相较于Apache\lighttpd具有占有内存少，稳定性高等优势，并且依靠并发能力强，丰富的模块库以及友好灵活的配置而闻名。在Linux操作系统下，nginx使用epoll事件模型,得益于此，nginx在Linux操作系统下效率相当高。同时Nginx在OpenBSD或FreeBSD操作系统上采用类似于Epoll的高效事件模型kqueue

## Nginx作为Web服务器

Nginx可以作为静态页面的服务器,同时还支持CGI协议的动态语言,比如prel、php等,但不支持Java ,Java程序只能通过Tomcat配置完成,**Nginx专门为性能优化而开发**,性能是其最重要的考量,实现上非常注重效率,能经受高负载的考验,有报告表明能接受高达 5w个并发连接数量 

## Nginx作为Http服务器,有以下几个基本特性

- 处理静态文件,索引文件文件,以及自动索引,打开文件描述符缓冲
- 无缓冲的反向代理加速,简单的负载均衡和容错
- Nginx支持热部署,他启动特别容易,几乎7*24小时不间断运行

## Nginx反向代理

[反向代理](%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%20860767c4f9f649c38d66d97a6c7b7c45.md)

## Nginx负载均衡

[负载均衡](%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1%20d2938afded6c4316bcc1ddfb91b5587c.md)

## Nginx动静分离

## Nginx高可用