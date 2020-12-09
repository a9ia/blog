---
title: 'Hello, World!'
date: 2020-12-09 08:19:35
tags: 'node 生日快乐 hexo volantis nginx circleCI'
excerpt: '第一次建站始末'
---


# 记录一下建站的过程踩过的坑

白嫖了阿里云的服务器和域名，用hexo+volantis主题+nginx快速搭建了一个网站。
后续用github+circleCI实现自动化部署，这个网站就算建成了。

# [hexo](https://hexo.io/zh-cn/)

[hexo](https://hexo.io/zh-cn/)是一个非常快捷的博客框架。


hexo本身的坑并不多，但是有一些网站初学者难以理解的点
+ hexo generate 生成的静态网页是运行在服务器上的，所以当你在个人电脑上打开你会发现加载不了css的静态文件。

这是因为css的引用是`/css/...`，在你的电脑上会被浏览器渲染成所在文件目录的根目录上，比如在E盘，他就会去`E://css/`里面找，自然是找不到的，当你在服务器端运行，经过nginx路由分发，他就能在web服务的根目录下找到css文件。

