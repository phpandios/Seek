//
//  AFHttpTool.m
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//


#import "AFHttpTool.h"
#import "AFNetworking.h"
#import "RCDLoginInfo.h"
#define DEV_FAKE_SERVER @"http://119.254.110.241/" //Beijing SUN-QUAN  测试环境（北京）
#define PRO_FAKE_SERVER @"http://119.254.110.79:8080/" //Beijing Liu-Bei    线上环境（北京）、
#define FAKE_SERVER @"http://hzftjy.com/seek/seek.php/"//@"http://119.254.110.241:80/" //Login 线下测试

//#define ContentType @"text/plain"
#define ContentType @"text/html"

@implementation AFHttpTool

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString*)url
                   params:(NSDictionary*)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure
{
    NSURL* baseURL = [NSURL URLWithString:FAKE_SERVER];
    //获得请求管理者
    AFHTTPRequestOperationManager* mgr = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

#ifdef ContentType
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObject:ContentType];
#endif
    mgr.requestSerializer.HTTPShouldHandleCookies = YES;
    
    switch (methodType) {
        case RequestMethodTypeGet:
        {
            //GET请求
            [mgr GET:url parameters:params
             success:^(AFHTTPRequestOperation* operation, NSDictionary* responseObj) {
                 if (success) {
                     success(responseObj);
                 }
             } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                 if (failure) {
                     failure(error);
                 }
             }];

        }
            break;
        case RequestMethodTypePost:
        {
            //POST请求
            [mgr POST:url parameters:params
              success:^(AFHTTPRequestOperation* operation, NSDictionary* responseObj) {
                  if (success) {
                      success(responseObj);
                  }
              } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                  if (failure) {
                      failure(error);
                  }
              }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 登陆
+ (void)loginWithTelPhone:(NSString *)telPhone password:(NSString *)password success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure;
{
    NSDictionary *params = @{@"telephone" : telPhone, @"password" : password, @"we_chat_id" : @"", @"qq_id" : @"", @"login_idenditifation" : kRegOrLoginTypeByTel, @"nick_name" : @"", @"head_portrait" :@""};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"mobile_login"
                           params:params
                          success:success
                          failure:failure];
}


#pragma mark - qq登陆
+ (void)loginWithQQID:(NSString *)qqid nick_name:(NSString *)nick_name head_portrait:(NSString *)head_portrait success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;
{
    NSDictionary *params = @{@"telephone" : @"", @"password" : @"", @"we_chat_id" : @"", @"qq_id" : qqid, @"login_idenditifation" : kRegOrLoginTypeByQQ, @"nick_name" : nick_name, @"head_portrait" :head_portrait};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"mobile_login"
                           params:params
                          success:success
                          failure:failure];
    
}

#pragma mark - 注册
+ (void)regWithTelPhone:(NSString *)telPhone password:(NSString *)password success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;
{
    NSDictionary *params = @{@"telephone" : telPhone, @"password" : password, @"we_chat_id" : @"", @"qq_id" : @"", @"login_idenditifation" : kRegOrLoginTypeByTel, @"nick_name" : @"", @"gender" : @(1), @"head_portrait" : @""};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"reg"
                           params:params
                          success:success
                          failure:failure];
}


#pragma mark - 获取token
+ (void)getTokenWithUser:(RCDLoginInfo *)user
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{@"user_id" : @(user.id), @"nick_name" : user.nick_name, @"head_portrait" : user.head_portrait};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"token"
                           params:params
                          success:success
                          failure:failure];
}


//get friends
+(void) getFriendsSuccess:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure
{
    //获取包含自己在内的全部注册用户数据
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"friends"
                           params:nil
                          success:success
                          failure:failure];
}

//get groups
+(void) getAllGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_all_group"
                           params:nil
                          success:success
                          failure:failure];
}

+(void) getMyGroupsSuccess:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_my_group"
                           params:nil
                          success:success
                          failure:failure];
}

//get group by id
+(void) getGroupByID:(int) groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"get_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];

}

//create group
+(void) createGroupWithName:(NSString *) name
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"create_group"
                           params:@{@"name":name}
                          success:success
                          failure:failure];
}

//join group
+(void) joinGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"join_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];
}

//quit group
+(void) quitGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"quit_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];
}


+(void)updateGroupByID:(int)groupID
         withGroupName:(NSString *)groupName
     andGroupIntroduce:(NSString *)introduce
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"update_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID],@"name":groupName,@"introduce":introduce}
                          success:success
                          failure:failure];
}

+(void)getFriendListFromServerSuccess:(void (^)(id))success
                              failure:(void (^)(NSError *))failure
{
    //获取除自己之外的好友信息
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_friend"
                           params:nil
                          success:success
                          failure:failure];
}


+(void)searchFriendListByEmail:(NSString*)email success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_email"
                           params:@{@"email":email}
                          success:success
                          failure:failure];
}

+(void)searchFriendListByName:(NSString*)name
                      success:(void (^)(id))success
                      failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_name"
                           params:@{@"username":name}
                          success:success
                          failure:failure];
}

+(void)requestFriend:(NSString*)userId
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure
{
    NSLog(@"%@",NSLocalizedStringFromTable(@"Request_Friends_extra", @"RongCloudKit", nil));
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"request_friend"
                           params:@{@"id":userId, @"message": NSLocalizedStringFromTable(@"Request_Friends_extra", @"RongCloudKit", nil)} //Request_Friends_extra
                          success:success
                          failure:failure];
}

+(void)processRequestFriend:(NSString*)userId
               withIsAccess:(BOOL)isAccess
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure
{

    NSString *isAcept = isAccess ? @"1":@"0";
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"process_request_friend"
                           params:@{@"id":userId,@"is_access":isAcept}
                          success:success
                          failure:failure];
}

+(void) deleteFriend:(NSString*)userId
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"delete_friend"
                           params:@{@"id":userId}
                          success:success
                          failure:failure];
}

+(void)getUserById:(NSString*) userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"profile"
                           params:@{@"id":userId}
                          success:success
                          failure:failure];
}
@end