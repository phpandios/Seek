//
//  NetHelper.m
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "NetHelper.h"

@implementation NetHelper

kSingleTon_M(NetHelper)

#pragma mark - 网络请求数据基类
- (void)getDataWithUrlString:(NSString *)urlString completionHandle:(void(^)(NSData *data))completionHandle
{
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) {
        SHOWMESSAGE(@"网络连接故障");
        if (completionHandle) {
            completionHandle(nil);
        }
        return;
    }
    [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandle) {
            completionHandle(data);
        }
    }];
}

@end
