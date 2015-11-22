//
//  UIImage+uploadImage.m
//  Seek
//
//  Created by apple on 15/11/3.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "UIImage+uploadImage.h"

@implementation UIImage (uploadImage)
+ (void)uplodImageWithData:(NSData *)data method:(NSString *)method urlString:(NSString *)urlString mimeType:(NSString *)mimeType inputName:(NSString *)inputName fileName:(NSString *)fileName returnUrl:(void (^)(id))returnUrl
{
    //创建serializer，请求，队列，和错误对象。
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    AFHTTPRequestOperation *operation;
    NSMutableURLRequest *request;
    NSError * error ;
    request = [serializer multipartFormRequestWithMethod:method URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //拼接每个图片表单
        [formData appendPartWithFileData:data name:inputName fileName:fileName mimeType:mimeType];
        //拼接参数表单
        [formData appendPartWithFormData:data name:inputName];
        
    } error:&error];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    operation = [manager HTTPRequestOperationWithRequest:request
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     
                                                     returnUrl(operation.responseString);
                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     NSLog(@"error:%@",error);
                                                     
                                                     
                                                 }];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
    }];
    [operation start];
}

+ (void)uplodImageWithData:(NSData *)data
                    method:(NSString *)method
                 urlString:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                  mimeType:(NSString *)mimeType
                 inputName:(NSString *)inputName
                  fileName:(NSString *)fileName
                 returnUrl:(void (^)(id obj))returnUrl
{
    //创建serializer，请求，队列，和错误对象。
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    AFHTTPRequestOperation *operation;
    NSMutableURLRequest *request;
    NSError * error ;
    request = [serializer multipartFormRequestWithMethod:method URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //拼接每个图片表单
        [formData appendPartWithFileData:data name:inputName fileName:fileName mimeType:mimeType];
        //拼接参数表单
        [formData appendPartWithFormData:data name:inputName];
        
    } error:&error];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    operation = [manager HTTPRequestOperationWithRequest:request
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     
                                                     returnUrl(operation.responseString);
                                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     NSLog(@"error:%@",error);
                                                     
                                                     
                                                 }];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
    }];
    [operation start];
}

//对图片尺寸进行压缩--

+(UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    
    // Create a graphics image context
    
    UIGraphicsBeginImageContext(newSize);
    
    
    
    // Tell the old image to draw in this new context, with the desired
    
    // new size
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    
    
    // Get the new image from the context
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    // End the context
    
    UIGraphicsEndImageContext();
    
    
    
    // Return the new image.
    
    return newImage;
    
}
@end
