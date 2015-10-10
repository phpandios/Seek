//
//  MineViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"
@interface MineViewController ()

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![Common shareCommon].loginUser) { // 没登陆
        [self presentLoginVC];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logoutBarButtonItemAction:)];
    }
}

// 到该方法.说明已经登陆了.设置界面的值
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //
    [self loadUserDataCompletionHandle:nil];
}

#pragma mark - 根据当前登陆用户获取用户信息
- (void)loadUserDataCompletionHandle:(void(^)())completionHandle
{
    // 获取用户信息后,
    [self updateUI];
}

#pragma mark 根据获取的用户信息更新界面
- (void)updateUI
{
    
}

#pragma mark - 弹出登陆
- (void)presentLoginVC
{
    __weak typeof(self) weakSelf = self;
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginVC.dismisBlock = ^(){
        if ([Common shareCommon].loginUser) { // 已经登陆
            
        } else { // 登陆失败
            UITabBarController *tab = (UITabBarController *)weakSelf.navigationController.parentViewController;
            tab.selectedIndex = weakSelf.preIndex;
        }
    };
    [self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark - 导航栏点击
- (void)logoutBarButtonItemAction:(UIBarButtonItem *)sender {
    [[Common shareCommon] logout];
    [self presentLoginVC];
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
