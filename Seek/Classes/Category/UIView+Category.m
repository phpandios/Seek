//
//  UIView+Category.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (void)setBackgroundColorFromHexColor:(NSString *)backgroundColorFromHexColor
{
    self.backgroundColor = kHexColor(backgroundColorFromHexColor);
}

- (NSString *)backgroundColorFromHexColor
{
    return nil;
}
@end
