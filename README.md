# AppMateClient
AppMate iOS client.

这是一个简单的 [AppMate](http://s17.mogucdn.com/new1/v1/fxihe/d0da31c875767324becb9e575f68fd34/A1c0b9eca4d2000802.appmate.png) iOS 客户端，功能仅用于测试 AppMate 整个链路。

**See Also**

* [AppMateServer](https://github.com/c98/AppMateServer)
* [AppMateBrowser](https://github.com/c98/AppMateBrowser)

## 环境依赖
* iOS 7.0+
* Xcode 7+

## 编译运行
工程是基于 Cocoapods 来管理依赖的，比较简单，有两个三方组件：
```shell
pod 'SocketRocket'   # iOS Websocket
pod 'JSPatch/JPCFunction'   # iOS Hotfix 赋予 App 动态化能力 (Sandbox 会用到)
```
接下来 `pod update` 之后就可以开始跑起来了。注意此时服务端需要先 run 起来。

## 文件组织

* `AppServer`: 用于处理服务端连接、断开、消息发送、消息监听、模块的主题订阅这些功能
* `HeartBeat`: 处理服务端发来的心跳同步消息
* `JSHotfix`: 执行服务端下发的 hotfix 消息
