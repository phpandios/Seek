//
//  IssueViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "IssueViewController.h"
#import "WFFDropdownList.h"

#import "MAPPOISearchViewController.h"
@interface IssueViewController ()<WFFDropdownListDelegate>
@property (weak, nonatomic) IBOutlet WFFDropdownList *categoryDropList;
@property (nonatomic, strong) NSArray *categoryArray;

- (IBAction)commitButtonAction:(UIButton *)sender;
- (IBAction)dismisButtonAction:(UIButton *)sender;

@property (nonatomic, copy) NSString *selectedCategory;
@end

@implementation IssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布";
    
    self.categoryArray = @[@"分类1", @"分类2", @"分类3", @"分类4", @"分类5"];
    self.selectedCategory = self.categoryArray.firstObject;
    
    // 分类下拉列表
    _categoryDropList.dataArray = self.categoryArray;
    _categoryDropList.delegate = self;
    _categoryDropList.textColor = [UIColor whiteColor];
    _categoryDropList.selectedIndex = 0;
    [_categoryDropList setListBackColor:kNavBgColor];
    [_categoryDropList setListTextColor:[UIColor whiteColor]];
    _categoryDropList.font = [UIFont systemFontOfSize:17];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_categoryDropList layoutIfNeeded];
    [_categoryDropList updateSubViews];
}

#pragma mark - WFFDropdownListDelegate
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    self.selectedCategory = self.categoryArray[selectedIndex];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)commitButtonAction:(UIButton *)sender {
    MAPPOISearchViewController *mapPOISearch = [[MAPPOISearchViewController alloc] initWithNibName:@"MAPPOISearchViewController" bundle:nil];
    // locationWithLatitude:39.990459 longitude:116.481476
    mapPOISearch.defaultLatitude = 39.990459;
    mapPOISearch.defaultLongitude = 116.481476;
    mapPOISearch.dismisBlock = ^(CGFloat la, CGFloat lo, NSString *address, NSString *name, BOOL hasChoose) {
        if (hasChoose) {
            SHOWMESSAGE(@"选中经纬度%.2f,%.2f的地址%@,名称%@", la, lo, address, name);
        } else {
            SHOWMESSAGE(@"未选中地址");
        }
    };
    [self presentViewController:mapPOISearch animated:YES completion:nil];
}
- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
