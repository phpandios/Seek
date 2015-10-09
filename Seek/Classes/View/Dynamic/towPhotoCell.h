//
//  towPhotoCell.h
//  Seek
//
//  Created by apple on 15/10/7.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface towPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_portrait;//头像
@property (weak, nonatomic) IBOutlet UILabel *name;//会员名称
@property (weak, nonatomic) IBOutlet UILabel *insert_time;//发布时间
@property (weak, nonatomic) IBOutlet UIButton *attention;//关注状态
@property (weak, nonatomic) IBOutlet UIImageView *onePhoto;//第一张照片
@property (weak, nonatomic) IBOutlet UIImageView *twoPhoto;//第二张照片
@property (weak, nonatomic) IBOutlet UILabel *publish_content;//发布内容
@property (weak, nonatomic) IBOutlet UILabel *comments_nums;//评论数量
@property (weak, nonatomic) IBOutlet UIButton *comments_btn;//评论按钮
@property (weak, nonatomic) IBOutlet UIButton *share_btn;//分享按钮
@end