//
//  Comment.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RespondTypeByDynamic, // 响应动态
    RespondTypeByComment // 响应评论
} RespondType;// 响应类型

@interface Comment : NSObject

// 评论属于哪一条动态
@property (nonatomic, assign) NSInteger dynamicId;

// 评论ID
@property (nonatomic, assign) NSInteger commentId;

// 评论的发送者
@property (nonatomic, copy) NSString *fromUserId;

@property (nonatomic, copy) NSString *fromUserHeadImage;

@property (nonatomic, copy) NSString *fromUserName;
// 评论的接收者
@property (nonatomic, copy) NSString *toUserId;

@property (nonatomic, copy) NSString *toUserName;

@property (nonatomic, assign) RespondType respondType;

// 子评论数组
@property (nonatomic, strong) NSArray *childComments;

// 评论内容
@property (nonatomic, copy) NSString *content;

// 时间
@property (nonatomic, strong) NSDate *timestamp;


@end
