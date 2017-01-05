//
//  JSHofix.m
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import "JSHofix.h"
#import "JPEngine.h"

@implementation JSHofix

- (void)onReceiveMessage:(NSDictionary *)message
{
	NSDictionary *payload = message[@"payload"];
	if (payload[@"content"]) {
		[AppServer publishTopic:@"Hotfix.Exec.ACK" withMessage:nil parameters:nil];
		[JPEngine evaluateScript:payload[@"content"]];
	}
}

@end
