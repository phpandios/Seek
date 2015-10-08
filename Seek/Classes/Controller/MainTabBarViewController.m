//
//  MainTabBarViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "ChatViewController.h"
#import "DynamicViewController.h"
#import "IssueViewController.h"
#import "MapViewController.h"
#import "MineViewController.h"



@interface MainTabBarViewController ()

@property (nonatomic, strong) NSArray *itemClasses;

@property (nonatomic, strong) NSArray *itemTitle;

@property (nonatomic, strong) NSArray *itemImagesName;

@property (nonatomic, strong) NSArray *itemNeedNav;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemClasses = @[@"DynamicViewController", @"MapViewController", @"ChatViewController", @"IssueViewController", @"MineViewController"];
    self.itemTitle = @[@"动态", @"地图", @"聊天", @"发布", @"我的"];
    self.itemNeedNav = @[@(YES), @(YES), @(YES), @(YES), @(YES)];
    self.itemImagesName = @[@"", @"", @"", @"", @""];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
