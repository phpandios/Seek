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
    [((AppDelegate *)[UIApplication sharedApplication].delegate) login];
}

#pragma mark - 注销
- (void)logout
{
    self.loginUser = nil;
    [((AppDelegate *)[UIApplication sharedApplication].delegate) logout];
}


#pragma mark - 获取token
- (void)getTokenWithUser:(User *)user completionHandle:(void (^)(BOOL isSucess))completionHandle
{
    __weak typeof(self) weakSelf = self;
    [[DataBaseHelper shareDataBaseHelper] postDataWithUrlString:kGetTokenUrlString paramString:kParamForGetToken(user.Id, user.nick_name, user.head_portrait) completionHandle:^(NSData *data) {
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
                weakSelf.token = dict[@"token"];
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

@end
