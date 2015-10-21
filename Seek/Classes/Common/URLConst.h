//
//  URLConst.h
//  Seek
//
//  Created by 吴非凡 on 15/10/20.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#ifndef URLConst_h
#define URLConst_h







/* 注册和登陆方式 BEGIN*/
#define kRegOrLoginTypeByTel @"tel"
#define kRegOrLoginTypeByWeChat @"we_chat"
#define kRegOrLoginTypeByQQ @"qq_chat"
/* 注册和登陆方式 END*/

// 注册
#define kRegUrlString @"http://hzftjy.com/seek/seek.php/reg"
#define kParamForReg(telephone, password, we_chat_id, qq_id, longitude, latitude, nick_name, gender, login_idenditifation) [NSString stringWithFormat:@"telephone=%@&password=%@&we_chat_id=%@&qq_id=%@&longitude=%f&latitude=%f&nick_name=%@&gender=%d&head_portrait=&login_idenditifation=%@", telephone, password, we_chat_id, qq_id, longitude, latitude, nick_name, gender, login_idenditifation]

// 登陆
#define kLoginUrlString @"http://hzftjy.com/seek/seek.php/mobile_login"
#define kParamForLogin(telephone, password, we_chat_id, qq_id, login_idenditifation) [NSString stringWithFormat:@"telephone=%@&password=%@&we_chat_id=%@&qq_id=%@&login_idenditifation=%@", telephone, password, we_chat_id, qq_id, login_idenditifation]

// 获取token
#define kGetTokenUrlString @"http://hzftjy.com/seek/seek.php/token"
#define kParamForGetToken(userId, name, portraitUri) [NSString stringWithFormat:@"user_id=%ld&nick_name=%@&head_portrait=%@", userId, name, portraitUri]

// 添加好友
#define kSendFriendRequestUrlString @"http://hzftjy.com/seek/seek.php/request_friend"
#define kParamForSendFriendRequest(id, message) [NSString stringWithFormat:@"id=%ld&message=%@", id, message]

// 获取好友
#define kGetFriendList @"http://hzftjy.com/seek/seek.php/get_friend"
#define kParamForGetFriendList(user_id) [NSString stringWithFormat:@"user_id=%ld", user_id]
#endif /* URLConst_h */
