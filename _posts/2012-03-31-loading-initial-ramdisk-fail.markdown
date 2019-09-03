---
author: huji0624
comments: true
date: 2012-03-31 16:26:27+00:00
layout: post
slug: loading-initial-ramdisk-fail
title: Loading initial ramdisk fail
wordpress_id: 427
categories:
- Linux
---

哈，我的Fedora终于又活过来了。

今天更新了一下100多M的软件包，结果更新完了一重启以后，就一直停在Loading initial ramdisk的提示处，也没有什么特别的提示错误。而且还能进入recovery mode ，也能进入irtual terminal执行命令，甚至还能上网。

重启以后换之前版本的kernel启动还是不行，应该不是kernel更新的错误，在网上一顿search。最近确实有很多人遇到这个现象，但搜出来的有好几个哥们和我的情况还是不同，例如有的换一个kernel就可以了，有的使用recovery mode启动以后就可以了，有的把bois设置为默认值就可以了，但我把这些方法都试了一遍还是不行，只有这个哥们[loading initial ramdisk fail](http://forums.fedoraforum.org/showthread.php?t=278034)貌似和我遇到差不多的问题。

下午在公司整了半天也没搞定，回来以后请教良神，终于搞定了。原来是在更新包的时候把gnome相关的一些组件卸载了，导致无法启动gnome。

我这个情况比较特别，因为之前我有在更新的时候被中断，导致有些更新不完整，可能导致系统对某些组件或者库的判定出现错误，而这次更新就把一些我没有重复（duplicate）的组件给卸载了。因为我之前运行过package-cleanup --cleanupdupes清除一些重复的库，可能就是在这里把那些删掉了。

查看了一下启动的shell源码 /etc/X11/prefdm


    
    
    
    if [ -f /etc/sysconfig/desktop ]; then
     13     . /etc/sysconfig/desktop
     14     if [ "$DISPLAYMANAGER" = GNOME ]; then
     15         preferred=/usr/sbin/gdm
     16     elif [ "$DISPLAYMANAGER" = KDE ]; then
     17         preferred=/usr/bin/kdm
     18     elif [ "$DISPLAYMANAGER" = WDM ]; then
     19         preferred=/usr/bin/wdm
     20         splash_quit_command="plymouth quit"
     21     elif [ "$DISPLAYMANAGER" = XDM ]; then
     22             preferred=/usr/bin/xdm
     23         splash_quit_command="plymouth quit"
     24         elif [ -n "$DISPLAYMANAGER" ]; then
     25         preferred=$DISPLAYMANAGER
     26         splash_quit_command="plymouth quit"
     27     fi
     28 fi
    
    



我的displaymanager是选的gnome，但是我又没有gdm，这里也没有输出任何错误信息,所以停在了Loading initial ramdisk这个地方，我的文章题目选则Loading initial ramdisk fail是希望上面链接里那哥们没准能搜到这篇文章，解决他的问题，因为那个论坛不知道为啥注册不了，我没法告诉他我的情况和解决方法。

所以解决方法很简单，sudo yum install gdm就行了。我还少了个gnome-shell也一起装了。

重启，打工告成，Fedora又活过来了。

以后还是没事别乱更新了。不过也好，搞出毛病，解决问题，又搞明白了不少东西。
