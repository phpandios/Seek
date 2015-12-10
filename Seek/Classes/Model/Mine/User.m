//
//  User.m
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "User.h"

@implementation User

+ (id)shareUserInfo
{
    static User *userInfo = nil;
    static dispatch_once_t  predicate;
    dispatch_once(&predicate,^{
        userInfo = [[self alloc] init];
    });
    return userInfo;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    SBLog(@"ERROR KEY:%@", key);
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues
{
    [super setValuesForKeysWithDictionary:keyedValues];
    if ([keyedValues.allKeys containsObject:@"id"]) {
        [super setValue:keyedValues[@"id"] forKey:@"Id"];
    }
}

@end
