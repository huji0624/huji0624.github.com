---
author: huji0624
comments: true
date: 2012-05-24 16:12:02+00:00
layout: post
slug: java%e7%a8%8b%e5%ba%8f%e5%91%98%e7%9c%bc%e4%b8%ad%e7%9a%84-objective-c-%e5%86%85%e5%ad%98%e7%9a%84%e9%82%a3%e4%ba%9b%e4%ba%8b
title: Java程序员眼中的 Objective-C 内存的那些事
wordpress_id: 480
categories:
- Objective-C
---

今天和liuhua交流了一下ios编程时内存管理的心得，他认真地给我总结了相关的情况，非常感谢，我也自己梳理一下，做个总结。

苹果的官方文档 内存管理指南 已经做了非常详细的说明和知道，读了那篇文档加上一些实践我感觉应该差不多能掌握objective c 编程时的一些内存使用方法，但是貌似对c部分的讲解比较少，我也是对这部分不太清楚，才产生了混淆。

应为Objective c是标准c的超集，所以在objc里面也能混合使用c代码，所以感觉其实在objc内存管理中得分为两部分来看，objective c部分和 c部分。

1.纯粹的objective c对象内存管理

首先看一下objective c的内存管理的基本原理，objc对每个对象（貌似只能是继承自NSObject）都有一个引用计数器，某些操作会让引用计数器 +1，某些操作会让引用计数器 -1 ，当引用计数器为 0 时，就会被系统的垃圾回收器回收。

再看objective c的内存管理基本原则：
会直接让计数器+1的操作：以init开头的方法获得的对象，以copy开头的方法获得的对象（记得貌似还有个，具体的可以参考官方 内存管理指南），对象的retain方法，@property 中被声明为 retain的变量在被set的时候等；
会直接让计数器-1的操作： release；
会在未来某个时候让计数器 -1的操作： autorelease（这个在需要返回对象参数的时候会用到，但不要乱用，可能会带来问题）；

所以根据根据基本原理和基本原则，还是能比较方便地管理 objc的内存的。具体的规则比如，init copy方法得到的对象，如果不适用了，就应该release ，如果可能会返回给别人使用就应该 autorelease。property中的对象在Dealloc时候应该release等等。NSArray等也有些比较需要注意的地方，在文档中有说明。

2.c 内存管理

目前我对本身c内存管理不熟(这也是我主要晕的部分)，在objective c中一般也不需要自己mallc 和 free，这部分主要是一些c实现的api的使用 ，比如CFxxx ，CGContextxxx等，在使用它们的时候的基本原则是，在调用了带有 Create开头的方法获得的对象后，要在不再使用时调用相应的 xxRelease方法以释放其资源，比如 CGContextCreate 和 CGContextRelease （记得是有这两个方法来着~）。

3.我晕菜的情形

其实我之前看了 内存管理指南 ，对objc的内存管理感觉还算了解了，对c也有一定了解，但在混合使用的时候自己还是晕菜了(也有对指针不熟的原因)，因为之前一直使用java，几乎不需要考虑什么时候释放的问题（当然某些情况还是需要注意）。

@interface A 
{
  int aInt;
  CGRect aRect;
  CGRect *bRect;
  NSObject *aOb;
  NSObject *bOb;
}

@property (noautom,retain) NSObject *bOb;

代码如上，我经常带代码中会有这种情形，这些变量和属性会在实现中的某些地方被置为某个值或指向某个内存，那么哪些需要释放，哪些不需要，哪些能放心使用，哪些可能会使用了已经被回收的数据.

aInt aRect *bOb 可以放心使用，*bOb需要在dealloc中release
*aOb *bRect 可能使用已经被回收的值

这里 aInt aRect是在对象的内存空间上的，没有指向别的对象，所以对他赋值时，就是创建了一个拷贝，*bRect 是指向了一个别的CGRect的指针，什么时候被回收是个未知数，所以使用不安全，*aOb同理，*bOb因为有retain属性在复制的时候会retain一下，所以不会被回收，*aOb如果再赋值以后也retain一下，应该也能安全使用，但那就应该自己在合适的时候release掉，所以使用property还是比较方便的。

大概就以上这么几点总结，欢迎指正。
