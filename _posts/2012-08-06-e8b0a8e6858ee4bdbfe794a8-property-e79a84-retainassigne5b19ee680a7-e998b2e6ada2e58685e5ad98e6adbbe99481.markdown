---
author: huji0624
comments: true
date: 2012-08-06 16:45:21+00:00
layout: post
slug: '%e8%b0%a8%e6%85%8e%e4%bd%bf%e7%94%a8-property-%e7%9a%84-retainassign%e5%b1%9e%e6%80%a7-%e9%98%b2%e6%ad%a2%e5%86%85%e5%ad%98%e6%ad%bb%e9%94%81'
title: 谨慎使用 property 的 retain,assign属性 防止内存死锁
wordpress_id: 548
categories:
- Objective-C
---

本来关于在property生命属性时，我常用的方式是 如果是类实例对象，就用retain，并在dealloc函数中释放它.如果是基本类型，就用assgin。这一用用成习惯，对于id类型，由于它是表示任意Objective-c对象，所以我一般也是使用retain声明，但在某些情况下，这样很容易就导致了内存死锁。

最近我在项目中遇到这么一次.

比如这样的情况.

你有一个类 Son ，还有另外一个类 Father.

对Faher来说，有一个属性


    
    
    @property (nonamic,retain) id<son> son;
    



然后你在dealloc函数中释放它的引用


    
    
    -(void)dealloc{
      self.son=nil;
      [super dealloc];
    }
    



对于Son来说,有一个属性

    
    
    @property (nonamic,retain) Father *father;
    



然后你同样在dealloc中释放它，并在初始化函数中初始化

    
    
    -(void)dealloc{
      self.father=nil;
      [super dealloc];
    }
    
    -(id)init{
      Father *fa = [[Father alloc] init];
      fa.son=self;
      self.father = fa;
      [fa release];
    }
    


这样的代码咋一看是非常符合Objective-c内存管理规范中的条条框框的(我理解的规范这样的代码应该是对的),但是如果你使用这个Son类时，创建一个Son的实例，并释放它。你会发现实际上s没有被回收.从内存泄露工具leaks你也查不出内存一直增大的原因.据我所知，让调用release让retaicount为0的时候系统会调用dealloc回收相应实例的内存，而不能直接调用dealloc的（具体忘记为啥了，记得文档上曾经看到过）.这里


    
    
    Son *s = [[Son alloc] init];// s.retaincount = 1 由于Son初始化函数的实现 s.retaincount = 2 , s.father.retaincount = 1
    [s release];// s.retaincount = 1 s.father.retaincount = 1.造成死锁.
    



所以这里的解决办法需要和实际情况结合，比如在我的项目中，Father的生命周期始终是比对应的Son短，所以我把Father中的property由retain改为assgin就行了。

目前我自己遇到的内存死锁的情况就是这种
当 class.property.property=self ，property的声明属性还是retain，就要小心了.


