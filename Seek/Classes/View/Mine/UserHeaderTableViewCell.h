//
//  UserHeaderTableViewCell.h
//  Seek
//
//  Created by 吴非凡 on 15/10/11.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (nonatomic, copy) void (^headerViewClickBlock)();
@end
