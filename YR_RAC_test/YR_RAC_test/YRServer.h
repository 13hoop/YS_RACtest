//
//  YRServer.h
//  YR_RAC_test
//
//  Created by YongRen on 16/2/27.
//  Copyright © 2016年 YongRen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  模拟服务器的验证和网络过程
 */

@interface YRServer : NSObject

- (void)logInWithUsername:(NSString *)username password:(NSString *)password finishedCallBack: (void (^) (BOOL isSuccess))finishedCallBack;
@end
