---
author: huji
comments: true
date: 2014-12-18 15:37:06+00:00
layout: post
slug: JRSwizzle应用
title: JRSwizzle应用
categories:
- ios
---
JRSwizzle是什么？


JRSwizzle是github上的一个简单的开源项目，让你可以利用objective-c runtime运行时交换类方法，JRSwizzle的实现很简单，某些情况下其实不需要JRSwizzle的封装，因为比如在我的场景下只是针对objc2.0以上，ios系统。


JRSwizzle的其他工程应用我目前还没怎么见过，貌似objective-c的aop编程是采用的类似实现，在我经历过的ios项目中，一般的应用是改变一些系统类的方法，来防止release版本中得一些崩溃发生，比如NSArray下标越界，NSMutableArray加入一个nil的object，NSMutableDictionary使用setObject:forKey插入一个nil的object等等。以防止NSArray下标越界来说，可以这么处理：


首先实现一个NSArray的Category:
	
	@interface NSArray (Safe)
	-(id)safeObjectAtIndex:(NSUInteger)index;
	@end

	@implementation NSArray (Safe)
	-(id)safeObjectAtIndex:(NSUInteger)index{
	    if (index<self.count) {
	        return [self safeObjectAtIndex:index];
	    }
	    return nil;
	}
	@end

然后调用交换方法：

	[[[NSArray array] class] jr_swizzleMethod:@selector(objectAtIndex:) withMethod:@selector(safeObjectAtIndex:) error:nil];

具体为什么这么写，google一下就知道了。


后来我发现这篇文章：http://blog.csdn.net/yiyaaixuexi/article/details/8970734，所以我下面写的很多都是废话了。


但是对于调用未实现的方法引起的crash，处理起来就比较麻烦了。对于[xx method];[xx performSelector:@selector(method)];等等各种写法的方法调用，其实最终都是通过objc_msgSend这个C函数来实现的。当执行某个instance的某个selector的时候，如果找不到该方法的实现，那么会调用NSObject的forwardTargetForSelector，去询问实现类是否把这个方法转发一个其他的实现，如果返回的object还是没有实现该方法，那么就会抛出一个unrecognized selector的exception导致应用程序的进程崩溃。


原理大概就是这样，show me the code.
首先实现一个NSObject的Category:

	@interface NSObject (Safe)
	-(id)safeForwardingTargetForSelector:(SEL)aSelector;
	@end

	@implementation NSObject (Safe)
		-(id)safeForwardingTargetForSelector:(SEL)aSelector{
			NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
			if ([self respondsToSelector:aSelector] || signature) {
				return [self safeForwardingTargetForSelector:aSelector];
			}

			FakeForwardTargetObject *tmp = [[FakeForwardTargetObject alloc] initWithSelector:aSelector];
			return tmp;
		}
	@end

这里FakeForwardTargetObject的实现为:

	@interface FakeForwardTargetObject : NSObject
	-(instancetype)initWithSelector:(SEL)aSelector;
	@end

	#import <objc/runtime.h>
	id fakeIMP(id sender,SEL sel,...){
		return nil;
	}
	@implementation FakeForwardTargetObject
	-(instancetype)initWithSelector:(SEL)aSelector{
		self = [super init];
		if (self) {
			if(class_addMethod([self class], aSelector, (IMP)fakeIMP, NULL)){
				NSLog(@"add Fake Selector:[instance %@]",NSStringFromSelector(aSelector));
			}
		}
		return self;
	}
	@end

上面把过程分析了，但实际实现中有一个特别的处理，在判断是否相应某个方法的时候，同时也判断了该instance是否含有一个该selector的methodsignature。系统类或者是别人会使用苹果的消息转发来实现多继承，这里你不能无视这种行为。但这个目前只是一个经验判断，因为没有看到过objc_msgSend的源码.


这样，在给很多类方法加上保护以后，你的app应该会稳定很多，但这都是治标不治本的方式，只对完成kpi什么的有点用....本身oc这样设计的目的并不是用于这个目的，所以这么使用会带来潜在的风险，如果哪个版本的ios把这里的实现变了，它可能会兼容正规的消息发送方式，但对于这些旁门左道，可能就会引起大面积的错误.
