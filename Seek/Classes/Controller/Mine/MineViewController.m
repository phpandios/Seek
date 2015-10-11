//
//  MineViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "MineViewController.h"
#import "LoginViewController.h"
#import "UserHeaderTableViewCell.h"
#import "UserLogoutTableViewCell.h"
@interface MineViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *canSelectedArray; // 标识允许选中的项

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    
    self.canSelectedArray = @[@[@(NO)], @[@(YES), @(YES)], @[@(YES), @(YES), @(YES)], @[@(YES), @(YES)], @[@(NO)]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"headerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserLogoutTableViewCell" bundle:nil] forCellReuseIdentifier:@"logoutCell"];
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
    [self.tableView reloadData];
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


#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // 头像
            return 1;
        case 1: // 关注,粉丝
            return 2;
        case 2: // 昵称,手机,性别
            return 3;
        case 3: // 修改密码,意见反馈
            return 2;
        case 4: // 退出登陆
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
        [((UserHeaderTableViewCell *)cell).headerImageView sd_setImageWithURL:[NSURL URLWithString:kCurrentUser.iconUrl] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
        ((UserHeaderTableViewCell *)cell).userNameLabel.text = kCurrentUser.userName;
        

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"normalCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"我的关注";
                    break;
                case 1:
                    cell.textLabel.text = @"我的粉丝";
                    break;
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"昵称";
                    cell.detailTextLabel.text = kCurrentUser.userName;
                    break;
                case 1:
                    cell.textLabel.text = @"手机";
                    if ([[kCurrentUser telPhone] length] == 0) { // 没绑定手机
                        cell.detailTextLabel.text = @"点击绑定手机";
                    } else {
                        cell.detailTextLabel.text = kCurrentUser.telPhone;
                    }
                    break;
                case 2:
                    cell.textLabel.text = @"性别";
                    cell.detailTextLabel.text = kCurrentUser.gender;
                    break;
            }
        } else if (indexPath.section == 3){
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"修改密码";
                    break;
                case 1:
                    cell.textLabel.text = @"意见反馈";
                    break;
            }
        } else {
            cell = (UserLogoutTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"logoutCell" forIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            ((UserLogoutTableViewCell *)cell).buttonClickBlock = ^(){
                [[Common shareCommon] logout];
                [weakSelf presentLoginVC];
            };
        }
    }
    // 设置选中无反应
    if ([self.canSelectedArray[indexPath.section][indexPath.row] boolValue]) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 20;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120;
    } else if (indexPath.section == 4) {
        return 60;
    }
    return 60;
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
