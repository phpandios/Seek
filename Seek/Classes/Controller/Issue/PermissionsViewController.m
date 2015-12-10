//
//  PermissionsViewController.m
//  Seek
//
//  Created by apple on 15/10/29.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#define cellH 67

#import "PermissionsViewController.h"
@interface PermissionsViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)exitAction:(UIButton *)sender;
- (IBAction)completeAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *permissionsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionH;
@property (nonatomic , retain) NSArray *permissionTitle;
@property (nonatomic, retain)NSIndexPath *lastIndexPath;
@end

@implementation PermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.permissionsTable.delegate = self;
    self.permissionsTable.dataSource = self;
    self.permissionTitle = @[
                             @[@"私有", @"朋友圈", @"公开"],
                             @[@"仅自己可见", @"关注可见", @"所有人都能看见"]
                             ];
    [self.permissionsTable removeConstraint:_permissionH];
      [self.permissionsTable addConstraint:  [NSLayoutConstraint constraintWithItem:self.permissionsTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self.permissionTitle[0] count]*cellH]];
    
}

- (NSArray *)permissionTitle
{
    if(!_permissionTitle)
    {
        _permissionTitle = [NSArray new];
    }
    return _permissionTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark -每个分组的条数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.permissionTitle[0] count];
}
#pragma mark -每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellH;
}
#pragma mark -数组源
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    cell.textLabel.text = self.permissionTitle[0][indexPath.row];
    cell.detailTextLabel.text = self.permissionTitle[1][indexPath.row];
    return cell;
}
#pragma mark -选中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath != _lastIndexPath)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        _lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -退出
- (IBAction)exitAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)completeAction:(UIButton *)sender {
    int currentN = (int)[_lastIndexPath row];
    if (_currentPermission) {
        _currentPermission(currentN, self.permissionTitle[0][currentN], self.permissionTitle[1][currentN]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
