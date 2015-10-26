//
//  RCDSelectPersonTableViewCell.m
//  Seek
//
//  Created by 吴非凡 on 15/10/26.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "RCDSelectPersonTableViewCell.h"

@implementation RCDSelectPersonTableViewCell


-(void)awakeFromNib
{
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 8.f;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _ivSelected.image = [UIImage imageNamed:@"select"];
    }else{
        _ivSelected.image = [UIImage imageNamed:@"unselect"];
    }
}
@end
