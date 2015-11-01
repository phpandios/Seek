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
    [self.head_portrait sd_setImageWithURL:[NSURL URLWithString:dynamicObj.head_portrait] placeholderImage:nil];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.name.text = dynamicObj.nick_name;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSString *nowtimeStr = [formatter stringFromDate:dynamicObj.timestamp];
    self.insert_time.text = nowtimeStr;
    self.publish_content.text =dynamicObj.content;
    self.comments_nums.text = [NSString stringWithFormat:@"%ld评论", dynamicObj.commentNum];
}
@end
