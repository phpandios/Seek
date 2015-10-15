//
//  MapSearchHelper.h
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AMapReGeocodeSearchResponse;
@class AMapInputTipsSearchResponse;
@class AMapPOISearchResponse;
@interface MapSearchHelper : NSObject
kSingleTon_H(MapSearchHelper)

#pragma mark - 搜索
- (void)reGoeCodeSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude completionHandle:(void (^)(AMapReGeocodeSearchResponse *response))completionHandle;
- (void)poiAroundSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude completionHandle:(void (^)(AMapPOISearchResponse *response))completionHandle;
- (void)inputTipSearchWithKeyword:(NSString *)keyword city:(NSString *)city completionHandle:(void (^)(AMapInputTipsSearchResponse *response))completionHandle;
@end
