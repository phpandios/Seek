//
//  Dynamic.h
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dynamic : NSObject

@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, assign) NSInteger dynamicId;

@property (nonatomic, assign) CGFloat longitude; // 经度

@property (nonatomic, assign) CGFloat latitude; // 纬度

// 动态内容
@property (nonatomic, copy) NSString *content;

// 动态标题
@property (nonatomic, copy) NSString *title;

// 动态的图片数组
@property (nonatomic, strong) NSArray *images;

/*
 * 评论数组<Comment>[主评论数,即只算 回复的是动态的评论]
 */
@property (nonatomic, strong) NSArray *comments;

// 动态时间
@property (nonatomic, strong) NSDate *timestamp;

@end
