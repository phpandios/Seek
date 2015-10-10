//
//  Common.h
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject


@property (nonatomic, strong, readonly) User *loginUser;

kSingleTon_H(Common)


#pragma mark - 登陆
- (void)loginWithUser:(User *)user;

#pragma mark - 注销
- (void)logout;

@end
