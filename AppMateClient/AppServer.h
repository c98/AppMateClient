//
//  AppServer.h
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppServerObserver <NSObject>

// 当从服务端拿到消息时，会调用这个方法把拿到的内容传过去
- (void)onReceiveMessage:(NSDictionary *)message;

@end


@interface AppServer : NSObject

// 连接 websocket 服务器
+ (void)startWithHost:(NSURL *)host;

// 停止发送
+ (void)stop;

// 发送消息
+ (void)publishTopic:(NSString *)topic withMessage:(NSString *)message parameters:(NSDictionary *)parameters;

// 注册 topic 的 observer
+ (void)registerObserver:(id<AppServerObserver>)observer forTopic:(NSString *)topic;

// 把 observer 从观察者列表中移除
+ (void)unregisterObserver:(id<AppServerObserver>)observer;

@end
