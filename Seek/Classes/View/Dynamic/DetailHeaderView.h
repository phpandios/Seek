//
//  DetailHeaderView.h
//  Seek
//
//  Created by apple on 15/11/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_portrait;//头像
@property (weak, nonatomic) IBOutlet UILabel *name;//会员名称
@property (weak, nonatomic) IBOutlet UILabel *insert_time;//发布时间
@property (weak, nonatomic) IBOutlet UILabel *publish_content;//发布内容


@end
