//
//  MapViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>

#import "UserInfoForMap.h"
@interface MapViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) NSArray *otherUserNearByArray; // 周边用户信息

@property (nonatomic, strong) NSMutableArray *otherAnnotationArray; // 周边用户标注

@property (nonatomic, strong) MAUserLocation *currentUserLocation;

@property (nonatomic, strong) MAPointAnnotation *currentUserAnnotation;

#pragma mark 控件组
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;
- (IBAction)locationSwitchValueChanged:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UIView *dropDownView;
- (IBAction)locationButtonAction:(UIButton *)sender;

@end

#define kSeparateString @"<**>"

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置key
    [MAMapServices sharedServices].apiKey = kLBSAppKey;
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    
    [self.view insertSubview:_mapView atIndex:0];
    // 开启定位
    _mapView.showsUserLocation = YES;
    // 定位用户位置的模式
    _mapView.userTrackingMode = MAUserTrackingModeFollow;//追踪用户的location与heading更新
    // 设置缩放级别
    [_mapView setZoomLevel:16 animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    // 大头针标注
//    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
//    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
//    pointAnnotation.title = @"方恒国际";
//    pointAnnotation.subtitle = @"阜通东大街6号";
//    
//    [_mapView addAnnotation:pointAnnotation];
}

#pragma mark - MAMapViewDelegate
// 设置标注样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        if (![self.otherAnnotationArray containsObject:annotation]) { // 不是周边用户
            static NSString *pointReuseIndentifier = @"currentUserReuserIndentifier";
            MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
            annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
            annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
            annotationView.pinColor = MAPinAnnotationColorRed;
            return annotationView;
        } else { // 周边用户
            NSInteger index = [self.otherAnnotationArray indexOfObject:annotation];
            UserInfoForMap *model = self.otherUserNearByArray[index];
            NSLog(@"annoTitle %@ indexTitle %@", model.userID, annotation.title);
            static NSString *pointReuseIndentifier = @"otherUserReuseIndentifier";
            MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO[自定义气泡的时候,需要设置为NO]//http://lbs.amap.com/api/ios-sdk/guide/mapkit/
            
            annotationView.image = [UIImage imageNamed:model.imageUrl];
            //设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -15);
            
            return annotationView;
        }
    }
    return nil;
    
}
// 用户位置变化时
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        self.currentUserLocation = userLocation;
        if (!_otherUserNearByArray) {// 还没有周边信息,则获取
            [self loadOtherUserNearByWithCompletionHandle:^() {
                
            }];
        }
        // 代表用户的大头针 -- 不存在则创建
        if (!_currentUserAnnotation) {
            self.currentUserAnnotation = [[MAPointAnnotation alloc] init];
            
            self.currentUserAnnotation.title = @"当前位置";
            
            [_mapView addAnnotation:self.currentUserAnnotation];
        }
        // 更新大头针坐标
        self.currentUserAnnotation.coordinate = CLLocationCoordinate2DMake(self.currentUserLocation.coordinate.latitude, self.currentUserLocation.coordinate.longitude);
        
    }
}


//// 自定义定位标注和精度圈的样式
//- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    MAAnnotationView *view = views[0];
//    
//    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
//    if ([view.annotation isKindOfClass:[MAUserLocation class]])
//    {
//        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
//        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
//        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
//        pre.image = [UIImage imageNamed:@"location.png"];
//        pre.lineWidth = 3;
//        pre.lineDashPattern = @[@6, @3];
//        
//        [self.mapView updateUserLocationRepresentation:pre];
//        
//        view.calloutOffset = CGPointMake(0, 0);
//    }
//}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"地图区域变更后");
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"地图区域即将变更");
}


#pragma mark - 更新其他用户的地图标注
- (void)updateAnnotationOfOtherUser
{
    // 移除标注
    [self.mapView removeAnnotations:self.otherAnnotationArray];
    self.otherAnnotationArray = [NSMutableArray array]; // 清空其中的annotation

    
    for (UserInfoForMap *model in self.otherUserNearByArray) {
     // 大头针标注
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
        pointAnnotation.title = model.userID;
        pointAnnotation.subtitle = nil;
        [self.otherAnnotationArray addObject:pointAnnotation];
    }
    // 把周边用户的标注添加到地图上[一个个添加到地图上,每添加一次就执行一轮viewFor标注.]
    if (_otherAnnotationArray.count > 0) {
        [_mapView addAnnotations:self.otherAnnotationArray];
    }

    // 刷新标注视图
    [self.mapView reloadInputViews];
}

#pragma mark - 网络请求
#pragma mark 获取周边用户信息列表
- (void)loadOtherUserNearByWithCompletionHandle:(void (^)())completionHandle
{
    /*
    [[NetHelper shareNetHelper] getDataWithUrlString:nil completionHandle:^(NSData *data) {
        
    }];*/
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        int dLa = (arc4random() % 50 - 25);
        int dLo = (arc4random() % 50 - 25);
        double dLatitude = dLa / (double)5000.0;
        double dLongitude = dLo / (double)5000.0;
        UserInfoForMap *model = [UserInfoForMap new];
        model.userID = [NSString stringWithFormat:@"用户%2d", i];
        model.imageUrl = @"userIcon";
        model.latitude = self.currentUserLocation.coordinate.latitude + dLatitude;
        model.longitude = self.currentUserLocation.coordinate.longitude + dLongitude;
        [array addObject:model];
    }
    //
    self.otherUserNearByArray = array;
    // 更新其他用户的地图标注
    [self updateAnnotationOfOtherUser];
    
    if (completionHandle) {
        completionHandle();
    }
    
}
- (IBAction)locationSwitchValueChanged:(UISwitch *)sender {
}
- (IBAction)locationButtonAction:(UIButton *)sender {
    [_mapView showAnnotations:@[self.currentUserAnnotation] animated:YES];
    [self loadOtherUserNearByWithCompletionHandle:^{
        // 定位结束[周边用户信息加载,显示结束]
    }];
}
@end
