//
//  YRServer.m
//  YR_RAC_test
//
//  Created by YongRen on 16/2/27.
//  Copyright © 2016年 YongRen. All rights reserved.
//

#import "YRServer.h"

@implementation YRServer

- (void)logInWithUsername:(NSString *)username password:(NSString *)password finishedCallBack: (void (^) (BOOL isSuccess))finishedCallBack {
    
    // 模拟网络延迟2s
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [username isEqualToString:@"KOBE"] && [password isEqualToString:@"mamaba"];
        finishedCallBack(success);
    });
}

@end
