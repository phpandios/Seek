//
//  MapSearchHelper.m
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MapSearchHelper.h"

#import <AMapSearchKit/AMapSearchKit.h>
@interface MapSearchHelper ()<AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI *searchAPI;

@property (nonatomic, strong) AMapInputTipsSearchRequest *inputTipsSearchRequest;// 输入提示搜索

@property (nonatomic, strong) AMapPOIAroundSearchRequest *poiAroundSearchRequest;// POI周边搜索

@property (nonatomic, strong) AMapReGeocodeSearchRequest *reGeocodeSearchRequest; // 逆向编码(进入后先根据坐标获取当前城市)

@property (nonatomic, strong) NSMutableDictionary *poiAroundSearchBlockDict;

@property (nonatomic, strong) NSMutableDictionary *inputTipSearchBlockDict;

@property (nonatomic, strong) NSMutableDictionary *reGeocodeSearchBlockDict;
@end

@implementation MapSearchHelper

kSingleTon_M(MapSearchHelper)

- (instancetype)init
{
    if (self = [super init]) {
        // 搜索
        [AMapSearchServices sharedServices].apiKey = kLBSAppKey;
        
        
        // 检索对象
        self.searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
        
    }
    return self;
}

#pragma mark - LazyLoading
- (NSMutableDictionary *)poiAroundSearchBlockDict
{
    if (!_poiAroundSearchBlockDict) {
        _poiAroundSearchBlockDict = [NSMutableDictionary dictionary];
    }
    return _poiAroundSearchBlockDict;
}

- (NSMutableDictionary *)inputTipSearchBlockDict
{
    if (!_inputTipSearchBlockDict) {
        _inputTipSearchBlockDict = [NSMutableDictionary dictionary];
    }
    return _inputTipSearchBlockDict;
}

- (NSMutableDictionary *)reGeocodeSearchBlockDict
{
    if (!_reGeocodeSearchBlockDict) {
        _reGeocodeSearchBlockDict = [NSMutableDictionary dictionary];
    }
    return _reGeocodeSearchBlockDict;
}
- (AMapReGeocodeSearchRequest *)reGeocodeSearchRequest
{
    if (!_reGeocodeSearchRequest) {
        // 逆向地理编码搜索 - 确定当前城市(用于输入提示搜索)
        _reGeocodeSearchRequest = [[AMapReGeocodeSearchRequest alloc] init];
        _reGeocodeSearchRequest.radius = 10000;
        _reGeocodeSearchRequest.requireExtension = YES;
    }
    return _reGeocodeSearchRequest;
}
- (AMapPOIAroundSearchRequest *)poiAroundSearchRequest
{
    if (!_poiAroundSearchRequest) {
        _poiAroundSearchRequest = [AMapPOIAroundSearchRequest new];
        _poiAroundSearchRequest.types = @"公司企业|道路附属设施|地名地址信息|公共设施|风景名胜|商务住宅|政府机构及社会团体";
        _poiAroundSearchRequest.sortrule = 0;
        _poiAroundSearchRequest.requireExtension = YES;
    }
    return _poiAroundSearchRequest;
}

- (AMapInputTipsSearchRequest *)inputTipsSearchRequest
{
    if (!_inputTipsSearchRequest) {
        _inputTipsSearchRequest = [AMapInputTipsSearchRequest new];
    }
    return _inputTipsSearchRequest;
}



#pragma mark - 搜索
- (void)reGoeCodeSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude completionHandle:(void (^)(AMapReGeocodeSearchResponse *response))completionHandle
{
    self.reGeocodeSearchRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    if (completionHandle) {
        [self.reGeocodeSearchBlockDict setObject:[completionHandle copy] forKey:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
    }
    [_searchAPI AMapReGoecodeSearch:_reGeocodeSearchRequest];
}
- (void)poiAroundSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude completionHandle:(void (^)(AMapPOISearchResponse *response))completionHandle

{
    self.poiAroundSearchRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    if (completionHandle) {
        [self.poiAroundSearchBlockDict setObject:[completionHandle copy] forKey:[NSString stringWithFormat:@"%f,%f", latitude, longitude]];
    }
    [_searchAPI AMapPOIAroundSearch:_poiAroundSearchRequest];
}

- (void)inputTipSearchWithKeyword:(NSString *)keyword city:(NSString *)city completionHandle:(void (^)(AMapInputTipsSearchResponse *response))completionHandle

{
    self.inputTipsSearchRequest.keywords = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.inputTipsSearchRequest.city = city;
    if (completionHandle) {
        [self.inputTipSearchBlockDict setObject:[completionHandle copy] forKey:[NSString stringWithFormat:@"%@,%@", city, keyword]];
    }
    [_searchAPI AMapInputTipsSearch:_inputTipsSearchRequest];
}


#pragma mark - AMapSearchDelegate
#pragma mark  实现POI搜索的回调函数
/*
 在地图表达中，一个POI可代表一栋大厦、一家商铺、一处景点等等。通过POI搜索，完成找餐馆、找景点、找厕所等等的功能
 */
- (void)onPOISearchDone:(AMapPOIAroundSearchRequest *)request response:(AMapPOISearchResponse *)response
{
    void (^completionHandle)(AMapPOISearchResponse *response) = self.poiAroundSearchBlockDict[[NSString stringWithFormat:@"%f,%f", request.location.latitude, request.location.longitude]];
    completionHandle(response);
}

////实现正向地理编码的回调函数
///*
// 地理编码是依据当前输入，根据标准化的地址结构（省/市/区或县/乡/村或社区/商圈/街道/门牌号/POI）进行各个地址级别的匹配，以确认输入地址对应的地理坐标，只有返回的地理坐标匹配的级别为POI，才会对应一个具体的地物（POI）
// */
//- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
//{
//    if(response.geocodes.count == 0)
//    {
//        return;
//    }
//
//    //通过AMapGeocodeSearchResponse对象处理搜索结果
//    NSString *strCount = [NSString stringWithFormat:@"count: %d", response.count];
//    NSString *strGeocodes = @"";
//    for (AMapGeocode *p in response.geocodes) {
//        strGeocodes = [NSString stringWithFormat:@"%@\ngeocode: %@", strGeocodes, p.formattedAddress];
//    }
//    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strGeocodes];
//    NSLog(@"Geocode: %@", result);
//}

#pragma mark 实现逆地理编码的回调函数
/*
 指从已知的经纬度坐标到对应的地址描述（如行政区划、街区、楼层、房间等）的转换。常用于根据定位的坐标来获取该地点的位置详细信息，与定位功能是黄金搭档
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        void (^completionHandle)(AMapReGeocodeSearchResponse *response) = self.reGeocodeSearchBlockDict[[NSString stringWithFormat:@"%f,%f", request.location.latitude, request.location.longitude]];
        completionHandle(response);
    }
    
}

#pragma mark  实现输入提示的回调函数
/*
 输入提示返回的提示语对象 AMapTip 有多种属性，可根据该对象的返回信息，配合其他搜索服务使用，完善您应用的功能。如：
 
 1）uid为空，location为空，该提示语为品牌词，可根据该品牌词进行POI关键词搜索。
 
 2）uid不为空，location为空，为公交线路，根据uid进行公交线路查询。
 
 3）uid不为空，location也不为空，是一个真实存在的POI，可直接显示在地图上。
 */
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    
    void (^completionHandle)(AMapInputTipsSearchResponse *response) = self.inputTipSearchBlockDict[[NSString stringWithFormat:@"%@,%@", request.city, request.keywords]];
    completionHandle(response);
}


@end
