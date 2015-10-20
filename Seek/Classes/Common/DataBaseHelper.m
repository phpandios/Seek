//
//  NetHelper.m
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DataBaseHelper.h"

@implementation DataBaseHelper

kSingleTon_M(DataBaseHelper)

#pragma mark - 网络请求数据基类
- (void)postDataWithUrlString:(NSString *)urlString paramString:(NSString *)paramString completionHandle:(void(^)(NSData *data))completionHandle
{
    if (![self checkConnectionStatus]) {
        if (completionHandle) {
            completionHandle(nil);
        }
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:({
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        //(2)超时
        [request setTimeoutInterval:10];
        
        //(3)设置请求头
        [request setAllHTTPHeaderFields:nil];
        request;
    }) completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandle) {
            completionHandle(data);
        }
    }];
    
    [dataTask resume];
}

- (void)getDataWithUrlString:(NSString *)urlString completionHandle:(void(^)(NSData *data))completionHandle
{
    if ([self checkConnectionStatus]) {
        if (completionHandle) {
            completionHandle(nil);
        }
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:({
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        request.HTTPMethod = @"GET";
        //(2)超时
        [request setTimeoutInterval:10];

        request;
    }) completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandle) {
            completionHandle(data);
        }
    }];
    
    [dataTask resume];
}

- (BOOL)checkConnectionStatus
{
    BOOL flag = ![Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable;
    if (!flag) {
        SHOWERROR(@"网络连接故障");
    }
    return flag;
}

@end
