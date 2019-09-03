---
author: huji0624
comments: true
date: 2012-09-10 14:14:41+00:00
layout: post
slug: '%e8%8b%b9%e6%9e%9c%e4%b9%9f%e5%9d%91%e4%ba%ba-setneeddisplayinrect%e6%96%b9%e6%b3%95%e7%9a%84%e5%9d%91'
title: 苹果也坑人 setNeedDisplayInRect方法的坑
wordpress_id: 579
categories:
- iOS
---

今天一下午就毁在这个坑爹的setNeedDisplayInRect方法上了.

先吐槽一下ipad3，像素点长宽各提高了一倍，但是处理能力不见长，于是我们之前的代码出现了很多效率问题，但也好，让我意识到之前写的代码的不足，有些地方写得有点随意了，没有做到效率最优。因为我调试的时候发现在ipad2上表现良好，但到了ipad3就悲剧了，基本上所有涉及到整个view刷新的地方全都出现了严重的效率问题，用户体验及其不流畅.有些地方确实是我自己代码的问题，但是有些地方真是没有办法，比如你从文件异步加载了一个图片到View的内存中，然后刷新一些view让图片显示，结果由于用户操作是上下滑动的，中间就会出现一个停顿，感觉很不好。

于是我修改代码，尽量把刷新的粒度减到最小，但是在测试的时候发现（这里轻描淡写地一句，但其实搞了好久才最终定位到setNeedDisplaiInRect方法上），在某些情况下，通常是第一次或者在隔了10几秒以后，调用setNeedDisplaiInRect时，View的整个区域都被刷新了，把setNeedDisplaiInRect的ClassReference反复读了两次，没有任何提到setNeedDisplaiInRect会引起整个View刷新的问题，最后还是在stackoverflow上查到了这个问题,见[http://stackoverflow.com/questions/10484291/setneedsdisplayinrect-causes-the-whole-view-to-be-updated](http://stackoverflow.com/questions/10484291/setneedsdisplayinrect-causes-the-whole-view-to-be-updated)，我整个人都斯巴达了.

据说是ios5以后才引入的这一机制，看苹果官方的文档也回答了这一问题，说实话，没太搞懂意义何在，提高drawimage的效率（也有人说这个是ios5的bug，我更希望是bug）？实在是不懂，这样一来，设计这两个方法有什么意义，刷新区域都不可控了，这也太不尊重接口了，用之前我们喜欢用的一句话说，信仰都没了。如果实在没办法要这么改，怎么也在方法的文档中说明一下吧，弄个那么偏僻的文档。还好有神器stackoverflow.先谢国家.
