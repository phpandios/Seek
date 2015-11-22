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

#import "OnePhotoCell.h"
#import "towPhotoCell.h"
#import "ThreePhotoCell.h"
#import "NoPhotoCell.h"
#import "FourPhotoViewCell.h"
#import "Dynamic.h"
#import "NSString+textHeightAndWidth.h"
#import "DynamicDetailViewController.h"
#import "AddFriendViewController.h"
#import "OtherDynamicViewController.h"
@interface SearchDynamicViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dynamicTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *categoryDynamicButton;
@property (nonatomic, strong) NSMutableArray *searchDynamicArray;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, assign) NSInteger currentPage;
@end

static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"threeCell";
static NSString *noPhotolIdentifier = @"noCell";
static NSString *fourPhotolIdentifier = @"fourCell";

@implementation SearchDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#warning tableView注册cell
    
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"OnePhotoCell" bundle:nil] forCellReuseIdentifier:onePhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"towPhotoCell" bundle:nil] forCellReuseIdentifier:twoPhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"ThreePhotoCell" bundle:nil] forCellReuseIdentifier:threePhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"FourPhotoViewCell" bundle:nil] forCellReuseIdentifier:fourPhotolIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"NoPhotoCell" bundle:nil] forCellReuseIdentifier:noPhotolIdentifier];
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
        if([response[@"result"] count] == 0)
        {
            return;
        }
        NSLog(@"%@", response);
#warning 遍历结果,直接append到searchDynamicArray中 ★只需要给tableView填充值即可,刷新tableView已经在block中做了,
        for (int i = 0 ; i < [response[@"result"] count]; i++) {
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"][i]];
            [weakSelf.searchDynamicArray addObject:dynamic];
        }
        
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
    return self.searchDynamicArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark -每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dynamic *dyamic = self.searchDynamicArray[indexPath.section];
    CGFloat height = [NSString calcWithTextHeightStr:dyamic.content width:self.dynamicTableView.bounds.size.width font:[UIFont systemFontOfSize:18.0]];
    NSArray *arr = [dyamic.images componentsSeparatedByString:@"#@#"];
    NSRange range = [dyamic.images rangeOfString:@"#@#"];
    NSInteger case_num = [arr count];
    
    if(range.location ==  NSNotFound && ![dyamic.images isEqualToString:@""])
    {
        case_num = 1;//如果为一张图
    }else if(range.location ==  NSNotFound && [dyamic.images isEqualToString:@""]){
        case_num = 0;
    }
    switch (case_num) {
        case 0:
            return 136 + height;
            break;
        case 3:
            return 507 + height;
            break;
        case 4:
            return 436 + height;
            break;
        default:
            return 352 + height;
            break;
    }
    return MAXFLOAT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnePhotoCell *oneCell = [tableView dequeueReusableCellWithIdentifier:onePhotoIdentifier];
    towPhotoCell *twoCell = [tableView dequeueReusableCellWithIdentifier:twoPhotoIdentifier];
    ThreePhotoCell *threeCell = [tableView dequeueReusableCellWithIdentifier:threePhotoIdentifier];
    NoPhotoCell *noPhotoCell = [tableView dequeueReusableCellWithIdentifier:noPhotolIdentifier];
    FourPhotoViewCell *fourCell = [tableView dequeueReusableCellWithIdentifier:fourPhotolIdentifier];
    
    Dynamic *dynamic = self.searchDynamicArray[indexPath.section];
    NSArray *arr = [dynamic.images componentsSeparatedByString:@"#@#"];
    NSRange range = [dynamic.images rangeOfString:@"#@#"];
    NSInteger case_num = [arr count];
    if(range.location ==  NSNotFound && ![dynamic.images isEqualToString:@""])
    {
        case_num = 1;//如果为一张图
    }else if(range.location ==  NSNotFound && [dynamic.images isEqualToString:@""]){
        case_num = 0;
    }
    switch (case_num) {
        case 1:
            if(!oneCell)
            {
                oneCell = [[NSBundle mainBundle] loadNibNamed:@"OnePhotoCell" owner:nil options:nil].firstObject;
            }
            oneCell.dynamicObj = dynamic;
            oneCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
            [oneCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
            [oneCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
            oneCell.comments_btn.tag = dynamic.userId;
            return oneCell;
            break;
        case 2:
            if(!twoCell)
            {
                twoCell = [[NSBundle mainBundle] loadNibNamed:@"towPhotoCell" owner:nil options:nil].firstObject;
            }
            twoCell.dynamicObj = dynamic;
            twoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
            [twoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
            [twoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
            twoCell.comments_btn.tag = dynamic.userId;
            return twoCell;
            break;
        case 3:
            if(!threeCell)
            {
                threeCell = [[NSBundle mainBundle] loadNibNamed:@"ThreePhotoCell" owner:nil options:nil].firstObject;
            }
            threeCell.dynamicObj = dynamic;
            threeCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
            [threeCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
            [threeCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
            threeCell.comments_btn.tag = dynamic.userId;
            return threeCell;
            break;
        case 4:
            if(!fourCell)
            {
                fourCell = [[NSBundle mainBundle] loadNibNamed:@"FourPhotoViewCell" owner:nil options:nil].firstObject;
            }
            fourCell.dynamicObj = dynamic;
            fourCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
            [fourCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
            [fourCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
            fourCell.comments_btn.tag = dynamic.userId;
            return fourCell;
            break;
        default:
            if(!noPhotoCell)
            {
                noPhotoCell = [[NSBundle mainBundle] loadNibNamed:@"NoPhotoCell" owner:nil options:nil].firstObject;
            }
            noPhotoCell.dynamicObj = dynamic;
            noPhotoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
            [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
            [noPhotoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
            noPhotoCell.comments_btn.tag = dynamic.userId;
            return noPhotoCell;
            break;
    }

    return [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
}

#pragma mark -关注
- (void)attentionAction:(UIButton *)sender
{
    NSArray *userArr = sender.accessibilityElements;
    
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = userArr[0];
    userInfo.name = userArr[1];
    userInfo.portraitUri = userArr[2];
    
    AddFriendViewController *addViewController = [[AddFriendViewController
                                                   alloc] initWithNibName:@"AddFriendViewController" bundle:nil];
    addViewController.targetUserInfo = userInfo;
    [self presentViewController:addViewController animated:YES completion:nil];
//    [self.navigationController pushViewController:addViewController animated:YES];
    
}

#pragma mark - 点击效果
- (void)commentAction:(UIButton *)sender
{
    self.hidesBottomBarWhenPushed = YES;
    OtherDynamicViewController *otherDynamic = [OtherDynamicViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:otherDynamic];
    otherDynamic.userID = [NSString stringWithFormat:@"%ld", sender.tag];
    [self presentViewController:nav animated:YES completion:nil];
    self.hidesBottomBarWhenPushed = NO;
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
