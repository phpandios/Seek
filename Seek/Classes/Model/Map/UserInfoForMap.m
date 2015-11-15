//
//  UserInfoForMap.m
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UserInfoForMap.h"
#import <objc/runtime.h>
@implementation UserInfoForMap
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
  if([key isEqualToString:@"id"])
  {
      self.userID = value;
  }
    if ([key isEqualToString:@"head_portrait"]) {
        self.imageUrl = value;
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
