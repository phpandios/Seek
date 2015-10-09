//
//  UserInfoForMap.h
//  Seek
//
//  Created by 吴非凡 on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface UserInfoForMap : NSObject

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, assign) double latitude;

@property (nonatomic, assign) double longitude;

@end
