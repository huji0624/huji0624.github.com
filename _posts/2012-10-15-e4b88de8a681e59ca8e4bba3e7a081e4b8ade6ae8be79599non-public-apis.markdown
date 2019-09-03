---
author: huji0624
comments: true
date: 2012-10-15 09:01:30+00:00
layout: post
slug: '%e4%b8%8d%e8%a6%81%e5%9c%a8%e4%bb%a3%e7%a0%81%e4%b8%ad%e6%ae%8b%e7%95%99non-public-apis'
title: 不要在代码中残留non public APIs
wordpress_id: 595
categories:
- iOS
---

最近我们提交了一个版本，本来抓紧时间在国庆之前提交了，希望能早点上线。结果国庆回来，收到了苹果Binary Rejected的回信。

原因大致是:


    
    
    We found that your app uses one or more non-public APIs, which is not in compliance with the App Store Review Guidelines. The use of non-public APIs is not permissible because it can lead to a poor user experience should these APIs change. 
    
    We found the following non-public API/s in your app:
    
    _performMemoryWarning
    
    ...
    



原来是因为我曾经在测试程序对Memory Warning的反应的时候，在调试代码中使用了私有api _perforMemoryWarning，比如:

    
    
    -(void)debugMemoryWarning:(id)sender{
        SEL memoryWarningSel = @selector(_performMemoryWarning);
        if ([[UIApplication sharedApplication] respondsToSelector:memoryWarningSel]) {
            [[UIApplication sharedApplication] performSelector:memoryWarningSel];
        }
    }
    



调试完成后，我没有删除这一段代码，但也从来没有调用过。但还是被苹果reject了。看来你代码中的所有方法都被苹果扫描了一遍。
我再进一步阅读了resolution center中的回信，貌似，如果你自己定义的方法和苹果程序员定义的私有api同名，你也会被打上这个调用私有api的标签.程序不会被通过.

写在这里给自己提个醒，对于这种情况，要及时注释掉相关代码，或者用宏定义进行条件编译。
