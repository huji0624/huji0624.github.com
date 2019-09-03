---
author: who
comments: true
date: 2011-08-17 09:59:55+00:00
layout: post
slug: '%ef%bc%88%ef%bc%81%e6%a0%87%ef%bc%89java-compareandset%ef%bc%88%ef%bc%89%e6%96%b9%e6%b3%95%e5%88%86%e6%9e%90%e5%8f%8a%e7%9b%b8%e5%85%b3%e6%a6%82%e5%bf%b5%e4%bb%8b%e7%bb%8d'
title: （！标）Java compareAndSet（）方法分析及相关概念介绍
wordpress_id: 109
categories:
- JAVA
- 非标准程序员成长之路
---

_恭喜，我写出了非标准程序员系列的第一篇文章，以后我都在会这个系列的题目前加一个（！标）的标记，这些文章都是原创，转载请注明。_

问题情景：公司要做一个解析库，是一个底层库，需要给公司的Android和Kjava版本的客户端做解析。我在写解析库的时候需要考虑到不同平台的Java版本问题，Android支持Java1.6版本，但Kjava貌似只支持1.0版本，所以在实现解析库的时候，为了提高整体效率，不让kjava拖后腿，我要针对两个平台写两种io流的实现方式。针对Android版本的不多说了，主要使用了文件通道和缓冲器。Kjava版本准备自己模仿Java的BufferedInputstream类写一个带有缓冲和标记的输入输出流。在读BufferedInputsteam类的源码的时候，遇到了这个让我晕了半天的compareAndSet（）方法。

<!-- more -->

先说源码遇到的问题，源码中一段填充缓冲区的代码如下（截取）：

byte[] buffer = getBufIfOpen();


byte nbuf[] = new byte[nsz];




System.arraycopy(buffer, 0, nbuf, 0, pos);




if (!bufUpdater.compareAndSet(this, buffer, nbuf)) {




// Can't replace buf if there was an async close.




// Note: This would need to be changed if fill()




// is ever made accessible to multiple threads.




// But for now, the only way CAS can fail is via close.




// assert buf == null;




throw new IOException("Stream closed");




}




**_buffer = nbuf;_**




count = pos;




int n = getInIfOpen().read(buffer, pos, buffer.length - pos);




if (n > 0)




count = n + pos;




在缓冲字节流中，当读取的位置大于了缓冲区的范围的时候，就会执行这段代码来读取更多的缓冲区数据，但由于对compareAndSet方法不了解，代码其中一处让我很困惑（粗体斜体部分）。这里buffer本来是取得了成员变量缓冲区数组的引用，并把当前的数据复制到新的数组中，但后来又让buffer=nbuf，那不就把原来的引用丢了么，最后还对这个已经不是原引用的数组进行read（）操作，感觉都乱套了，我猜测应该是在compareAndSet方法上有什么猫腻。研读了一下关于这个方法的解释，如下：




_ 如果当前值 `==` 预期值，则以原子方式将此更新器所管理的给定对象的字段值设置为给定的更新值。对  `compareAndSet` 和 `set` 的其他调用，此方法可以确保原子性，但对于字段中的其他更改则不一定确保原子性。_




对于一个非标准程序员来说，有点晦涩，原子性？不懂，又到网上查了一下这个函数的用法，如下：




_ 在method 启动时预期数据所具有的值，以及要把数据所设定成的值。method只会在变量具有预期值的时候才会将它设定成新值。如果当前值不等于预期值，该变量不会被重新赋值且method 返回false。如果当前值等于预期值会返回boolean 的true 值，在这种情况下，值会被设定成新值。_




感觉大概意思是为了方式由于异步操作造成数据混乱，所以搞了个这个方法。但还是有点晕，于是做了几个实验，来得直观。代码如下：







byte[] bb=buf;




byte[] cc = new byte[4];




print(cc);




print(buf);




print(bb);




System.arraycopy(bb, 0, cc, 0, 2);




print(cc);




print(buf);




print(bb);




print(bufUpdater.compareAndSet(this, bb, cc));




print(cc);




print(buf);




print(bb);




buf是成员变量中的一个byte数组，得到的结果如下：







[B@c17164




[B@1fb8ee3




[B@1fb8ee3




[B@c17164




[B@1fb8ee3




[B@1fb8ee3




true




[B@c17164




[B@c17164




[B@1fb8ee3




这里print打印的是引用的地址，可见，本来bb是指向buf，所以在执行方法前bb和buf的地址一样，当执行了compareAndSet方法后，居然是buf的地址变为了cc的地址，也就是说buf被重新指向cc了，这就不难理解源码里那句代码了。







对于一个非标准程序员来说，这样的结果已经很让人满意了，但我还是不理解为什么代码的原作者非要这么写，我觉得在执行System.arraycopy(bb, 0, cc, 0, 2);这句以后，再来一句buf=cc；不就也完成了一样的任务么。我觉得应该是在这个原子性上的文章。







在网上查了一下资料，其实多数地方说的还是有点晦涩，按照我的理解，原子操作就是程序必须执行的一段最小的代码，这段代码不会因为任何原因被打断，比如i++，但是有点复杂的操作，因为某些中间过程很多，有可能被某些机制挂起，比如阻塞，比如同步锁。也就是说这里说的原子性的xxxx云云，是为了保证在某些多线程情况下，这个缓冲数组都是同一个，不会混乱，我目前也顶多能理解到这个地步了。虽然我又继续顺藤摸瓜看了下compareandSet方法的源码，一路是各种继承关系往下，各种判断，但在某个地方就看不到更多有实际意义的源码了，所以具体引用地址是如何变了的，我还不甚了解，希望明白人留下个解答最好。







最后总结下理解某些东西最好的方法就是实验，自己编写测试代码，即使不理解那些晦涩的词汇和描述性说法，但至少自己心里清楚怎么回事，我觉得这就非常好。
