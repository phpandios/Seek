//
//  AFHttpTool.h
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestMethodType){
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2
};

@class RCDLoginInfo;
@class Dynamic;
@interface AFHttpTool : NSObject

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success      请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure      请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+(void) requestWihtMethod:(RequestMethodType)
          methodType url : (NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

#pragma mark - 更新位置
+ (void)updateLocationWithLongitude:(CGFloat)longitude
                           latitude:(CGFloat)latitude
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *err))failure;

#pragma mark - 手机号是否存在
+ (void)telphoneIsExist:(NSString *)telphone
                success:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure;

#pragma mark - 修改密码
+ (void)modifyPassword:(NSString *)password
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

#pragma mark - 上传头像
+ (void)uploadImage:(NSData *)imageData
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure;


#pragma mark - 改绑手机
+ (void)bindingTelphone:(NSString *)telPhone
               password:(NSString *)password
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;

#pragma mark - 手机登陆
+ (void)loginWithTelPhone:(NSString *)telPhone
                 password:(NSString *)password
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure;

#pragma mark - qq登陆
+ (void)loginWithQQID:(NSString *)qqid
            nick_name:(NSString *)nick_name
        head_portrait:(NSString *)head_portrait
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

#pragma mark - 注册
+ (void)regWithTelPhone:(NSString *)telPhone
               password:(NSString *)password
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;


#pragma mark - 获取token
+ (void)getTokenWithUser:(RCDLoginInfo *)user
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure;

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
                   failure:(void (^)(NSError * err))failure;
#pragma mark -请求动态消息
+ (void)getDynamicWithPage:(NSInteger)page
                     limit:(NSInteger)limit
               permissions:(NSInteger)permissions
             promote_state:(NSInteger)promote_state
                     state:(NSInteger)state
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;

#pragma mark -请求动态分类
+ (void)getCateGoryWithstate:(NSInteger)state
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure;
//get token
//+(void) getTokenSuccess:(void (^)(id response))success
//                failure:(void (^)(NSError* err))failure;

//get friends
+(void) getFriendsSuccess:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure;

//get groups
+(void) getMyGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;
+(void) getAllGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;
//get group by id
+(void) getGroupByID:(int) groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

//create group
+(void) createGroupWithName:(NSString *) name
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure;

//join group
+(void) joinGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//quit group
+(void) quitGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//update group
+(void) updateGroupByID:(int) groupID withGroupName:(NSString*) groupName andGroupIntroduce:(NSString*) introduce
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//获取好友列表
+(void)getFriendListFromServerSuccess:(void (^)(id response))success
                              failure:(void (^)(NSError* err))failure;

//按昵称搜素好友
+(void)searchFriendListByName:(NSString*)name success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;
//按手机搜素好友
+(void)searchFriendListByTel:(NSString*)telePhone
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure;

//请求加好友
+(void)requestFriend:(NSString*) userId
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;
//处理请求加好友
+(void)processRequestFriend:(NSString*) userId
               withIsAccess:(BOOL)isAccess
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure;
//删除好友
+(void)deleteFriend:(NSString*) userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure;

//获取好友信息
+(void)getUserById:(NSString*) userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure;

@end

