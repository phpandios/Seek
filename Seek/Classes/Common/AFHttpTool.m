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
#define FAKE_SERVER @"http://www.seek-sb.cn/seek.php/"//@"http://119.254.110.241:80/" //Login 线下测试

//#define ContentType @"text/plain"
#define ContentType @"text/html"

/* 注册和登陆方式 BEGIN*/
#define kRegOrLoginTypeByTel @"tel"
#define kRegOrLoginTypeByWeChat @"we_chat"
#define kRegOrLoginTypeByQQ @"qq_chat"
/* 注册和登陆方式 END*/

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
#pragma mark - 更新位置
+ (void)updateLocationWithLongitude:(CGFloat)longitude
                           latitude:(CGFloat)latitude
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *err))failure
{
    NSDictionary *params = @{@"longitude" : @(longitude), @"latitude" : @(latitude)};
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"update_location"
                           params:params
                          success:success
                          failure:failure];

}

#pragma mark - 手机号是否存在
+ (void)telphoneIsExist:(NSString *)telphone
                success:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure
{
    NSDictionary *params = @{@"telephone" : telphone};
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"mobile_exists"
                           params:params
                          success:success
                          failure:failure];
}

#pragma mark - 修改密码
+ (void)modifyPassword:(NSString *)password
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure
{
    NSDictionary *params = @{@"password" : password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"update_password"
                           params:params
                          success:success
                          failure:failure];
}

#pragma mark - 上传头像
+ (void)uploadImage:(NSData *)imageData
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{@"upload_file" : imageData};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"update_photo"
                           params:params
                          success:success
                          failure:failure];
}


#pragma mark - 改绑手机
+ (void)bindingTelphone:(NSString *)telPhone
               password:(NSString *)password
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;
{
    NSDictionary *params = @{@"telephone" : telPhone, @"password" : password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"update_phone"
                           params:params
                          success:success
                          failure:failure];
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
#pragma mark - 搜索动态
+ (void)searchDynamicWithPage:(NSInteger)page
                        limit:(NSInteger)limit
                  category_id:(NSInteger)category_id
                      keyword:(NSString *)keyword
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError * err))failure
{
    NSDictionary *params = @{@"page" : @(page), @"limit" : @(limit), @"category_id" : @(category_id), @"keyword" : keyword};
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"search__dynamic"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark -发布消息
+ (void)publishMessageCate:(NSInteger)category_id
                     title:(NSString *)title
               content:(NSString *)content
                images:(NSString *)images
             longitude:(CGFloat)longitude
              latitude:(CGFloat)latitude
          locationName:(NSString *)locationName
       locationAddress:(NSString *)locationAddress
            permission:(NSInteger)permission
               success:(void (^)(id response))success
               failure:(void (^)(NSError * err))failure
{
    NSDictionary *params = @{
                             @"category_id":@(category_id),
                             @"title" : title,
                             @"content" : content,
                             @"images" : images,
                             @"longitude" : @(longitude),
                             @"latitude" : @(latitude),
                             @"locationName":locationName,
                             @"locationAddress":locationAddress,
                             @"permission" : @(permission)};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"pulish_dynamic"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark -请求动态消息
+ (void)getDynamicWithPage:(NSInteger)page
                     limit:(NSInteger)limit
               permissions:(NSInteger)permissions
             promote_state:(NSInteger)promote_state
                     state:(NSInteger)state
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{
                             @"page" : @(page),
                             @"limit" : @(limit),
                             @"permissions" : @(permissions),
                             @"promote_state" : @(promote_state),
                             @"state" : @(state)
                             };
    NSLog(@"%@", params);
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_dynamic"
                           params:params
                          success:success
                          failure:failure];
}

#pragma mark -请求动态分类
+ (void)getCateGoryWithstate:(NSInteger)state
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{
                            @"state" : @(state)
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"category_list"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark -获取评论
+ (void)getReplyWithSuccess:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{
                             @"state" : @(1)
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_reply"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark - 获取其它动态
+ (void)getOtherDynamicWithPage:(NSInteger)page
                          limit:(NSInteger)limit
                        user_id:(NSInteger)user_id
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError * err))failure
{
    NSDictionary *params = @{
                             @"page" : @(page),
                             @"limit" : @(limit),
                             @"user_id" : @(user_id)
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_other_dynamic"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark - 评论动态
+ (void)commentsDynamicWithDynamicId:(NSInteger)DynamicId
                             content:(NSString *)content
                            toUserId:(NSInteger)toUserId
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{
                             @"dynamic_id" : @(DynamicId),
                             @"content" : content,
                             @"toUserId" :@(toUserId),
                             @"respondType" : @(1)
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"reply_dynamic"
                           params:params
                          success:success
                          failure:failure];
}
#pragma mark -回复评论
+ (void)replyCommentWithReplyid:(NSInteger)Replyid
                        content:(NSString *)content
                       toUserId:(NSInteger)toUserId
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{
                             @"reply_id" : @(Replyid),
                             @"content" : content,
                             @"toUserId" : @(toUserId)
                             };
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"reply_child_dynamic"
                           params:params
                          success:success
                          failure:failure];
    
}
#pragma mark -获取周边用户
+ (void)getNearUserWithSuccess:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"get_near_user"
                           params:nil
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


+(void)searchFriendListByTel:(NSString*)telePhone success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_telephone"
                           params:@{@"telephone":telePhone}
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
