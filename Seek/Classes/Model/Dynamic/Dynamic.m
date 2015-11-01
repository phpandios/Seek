//
//  Dynamic.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "Dynamic.h"
#import <objc/runtime.h>
@implementation Dynamic

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"comment_num"]) {
        self.commentNum = [value integerValue];
    }
    if ([key isEqualToString:@"insert_time"]) {
        self.timestamp = value;
    }
    if ([key isEqualToString:@"contents"]) {
        self.content = value;
    }
}
#pragma mark -防止数据为空
- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!obj || [obj isKindOfClass:[NSNull class]]) {
            
        } else {
            [self setValue:obj forKey:key];
        }
    }];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned int count;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            //
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}
@end
