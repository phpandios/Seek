//
//  IssueViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

//动态发布屏蔽敏感词
#define Sensitive_words @""

#import "IssueViewController.h"
#import "WFFDropdownList.h"
#import "AutoHeightTextView.h"
#import "MAPPOISearchViewController.h"
#import "PermissionsViewController.h"
#import "AFHttpTool.h"
@interface IssueViewController ()<WFFDropdownListDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet WFFDropdownList *categoryDropList;
@property (nonatomic, strong) NSArray *categoryArray;

- (IBAction)commitButtonAction:(UIButton *)sender;
- (IBAction)dismisButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet AutoHeightTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *permissionButton;
- (IBAction)permissionButtonAction:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, copy) NSString *selectedCategory;

@property (nonatomic, strong) NSDictionary *selectedAddressDict;// 键值对,latitude, longitude, address, name
@property (nonatomic, retain) NSMutableDictionary *currentPermission;
@property (weak, nonatomic) IBOutlet UIButton *perssionName;
@property (weak, nonatomic) IBOutlet UILabel *perssionDecrip;

@end

@implementation IssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布";
    //赋初值
    _titleTextField.text = nil;
    _contentTextView.text = nil;
    
    [self.imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.imagesArray = [NSMutableArray arrayWithObject:[UIImage imageNamed:@"issueAddImage"]];
    
    
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
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField) {
        [self.contentTextView becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    if (textField == self.addressTextField) {
        [self presentPOISearchViewControllerWithCompletionHandle:^(CGFloat la, CGFloat lo, NSString *address, NSString *name, BOOL hasChoose) {
            if (hasChoose) {
//                SHOWMESSAGE(@"选中经纬度%.2f,%.2f的地址%@,名称%@", la, lo, address, name);
                weakSelf.selectedAddressDict = @{@"latitude" : @(la), @"longitude" : @(lo), @"address" : address, @"name" : name};
                weakSelf.addressTextField.text = name;
            } else {
//                SHOWMESSAGE(@"未选中地址");
//                weakSelf.selectedAddressDict = nil;
            }
        }];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate

#pragma mark - UICollectionViewDelegate && UICollectionViewDatasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.tag = 100;
        [cell addSubview:imageView];
    }
    imageView.image = self.imagesArray[indexPath.row];
    
    return cell;
}
#pragma mark - 自定义方法
- (void)presentPOISearchViewControllerWithCompletionHandle:(void (^)(CGFloat la, CGFloat lo, NSString *address, NSString *name, BOOL hasChoose))completionHandle
{
    MAPPOISearchViewController *mapPOISearch = [[MAPPOISearchViewController alloc] initWithNibName:@"MAPPOISearchViewController" bundle:nil];
    // locationWithLatitude:39.990459 longitude:116.481476
    mapPOISearch.defaultLatitude = 39.990459;
    mapPOISearch.defaultLongitude = 116.481476;
    mapPOISearch.dismisBlock = completionHandle;
    [self presentViewController:mapPOISearch animated:YES completion:nil];
}
#pragma mark - 按钮点击
- (IBAction)commitButtonAction:(UIButton *)sender {
    if ([_titleTextField.text isEqualToString:@""] || _titleTextField.text== nil ) {
        [KVNProgress showErrorWithStatus:@"标题不能为空"];
    }else if ([_contentTextView.text isEqualToString:@""] || _contentTextView.text== nil )
    {
        [KVNProgress showErrorWithStatus:@"内容不能为空"];
    }
    else
    {
        if ([NSString feifaSensitiveStr:_titleTextField.text]) {
            [KVNProgress showErrorWithStatus:@"标题不能出现敏感词语"];
        } else if([NSString feifaSensitiveStr:_contentTextView.text]) {
            [KVNProgress showErrorWithStatus:@"内容不能出现敏感词语"];
        } else {
            NSInteger permission = [self.currentPermission objectForKey:_perssionName.titleLabel.text] ? [[self.currentPermission objectForKey:_perssionName.titleLabel.text] intValue] : 3;
            
            [AFHttpTool publishMessage:_titleTextField.text
                               content:_contentTextView.text
                                images:@"faf"
                             longitude:[[_selectedAddressDict objectForKey:@"longitude"] floatValue]
                              latitude:[[_selectedAddressDict objectForKey:@"latitude"] floatValue]
                          locationName:[_selectedAddressDict objectForKey:@"name"]
                       locationAddress:[_selectedAddressDict objectForKey:@"address"]
                            permission:permission
                               success:^(id response)
                                    {
                                        [KVNProgress showSuccessWithStatus:@"发布成功"];
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                    }
                               failure:^(NSError *err) {
                                   [KVNProgress showErrorWithStatus:@"发布失败请重新发布"];
            }];
        }
    }
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableDictionary *)currentPermission
{
    if (_currentPermission) {
        self.currentPermission = [NSMutableDictionary new];
    }
    return _currentPermission;
}

- (IBAction)permissionButtonAction:(UIButton *)sender {
    PermissionsViewController *permission = [PermissionsViewController new];
    __weak typeof(self) weakSelf = self;
    permission.currentPermission = ^(int currentNum, id currentName, id currentDescrip){
        weakSelf.perssionName.titleLabel.text = currentName;
        weakSelf.perssionDecrip.text = currentDescrip;
        [weakSelf.currentPermission setObject:[NSNumber numberWithInt:currentNum] forKey:currentName];
    };
    [self presentViewController:permission animated:YES completion:nil];
}


@end
