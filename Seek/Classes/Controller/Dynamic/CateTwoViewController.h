//
//  CateTwoViewController.h
//  Seek
//
//  Created by apple on 15/11/25.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CateTwoViewController : UIViewController
@property (nonatomic, assign) NSInteger parent_id;
@property (nonatomic, copy) void (^cateTwoCurrent)(NSString *currentName, NSInteger ID);
@end
