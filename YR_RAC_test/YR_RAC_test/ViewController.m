//
//  ViewController.m
//  YR_RAC_test
//
//  Created by YongRen on 16/2/25.
//  Copyright © 2016年 YongRen. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (assign, nonatomic) BOOL isStatusHidden;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self test001];
    
    [self test002];
    
}

- (IBAction)logInBtnClick:(id)sender {
    
}

- (void) test002 {
    
    // map 去的只能说对象，所以bool要包装成NSNumber
    RACSignal *validUserNameSG = [self.userNameTF.rac_textSignal map:^id(NSString *text) {
        return @([self isValidUserName: text]);
    }];
    RACSignal *validPasswordSG = [self.passwordTF.rac_textSignal map:^id(NSString *text) {
        return @([self isValidxPassword: text]);
    }];
    
    // 将validUserNameSG信号输出应用到输入框的backgroundColor上
    [[validUserNameSG map:^id(NSNumber *userNameValid) {
        return [userNameValid boolValue]? [UIColor clearColor] : [UIColor yellowColor];
    }] subscribeNext:^(UIColor *color) {
        self.userNameTF.backgroundColor = color;
    }];
    // 更优雅的写法，利用RAC宏 - 直接把信号对应输出到对象的属性上
        RAC(self.passwordTF, backgroundColor) =
        [validPasswordSG map:^id(NSNumber *passwordValid) {
            return [passwordValid boolValue]? [UIColor clearColor] : [UIColor yellowColor];
        }];
}

- (void) test001 {
    // signal流给订阅者－subscriber
    [self.userNameTF.rac_textSignal subscribeNext:^(NSString *text) {
        NSLog(@"  --userName Input:  %@", text);
    }];
    
    // signal流过滤，会产生过滤后的signal－filter
    [[self.passwordTF.rac_textSignal filter:^BOOL(NSString *text) {
        return text.length > 6;
    }] subscribeNext:^(NSString *text) {
        NSLog(@"  --password Input:  %@", text);
    }];
    
    // 对源signal流的更改，产生对不同值变化的新signal － map － signal的内容为对象
    // －－－NSString－－－［map］－－－> NSNumber（NSUInteger封装成对象）－－－
    [[[self.passwordTF.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }] filter:^BOOL(NSNumber *length) {
        return [length integerValue] > 4;
    }] subscribeNext:^(NSNumber *length) {
        NSLog(@" - 当前PWD长度： %@", length);
    }];
    
}

/**
 *  用户名 > 3
 *  密码 > 4
 */
- (BOOL) isValidUserName:(NSString *)text {
    return text.length > 3;
}
- (BOOL) isValidxPassword:(NSString *)text {
    return text.length > 4;
}
@end
