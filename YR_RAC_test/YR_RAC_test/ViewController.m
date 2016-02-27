//
//  ViewController.m
//  YR_RAC_test
//
//  Created by YongRen on 16/2/25.
//  Copyright © 2016年 YongRen. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YRServer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIButton *LogIn;
//@property (copy, nonatomic) void (^finishedCallBack)(BOOL);

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // signal创建和subscriber
//    [self test001];
    
    
    // signal 过滤（filter），转化（Map） 和聚合（combineLatest）以及 RAC宏
//    [self test002];
    
    
    // rac_signalForControlEvents
//    [self test003];
    
    
    // createSignal ＋ signal of singnal［flatten／merge］信号复合成流 及其 处理
//    [self test004];
    // 4的进化版 － flattenMap处理flatten signal
//    [self test004_1];
    
    
    //  附作用 side-effect - "doNext:"
    [self test005];
}


// 附加操作： 在登录点击之后，callBack之前，按钮不可点击
- (void) test005 {
    [self test002];
    
    // 1 创建登录操作sigal － createSignal and RACDisposable
    YRServer *server = [[YRServer alloc] init];
    RACSignal *logInAndCallBackSG = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [server logInWithUsername:self.userNameTF.text password:self.passwordTF.text finishedCallBack:^(BOOL isSuccess) {
            [subscriber sendNext:@(isSuccess)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    // 2 登录操作 - 将按钮的登录操作事件 map为 登录操作信号
    // 复合信号成流［steam］
    [[[[self.LogIn rac_signalForControlEvents:UIControlEventTouchUpInside]doNext:^(id x) {
        self.LogIn.enabled = NO;
    }] flattenMap:^RACStream *(id value) {
        return logInAndCallBackSG;
    }] subscribeNext:^(id x) {
        self.LogIn.enabled = YES;
        NSLog(@"inner signal - 是否登录成功了？： %@", x);
    }];
}

// luckly,signal of signals 是如此的普遍，所以RAC给我提供一一个新方法：flattenMap
- (void) test004_1 {
    [self test002];
    
    // 1 创建登录操作sigal － createSignal and RACDisposable
    YRServer *server = [[YRServer alloc] init];
    RACSignal *logInAndCallBackSG = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [server logInWithUsername:self.userNameTF.text password:self.passwordTF.text finishedCallBack:^(BOOL isSuccess) {
            [subscriber sendNext:@(isSuccess)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    // 2 登录操作 - 将按钮的登录操作事件 map为 登录操作信号
    // 复合信号成流［steam］
    [[[self.LogIn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^RACStream *(id value) {
        return logInAndCallBackSG;
    }] subscribeNext:^(id x) {
        NSLog(@"inner signal - 是否登录成功了？： %@", x);
    }];
    
}

- (void) test004 {
    [self test002];
    
    // 现在，尝试有异步回调下会有以下情形：登录成功，登录失败，其他错误
    // 1 创建登录操作sigal － createSignal and RACDisposable
    YRServer *server = [[YRServer alloc] init];
    RACSignal *logInAndCallBackSG = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [server logInWithUsername:self.userNameTF.text password:self.passwordTF.text finishedCallBack:^(BOOL isSuccess) {
            [subscriber sendNext:@(isSuccess)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    
    // 2 登录操作 - 将按钮的登录操作事件 map为 登录操作信号
    // 同时 “整流／合并信号” －Flattens/merge a stream of streams
    [[[self.LogIn rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return logInAndCallBackSG; // 并不是普通转化，而是创建了又一个sigal，称之为［signal of signals］
    }] subscribeNext:^(id x) {
        
        // 这里需要注意：
        // rac_signalForControlEvents 会将button本身 流给（next） subscribe
        // 而map中，又create一个新的signal－logInAndCallBackSG
        // 所以实际上在这里，得到了一个信号的信号，我称之为复合的signal
        NSLog(@"得到一个信号的信号signal of signals，这里仅仅只能查看outer signal： %@", x);
        
        // inner signal还需要自己的 subscribe
        [x subscribeNext:^(id x) {
            
            NSLog(@"inner signal - 是否登录成功了？： %@", x);
        }];
    }];
}


// test002中，已经将用户名和密码signal聚合并绑定到LogInBtn的enable中了
// 但是还不够完全，事实上在响应式编程中原则尽量做到所有的一切都是signal，
// 意味着，btn的touch事件也会被signal化  －  rac_signalForControlEvents
- (void) test003 {
    RACSignal *logInBtnClickedSG = [self.LogIn rac_signalForControlEvents:UIControlEventTouchUpInside];
    [logInBtnClickedSG subscribeNext:^(id x) {
        NSLog(@" - logInBtn been clicked! -");
    }];
}

// 而IBAction和AddTargat不再起作用
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
    
    
    // signal聚合 - combineLast: 可以聚合任意数量的信号 - userNameSG 和 passwordSG 聚合
    RACSignal *logInActionSG = [RACSignal combineLatest:@[validUserNameSG, validPasswordSG] reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid){
        return @([usernameValid boolValue] && [passwordValid boolValue]);
    }];
    // 聚合的signal － 按钮enable属性
    [logInActionSG subscribeNext:^(NSNumber *logInActive) {
        self.LogIn.enabled = [logInActive boolValue];
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
