//
//  OnePhotoCell.m
//  Seek
//
//  Created by apple on 15/10/6.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "NoPhotoCell.h"
#import "Dynamic.h"
@implementation NoPhotoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDynamicObj:(Dynamic *)dynamicObj
{
    _dynamicObj = dynamicObj;
    if ([[User shareUserInfo] backColor] != nil) {
        self.backgroundColor = [[User shareUserInfo] backColor];
    }
    
    if([[User shareUserInfo] textColor] != nil)
    {
        self.name.textColor = [[User shareUserInfo] textColor];
        self.insert_time.textColor = [[User shareUserInfo] textColor];
        self.publish_content.textColor = [[User shareUserInfo] textColor];
        self.comments_nums.textColor = [[User shareUserInfo] textColor];
    }
    
    [self.head_portrait sd_setImageWithURL:[NSURL URLWithString:dynamicObj.head_portrait] placeholderImage:nil];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.name.text = dynamicObj.nick_name;
    self.insert_time.text = dynamicObj.timestamp;
    self.publish_content.text =dynamicObj.content;
    self.comments_nums.text = [NSString stringWithFormat:@"%ld评论", dynamicObj.commentNum];
    if (dynamicObj.is_friend == 1) {
        [self.attention removeFromSuperview];
    }
}
@end
