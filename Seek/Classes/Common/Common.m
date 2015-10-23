//
//  Common.m
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"
@interface Common ()

@property (nonatomic, strong) User *loginUser;

@property (nonatomic, copy) NSString *token;

@end

@implementation Common

kSingleTon_M(Common)

#pragma mark - 登陆

#pragma mark - 登陆
- (void)loginWithTelPhone:(NSString *)telPhone password:(NSString *)password completionHandle:(void(^)(BOOL isSuccess))completionHandle
{
    
    __weak typeof(self) weakSelf = self;
    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kLoginUrlString paramString:kParamForLogin(telPhone, password, @"", @"", kRegOrLoginTypeByTel) completionHandle:^(NSData *data) {
        if (!data) {
            SHOWERROR(@"网络故障,请检查后重试!");
            if (completionHandle) {
                completionHandle(NO);
            }
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (dict[@"code"]) {
            NSInteger code = [dict[@"code"] integerValue];
            if (code == 200) {
                NSDictionary *result = dict[@"result"];
                User *user = [User new];
                [user setValuesForKeysWithDictionary:result];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf loginWithUser:user];
                });
                
                if (completionHandle) {
                    completionHandle(YES);
                }
            } else {
                if (dict[@"message"] && [dict[@"message"] length] > 0) {
                    NSString *message = dict[@"message"];
                    SHOWERROR(@"%@", message);
                } else {
                    SHOWERROR(@"登录失败,未知错误!");
                }
                if (completionHandle) {
                    completionHandle(NO);
                }
            }
        } else {
            SHOWERROR(@"登录失败");
            if (completionHandle) {
                completionHandle(NO);
            }
        }

    }];
}


#pragma mark - qq登陆
- (void)loginWithQQID:(NSString *)qqid nick_name:(NSString *)nick_name head_portrait:(NSString *)head_portrait completionHandle:(void(^)(BOOL isSuccess))completionHandle
{
    __weak typeof(self) weakSelf = self;
    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kLoginUrlString paramString:kParamForLogin(@"", @"", @"", qqid, kRegOrLoginTypeByQQ) completionHandle:^(NSData *data) {
        if (!data) {
            SHOWERROR(@"网络故障,请检查后重试!");
            if (completionHandle) {
                completionHandle(NO);
            }
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict[@"code"] && [dict[@"code"] integerValue] == 200) {
            NSDictionary *result = dict[@"result"];
            User *user = [User new];
            [user setValuesForKeysWithDictionary:result];
            if ([user.nick_name isEmpty]) {
                user.nick_name = nick_name;
            }
            if ([user.head_portrait isEmpty]) {
                user.head_portrait = head_portrait;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf loginWithUser:user];
            });
            if (completionHandle) {
                completionHandle(YES);
            }
        } else {
            SHOWERROR(@"用户名密码错误,请重新输入!");
            if (completionHandle) {
                completionHandle(NO);
            }
        }
    }];
}

#pragma mark - 注册
- (void)regWithTelPhone:(NSString *)telPhone password:(NSString *)password completionHandle:(void(^)(BOOL isSuccess))completionHandle
{
    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kRegUrlString paramString:kParamForReg(telPhone, password, @"", @"", 0.0f, 0.0f, @"", 1, kRegOrLoginTypeByTel) completionHandle:^(NSData *data) {
        if (!data) {
            SHOWERROR(@"网络故障,请检查后重试!");
            if (completionHandle) {
                completionHandle(NO);
            }
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict[@"code"]) {
            NSInteger code = [dict[@"code"] integerValue];
            if (code == 200) {
                if (completionHandle) {
                    completionHandle(YES);
                }
            } else {
                if (dict[@"message"] && [dict[@"message"] length] > 0) {
                    NSString *message = dict[@"message"];
                    SHOWERROR(@"%@", message);
                } else {
                    SHOWERROR(@"注册失败,未知错误!");
                }
                if (completionHandle) {
                    completionHandle(NO);
                }
            }
        } else {
            SHOWERROR(@"注册失败");
            if (completionHandle) {
                completionHandle(NO);
            }
        }
    }];
}

#pragma mark 登陆
- (void)loginWithUser:(User *)user
{
    self.loginUser = user;
    if (![KVNProgress isVisible]) {
        [KVNProgress show];
    }
    [[Common shareCommon] getTokenWithUser:kCurrentUser completionHandle:^(BOOL isSucess) {
        if (isSucess) {
            NSLog(@"%@", kCurrentToken);
            [[RCIM sharedRCIM] connectWithToken:kCurrentToken success:^(NSString *userId) {
                //设置用户信息提供者,页面展现的用户头像及昵称都会从此代理取
//                [[RCIM sharedRCIM] setUserInfoDataSource:self];
                SBLog(@"连接服务器成功 TOKEN -- %@", kCurrentToken);
            } error:^(RCConnectErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    SBLog(@"连接服务器失败,暂时无法使用聊天功能!");
                });
            } tokenIncorrect:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SBLog(@"TOKEN失效,暂时无法使用聊天功能,请联系客服解决!");
                });
            }];
            if ([KVNProgress isVisible]) {
                [KVNProgress dismiss];
            }
        }
    }];
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate) login];
}

