//
//  UserHeaderTableViewCell.m
//  Seek
//
//  Created by 吴非凡 on 15/10/11.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UserHeaderTableViewCell.h"

@implementation UserHeaderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.headerImageView.layer.cornerRadius = self.headerImageView.bounds.size.width / 2;
//    self.headerImageView.layer.borderWidth = 1;
//    self.headerImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}
@end
