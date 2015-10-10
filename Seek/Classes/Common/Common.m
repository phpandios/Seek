//
//  Common.m
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "Common.h"

@interface Common ()

@property (nonatomic, strong) User *loginUser;

@end

@implementation Common

kSingleTon_M(Common)

#pragma mark - 登陆
- (void)loginWithUser:(User *)user
{
    self.loginUser = user;
}

#pragma mark - 注销
- (void)logout
{
    self.loginUser = nil;
}
@end
