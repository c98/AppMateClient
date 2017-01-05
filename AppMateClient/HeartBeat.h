//
//  HeartBeat.h
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppServer.h"

/**
 @brief	心跳反馈
 @discussion	虽然 websocket 可以通过 ping/pong 来处理心跳，但实际上各种公开的实现都无法满足复杂场景下的需求，这里配合服务端单独实现了一套。
 */
@interface HeartBeat : NSObject <AppServerObserver>

@end
