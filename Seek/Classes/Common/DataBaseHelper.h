//
//  DataBaseHelper.h
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 网络请求基类
 */
@interface DataBaseHelper : NSObject

kSingleTon_H(DataBaseHelper)

#pragma mark - 网络请求数据基类
- (void)getDataWithUrlString:(NSString *)urlString completionHandle:(void(^)(NSData *data))completionHandle;

- (void)postDataWithUrlString:(NSString *)urlString paramString:(NSString *)paramString completionHandle:(void(^)(NSData *data))completionHandle;

- (BOOL)checkConnectionStatus;

@end
