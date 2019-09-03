---
author: huji
comments: true
date: 2014-07-24 14:21:41+00:00
layout: post
slug: Git合并branch上的指定文件
title: Git合并branch上的指定文件
categories:
- git
---
我的主branch是master，一个开发分支是RemLan，现在需要把RemLan上的某些修改合并到master上来，发现用merge只能对所有的diff进行merge，最多根据commit进行区分（这也提醒我以后如果做某些基础功能的开发，那就统一成一次提交，我觉得这个应该是git原本的设计），但没有直接的命令支持某几个指定文件的合并。

但是通过某些命令的简单组合，也可以达到这个效果，但总的来说我感觉git的使用逻辑还是应该用commit来区分才是正统的方法。

以我的需求为例，RemLan上修改了一个文件A.h，新增了一个文件B.h，删除了一个文件C.h。

	1.git checkout master //首先切换到master分支
	2.git checkout -p RemLan A.h //不切换branch，把RemLan上的A.h更新到当前分支
	3.git checkout RemLan B.h //去掉-p参数，新增该B.h文件
	4.rm C.h  //删除文件目前还没找到其他办法，但效果是一样的
	5.提交

这样就算是合并了指定文件了。

另外在解决merge的时候，有这个情况
# To remove '-' lines, make them ' ' lines (context).
其实就是把 '-' 换成 ' '，这个我刚开始也没理解...
