//
//  MainTabBarViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "DynamicViewController.h"
#import "IssueViewController.h"
#import "MapViewController.h"
#import "MineViewController.h"
#import "ChatListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "RCDLoginInfo.h"
#import "MapSearchHelper.h"
#import <AMapSearchKit/AMapSearchKit.h>
//#import "RCDChatListViewController.h"


@interface MainTabBarViewController ()<UITabBarControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager  *locationManager;

@property (nonatomic, strong) NSArray *itemClasses;

@property (nonatomic, strong) NSArray *itemTitle;

@property (nonatomic, strong) NSArray *itemImagesName;

@property (nonatomic, strong) NSArray *itemNeedNav;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;
    }else {
        SHOWERROR(@"无法开启定位,请确认是否开启定位功能");
        //提示用户无法进行定位操作
    }
    [self.locationManager requestAlwaysAuthorization];//添加这句
    [self.locationManager requestLocation];
    // 开始定位
    [self.locationManager startUpdatingLocation];
    
    
    [[UINavigationBar appearance] setBarTintColor:kNavBgColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    self.delegate = self;
    
    self.tabBar.translucent = NO;
    self.itemClasses = @[@"DynamicViewController", @"MapViewController", @"ChatListViewController", @"MineViewController"];
    self.itemTitle = @[@"动态", @"地图", @"消息", @"我的"];
    self.itemNeedNav = @[@(YES), @(NO), @(YES), @(YES)];
    self.itemImagesName = @[@"dynamic", @"mapTab", @"message", @"mine"];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (int i = 0; i < self.itemClasses.count; i++) {
        NSString *classes = self.itemClasses[i];
        NSString *title = self.itemTitle[i];
        NSString *imageName = self.itemImagesName[i];
        BOOL needNav = [self.itemNeedNav[i] boolValue];
        
        UIViewController *vc = [((UIViewController *)[NSClassFromString(classes) alloc]) initWithNibName:classes bundle:nil];
        
        if (needNav) {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
            navigationController.tabBarItem.title = title;
            navigationController.tabBarItem.image = [UIImage imageNamed:imageName];
            [viewControllers addObject:navigationController];
        } else {
            vc.tabBarItem.title = title;
            vc.tabBarItem.image = [UIImage imageNamed:imageName];
            [viewControllers addObject:vc];
        }
        
    }
    
    
    self.viewControllers = viewControllers;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedViewController == viewController) { // 重复点击
        return YES;
    }
    if (tabBarController.viewControllers.lastObject == viewController) { // 选中的是我的
        UINavigationController *mineNav = (UINavigationController *)viewController;
        MineViewController *mineVC = mineNav.viewControllers.firstObject;
        NSInteger index = tabBarController.selectedIndex;
        
        mineVC.preIndex = index;
    }
    return YES;
}

#pragma mark - 实时同步位置

#ifdef IS_IOS6_OR_ABOVE
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    
    if ([[RCDLoginInfo shareLoginInfo] longitude] == coor.longitude && [[RCDLoginInfo shareLoginInfo] latitude] == coor.latitude) {
        return;
    }
    [[RCDLoginInfo shareLoginInfo] setLongitude:coor.longitude];
    [[RCDLoginInfo shareLoginInfo] setLatitude:coor.latitude];
     [AFHttpTool updateLocationWithLongitude:coor.longitude latitude:coor.latitude success:^(id response) {
         NSLog(@"%@", @"位置更新成功");
     } failure:^(NSError *err) {
         
     }];
    
    [[MapSearchHelper shareMapSearchHelper] poiAroundSearchWithLatitude:coor.latitude longitude:coor.longitude completionHandle:^(AMapPOISearchResponse *response) {
        AMapPOI *poi = response.pois.firstObject;
        [[RCDLoginInfo shareLoginInfo] setAddressName:poi.name];
    }];
    
    //
    
    
    
}

#else
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [AFHttpTool updateLocationWithLongitude:coor.longitude latitude:coor.latitude success:^(id response) {
        NSLog(@"%@", @"位置更新成功");
    } failure:^(NSError *err) {
        
    }];
    
}

#endif

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        SHOWERROR(@"%@", error.localizedDescription);
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

@end
