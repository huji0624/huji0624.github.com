---
author: huji0624
comments: true
date: 2012-12-18 11:52:33+00:00
layout: post
slug: ios-%e6%80%8e%e6%a0%b7%e5%ae%9e%e7%8e%b0%e4%b8%80%e4%b8%aa%e7%81%b5%e6%b4%bb%e5%bc%82%e6%ad%a5%e9%ab%98%e5%ba%a6%e5%8f%af%e5%8f%98%e7%9a%84uitableiview
title: iOS 怎样实现一个灵活异步高度可变的UITableiView
wordpress_id: 625
categories:
- iOS
---

在实现一个类似QQ的聊天窗口时，有一种方式是使用SDK自带的UITableView，每一个UITableViewCell就是一个聊天项。每一个聊天项的文字长度，图片大小都可能不一样，所以你的UITableView的一个Cell的高度应当是可变的，并且，当你的图片不在内存中时，你还需要异步地来改变这个Cell的高度。当然你也可以自己继承UISCrollView完全自己实现这么一个东西，不过总体来说比较麻烦。

首先得搞清楚UITableView是如何工作的。撇开类似- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section这种比较基础的用法不说。主要关注下如何实现高度可变，文字方面主要利用的是NSString的sizeWithFont:_messageTextLabel.font constrainedToSize: lineBreakMode方法，能让你计算出该段文字所占的大小，然后你再根据这个大小来设置Cell的大小。图片方面需要绕一个弯子，因为图片一般并不是存储在内存中的，你需要异步地从网络或者硬盘中先取得图片，再通知通知的UITableViewCell更新相关的内容（包括高度和图片内容），我的大体思路是就是这样的，本来是件很简单的事情，但我发现在iOS里面实现起来还挺麻烦的（在Android上就相对简单得多)。这里相关的主要是实现两个方法：-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 和 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath。当UITableView reload的时候，他会根据numberOfRows返回的个数，调用相应次数的heightForRowAt....方法，来确定每个Cell的高度（并存储起来，在再次调用reloadxxx之前不会再询问某个Cell的高度了），然后会调用相应的cellForRowAtIndexPath来返回这个Cell的实例。

这里第一个问题就出来了,我实现的时候，希望的是heightForRowxx返回的值就是我的Cell的高，而且我希望计算的代码都在Cell当中，因为这本来就应该是Cell做的事。我在网上看到有国外的哥们的解决办法是在heightForRowxx中先用nsstring计算大小返回并缓存起来，然后在Cell中就不用再次计算了，但我很不喜欢这么写。我的第一版，采用了非常暴力的办法，直接在heightForRowxx方法中调用cellForRowAtIndexPath方法来取得相应的cell，然后返回这个高，所以cellForRowxx方法就会被调用两次，效率非常低。后来我增加了一个NSMutableDictionary，在heightForRowAtIndexPath调用的时候，把取得的Cell缓存起来，在cellForRowxx方法中就直接返回这个缓存的Cell，利用row来作为key。这样的好处是，你可以不用理会UITableView的调用逻辑，把Cell的高度完全由它内部的内容来决定，并且把这个值返回给tableview。对于异步加载过来的图片，你需要调用[tb reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic]来刷新相应的行。
代码大概这样:

    
    
    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        id aKey = [self buildCellCacheKey:indexPath];
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        
        if ([_cellCache objectForKey:aKey]==nil) {
            [_cellCache setObject:cell forKey:aKey];
        }
        
        return cell.bounds.size.height;
    }
    
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        //for flexible height of table view cell.in this way,the cell height won't be caculate twice.
        id aKey = [self buildCellCacheKey:indexPath];
        UITableViewCell *cacheCell = [_cellCache objectForKey:aKey];
        if (cacheCell) {
            [cacheCell retain];
            [_cellCache removeObjectForKey:aKey];
            LOGDebug(@"return cache cell [%d]",indexPath.row);
            return [cacheCell autorelease];
        }
    
    	//这里可以来定制自己的Cell.	
    }
    



这里我发现一些问题，就是这里的Tableviewcell实际上是没能复用的，所以这个只适合cell比较少的情况，因为cell如果太多，那代价是非常大的。目前我还没有发现更好的解决方案，貌似只能采用计算高度并cache的办法了。

本来逻辑上就应该是这么，但是我在实现的时候发现了一些特别的情况。本来当你从网络读取图片的时候，一般大概得1,2秒才能返回图片数据，这时刷新相应行时，能完全正常刷新。但是当你把图片缓存到本地时，经常发生的情况是，在heightForRowAtIndexPath后，cellForRowAtIndexPath之前就已经返回图片数据了，这时的刷新就没有效果了，因为这时上一次缓存的Cell甚至都还没有返回，所以这种情况下，应该把之前缓存的Cell先清理掉。但是这一块目前还有个问题我没有解决，就是一般来说你应该在用户第一次打开某个聊天的时候，把记录滚到最下面，表示是最新的记录在下。这里的动画目前看起来比较古怪，我研究了一下QQHD的消息列表，加上自己的实践，我觉得基本上只能是延迟加载图片才能真正解决这个问题，也就是当tableview不再滚动的时候，加载能见cell的图片，主要利用以下几个方法:

    
    
    -(void)loadImageInVisible{
        NSArray *visibles = [self.tableView visibleCells] ;
        
        for (MsgBoxImageCell *ic in visibles) {
            if ([ic isKindOfClass:[MsgBoxImageCell class]]) {
                [ic loadImageWhenScrollEnd];
            }
        }
    }
    
    -(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
        [self loadImageInVisible];
    }
    
    - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
    {
        if (!decelerate)
        {
            [self loadImageInVisible];
        }
    }
    
    - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
    {
       [self loadImageInVisible];
    }
    
