//
//  MapViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
@interface MapViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置key
    [MAMapServices sharedServices].apiKey = kLBSAppKey;
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    // 开启定位
    _mapView.showsUserLocation = YES;
    // 定位用户位置的模式
    _mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;//追踪用户的location与heading更新
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
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
    pointAnnotation.title = @"方恒国际";
    pointAnnotation.subtitle = @"阜通东大街6号";
    
    [_mapView addAnnotation:pointAnnotation];
}

#pragma mark - MAMapViewDelegate
// 设置标注样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO[自定义气泡的时候,需要设置为NO]//http://lbs.amap.com/api/ios-sdk/guide/mapkit/
        //        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        //        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        
        //        annotationView.pinColor = MAPinAnnotationColorPurple;
        
        annotationView.image = [UIImage imageNamed:@"mapPoint.png"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -20);
        
        return annotationView;
    }
    return nil;
    
}
// 用户位置变化时
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        // 大头针标注
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        pointAnnotation.title = @"当前位置";
        
        [_mapView addAnnotation:pointAnnotation];
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}
// 自定义定位标注和精度圈的样式
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        pre.image = [UIImage imageNamed:@"location.png"];
        pre.lineWidth = 3;
        pre.lineDashPattern = @[@6, @3];
        
        [self.mapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"地图区域变更后");
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"地图区域即将变更");
}
@end
