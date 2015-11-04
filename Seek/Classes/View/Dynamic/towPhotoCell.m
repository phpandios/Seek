//
//  towPhotoCell.m
//  Seek
//
//  Created by apple on 15/10/7.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "towPhotoCell.h"
#import "Dynamic.h"
@implementation towPhotoCell

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
    [self.head_portrait sd_setImageWithURL:[NSURL URLWithString:dynamicObj.head_portrait] placeholderImage:nil];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.name.text = dynamicObj.nick_name;
    self.insert_time.text = dynamicObj.timestamp;
    
    self.publish_content.text =dynamicObj.content;
    NSArray *arr = [_dynamicObj.images componentsSeparatedByString:@"#@#"];
    self.onePhoto.contentMode = UIViewContentModeScaleAspectFit;
    self.twoPhoto.contentMode = UIViewContentModeScaleAspectFit;
    [self.onePhoto sd_setImageWithURL:[NSURL URLWithString:arr[0]] placeholderImage:nil];
    [self.twoPhoto sd_setImageWithURL:[NSURL URLWithString:arr[1]] placeholderImage:nil];
    self.comments_nums.text = [NSString stringWithFormat:@"%ld评论", dynamicObj.commentNum];
    if (dynamicObj.is_friend == 1 || [[[RCDLoginInfo shareLoginInfo] valueForKey:@"id"] intValue] == dynamicObj.userId) {
        [self.attention removeFromSuperview];
    }
}
@end
