//
//  User.h
//  Seek
//
//  Created by 吴非凡 on 15/10/10.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, copy) NSString *Id;

@property (nonatomic, copy) NSString *nick_name;

@property (nonatomic, copy) NSString *head_portrait;

@property (nonatomic, copy) NSString *telephone;

@property (nonatomic, assign) NSInteger gender;

@property (nonatomic, copy) NSString *qq_id;

@property (nonatomic, copy) NSString *we_chat_id;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) CGFloat latitude;

@end
