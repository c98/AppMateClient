//
//  AppServer.m
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import "AppServer.h"
#import "SocketRocket.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>


static inline NSString * getSessionID() {
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	NSString *finalAppVersion = [NSString stringWithFormat:@"%@.%@", appVersion, buildVersion];
	return [NSString stringWithFormat:@"%@:%@:%@",
			[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString],
			[[NSBundle mainBundle] bundleIdentifier],
			finalAppVersion];
}


@interface AppServer () <SRWebSocketDelegate>
{
	SRWebSocket *_socket;
}

@property (nonatomic) SRWebSocket *socket;
@property (nonatomic) NSMutableDictionary *topicTable;
@property (nonatomic, strong) NSMutableArray *queuedMessages;

@end

@implementation AppServer

+ (instancetype)sharedInstance
{
	static AppServer *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[AppServer alloc] init];
	});
	return instance;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.topicTable = [NSMutableDictionary dictionary];
		self.queuedMessages = [NSMutableArray array];
	}
	return self;
}

+ (void)sendMessage:(NSString *)message
{
	if ([AppServer sharedInstance].socket.readyState != SR_OPEN) {
		if ([AppServer sharedInstance].socket.readyState == SR_CONNECTING) {
			[[AppServer sharedInstance].queuedMessages addObject:message];
		}
	} else {
		[[AppServer sharedInstance].socket send:message];
	}
}

+ (void)startWithHost:(NSURL *)host
{
	if (!host)
		return;

	[[AppServer sharedInstance].socket close];
	
	[AppServer sharedInstance].socket = [[SRWebSocket alloc] initWithURL:host];
	[AppServer sharedInstance].socket.delegate = [AppServer sharedInstance];
	[[AppServer sharedInstance].socket open];
}

// 停止发送
+ (void)stop
{
	[[AppServer sharedInstance].socket close];
}

+ (void)publishTopic:(NSString *)topic withMessage:(NSString *)message parameters:(NSDictionary *)parameters
{
	if (!topic) {
		return;
	}
	NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithDictionary:@{
		@"topic": topic,
		@"session_id":getSessionID(),
		@"payload":@{}
	}];
	if (parameters) {
		msg[@"payload"] = [NSMutableDictionary dictionaryWithDictionary: parameters];
	}
	if (message) {
		msg[@"payload"][@"message"] = message;
	}
	
	NSData *messageData = [NSJSONSerialization dataWithJSONObject:@{@"publish":msg} options:0 error:nil];
	if (messageData) {
		NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
		[self sendMessage:messageString];
	}
}

+ (void)registerObserver:(id<AppServerObserver>)observer forTopic:(NSString *)topic
{
	if (!observer || !topic)
		return;
	
	NSMutableArray *observers = [AppServer sharedInstance].topicTable[topic];
	if (!observers) {
		[AppServer sharedInstance].topicTable[topic] = [NSMutableArray arrayWithObject:observer];
	} else {
		if ([observers indexOfObject:observer] == NSNotFound) {
			[observers addObject:observer];
		}
	}
	
	
	NSData *messageData = [NSJSONSerialization dataWithJSONObject:@{
																	@"subscribe": @{
																			@"topic": topic,
																			@"session_id": getSessionID(),
																			@"payload": @{}
																			}
																	}
														  options:0
															error:nil];
	if (messageData) {
		NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
		[self sendMessage:messageString];
	}
}

// 把 observer 从观察者列表中移除
+ (void)unregisterObserver:(id<AppServerObserver>)observer
{
	if (!observer)
		return;
	
	for (NSMutableArray *observersList in [AppServer sharedInstance].topicTable.allValues) {
		for (NSMutableArray *observers in observersList) {
			[observers removeObject:observer];
		}
	}
}

#pragma mark - Delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
	NSDictionary *messageObject = message;
	NSError *error;
	if ([message isKindOfClass:[NSString class]]) {
		NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
		messageObject = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:&error];
	}
	if (!messageObject) {
		return;
	}
	
	[self.topicTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull pattern, NSMutableSet * _Nonnull observers, BOOL * _Nonnull stop) {
		NSString *topic = messageObject[@"publish"][@"topic"];
		
		[observers enumerateObjectsUsingBlock:^(id <AppServerObserver> observer, BOOL * _Nonnull stop) {
			NSPredicate *pred = [NSPredicate predicateWithFormat:@"self LIKE %@", pattern];
			BOOL match = [pred evaluateWithObject:topic];
			if (match) {
				[observer onReceiveMessage:messageObject[@"publish"]];
			}
		}];
	}];

}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
	NSDictionary *message = @{
							  @"publish": @{
									  @"topic": @"App.Start.Log",
									  @"session_id": getSessionID(),
									  @"payload": @{
											  @"platform": @"iOS",
											  @"osVersion": [[UIDevice currentDevice] systemVersion],
											  @"deviceName": [[UIDevice currentDevice] name]
											  }
									  }
							  };
	NSData *messageData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
	if (messageData) {
		NSString *messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
		[self.class sendMessage:messageString];
	}
	
	// 发送积累的数据
	[self.queuedMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[self.class sendMessage:obj];
	}];
	
	[self.queuedMessages removeAllObjects];

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
	
}

@end
