//
//  LoginInfo.h
//  RongCloud
//  登陆信息
//  Created by Liv on 14/11/10.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface RCDLoginInfo : JSONModel

@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *token;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *nick_name;

@property (nonatomic, copy) NSString *head_portrait;

@property (nonatomic, copy) NSString *telephone;

@property (nonatomic, assign) NSInteger gender;

@property (nonatomic, copy) NSString *qq_id;

@property (nonatomic, copy) NSString *we_chat_id;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) CGFloat latitude;

@property (nonatomic, copy) NSString *addressName;

@property (nonatomic, assign) BOOL isThirdLogin;

@property (nonatomic, assign) BOOL needUpdateFriend;

+(id) shareLoginInfo;

@end
