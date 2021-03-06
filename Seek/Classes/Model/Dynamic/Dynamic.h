//
//  Dynamic.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dynamic : NSObject<NSCoding>

@property (nonatomic, assign)NSInteger category_id;//分类id

@property (nonatomic, retain)NSDate *statr_time;

@property (nonatomic, retain)NSDate *end_time;

@property (nonatomic, copy) NSString *nick_name;

@property (nonatomic, copy) NSString *head_portrait;

@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, assign) NSInteger dynamicId;

@property (nonatomic, assign) BOOL is_friend;

// 地点
@property (nonatomic, assign) CGFloat longitude; // 经度

@property (nonatomic, assign) CGFloat latitude; // 纬度

@property (nonatomic, copy) NSString *locationName; // 地点名称

@property (nonatomic, copy) NSString *locationAddress;

// 动态内容
@property (nonatomic, copy) NSString *content;

// 动态标题
@property (nonatomic, copy) NSString *title;

// 动态的图片数组
@property (nonatomic, copy) NSString *images;

/*
 * 评论数量[主评论数,即只算 回复的是动态的评论]
 */
@property (nonatomic, assign) NSInteger commentNum;

// 动态时间
@property (nonatomic, copy) NSString *timestamp;

@end
