//
//  UIViewController+PresentAlertController.h
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 东方佳联. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PresentAlertController)

#pragma mark - 弹出提示窗(当有textField时,再okhandle中返回. 当cancelhandle为空时,不显示取消按钮)
- (void)showAlertControllerWithTitle:(NSString *)title hasTextField:(BOOL)hasTextField okHandle:(void(^)(NSString *returnText))okHandle cancelHandle:(void (^)())cancelHandle;

- (void)showAlertControllerWithTitle:(NSString *)title;
@end