#pragma mark - 注销
- (void)logout
{
    self.loginUser = nil;
    [((AppDelegate *)[UIApplication sharedApplication].delegate) logout];
}


#pragma mark - 获取token
- (void)getTokenWithUser:(RCDLoginInfo *)user completionHandle:(void (^)(BOOL isSucess))completionHandle
{
    __weak typeof(self) weakSelf = self;
    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kGetTokenUrlString paramString:kParamForGetToken(user.id, user.nick_name, user.head_portrait) completionHandle:^(NSData *data) {
        if (!data) {
            SHOWERROR(@"网络故障,获取TOKEN失败,聊天功能暂时无法使用!");
            if (completionHandle) {
                completionHandle(NO);
            }
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (dict[@"code"]) {
            NSInteger code = [dict[@"code"] integerValue];
            if (code == 200) {
                weakSelf.token = dict[@"result"][@"token"];
//                // 获取token后,自动获取好友列表
//                [weakSelf getFriendListCompletionHandle:nil];
                if (completionHandle) {
                    completionHandle(YES);
                }
            } else {
                if (dict[@"message"] && [dict[@"message"] length] > 0) {
                    NSString *message = dict[@"message"];
                    SHOWERROR(@"%@", message);
                } else {
                    SHOWERROR(@"获取TOKEN失败,聊天功能暂时无法使用!");
                }
                if (completionHandle) {
                    completionHandle(NO);
                }
            }
        } else {
            SHOWERROR(@"获取TOKEN失败,聊天功能暂时无法使用!");
            if (completionHandle) {
                completionHandle(NO);
            }
        }
    }];
}
//
//#pragma mark - 添加好友
//- (void)sendFriendRequestWithUserId:(NSInteger)userId message:(NSString *)message completionHandle:(void (^)(BOOL isSuccess))completionHandle
//{
//    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kSendFriendRequestUrlString paramString:kParamForSendFriendRequest(userId, message) completionHandle:^(NSData *data) {
//        if (!data) {
//            SHOWERROR(@"网络故障,请重试!");
//            if (completionHandle) {
//                completionHandle(NO);
//            }
//            return ;
//        }
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        if (dict[@"code"]) {
//            NSInteger code = [dict[@"code"] integerValue];
//            if (code == 200) {
//                if (completionHandle) {
//                    completionHandle(YES);
//                }
//            } else {
//                if (dict[@"message"] && [dict[@"message"] length] > 0) {
//                    NSString *message = dict[@"message"];
//                    SHOWERROR(@"%@", message);
//                } else {
//                    SHOWERROR(@"添加好友失败!");
//                }
//                if (completionHandle) {
//                    completionHandle(NO);
//                }
//            }
//        } else {
//            SHOWERROR(@"添加好友失败!");
//            if (completionHandle) {
//                completionHandle(NO);
//            }
//        }
//    }];
//}
//
//
//#pragma mark - 获取好友列表
//- (void)getFriendListCompletionHandle:(void (^)(NSArray *friendArray))completionHandle
//{
//    __weak typeof(self) weakSelf = self;
//    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kGetFriendList paramString:kParamForGetFriendList(kCurrentUser.Id) completionHandle:^(NSData *data) {
//        if (!data) {
//            SHOWERROR(@"网络故障,请重试!");
//            if (completionHandle) {
//                completionHandle(nil);
//            }
//            return ;
//        }
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        if (dict[@"code"]) {
//            NSInteger code = [dict[@"code"] integerValue];
//            if (code == 200) {
//                NSArray *array = dict[@"result"];
//                weakSelf.friendArray = [NSMutableArray array];
//                for (NSDictionary *userDict in array) {
//                    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userDict[@"id"] name:userDict[@"nick_name"] portrait:userDict[@"head_portrait"]];
//                    [weakSelf.friendArray addObject:user];
//                }
//                if (completionHandle) {
//                    completionHandle(weakSelf.friendArray);
//                }
//            } else {
//                if (dict[@"message"] && [dict[@"message"] length] > 0) {
//                    NSString *message = dict[@"message"];
//                    SHOWERROR(@"%@", message);
//                } else {
//                    SHOWERROR(@"获取好友列表失败!");
//                }
//                if (completionHandle) {
//                    completionHandle(nil);
//                }
//            }
//        } else {
//            SHOWERROR(@"获取好友列表失败!");
//            if (completionHandle) {
//                completionHandle(nil);
//            }
//        }
//    }];
//}
//
//#pragma mark - RCIMUserInfoDataSource
//- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion
//{
//    
//}
@end
