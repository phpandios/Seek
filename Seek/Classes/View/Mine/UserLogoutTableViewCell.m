//
//  UserLogoutTableViewCell.m
//  Seek
//
//  Created by 吴非凡 on 15/10/11.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UserLogoutTableViewCell.h"

@implementation UserLogoutTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)buttonAction:(UIButton *)sender {
    if (self.buttonClickBlock) {
        self.buttonClickBlock();
    }
}


@end
