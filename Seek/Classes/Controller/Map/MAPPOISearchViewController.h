//
//  MAPPOISearchViewController.h
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MAPPOISearchViewController : UIViewController

@property (nonatomic, assign) CGFloat defaultLatitude;

@property (nonatomic, assign) CGFloat defaultLongitude;

// 回调block,BOOL值代表是否选中某个地点 两个float为经纬度
@property (nonatomic, copy) void (^dismisBlock)(CGFloat latitude, CGFloat longitude, NSString *locationAddress, NSString *locationName, BOOL hasChoose);
@end
