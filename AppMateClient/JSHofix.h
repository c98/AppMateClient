//
//  JSHofix.h
//  AppMateClient
//
//  Created by 止水 on 1/5/17.
//  Copyright © 2017 mogujie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppServer.h"

/**
 @brief	JS Patch 下发
 @discussion	得益于 JSPatch，现在 AppMateClient 基本上可以实现任何动态需求而无需客户端做额外编码工作
		e.g. 
		* 在网页端直接查看 App Sandbox
		* 页面 URL 跳转
		* 当然还有实时 Hotfix
 */
@interface JSHofix : NSObject <AppServerObserver>

@end
