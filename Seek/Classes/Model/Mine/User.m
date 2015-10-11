//
//  User.m
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "User.h"

@implementation User

// 默认性别男
- (instancetype)init
{
    if (self = [super init]) {
        self.gender = @"男";
    }
    return self;
}

@end
