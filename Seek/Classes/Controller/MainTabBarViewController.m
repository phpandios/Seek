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
#import "MessageViewController.h"


@interface MainTabBarViewController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) NSArray *itemClasses;

@property (nonatomic, strong) NSArray *itemTitle;

@property (nonatomic, strong) NSArray *itemImagesName;

@property (nonatomic, strong) NSArray *itemNeedNav;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KVNProgress show];
    [[Common shareCommon] getTokenWithUser:kCurrentUser completionHandle:^(BOOL isSucess) {
        if (isSucess) {
            [[RCIM sharedRCIM] connectWithToken:kCurrentToken success:^(NSString *userId) {
                SBLog(@"连接服务器成功 TOKEN -- %@", kCurrentToken);
            } error:^(RCConnectErrorCode status) {
                SHOWERROR(@"连接服务器失败,暂时无法使用聊天功能!");
            } tokenIncorrect:^{
                SHOWERROR(@"TOKEN失效,暂时无法使用聊天功能,请联系客服解决!");
            }];
        }
        [KVNProgress dismiss];
    }];
    
    self.delegate = self;
    
    self.tabBar.translucent = NO;
    self.itemClasses = @[@"DynamicViewController", @"MapViewController", @"MessageViewController", @"MineViewController"];
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
            navigationController.navigationBar.translucent = NO;
            // item的颜色
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            // 背景颜色
            navigationController.navigationBar.barTintColor = kNavBgColor;
            // title的颜色
            navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
