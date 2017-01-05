//
//  HeartBeat.m
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import "HeartBeat.h"

@implementation HeartBeat

- (void)onReceiveMessage:(NSDictionary *)message
{
	[AppServer publishTopic:@"HeartBeat.ACK" withMessage:nil parameters:nil];
}

@end
