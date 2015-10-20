//
//  Tool.h
//  Seek
//
//  Created by 吴非凡 on 15/10/20.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject

/**
 *  用于判断是否为手机号码
 *
 *  @param mobileNum 手机号
 *
 *  @return 返回是或否
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

@end
