//
//  PermissionsViewController.h
//  Seek
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PermissionsViewController : UIViewController
@property (nonatomic, copy) void (^currentPermission)(int currentNum, NSString *currentName, NSString *currentDescrip);
@end
