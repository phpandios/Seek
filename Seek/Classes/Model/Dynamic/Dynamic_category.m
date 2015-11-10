//
//  Dynamic_category.m
//  Seek
//
//  Created by apple on 15/11/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "Dynamic_category.h"

@implementation Dynamic_category

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.ID = [value integerValue];
    }
}
@end
