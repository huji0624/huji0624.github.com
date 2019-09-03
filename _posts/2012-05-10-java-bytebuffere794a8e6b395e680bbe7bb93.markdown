---
author: huji0624
comments: true
date: 2012-05-10 10:50:58+00:00
layout: post
slug: java-bytebuffer%e7%94%a8%e6%b3%95%e6%80%bb%e7%bb%93
title: Java ByteBuffer用法总结
wordpress_id: 469
categories:
- JAVA
---

最近用SocketChannel进行网络编程比较多，中间也遇到了几个问题，出现的bug也主要来自于对于ByteBuffer的使用不当。现在终于调通了，对ByteBuffer及Socket网络编程也有了更深的认识，特此总结一下。

对于ByteBuffer主要需要注意的是几个标志的含义：position,limit,capability,mark.几个操作的影响：flip(),clear(),rewind().还有就是在读取或者写入时，标志的变化,比如get()方法导致position加1.

SocketChannel采用的是非阻塞异步读取流数据，在读取的时候，通常是


    
    
    ByteBuffer.clear();
    SocketChannel.read(ByteBuffer);
    



如果流中有数据，就会把数据从position开始读到ByteBuffer中，在读取之前ByteBuffer的clear操作会把position置为0,limit置为capability,也就是相当于清空了之前的内容，但是ByteBuffer中数组的内容在read之前是没有改变的.

read之后，通常就是开始从ByteBuffer中提取读到的数据，如果你的数据是以自己定义的数据包的格式进行发送的，那你还需要判断是否读到了数据包的结尾，因为对流数据本身来说是没有结尾这一说的。在提取数据之前，要先把position放到开始读取时的位置,把limit放到当前位置，所以要flip一下,表示从position到limit的位置都是需要的数据。


    
    
    ByteBuffer.flip();
    while(ByteBuffer.hasRemaining()){
    	byte c=ByteBuffer.get();
    	if (b == PACKAGE_END) {
    		//you can return the package here
    	}else{
    		//you can append the byte here.like StringBuilder.append().
    	}
    }
    



这样以来也存在一个问题，当一次读到的ByteBuffer不包含完整的数据包或者包含多个数据包.那么就需要在下一次继续把这些包分拆出来.那么在读取数据的代码处就可以改为,这样就把之前读取到的未完整的包保留了下来:


    
    
    if(!ByteBuffer.hasRemaining){
    	ByteBuffer.clear();
    	SocketChannel.read(ByteBuffer);
    }
    



另外一个可能会用到的操作就是ByteBuffer.rewind(),他会把position置为0，limit保持不变，可以用于重复读取一段数据.

ByteBuffer是nio中一个非常方便的工具.设计思想也非常值得借鉴.
