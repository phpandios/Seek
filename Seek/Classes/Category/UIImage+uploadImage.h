//
//  UIImage+uploadImage.h
//  Seek
//
//  Created by apple on 15/11/3.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (uploadImage)
+ (void)uplodImageWithData:(NSData *)data
                          method:(NSString *)method
                       urlString:(NSString *)urlString
                        mimeType:(NSString *)mimeType
                       inputName:(NSString *)inputName
                        fileName:(NSString *)fileName
                       returnUrl:(void (^)(id obj))returnUrl;
+ (void)uplodImageWithData:(NSData *)data
                    method:(NSString *)method
                 urlString:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                  mimeType:(NSString *)mimeType
                 inputName:(NSString *)inputName
                  fileName:(NSString *)fileName
                 returnUrl:(void (^)(id obj))returnUrl;
+(UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
