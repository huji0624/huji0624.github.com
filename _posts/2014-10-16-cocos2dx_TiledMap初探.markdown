---
author: huji
comments: true
date: 2014-10-16 09:45:56+00:00
layout: post
slug: cocos2dx_TiledMap初探
title: cocos2dx_TiledMap初探
categories:
- game
---
首先创建tiledmap我使用的是Tiled这个工具，网上到处都有下载的，免费。


我在Tiled中创建了以下两个图层，一个是作为背景使用，一个作为游戏中的对象层.
<img src="/images/tiledmap_layer.png"/>


在boards对象层中，创建了四种类型的对象，圆，矩形，多边形，折线。
<img src="/images/tiledmap_objects.png"/>


开始搞代码部分，使用Tiled工具可以生成tmx格式的地图文件，在cocos2dx中，可以这样初始化这个地图:


	TMXTiledMap *map = TMXTiledMap::create("jb.tmx");
	gameLayer->addChild(map);


这里说一句，gameLayer是我新创建的用于放置游戏对象的层，其他的一些ui的东西，放在最外层的layer中，这样我们就可以整体移动这个层达到移动地图的目的。


然后我们取得boards这个对象层：


	TMXObjectGroup *group = map->getObjectGroup("boards");
    const ValueVector vv = group->getObjects();
    for (int i = 0 ; i<vv.size(); i++) {
        ValueMap v = vv.at(i).asValueMap();
        
        float x = v.at("x").asFloat();
        float y = v.at("y").asFloat();
        std::string name = v.at("name").asString();
        
        log("----------KEY----------- %s",name.c_str());
        for (auto iter = v.begin(); iter != v.end(); iter++) {
            log("key %s",iter->first.c_str());
        }
    }


利用上面的代码，你可以遍历整个boards层中的对象，我只使用到了x，y，name三个属性，其余的所有属性根据对象的类型不同略有不同，代码中已经打印出了所有的属性，打印输出如下：


	cocos2d: ----------KEY----------- circle
	cocos2d: key name
	cocos2d: key width
	cocos2d: key type
	cocos2d: key x
	cocos2d: key height
	cocos2d: key gid
	cocos2d: key y
	cocos2d: ----------KEY----------- rect
	cocos2d: key y
	cocos2d: key gid
	cocos2d: key height
	cocos2d: key type
	cocos2d: key x
	cocos2d: key name
	cocos2d: key width
	cocos2d: ----------KEY----------- polygon
	cocos2d: key points
	cocos2d: key width
	cocos2d: key name
	cocos2d: key type
	cocos2d: key x
	cocos2d: key height
	cocos2d: key gid
	cocos2d: key y
	cocos2d: ----------KEY----------- path
	cocos2d: key width
	cocos2d: key name
	cocos2d: key type
	cocos2d: key x
	cocos2d: key height
	cocos2d: key gid
	cocos2d: key y
	cocos2d: key polylinePoints


可以看到，多边形和折线的属性略有不同，其他的属性类似，利用这些属性，就可以取得地图中不同的对象的来初始化你在游戏中的对象，这样，你就只需要编辑对应的tmx文件就可以创造不同的地图关卡了。


关于TMXTiledMap类的其他函数，这里先不介绍了，我也用的比较少。对gamelayer的操作，可以自己斟酌，比如移动的时候不要把后面的背景露出来，就需要计算整个tiledmap的大小来决定是否继续移动，这些都很简单。