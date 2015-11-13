//
//  SearchDynamicViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/11/13.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "SearchDynamicViewController.h"
#import "CateViewController.h"
#import "MJRefresh.h"
@interface SearchDynamicViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dynamicTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *categoryDynamicButton;
@property (nonatomic, strong) NSMutableArray *searchDynamicArray;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation SearchDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#warning tableView注册cell
    [self.dynamicTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.currentPage = 0;
    [self refreshHeaderFooer];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 退出
- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 跳转分类选择
- (IBAction)showCategoryVC:(UIButton *)sender {
    CateViewController *cate = [[CateViewController alloc] initWithNibName:@"CateViewController" bundle:nil];
    __weak typeof(self) weakSelf=self;
    cate.cateCurrent = ^(NSString *cate_name, NSInteger ID){
        if (ID < 0) {
            return ;
        }
        weakSelf.infoLabel.text = @"暂无数据";
        [weakSelf.categoryDynamicButton setTitle:cate_name forState:UIControlStateNormal];
        weakSelf.categoryDynamicButton.tag = ID;
        [weakSelf loadDataWithCategory_id:ID keyword:weakSelf.searchBar.text completionHandle:^(BOOL success) {
            
            [weakSelf doByLoadDataResult:success];
        }];
    };
    [self presentViewController:cate animated:YES completion:nil];
}

- (void)doByLoadDataResult:(BOOL)success
{
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [KVNProgress dismiss];
            [self.dynamicTableView reloadData];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [KVNProgress showErrorWithStatus:@"网络故障,请重试"];
        });
    }
}

#pragma mark - 上拉下载
- (void)refreshHeaderFooer
{
    __weak typeof(self) weakSelf = self;
    // 下拉刷新
    self.dynamicTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        weakSelf.currentPage = 0;
        [weakSelf loadDataWithCategory_id:self.categoryDynamicButton.tag keyword:self.searchBar.text completionHandle:^(BOOL success) {
            [weakSelf doByLoadDataResult:success];

        }];
    }];
    
    
    // 上拉刷新
    self.dynamicTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.currentPage++;
        [weakSelf loadDataWithCategory_id:self.categoryDynamicButton.tag keyword:self.searchBar.text completionHandle:^(BOOL success) {
            [weakSelf doByLoadDataResult:success];
            
        }];
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // XIB中,分类按钮tag初始为0
    if (self.categoryDynamicButton.tag < 0) {
        return;
    }
    
    
    self.currentPage = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadDataWithCategory_id:self.categoryDynamicButton.tag keyword:searchText completionHandle:^(BOOL success){
       [weakSelf doByLoadDataResult:success];
        
    }];
}

- (void)loadDataWithCategory_id:(NSInteger)category_id
                 keyword:(NSString *)keyword
               completionHandle:(void (^)(BOOL success))completionHandle
{
    // 判断searchBar的text是否为空,为空则清除数据,隐藏tableView
    //                           有值则显示,并请求数据
    if ([keyword length] > 0) {
        self.dynamicTableView.hidden = NO;
    } else {
        self.searchDynamicArray = nil;
        [self.dynamicTableView reloadData];
        self.dynamicTableView.hidden = YES;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [AFHttpTool searchDynamicWithPage:self.currentPage limit:20 category_id:category_id keyword:keyword success:^(id response) {
        if (weakSelf.currentPage == 0) {
            weakSelf.searchDynamicArray = [NSMutableArray array];
        }
#warning 遍历结果,直接append到searchDynamicArray中 ★只需要给tableView填充值即可,刷新tableView已经在block中做了,
        
        if (completionHandle) {
            completionHandle(YES);
        }
    } failure:^(NSError *err) {
        if (completionHandle) {
            completionHandle(NO);
        }
    }];
}

#warning tableView代理
#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchDynamicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
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
