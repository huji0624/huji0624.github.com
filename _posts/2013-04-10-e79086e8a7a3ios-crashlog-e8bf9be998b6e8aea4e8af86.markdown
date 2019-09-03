---
author: huji0624
comments: true
date: 2013-04-10 07:29:30+00:00
layout: post
slug: '%e7%90%86%e8%a7%a3ios-crashlog-%e8%bf%9b%e9%98%b6%e8%ae%a4%e8%af%86'
title: 理解iOS Crashlog 进阶认识
wordpress_id: 662
categories:
- iOS
---

之前写过一个关于iOS crashlog的文章，但当时也还有挺多东西没搞明白，正好这段时间在新公司也要进行这方面的工作，发现之前很多没有理解的地方都慢慢更理解了，再做个小总结。

其实这些东西开始觉得很晕，但只要看了两个东西就大体上明白了，一是symbolicatecrash这个脚本，一是苹果一个叫CrashReport的文档，网上一搜就搜到了。

我先按自己的理解还原一下生成crashlog的过程：
	假设你的程序在运行的过程中，访问了一个错误的内存，这时候系统要kill掉你这个进程，在kill你之前，会先给你传一个signal，并且在结束进程前执行一个你的回调函数，这个时候，就可以在这个回调函数中拿出来函数调用栈中的信息，并按照一定的格式生成crashlog。

symbolicatecrash脚本的执行过程
	首先解析crashlog，取得其中某些必要的参数和内容，比如crashreport的版本，取得Binary Image部分的内容，取得栈地址部分的内容，很多解析都是用正则匹配得到的，所以如果你自己拼接的crashreport的格式不正确那么在使用这个脚本的时候，就可能不能正确的解析。
	然后脚本会开始做一些检测，比如你的crashlog中有一些uuid的参数，用<>括起来的部分，其中有你自己的可执行文件的，也有一些系统库的，脚本会利用一些命令来对比crashlog中的这些库和你这台机子上的库的uuid是否匹配，还有arch是否匹配，及其和dSYM的uuid是否匹配等等。
	最后脚本会根据解析得到的内容，开始组合另外一些工具来生成新的crashreport，主要是使用atos工具，把栈地址转换为函数名，在转换的时候，它不仅会使用crashreport中直接记录的那个栈地址，还要用到每一个库（包括自己的executable）在该系统中内存开始加载的开始地址，这里还有一个slide的概念，它其实就是打算加载地址（Intended load address比如0x100000减去实际加载地址的值-实际加载地址就是Binaryimage中记载的值）。
最后脚本把原本的东西和新生成的东西按一定格式拼接起来，就是转换以后的crashlog了。

symbolicatecrash脚本使用注意:
	symbolicatecrash脚本要加上-v参数才会输出标准错误，否则出错了也不知道.
	symbolicatecrash脚本会寻找你mac中所有和dSYM的名字相同的.app文件的可执行文件来对比uuid看是否配套.
	针对模拟器生成的executable缺失了很多内容，所以在模拟器中发生的崩溃的crashlog不能正常转换.你用otool工具来分析针对真机和模拟器生成的executable的时候，就能发现这个区别.

.dSYM的作用
	.dSYMy用于记录在executable中各偏移量所对应的函数地址的关系。可以通过atos转换。

一些相关命令:
atos
dwarfdump
otool
lipo


