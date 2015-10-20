//
//  URLConst.h
//  Seek
//
//  Created by 吴非凡 on 15/10/20.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#ifndef URLConst_h
#define URLConst_h








#define kRegUrlString @"http://hzftjy.com/seek/seek.php/reg"
#define kLoginUrlString @"http://hzftjy.com/seek/seek.php/mobile_login"
#define kParamForReg(telephone, password, we_chat_id, qq_id, longitude, latitude, nick_name, gender, login_idenditifation) [NSString stringWithFormat:@"telephone=%@&password=%@&we_chat_id=%@&qq_id=%@&longitude=%f&latitude=%f&nick_name=%@&gender=%d&head_portrait=&login_idenditifation=%@", telephone, password, we_chat_id, qq_id, longitude, latitude, nick_name, gender, login_idenditifation]
#define kParamForLogin(telephone, password, we_chat_id, qq_id, login_idenditifation) [NSString stringWithFormat:@"telephone=%@&password=%@&we_chat_id=%@&qq_id=%@&login_idenditifation=%@", telephone, password, we_chat_id, qq_id, login_idenditifation]
/* 注册和登陆方式 BEGIN*/
#define kRegOrLoginTypeByTel @"tel"
#define kRegOrLoginTypeByWeChat @"we_chat"
#define kRegOrLoginTypeByQQ @"qq_chat"
/* 注册和登陆方式 END*/

#endif /* URLConst_h */
