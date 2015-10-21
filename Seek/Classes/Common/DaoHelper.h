//
//  DaoHelper.h
//  Seek
//
//  Created by 吴非凡 on 15/10/20.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>


/* 
 本地缓存基类
 */
@interface DaoHelper : NSObject

kSingleTon_H(DaoHelper)

/*
 会话列表
 */
#pragma mark 根据当前用户id 及 好友模型添加会话记录
- (void)insertConversationWithUser:(RCUserInfo *)user;
#pragma mark 删除当前用户id 及 好友id的会话记录
- (void)deleteConversationWithUserId:(NSInteger)userId;
#pragma mark 更新当前用户id 及 好友id的时间戳
- (void)updateTimestampWithUserId:(NSInteger)userId;
#pragma mark 获取当前用户的所有会话列表
- (NSArray *)getAllConversation;
#pragma mark 清楚当前用户所有会话列表
- (void)deleteAllConversation;
@end
