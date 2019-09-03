---
author: huji0624
comments: true
date: 2013-07-30 15:21:46+00:00
layout: post
slug: '%e5%85%b3%e4%ba%8euiviewcontroller%e7%9a%84presentviewcontroller%e5%ae%9e%e7%8e%b0'
title: 关于UIViewController的presentViewController实现
wordpress_id: 700
categories:
- iOS
---

cocoa本身的UIViewController提供了一些用来模态展示ViewController的方法，在比较旧的系统上是presentModalViewController这个接口，在5.0及以后的系统中统一为presentViewController接口。

我们通常可以这么调用:
[self presentViewController:<#(UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>];

但是这么调用以后，被展示的ViewController所对应的view，实际上是被放都了哪里呢，我之前曾有过三种猜测:
1）被加入到了keyWindow中
2) 被加入到了keyWindow的rootViewController.view中
3) 被加入到了self.view中

但最近在项目中有一个非常有意思的发现:
在appdelegate中初始化一个ViewController并赋给keywindow的rootViewController，然后往该rootViewController.view加入某个UIViewController的view(AVC.view)，这时候，理论上这时rootViwController.view.subviews里面应该包含的仅有一个AVC.view，然后再在这个AVC中presentViewController一个UIViewController(BVC)，这时候，理论上如果BVC.view被加到rootViewController的话，rootViwController.view.subviews里面应该包含的子view就是AVC.view,BVC.view。但实际上我们会发现rootViwController.view.subviews里面应该包含的子view仅有BVC.view，对，在实际的实现中，cocoa是把那个view替换掉了.

后来我又发现了，确实有被presentViewController加入到keywindow中的情况，我猜想cocoa的实现应该是，如果调用presentViewController的这个UIViewController的view的superView是window的话，那么被present的这个ViewController的view就会被加到window中，否则被加入到keyWindow的rootViewController当中.

很苹果的技术风格.


