//
//  AppDelegate.h
//  Seek
//
//  Created by 吴非凡 on 15/10/4.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


// 弹出登陆窗口
// 登陆窗口关闭时调用
+ (void)presentLoginVCWithDismisBlock:(void (^)())dismisBlock;

@end

