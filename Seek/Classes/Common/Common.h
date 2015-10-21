//
//  Common.h
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <RongIMKit/RongIMKit.h>
#define kCurrentUser ([[Common shareCommon] loginUser])
#define kCurrentToken ([[Common shareCommon] token])
@interface Common : NSObject

// 对于外界 将loginUser属性改成只读
@property (nonatomic, strong, readonly) User *loginUser;

@property (nonatomic, copy, readonly) NSString *token;

@property (nonatomic, strong) NSMutableArray *friendArray;
kSingleTon_H(Common)

#pragma mark - 手机登陆
- (void)loginWithTelPhone:(NSString *)telPhone password:(NSString *)password completionHandle:(void(^)(BOOL isSuccess))completionHandle;
#pragma mark - qq登陆
- (void)loginWithQQID:(NSString *)qqid nick_name:(NSString *)nick_name head_portrait:(NSString *)head_portrait completionHandle:(void(^)(BOOL isSuccess))completionHandle;
#pragma mark - 注销
- (void)logout;

#pragma mark - 注册
- (void)regWithTelPhone:(NSString *)telPhone password:(NSString *)password completionHandle:(void(^)(BOOL isSuccess))completionHandle;

#pragma mark - 获取token
- (void)getTokenWithUser:(User *)user completionHandle:(void (^)(BOOL isSucess))completionHandle;

//#pragma mark - 添加好友
//- (void)sendFriendRequestWithUserId:(NSInteger)userId message:(NSString *)message completionHandle:(void (^)(BOOL isSuccess))completionHandle;
//
//#pragma mark - 获取好友列表
//- (void)getFriendListCompletionHandle:(void (^)(NSArray *friendArray))completionHandle;
@end
