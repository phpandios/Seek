//
//  CALayer+BorderColorFromUIColor.m
//  MultimediaInteractive
//
//  Created by 吴非凡 on 15/9/17.
//  Copyright (c) 2015年 东方佳联. All rights reserved.
//

#import "CALayer+BorderColorFromUIColor.h"

@implementation CALayer (BorderColorFromUIColor)


- (UIColor *)borderColorFromUIColor
{
    return nil;
}

- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor
{
    self.borderColor = borderColorFromUIColor.CGColor;
}

- (NSString *)borderColorFromRGBString
{
    return nil;
}

- (void)setBorderColorFromRGBString:(NSString *)borderColorFromRGBString
{
    CGFloat red = [[borderColorFromRGBString componentsSeparatedByString:@","][0] floatValue] / 255.0f;
    CGFloat green = [[borderColorFromRGBString componentsSeparatedByString:@","][1] floatValue] / 255.0f;
    CGFloat blue = [[borderColorFromRGBString componentsSeparatedByString:@","][2] floatValue] / 255.0f;
    self.borderColor = [UIColor colorWithRed:red green:green blue:blue alpha:1].CGColor;
}

- (NSString *)borderColorFromHexColor
{
    return nil;
}

- (void)setBorderColorFromHexColor:(NSString *)borderColorFromHexColor
{
    self.borderColor = kHexColor(borderColorFromHexColor).CGColor;
}
@end
