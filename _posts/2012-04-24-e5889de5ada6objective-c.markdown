---
author: huji0624
comments: true
date: 2012-04-24 16:29:22+00:00
layout: post
slug: '%e5%88%9d%e5%ad%a6objective-c'
title: 初学Objective-C
wordpress_id: 452
categories:
- Objective-C
tags:
- 笔记
---

由于自身的兴趣和公司需要，也开始搞iOS。

因为以前在学Android的过程中走了很多弯路，所以打算这次就直接从苹果的官方文档开始，发现苹果的官方文档数量真是多得惊人，远比Android的文档要完善，一点一点啃了，今天完整地学习了官方的这篇文档，算是一个起步，[Learning Objective-C: A Primer](http://developer.apple.com/library/ios/#referencelibrary/GettingStarted/Learning_Objective-C_A_Primer/_index.html)，发现Objc也不像之前偶然看到的那么别扭了，顺眼了许多。

感谢台湾同胞的这篇文章，解除了我许多困惑.[protocol-in-objective-c](http://blog.eddie.com.tw/2010/12/11/protocol-in-objective-c/).

一下是从这篇文章延伸出来打算先看的文档：
The Objective-C Programming Language
Advanced Memory Management Programming Guide
Garbage Collection Programming Guide
Objective-C Runtime Programming Guide
Cocoa Fundamentals Guide

再吐槽几句这两天看Objective-C的感觉：

1。从语法上虽然咋一看稀奇古怪的，但抛开一些别的符号不说，总的来说和Java还是比较像，毕竟都是OO语言。比如单继承，比如接口和类的定义，方法的重写。我在想那很多Java中用到的设计模式，在Objc里应该也能使用了。看多了语法，还觉得可以接受，就是对反复使用[]符号不太习惯。

2.有一点觉得比较蛋疼的就是感觉ObjC编写程序总有一种相当不安全的感觉，在编译阶段的检查感觉不如Java考虑得多，比如他的Message机制，感觉就是不断使用Java的反射进行方法的调用，总觉得相当不安全，再比如方法的重写，貌似也没有什么特别的声明，总觉得会不小心重写掉一些自己都不清楚的方法。

3.BOOL类型 YES NO ，我勒个去，真是通俗易懂，一点不像TRUE FALSE一样装科学....

4.@interface其实是Java中的class，Protocol才是Java中的interface。在@interface中只有各种定义，变量的定义，方法的定义，把所有实现都丢在@implementation中。

5.比较蛋疼的初始化类的方法，感觉和Python的某些特点有相似之处，说不清楚，也许能提供某些比较有特点的使用方式，但总觉得在初始化中还需要判断self==自己的类，灰常不爽快，父类当时又不知道会有哪些子类，何必呢。
