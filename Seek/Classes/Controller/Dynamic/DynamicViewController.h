//
//  DynamicViewController.h
//  Seek
//
//  Created by apple on 15/12/1.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicViewController : UIViewController

// 如果是当前用户的动态,第一行显示的发布
@property (nonatomic, assign) NSInteger userId;
@end
