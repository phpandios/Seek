//
//  DaoHelper.m
//  Seek
//
//  Created by 吴非凡 on 15/10/20.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DaoHelper.h"
#import "FMDatabase.h"

#define kDocumentFilePath (NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject)
@interface DaoHelper ()

@property (nonatomic, strong) FMDatabase *db;

@end


// 会话列表
static NSString *TableNameForConversationList = @"conversationList";


@implementation DaoHelper

kSingleTon_M(DaoHelper)
- (instancetype)init
{
    if (self = [super init]) {
        self.db = [FMDatabase databaseWithPath:[kDocumentFilePath stringByAppendingPathComponent:@"db.sqlite"]];
        [self createTable];
    }
    return self;
}

- (void)createTable
{
    NSString *sqlStringForconversationList = @"create table if not exists conversationList(Id integer,friend_Id integer, friend_nick_name, friend_head_portrait, timestamp integer)";
    
    [_db open];
    if ([_db executeUpdate:sqlStringForconversationList]) {
        NSLog(@"本地会话列表创建成功");
    }
   
    [_db close];
}


#pragma mark - 会话
#pragma mark 根据当前用户id 及 好友模型添加会话记录
- (void)insertConversationWithUser:(RCUserInfo *)user
{
    [self deleteConversationWithUserId:[user.userId integerValue]];
    
    [_db open];
    
    [_db executeUpdate:[NSString stringWithFormat:@"insert into %@(Id, friend_Id, friend_nick_name, friend_head_portrait, timestamp) values(Id = :Id, friend_Id = :friend_Id, friend_nick_name = :friend_nick_name, friend_head_portrait = :friend_head_portrait, timestamp = :timestamp)", TableNameForConversationList] withParameterDictionary:@{@"Id" : @(kCurrentUser.Id), @"friend_Id" : user.userId, @"friend_nick_name" : user.name, @"friend_head_portrait" : user.portraitUri, @"timestamp" : @(((long)[NSDate date]))}];
    [_db close];
}
#pragma mark 删除当前用户id 及 好友id的会话记录
- (void)deleteConversationWithUserId:(NSInteger)userId
{
    [_db open];
    [_db executeUpdate:[NSString stringWithFormat:@"delete from %@ where Id = :Id and friend_Id = :friend_Id", TableNameForConversationList] withParameterDictionary:@{@"Id" : @(kCurrentUser.Id), @"friend_Id" : @(userId)}];
    [_db close];
}
#pragma mark 更新当前用户id 及 好友id的时间戳
- (void)updateTimestampWithUserId:(NSInteger)userId;
{
    [_db open];
    [_db executeUpdate:[NSString stringWithFormat:@"update %@ set timestamp = :timestamp where Id = :Id and friend_Id = :friend_Id", TableNameForConversationList] withParameterDictionary:@{@"Id" : @(kCurrentUser.Id), @"friend_Id" : @(userId), @"timestamp" : @(((long)[NSDate date]))}];
    [_db close];
}
#pragma mark 获取当前用户的所有会话列表
- (NSArray *)getAllConversation
{
    [_db open];
    
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select * from %@ wherre Id = :Id order by timestamp desc", TableNameForConversationList] withParameterDictionary:@{@"Id" : @(kCurrentUser.Id)}];
    NSMutableArray *array = nil;
    while ([set next]) {
        RCUserInfo *user = [RCUserInfo new];
        user.userId = [NSString stringWithFormat:@"%d", [set intForColumn:@"friend_Id"]];
        user.name = [set stringForColumn:@"friend_nick_name"];
        user.portraitUri = [set stringForColumn:@"friend_head_portrait"];
        if (!array) {
            array = [NSMutableArray array];
        }
        [array addObject:user];
    }
    
    [_db close];
    return array;
}
#pragma mark 清楚当前用户所有会话列表
- (void)deleteAllConversation
{
    [_db open];
    [_db executeUpdate:[NSString stringWithFormat:@"delete from %@ where Id = :Id", TableNameForConversationList] withParameterDictionary:@{@"Id" : @(kCurrentUser.Id)}];
    [_db close];
}
@end
