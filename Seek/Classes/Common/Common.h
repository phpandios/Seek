//
//  Common.h
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCurrentUser ([[Common shareCommon] loginUser])

@interface Common : NSObject

// 对于外界 将loginUser属性改成只读
@property (nonatomic, strong, readonly) User *loginUser;

kSingleTon_H(Common)


#pragma mark - 登陆
- (void)loginWithUser:(User *)user;

#pragma mark - 注销
- (void)logout;

@end
