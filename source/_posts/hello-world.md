---
title: 'Hello, World!'
date: 2020-12-09 08:19:35
tags: 'node 生日快乐 hexo volantis nginx circleCI'
excerpt: '第一次建站始末'

---


# 记录一下建站的过程踩过的坑

用hexo+volantis主题+nginx快速搭建了一个网站。
用github+circleCI实现自动化部署，这个网站就算建成了。

记录一下这个过程，为后来hexo初用者做一个参考。

### 文件目录

<img src=".\image-20201210092650717.png" alt="image-20201210092718903" style="zoom:50%;" />

# [hexo](https://hexo.io/zh-cn/)

[hexo](https://hexo.io/zh-cn/)是一个非常快捷的博客框架。


hexo本身的坑并不多，但是有一个初学者可能难以理解的点

+ hexo generate 生成的静态网页是运行在服务器上的，所以当你在个人电脑上打开你会发现加载不了css的静态文件。

<img src=".\image-20201210092718903.png" alt="image-20201210092718903" style="zoom:50%;" />

这是因为css的引用是`/css/...`，在你的电脑上会被浏览器渲染成所在文件目录的根目录上，比如在E盘，他就会去`E:/css/`里面找，自然是找不到的，当你在服务器端运行，经过nginx路由分发，才能在web服务的根目录下找到css文件。所以这是正常的

<img src=".\image-20201210092740581.png" alt="image-20201210092740581" style="zoom:50%;" />

# [volantis](https://volantis.js.org/)

[volantis](https://volantis.js.org/)是一个十分好看易用的开源hexo主题。volantis有非常完善的[文档](https://volantis.js.org/getting-started/)。按照文档一步步来就能完成自己博客的搭建。

<img src=".\image-20201210092805147.png" alt="image-20201210092805147" style="zoom:50%;" />



# [circleCI部署](https://circleci.com/)

[circleCI](https://circleci.com/)是一个非常易用而且强大的自动化部署工具。

### 为什么需要自动化部署？

平时发布博客需要

```
hexo new
hexo clean
hexo g
git add .
git commit
git push
ssh 服务器
cd ~/blog
git pull
```

这样就会有很多问题

+ 指令过多，操作非常复杂
+ git上包含生成的public文件，对一个源代码平台来说这是冗余的
+ 在服务器上有不必要的源码文件

解决方案是这样的，首先通过bat文件减少本地的指令

```
@REM ./push.bat
git add .
git commit -m "update"
git push
```

虽然commit message如果能作为参数传入更好，但是这对于一个普通的博客已经是够用的了。

然后通过circleCI实现

+ hexo g生成静态文件并将public静态文件传到服务器

```
# ./.circleci/config.yml
version: 2
jobs:
  build:
    docker:
      - image: circleci/node:latest # 拉取带有node的image
    working_directory: ~/blog # 指定虚拟服务器中工作目录
    steps:
      - checkout # 检查
      - run: sudo npm install # 安装node modules
      - run: sudo npm install hexo-cli -g # 安装hexo环境
      - run: hexo g # 生成静态文件
      - save_cache:
          key: v1-dependencies-{{ checksum "package.json" }}
          paths:
            - node_modules
      - run: echo 'deploying'
      - run: sudo apt-get update && sudo apt-get install rsync && sudo apt-get install openssh-client # 安装rsync所需
      - restore_cache:
          keys: 
            - v1-dependencies-{{ checksum "package.json" }}
            - v1-dependencies
      - add_ssh_keys:
          fingerprints:
            - "f9:a5:6b:ad:73:78:5b:50:ab:e7:30:ca:03:50:8d:59" # 指定ssh目标的指纹
      - run: echo $REMOTE_HOSTKEY >> ~/.ssh/known_hosts # 将HOSTKEY加入服务器的known_hosts避免提示
      - deploy:
          name: deploy
          command: |
            if [ "${CIRCLE_BRANCH}" = "master" ]; then
              rsync -avc ../blog/public $SSH_USER@$SSH_IP:/root/ 
            else
              echo "Not master branch, dry run only"
            fi
      # 通过rsync 将../blog/中的目录传到/root/中去
      - run: echo 'deploy successfully'
workflows: # 工作流，实际执行的代码
  version: 2
  deploy: # 操作名
    jobs:
      - build # 执行的job
  
```

> 这部分内容参考[发声的沉默者的博客](https://blog.csdn.net/weixin_42439919/article/details/103992977)

在博客中有更详细的解析，值得一提的是`rsync`这个指令由于版本更新已经不用`-e`来指定ssh了，如果添加会报错



CircleCI的逻辑是`jobs`是定义所做的工作，是通过**circleCI的服务器**拉取docker的image，在docker中执行steps的指令，并通过rsync传递到我们的服务器中去。

目前`npm install`的指令还会因为`socket timeout`而导致自动化部署失败，这是我没有找到解决方案的一个问题。



# 结束

博客搭建差不多结束了，还是很有意思的。

希望接下来我能在这里玩的开心。
