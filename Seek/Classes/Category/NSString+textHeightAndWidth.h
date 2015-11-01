//
//  NSString+textHeightAndWidth.h
//  Seek
//
//  Created by apple on 15/11/1.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (textHeightAndWidth)
//计算文本的高度
+ (CGFloat)calcWithTextHeightStr:(NSString *)str
                           width:(CGFloat)width
                            font:(UIFont *)font;
//计算文本的宽度
+ (CGFloat)calcWithTextWidthStr:(NSString *)str
                         height:(CGFloat)height
                           font:(UIFont *)font;
@end
