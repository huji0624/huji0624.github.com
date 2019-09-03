---
author: huji0624
comments: true
date: 2012-06-07 11:34:42+00:00
layout: post
slug: objective-c-id%e7%b1%bb%e5%9e%8b%e5%92%8cprocotol%e7%9a%84%e4%bd%bf%e7%94%a8
title: Objective-c id类型和procotol的使用
wordpress_id: 506
categories:
- Objective-C
---

晕了一下午，终于把Objective-C里面这个procotol的常用用法给搞明白了.

根据苹果的 The Objective-C Programming language 文档的指示，对某个 procotol 类型的声明为:


    
    
    
    id<procotol> xxprocotol;
    
    



在方法的返回值，参数，和inerface的实例变量和property中都是这么声明，记得以前看苹果文档中id可表示Object类型，类似void，但一般在objective-C中表示类实例的地方一般都是用指针，这样你才能操作到指针所指的那个实例，所以这个地方让我困惑了很久，看了一些demo代码和公司的代码，发现不管是返回值还是在实例变量中声明，都是使用的id ，而不是 id *。

后来才发现对id的解释是 **id关键字类似void* **，这样才把这个想通，那id的用法就完全是合情合理的了，id * 则是指向指针的指针了.

进一步搜索了一下，关于 id和void* 的区别。有一篇StackOverflow上的问题做了很多讨论，[id&&void;*](http://stackoverflow.com/questions/1304176/objective-c-difference-between-id-and-void)，我觉得是比较好的回答。

那么按照这个逻辑，在代码中如下使用也应该是完全合法的(这里的<>感觉类似Java中的范型的使用，具体还不是很清楚):


    
    
    
    NSObject<procotol> *xxprocotol;
    
    



我尝试了一下，编译能通过，运行应该没有问题，等以后验证了再议。不太清楚这样设计的目的，我猜测是不是因为Objective是c的超集，同时能混入c／c＋＋代码，为了和这两种语言取得某种意义上的相似性.
