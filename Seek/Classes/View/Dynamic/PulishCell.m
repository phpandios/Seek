//
//  PulishCell.m
//  Seek
//
//  Created by apple on 15/10/7.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "PulishCell.h"

@implementation PulishCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    if ([[User shareUserInfo] backColor] != nil) {
        self.backgroundColor = [[User shareUserInfo] backColor];
    }
}

@end
