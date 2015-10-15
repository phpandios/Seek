//
//  MAPPOISearchViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MAPPOISearchViewController.h"
#import "SearchInputTipTableView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
@interface MAPPOISearchViewController ()<MAMapViewDelegate, AMapSearchDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

- (IBAction)dismisButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet SearchInputTipTableView *inputTipTableView;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AMapSearchAPI *searchAPI;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) AMapInputTipsSearchRequest *inputTipsSearchRequest;// 输入提示搜索
@property (nonatomic, strong) NSMutableArray *inputTipsArray;

@property (nonatomic, strong) AMapPOIAroundSearchRequest *poiAroundSearchRequest;// POI周边搜索
@property (nonatomic, strong) NSMutableArray *poiAroundArray;

@property (nonatomic, strong) AMapReGeocodeSearchRequest *reGeocodeSearchRequest; // 逆向编码(进入后先根据坐标获取当前城市)

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *province;


@property (nonatomic, assign) CLLocationCoordinate2D selectedCoordinate;

@end

@implementation MAPPOISearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 配置key
        [MAMapServices sharedServices].apiKey = kLBSAppKey;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // 检索对象
    self.searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    
    
    // 地图
    _mapView.delegate = self;
    // 开启定位
    _mapView.showsUserLocation = YES;
    // 定位用户位置的模式
    _mapView.userTrackingMode = MAUserTrackingModeNone;//不追踪用户
    // 设置缩放级别
    [_mapView setZoomLevel:16 animated:YES];
    
    
    
    
    
//    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
//    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
//    geo.city = @"北京";
//    geo.address = @"望京";
//    //发起正向地理编码
//    [_searchAPI AMapGeocodeSearch:geo];
    
    
    
    
    [self.searchBar becomeFirstResponder];
    
}

#pragma mark - 根据传进来的默认位置,逆地理编码获取所在城市.(用于输入提示搜索)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LazyLoading
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

- (NSMutableArray *)poiAroundArray
{
    if (!_poiAroundArray) {
        _poiAroundArray = [NSMutableArray array];
    }
    return _poiAroundArray;
}

- (NSMutableArray *)inputTipsArray
{
    if (!_inputTipsArray) {
        _inputTipsArray = [NSMutableArray array];
    }
    return _inputTipsArray;
}
#pragma mark - UISearchBarDelegate
//构造AMapInputTipsSearchRequest对象，设置请求参数
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText != nil) {
        [self inputTipSearchWithKeyword:searchBar.text];
    }
}

#pragma mark - MAMapViewDelegate
#pragma mark 定位后,逆向编码获取当前城市.
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    
    // 获取城市
    [self reGoeCodeSearchWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    // 定位后设置中心
    [mapView setCenterCoordinate:userLocation.coordinate];
    // 保存当前定位信息 - 用于poi
    self.selectedCoordinate = userLocation.location.coordinate;
    [self poiAroundSearch];
}
#pragma mark 移动地图时,刷新poi数组
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
    // 保存当前定位信息 - 用于poi
    self.selectedCoordinate = coordinate;
    [self poiAroundSearch];
}

#pragma mark - AMapSearchDelegate
#pragma mark  实现POI搜索的回调函数
/*
 在地图表达中，一个POI可代表一栋大厦、一家商铺、一处景点等等。通过POI搜索，完成找餐馆、找景点、找厕所等等的功能
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    self.poiAroundArray = nil;
    if(response.pois.count == 0)
    {
        return;
    }
    for (AMapPOI *p in response.pois) { // 名称 地址和位置都不为空 -- 名称和地址用于显示,地址用于返回
        if (p.address && p.location && p.name) {
            [self.poiAroundArray addObject:p];
        }
    }
    
    [self.tableView reloadData];
    

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
        AMapReGeocode *reGeocode = response.regeocode;
        self.city = reGeocode.addressComponent.city;
        self.province = reGeocode.addressComponent.province;
        self.inputTipsSearchRequest.city = _city ? _city : _province;
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
    
    self.inputTipsArray = nil;
    if(response.tips.count == 0) {
        
    } else {
        for (AMapTip *tip in response.tips) {
            if (tip.name && tip.location) { // 名称和位置都不为空 -- 名称用于显示,地址用于POI搜索
                [self.inputTipsArray addObject:tip];
            }
        }
    }
    
    [self.inputTipTableView reloadData];
    
    self.inputTipTableView.hidden = NO;
    // tableview自适应大小(最高200-在自定义tableview内修改)
    [self.inputTipTableView invalidateIntrinsicContentSize];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.inputTipTableView) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.inputTipTableView) {
        return self.inputTipsArray.count;
    }
    return self.poiAroundArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.inputTipTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inputTipCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inputTipCell"];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        AMapTip *tip = self.inputTipsArray[indexPath.row];
        cell.textLabel.text = tip.name;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiAroundCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"poiAroundCell"];
    }
    AMapPOI *poi = self.poiAroundArray[indexPath.row];
    cell.detailTextLabel.text = poi.address;
    cell.textLabel.text = poi.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.inputTipTableView) {
        return 30;
    }
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 不管点击哪一个tableview都要隐藏输入的
    self.inputTipTableView.hidden = YES;
    if (tableView == self.inputTipTableView) {
        AMapTip *tip = self.inputTipsArray[indexPath.row];
        self.searchBar.text = tip.name;
        self.selectedCoordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
//        [self searchBar:_searchBar textDidChange:tip.name];
        [self poiAroundSearch];
    } else {
        AMapPOI *poi = self.poiAroundArray[indexPath.row];
        if (_dismisBlock) {
            _dismisBlock(poi.location.latitude, poi.location.longitude, YES);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    if (_dismisBlock) {
        _dismisBlock(0, 0, NO);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 搜索
- (void)reGoeCodeSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    //发起逆地理编码
    self.reGeocodeSearchRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    [_searchAPI AMapReGoecodeSearch:_reGeocodeSearchRequest];
}
- (void)poiAroundSearch
{
    self.poiAroundSearchRequest.location = [AMapGeoPoint locationWithLatitude:self.selectedCoordinate.latitude longitude:self.selectedCoordinate.longitude];
    [_searchAPI AMapPOIAroundSearch:_poiAroundSearchRequest];
}

- (void)inputTipSearchWithKeyword:(NSString *)keyword
{
    self.inputTipsSearchRequest.keywords = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_searchAPI AMapInputTipsSearch:_inputTipsSearchRequest];
}
@end
