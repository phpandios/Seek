//
//  SearchInputTipTableView.m
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "SearchInputTipTableView.h"

@implementation SearchInputTipTableView


- (CGSize)intrinsicContentSize
{
//    CGFloat height = self.rowHeight * [self numberOfRowsInSection:0];
    CGFloat height = self.contentSize.height;
//    NSLog(@"%.2f -- %.2f", height, height1);
    return CGSizeMake(UIViewNoIntrinsicMetric, height > 200 ? 200 : height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
