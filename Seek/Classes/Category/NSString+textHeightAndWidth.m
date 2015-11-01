//
//  NSString+textHeightAndWidth.m
//  Seek
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "NSString+textHeightAndWidth.h"

@implementation NSString (textHeightAndWidth)
#pragma mark计算文字高度
//计算文本的高度
+ (CGFloat)calcWithTextHeightStr:(NSString *)str
                           width:(CGFloat)width
                            font:(UIFont *)font
{
    CGSize size = CGSizeMake(width, MAXFLOAT);
    NSDictionary *dict = @{
                           NSFontAttributeName :font
                           };
    /*
     1.在这个大小范围内进行计算
     2.计算高度需要的枚举值
     3.字典，包含文字的字体大小
     4.上下文对象，此处设置为空
     */
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.height;
}
//计算文本的宽度
+ (CGFloat)calcWithTextWidthStr:(NSString *)str
                         height:(CGFloat)height
                           font:(UIFont *)font
{
    CGSize size = CGSizeMake(MAXFLOAT, height);
    NSDictionary *dict = @{
                           NSFontAttributeName :font
                           };
    /*
     1.在这个大小范围内进行计算
     2.计算高度需要的枚举值
     3.字典，包含文字的字体大小
     4.上下文对象，此处设置为空
     */
    CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return rect.size.width;
}
@end
