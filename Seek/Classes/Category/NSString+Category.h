//
//  NSString+Category.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)


/**
 *  字符串判空(空字符串)
 *
 *  @return YES/NO
 */
- (BOOL)isEmpty;


/**
 *  获取MD5字符串
 *
 *  @return MD5字符串
 */
- (NSString *)md5Value;


/**
 *  计算字符串尺寸的方法
 */
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize;
@end
