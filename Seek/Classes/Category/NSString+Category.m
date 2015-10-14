//
//  NSString+Category.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "NSString+Category.h"

#import <CommonCrypto/CommonDigest.h>
@implementation NSString (Category)



/**
 *  字符串判空(空字符串)
 *
 *  @return YES/NO
 */
- (BOOL)isEmpty
{
    if (self == nil)
    {
        return YES;
    }
    
    if (self == NULL)
    {
        return YES;
    }
    
    if ([self isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        return YES;
    }
    
    return NO;
}

/**
 *  获取MD5字符串
 *
 *  @return MD5字符串
 */
- (NSString *)md5Value
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result);
    
    NSString *md5Value = [NSString stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
                          ];
    return md5Value;
}

/**
 *  计算字符串尺寸的方法
 */
+ (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    if (font) {
        attr[NSFontAttributeName] = font;
    }
    CGSize stringSize = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    return stringSize;
}


@end
