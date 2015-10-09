//
//  NetHelper.h
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetHelper : NSObject

kSingleTon_H(NetHelper)

#pragma mark - 网络请求数据基类
- (void)getDataWithUrlString:(NSString *)urlString completionHandle:(void(^)(NSData *data))completionHandle;


//- (void)postDataWithUrlString:(NSString *)urlString completionHandle:(void(^)(NSData *data))completionHandle;

@end
