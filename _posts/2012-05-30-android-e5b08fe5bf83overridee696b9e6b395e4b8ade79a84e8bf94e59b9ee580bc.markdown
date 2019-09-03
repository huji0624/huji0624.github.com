---
author: huji0624
comments: true
date: 2012-05-30 03:16:46+00:00
layout: post
slug: android-%e5%b0%8f%e5%bf%83override%e6%96%b9%e6%b3%95%e4%b8%ad%e7%9a%84%e8%bf%94%e5%9b%9e%e5%80%bc
title: Android 小心@override方法中的返回值
wordpress_id: 484
categories:
- Android
tags:
- Bug
---

今天调了一个非常蛋疼的bug，花了差不多一个小时的时间，在应用内的某个activity中不能使用设备的音量调节按钮调节音量，开始以为是因为window的某些flag导致的，试了试，貌似没有影响，后来又查manifest，也没有什么问题，最后还是定位到activity的代码上。读了半天代码没发现有哪异样的地方，只能苦比地一点一点删，看删了哪些部分以后会有影响，最后终于发现是override onKeyDown方法的时候的问题.


    
    
    @Override
    	public boolean onKeyDown(int keyCode, KeyEvent event) {
    
    		if (keyCode == KeyEvent.KEYCODE_BACK) {
    	                close();
    		}
    
    		return true;
    	}
    



本来是想用户按了返回键以后，执行关闭操作。但是在最后很随意地返回了一个true，最终导致这一个多小时的悲剧。先看看onKeyDown对return值的说明。

public boolean onKeyDown (int keyCode, KeyEvent event)

Returns

Return true to prevent this event from being propagated further, or false to indicate that you have not handled this event and it should continue to be propagated.

返回true表示你已经处理了，就不会在onKeyDown的事件中继续传递，所以相当于在当前activity中，所有的keyevent都被拦截了，但是对于close（）的响应是正确的，所以当时在写代码的时候就没有注意这个引入的bug，因为close（）工作正常！

修正后的代码:

    
    
    @Override
    	public boolean onKeyDown(int keyCode, KeyEvent event) {
    
    		if (keyCode == KeyEvent.KEYCODE_BACK) {
    	                close();
                            return true;
    		}
    
    		return super.onKeyDown(keyCode, event);
    	}
    


这里最后是返回 false 还是 super.onKeyDown(keyCode, event)。我觉得还是super方法比较好，因为父类还有很多对keydown事件的处理，置于要不要返回 true，就得具体情况具体分析了。

在Android当中，经常会用到这样的设计。尤其是很多返回 boolean 值的方法，比如 onTouch ， dispatchTouchEvent 。在我们继承系统组件的时候，经常会遇到这种情形，所以一定要认真看返回值的意义，在相应的时候返回正确的返回值，不然会引入一些很难察觉的bug，让程序出现一些很奇怪的现象。浪费青春阿！
