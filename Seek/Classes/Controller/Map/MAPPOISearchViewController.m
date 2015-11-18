//
//  MAPPOISearchViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MAPPOISearchViewController.h"
#import "SearchInputTipTableView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapSearchHelper.h"
@interface MAPPOISearchViewController ()<MAMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

- (IBAction)dismisButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet SearchInputTipTableView *inputTipTableView;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintsWhileHideKeyboard;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *inputTipsArray;

@property (nonatomic, strong) NSMutableArray *poiAroundArray;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *province;


@property (nonatomic, assign) CLLocationCoordinate2D selectedCoordinate;

@end

@implementation MAPPOISearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // 地图
    _mapView.delegate = self;
//    // 开启定位
//    _mapView.showsUserLocation = YES;
    // 定位用户位置的模式
    _mapView.userTrackingMode = MAUserTrackingModeNone;//不追踪用户
    
    // 设置缩放级别
    [_mapView setZoomLevel:16 animated:YES];
    
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake([[RCDLoginInfo shareLoginInfo] latitude], [[RCDLoginInfo shareLoginInfo] longitude])];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];    
    
//    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
//    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
//    geo.city = @"北京";
//    geo.address = @"望京";
//    //发起正向地理编码
//    [_searchAPI AMapGeocodeSearch:geo];
    
    
    
    
    
}

#pragma mark 根据传进来的默认位置,逆地理编码获取所在城市.(用于输入提示搜索)
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardDidShow:(NSNotification *)sender
{
    self.mapView.hidden = YES;
    [self.mapView addTransitionWithType:kCATransitionMoveIn subType:kCATransitionFromTop duration:0.5 key:nil];
    [self.tableView addTransitionWithType:kCATransitionMoveIn subType:kCATransitionFromTop duration:0.5 key:nil];
    [self.tableView removeConstraint:self.heightConstraintsWhileHideKeyboard];
}

- (void)keyboardDidHide:(NSNotification *)sender
{
    self.mapView.hidden = NO;
    [self.tableView addTransitionWithType:kCATransitionMoveIn subType:kCATransitionFromBottom duration:0.5 key:nil];
    [self.mapView addTransitionWithType:kCATransitionMoveIn subType:kCATransitionFromBottom duration:0.5 key:nil];
    [self.tableView addConstraint:self.heightConstraintsWhileHideKeyboard];
}
#pragma mark - LazyLoading
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}
#pragma mark - MAMapViewDelegate
#pragma mark 定位后,逆向编码获取当前城市.
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    
    // 获取城市
    [self reGoeCodeSearchWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    
    
}
#pragma mark 移动地图时,刷新poi数组
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
    // 保存当前定位信息 - 用于poi
    self.selectedCoordinate = coordinate;
    [self poiAroundSearch];
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
        [self dismissViewControllerAnimated:YES completion:nil];
        if (_dismisBlock) {
            _dismisBlock(poi.location.latitude, poi.location.longitude, poi.address, poi.name, YES);
        }
        
    }
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_dismisBlock) {
        _dismisBlock(0, 0, nil, nil, NO);
    }
}

#pragma mark - 搜索
- (void)reGoeCodeSearchWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
{
    __weak typeof(self) weakSelf = self;
    [[MapSearchHelper shareMapSearchHelper] reGoeCodeSearchWithLatitude:latitude longitude:longitude completionHandle:^(AMapReGeocodeSearchResponse *response) {
        if(response.regeocode != nil)
        {
            //通过AMapReGeocodeSearchResponse对象处理搜索结果
            AMapReGeocode *reGeocode = response.regeocode;
            weakSelf.city = reGeocode.addressComponent.city;
            weakSelf.province = reGeocode.addressComponent.province;
        }
        
    }];
}
- (void)poiAroundSearch
{
    __weak typeof(self) weakSelf = self;
    [[MapSearchHelper shareMapSearchHelper] poiAroundSearchWithLatitude:self.selectedCoordinate.latitude longitude:self.selectedCoordinate.longitude completionHandle:^(AMapPOISearchResponse *response) {
        weakSelf.poiAroundArray = nil;
        if(response.pois.count == 0)
        {
            return;
        }
        for (AMapPOI *p in response.pois) { // 名称 地址和位置都不为空 -- 名称和地址用于显示,地址用于返回
            if (p.address && p.location && p.name) {
                [weakSelf.poiAroundArray addObject:p];
            }
        }
        
        [weakSelf.tableView reloadData];
    }];
}

- (void)inputTipSearchWithKeyword:(NSString *)keyword
{
    __weak typeof(self) weakSelf = self;
    [[MapSearchHelper shareMapSearchHelper] inputTipSearchWithKeyword:keyword city: (_city ? _city : _province) completionHandle:^(AMapInputTipsSearchResponse *response) {
        weakSelf.inputTipsArray = nil;
        if(response.tips.count == 0) {
            
        } else {
            for (AMapTip *tip in response.tips) {
                if (tip.name && tip.location) { // 名称和位置都不为空 -- 名称用于显示,地址用于POI搜索
                    [weakSelf.inputTipsArray addObject:tip];
                }
            }
        }
        
        [self.inputTipTableView reloadData];
        
        self.inputTipTableView.hidden = NO;
        // tableview自适应大小(最高200-在自定义tableview内修改)
        [self.inputTipTableView invalidateIntrinsicContentSize];
    }];
}

@end
