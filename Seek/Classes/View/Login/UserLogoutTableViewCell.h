//
//  UserLogoutTableViewCell.h
//  Seek
//
//  Created by 吴非凡 on 15/10/11.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserLogoutTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^buttonClickBlock)();

@end