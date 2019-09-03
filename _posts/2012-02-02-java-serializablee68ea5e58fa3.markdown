---
author: huji0624
comments: true
date: 2012-02-02 08:28:30+00:00
layout: post
slug: java-serializable%e6%8e%a5%e5%8f%a3
title: Java Serializable接口
wordpress_id: 373
categories:
- JAVA
---

Java的Serializable接口是为了方便保存对象信息设计的接口，凡是实现了这个接口的类，可以把对象中的成员变量保存到文件或者数据库中，但不能保存方法（我觉得也没有必要），也就是说保存了对象的状态。

项目中可能会遇到需要使用到序列化的情况，先熟悉下。

先创建两个实现序列化接口的类：



    
    
    public class SerializeObject implements Serializable{
    
    	/**
    	 * 
    	 */
    	private static final long serialVersionUID = -1294114618002401119L;
    
    	private int pri;
    	public String pub;
    	protected Inner pro;
    	
    	public int getPri() {
    		return pri;
    	}
    	public void setPri(int pri) {
    		this.pri = pri;
    	}
    	public String getPub() {
    		return pub;
    	}
    	public void setPub(String pub) {
    		this.pub = pub;
    	}
    	public Inner getPro() {
    		return pro;
    	}
    	public void setPro(Inner pro) {
    		this.pro = pro;
    	}
    	
    	@Override
    	public String toString() {
    		return "SerializeObject [pri=" + pri + ", pub=" + pub + ", pro=" + pro + "]";
    	}
    	
    }
    
    class Inner implements Serializable{
    	private int in;
    
    	public int getIn() {
    		return in;
    	}
    
    	public void setIn(int in) {
    		this.in = in;
    	}
    
    	@Override
    	public String toString() {
    		return "Inner [in=" + in + "]";
    	}
    	
    	
    }
    



然后实例化SerializeObject并赋值，并把对象存储到文件中，再从文件中还原对象：


    
    
                    SerializeObject s=new SerializeObject();
    		s.setPri(99);
    		s.setPub("God");
    		Inner i=new Inner();
    		i.setIn(80);
    		s.setPro(i);
    		
    		try {
    			FileOutputStream fs = new FileOutputStream("huji.ser");  
    			ObjectOutputStream os = new ObjectOutputStream(fs);  
    			os.writeObject(s);
    			os.close();
    			fs.close();
    		} catch (FileNotFoundException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IOException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		}  
    		
    		try {
    			SerializeObject ss=new SerializeObject();
    			FileInputStream in=new FileInputStream("huji.ser");
    			ObjectInputStream is=new ObjectInputStream(in);
    			ss=(SerializeObject)is.readObject();
    			
    			print(ss);
    		} catch (FileNotFoundException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (SecurityException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (IOException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		} catch (ClassNotFoundException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		}
    



输出为：

SerializeObject [pri=99, pub=God, pro=Inner [in=80]]

可见，完全还原了原对象的状态信息。
1.不论是私有属性还是公有属性，都被序列化并且还原了。
2.成员变量含别的类的时候，如果该类没有实现序列化接口，那么这个类也不能序列化，在你试图序列化时会有exception，如果该类也实现了序列化，那么就没有问题了。
3.serialVersionUID主要是用来处理当你的类变量变动时的兼容性问题。
