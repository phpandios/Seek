//
//  DynamicViewController.m
//  Seek
//
//  Created by apple on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//
#define dynamicList @"dynamic"
#define dynamicRecommend @"recommend_dynamic"
#define kCateList @"http://www.seek-sb.cn/seek.php/category_list?parent_id=0"

#import "DynamicViewController.h"
#import "KnowPersonCell.h"
#import "OnePhotoCell.h"
#import "PulishCell.h"
#import "towPhotoCell.h"
#import "ThreePhotoCell.h"
#import "NoPhotoCell.h"
#import "FourPhotoViewCell.h"

#import "DynamicDetailViewController.h"
#import "AddFriendViewController.h"
#import "Dynamic.h"
#import "Comment.h"

#import "MJRefresh.h"
#import "NSString+textHeightAndWidth.h"
#import "IssueViewController.h"
#import "RCDLoginInfo.h"
#import "NoMessage.h"

#import "MAPPOISearchViewController.h"
#import "SearchDynamicViewController.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "DynamicView.h"
#import "Dynamic_category.h"
@interface DynamicViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate,UMSocialUIDelegate,UITableViewDataSource,UITableViewDelegate>
{
     MBProgressHUD *HUD;
    UMSocialBar *_socialBar;
}

@property (nonatomic, retain)NSMutableArray *dynamicArr;
@property (nonatomic, retain)Dynamic *dynamicObj;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) UIView *noMessage;

@property (nonatomic, retain) DynamicView *dynamicView;

@property (nonatomic, retain) NSArray *cateArr;
@end
static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"threeCell";
static NSString *pulishIdentifier = @"pulishCell";
static NSString *noPhotolIdentifier = @"noCell";
static NSString *fourPhotolIdentifier = @"fourCell";
@implementation DynamicViewController
/**
 *  加载视图
 */
- (void)loadView
{
    self.cateArr= [self loadCateGory];
    self.dynamicView = [[DynamicView alloc] initWithFrame:[UIScreen mainScreen].bounds cateArr:_cateArr];
    self.view = _dynamicView;
}

- (NSArray *)cateArr
{
    if (_cateArr == nil) {
        self.cateArr = [NSArray new];
    }
    return _cateArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"动态";
    self.dynamicView.tableView.delegate = self;
    self.dynamicView.tableView.dataSource = self;
    
    
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"OnePhotoCell" bundle:nil] forCellReuseIdentifier:onePhotoIdentifier];
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"towPhotoCell" bundle:nil] forCellReuseIdentifier:twoPhotoIdentifier];
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"ThreePhotoCell" bundle:nil] forCellReuseIdentifier:threePhotoIdentifier];
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"FourPhotoViewCell" bundle:nil] forCellReuseIdentifier:fourPhotolIdentifier];
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"NoPhotoCell" bundle:nil] forCellReuseIdentifier:noPhotolIdentifier];
    [self.dynamicView.tableView registerNib:[UINib nibWithNibName:@"PulishCell" bundle:nil] forCellReuseIdentifier:pulishIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorAction:) name:@"background" object:nil];
    
    self.noMessage= [[NSBundle mainBundle] loadNibNamed:@"NoMessage" owner:nil options:nil].firstObject;
    self.dynamicView.tableView.tableFooterView = _noMessage;
    
    self.dynamicView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    self.navigationItem.rightBarButtonItems = ({
        UIBarButtonItem *issueBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(issueBarButtonItemAction:)];
        UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarButtonItemAction:)];
        @[issueBarButtonItem, searchBarButtonItem];
        
    });
    
    HUD.labelText = @"正在加载中...";
    [HUD show:YES];
    [self loadLocalDataList:^(id obj) {
        if (obj != nil) {
            //取消
            [HUD hide:YES];
        }
    }];
    if (kIsNetWork) {
        [self loadRemmondData];
        // 加载数据
        [self loadDataPage:0 limit:10 finish:^(id obj) {
            if (obj != nil) {
                //取消
                [HUD hide:YES];
            }
        }];
    }
    //上拉下载刷新
    [self refreshHeaderFooer];
    
    
  
}

- (NSArray *)loadCateGory
{
    //获取url地址内
    NSURL *url =[NSURL URLWithString:kCateList];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", dict);
    NSMutableArray *cateArr = [NSMutableArray new];
    for (int i = 0; i < [dict[@"result"] count]; i++) {
        NSLog(@"%@", dict[@"result"][i]);
        Dynamic_category *dynaCate = [Dynamic_category new];
        [dynaCate setValuesForKeysWithDictionary:dict[@"result"][i]];
        [cateArr addObject:dynaCate];
    }
    return  cateArr;
}

#pragma mark - 上拉下载
- (void)refreshHeaderFooer
{
    __weak typeof(self) weakSelf = self;
    // 下拉刷新
    self.dynamicView.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadRemmondData];
            [weakSelf.dynamicArr removeAllObjects];
            // 加载数据
            [weakSelf loadDataPage:0 limit:10 finish:^(id obj) {
                NSLog(@"%@", obj);
                if (obj != nil) {
                    weakSelf.dynamicArr = obj;
                    //取消
                    [HUD hide:YES];
                    // 结束刷新
                    [weakSelf.dynamicView.tableView.header endRefreshing];
                }
                //重新加载
                [weakSelf.dynamicView.tableView reloadData];
                // 结束刷新
                [weakSelf.dynamicView.tableView.header endRefreshing];
                
            }];
            
            
        });
    }];
    
    
    // 上拉刷新
    self.dynamicView.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            static NSInteger page = 1,offset=0,limit=10;
            offset = page * limit;
            page++;
            [weakSelf loadDataPage:offset limit:limit finish:^(id obj) {
                [weakSelf.dynamicView.tableView reloadData];
                // 结束刷新
                [weakSelf.dynamicView.tableView.footer endRefreshing];
            }];
        });
    }];
}


- (NSMutableArray *)dynamicArr
{
    if (!_dynamicArr) {
        self.dynamicArr = [NSMutableArray new];
    }
    return _dynamicArr;
}
#pragma mark -加载本地数据
- (void)loadLocalDataList:(void (^)(id obj))load
{
    self.dynamicArr=[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:dynamicList]];
    load(self.dynamicArr);
    self.dynamicObj =[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:dynamicRecommend]];
    
}

#pragma mark -请求数据
- (void)loadDataPage:(NSInteger)page
               limit:(NSInteger)limit
              finish:(void(^)(id obj))finish
{
    __weak typeof(self) weakSelf = self;
    NSInteger permission = 0, promote_state=0, state = 2;
    static NSInteger first_state = 1;
    if ([self.dynamicArr count] > 0 ) {
        //移除内容
        self.dynamicView.tableView.tableFooterView = nil;
    }
    //判断第一次加载的时候清除内容
    if (first_state == 1) {
        [self.dynamicArr removeAllObjects];
    }

    [AFHttpTool getDynamicWithPage:page limit:limit permissions:permission promote_state:promote_state state:state success:^(id response) {
        if ([response[@"result"] count] == 0) {
            finish(nil);
            return;
        }
        //移除内容
        weakSelf.dynamicView.tableView.tableFooterView = nil;
        for (int i=0; i < [response[@"result"] count]; i++) {
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"][i]];
            [weakSelf.dynamicArr addObject:dynamic];
        }
        finish(weakSelf.dynamicArr);
        //判断本地缓存存在进行移除
        if ([[NSUserDefaults standardUserDefaults] objectForKey:dynamicList]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:dynamicList];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:weakSelf.dynamicArr] forKey:dynamicList];
        first_state++;
        [weakSelf.dynamicView.tableView reloadData];
    } failure:^(NSError *err) {
        weakSelf.dynamicView.tableView.tableFooterView = _noMessage;
        NSLog(@"%@", err);
    }];
}
#pragma mark -请求推荐数据
- (void)loadRemmondData
{
    NSInteger page = 0, limit = 1, permission = 3, promote_state=1, state = 2;
    __weak typeof(self) weakSelf = self;
    if (self.dynamicObj != nil) {
        //移除内容
        self.dynamicView.tableView.tableFooterView = nil;
    }
    
    [AFHttpTool getDynamicWithPage:page limit:limit permissions:permission promote_state:promote_state state:state success:^(id response) {
        if (!response) {
            return;
        }
        if ([response[@"result"] count] != 0) {
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"]];
            weakSelf.dynamicObj = dynamic;
            if ([[NSUserDefaults standardUserDefaults] objectForKey:dynamicRecommend]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:dynamicRecommend];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:dynamic] forKey:dynamicRecommend];
            [weakSelf.dynamicView.tableView reloadData];
        } else {
            weakSelf.dynamicObj = nil;
        }
       
    } failure:^(NSError *err) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)issueBarButtonItemAction:(UIBarButtonItem *)sender {
    IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)searchBarButtonItemAction:(UIBarButtonItem *)sender {
    SearchDynamicViewController *vc = [[SearchDynamicViewController alloc] initWithNibName:@"SearchDynamicViewController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark-点击编辑按钮模态发布页面
- (void)issueEditBtnAction:(UIButton *)sender
{
    IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
    __weak typeof(self) weakSelf = self;
    vc.currentIssue = ^(id obj){
        if (obj != nil) {
            // 加载数据
            [weakSelf loadDataPage:0 limit:10 finish:^(id obj) {
            }];

        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%s", __FUNCTION__);
    if (_dynamicObj != nil) {
        return [self.dynamicArr count] + 2;
    }
    return [self.dynamicArr count] + 1;
}
#pragma mark -每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 116;
    }
    if (indexPath.section == 1 && _dynamicObj != nil) {
        CGFloat height = [NSString calcWithTextHeightStr:_dynamicObj.content width:self.dynamicView.tableView.bounds.size.width font:[UIFont systemFontOfSize:18.0]];
        NSArray *arr = [_dynamicObj.images componentsSeparatedByString:@"#@#"];
        NSRange range = [_dynamicObj.images rangeOfString:@"#@#"];
        NSInteger case_num = [arr count];
    
        if(range.location ==  NSNotFound && ![_dynamicObj.images isEqualToString:@""])
        {
            case_num = 1;//如果为一张图
        }else if(range.location ==  NSNotFound && [_dynamicObj.images isEqualToString:@""]){
            case_num = 0;
        }
        switch (case_num) {
            case 0:
                return 146 + height;
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
        
    }else{
        NSInteger num1 = 0;
        if (_dynamicObj != nil) {
            num1 = indexPath.section -2;
        }else{
            num1 = indexPath.section - 1;
        }
        NSLog(@"%@", self.dynamicArr);
        Dynamic *dynamic = self.dynamicArr[num1];
        CGFloat height = [NSString calcWithTextHeightStr:dynamic.content width:self.dynamicView.tableView.bounds.size.width font:[UIFont systemFontOfSize:18.0]];
        
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
            case 0:
                return 146 + height;
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
    }
    
    return MAXFLOAT;
}
#pragma mark -显示行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
#pragma mark -cell之间的间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 && _dynamicObj != nil) {
        return 40;
    }
    return 0.01;
}
#pragma mark -头部标题
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1 && _dynamicObj != nil) {
        int wrapH = 40;
        int imageH = 30, margin = 10;
        UIView *recommdV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, wrapH)];
        recommdV.backgroundColor = [UIColor whiteColor];
        UIImage *image = [UIImage imageNamed:@"recommd"];
        UIImageView *recommdI = [[UIImageView alloc] initWithFrame:CGRectMake(margin, (wrapH-imageH)/2, imageH, imageH)];
        [recommdI setImage:image];
        UILabel *textL = [[UILabel alloc] initWithFrame:CGRectMake(wrapH + margin/2, 0, kScreenWidth - wrapH + margin/2, wrapH)];
        textL.text = @"推荐";
        [recommdV addSubview:recommdI];
        [recommdV addSubview:textL];
        return recommdV;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OnePhotoCell *oneCell = [tableView dequeueReusableCellWithIdentifier:onePhotoIdentifier];
    towPhotoCell *twoCell = [tableView dequeueReusableCellWithIdentifier:twoPhotoIdentifier];
    ThreePhotoCell *threeCell = [tableView dequeueReusableCellWithIdentifier:threePhotoIdentifier];
    NoPhotoCell *noPhotoCell = [tableView dequeueReusableCellWithIdentifier:noPhotolIdentifier];
    PulishCell *pulishCell = [tableView dequeueReusableCellWithIdentifier:pulishIdentifier];
    FourPhotoViewCell *fourCell = [tableView dequeueReusableCellWithIdentifier:fourPhotolIdentifier];
    
    if(indexPath.section == 0)
    {
        [pulishCell.edit_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.share_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.take_photo addTarget:self action:@selector(showImagePickerController:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.sign_btn addTarget:self action:@selector(signBtnAtion:) forControlEvents:UIControlEventTouchUpInside];
        NSString *loginUserPortrait = [[RCDLoginInfo shareLoginInfo] head_portrait];
        [pulishCell.head_portrait sd_setImageWithURL:[NSURL URLWithString:loginUserPortrait] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
        pulishCell.contentMode = UIViewContentModeScaleAspectFit;
        return pulishCell;
    }else if(indexPath.section == 1 && _dynamicObj != nil){
        
        NSArray *arr = [_dynamicObj.images componentsSeparatedByString:@"#@#"];
        NSRange range = [_dynamicObj.images rangeOfString:@"#@#"];
        NSInteger case_num = [arr count];
        if(range.location ==  NSNotFound && ![_dynamicObj.images isEqualToString:@""])
        {
            case_num = 1;//如果为一张图
        }else if(range.location ==  NSNotFound && [_dynamicObj.images isEqualToString:@""]){
            case_num = 0;
        }
        switch (case_num) {
            case 1:
                oneCell.dynamicObj = _dynamicObj;
                oneCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(_dynamicObj.userId), _dynamicObj.nick_name, _dynamicObj.head_portrait, nil];
                [oneCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [oneCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                oneCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                [oneCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                oneCell.share_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                return oneCell;
                break;
            case 2:
                twoCell.dynamicObj = _dynamicObj;
                twoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(_dynamicObj.userId), _dynamicObj.nick_name, _dynamicObj.head_portrait, nil];
                [twoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [twoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [twoCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                twoCell.share_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                twoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                return twoCell;
                break;
            case 3:
                threeCell.dynamicObj = _dynamicObj;
                [threeCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [threeCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [threeCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                threeCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                threeCell.share_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                return threeCell;
                break;
            case 4:
                
                fourCell.dynamicObj = _dynamicObj;
                [fourCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [fourCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [fourCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                fourCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                fourCell.share_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                return fourCell;
                break;
            default:
            
                noPhotoCell.dynamicObj = _dynamicObj;
                [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [noPhotoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [noPhotoCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                noPhotoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                noPhotoCell.share_btn.accessibilityElements = [NSArray arrayWithObject:_dynamicObj];
                return noPhotoCell;
                break;
        }
    }else
    {
        NSInteger num = 0;
        if (_dynamicObj != nil) {
            num = indexPath.section -2;
        }else{
            num = indexPath.section - 1;
        }
        Dynamic *dynamic = self.dynamicArr[num];
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
                oneCell.dynamicObj = dynamic;
                oneCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [oneCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [oneCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [oneCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                oneCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                oneCell.share_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                return oneCell;
                break;
            case 2:
                
                twoCell.dynamicObj = dynamic;
                twoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [twoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [twoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [twoCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                twoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                twoCell.share_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                return twoCell;
                break;
            case 3:
            
                threeCell.dynamicObj = dynamic;
                threeCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [threeCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [threeCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [threeCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                threeCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                threeCell.share_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                return threeCell;
                break;
            case 4:
                
                fourCell.dynamicObj = dynamic;
                fourCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [fourCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [fourCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [fourCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                fourCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                fourCell.share_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                return fourCell;
                break;
            default:
            
                noPhotoCell.dynamicObj = dynamic;
                noPhotoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [noPhotoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                [noPhotoCell.share_btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                noPhotoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                noPhotoCell.share_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
                return noPhotoCell;
                break;
        }
        
    }
    return nil;
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
     [self.navigationController pushViewController:addViewController animated:YES];
        
}

#pragma mark -分享
- (void)shareAction:(UIButton *)sender
{
    Dynamic *dynamic = sender.accessibilityElements.firstObject;
    NSArray *arr = [dynamic.images componentsSeparatedByString:@"#@#"];
    NSRange range = [dynamic.images rangeOfString:@"#@#"];
    NSString *imageUrl = nil;
    if(range.location ==  NSNotFound && ![dynamic.images isEqualToString:@""])
    {
        imageUrl = dynamic.images;
    }
    else
    {
        imageUrl = arr.firstObject;
    }
    [UMSocialWechatHandler setWXAppId:kUMWXAppID appSecret:kUMWXAppKey url:kUMUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMAppKey
                                      shareText:dynamic.content
                                     shareImage:nil
                                shareToSnsNames:@[UMShareToWechatTimeline,UMShareToWechatSession]
                                       delegate:self];
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
}

//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OnePhotoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - 点击效果
- (void)commentAction:(UIButton *)sender
{
    self.hidesBottomBarWhenPushed = YES;
    DynamicDetailViewController *vc = [[DynamicDetailViewController alloc] initWithNibName:@"DynamicDetailViewController" bundle:nil];
    vc.dnamicObj = sender.accessibilityElements[0];
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}


#pragma mark - UIImagePickerController
- (void)showImagePickerController:(UIButton *)sender{
    self.imagePickerController = [[UIImagePickerController alloc]init];
    _imagePickerController.delegate = self;
    
    // 判断支持来源类型(拍照,照片库,相册)
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL isPhotoLibrarySupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL isSavedPhotosAlbumSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"图片上传" message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (isCameraSupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //指定使用照相机模式,可以指定使用相册／照片库
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            /// 相机相关 [sourceType不设置为Camera.下面属性无法设置]
            //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
            _imagePickerController.showsCameraControls  = YES;
            //设置当拍照完或在相册选完照片后，是否跳到编辑模式进行图片剪裁。只有当showsCameraControls属性为true时才有效果
            _imagePickerController.allowsEditing = YES;
            // 支持的摄像头类型(前置 后置)
            BOOL isRearSupport = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
            if (isRearSupport) {
                //设置使用后置摄像头，可以使用前置摄像头
                _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            } else {
                _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            //设置闪光灯模式 自动
            _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            //设置相机支持的类型，拍照和录像
            _imagePickerController.mediaTypes = @[@"public.image"];// public.movie(录像)
            
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }]];
    }
    
    if (isPhotoLibrarySupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从照片库选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //指定使用照相机模式,可以指定使用相册／照片库
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }]];
    }
    
    if (isSavedPhotosAlbumSupport) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //指定使用照相机模式,可以指定使用相册／照片库
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }]];
    }
    // 取消
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    if (!(isCameraSupport || isPhotoLibrarySupport || isSavedPhotosAlbumSupport)) { // 三种都不支持
        alertController.title = @"无法找到可用图片源,请检查设备后重试";
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
   }
#pragma mark-获取图片的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage] ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
    vc.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 自定义方法
- (void)presentPOISearchViewControllerWithCompletionHandle:(void (^)(CGFloat la, CGFloat lo, NSString *address, NSString *name, BOOL hasChoose))completionHandle
{
    MAPPOISearchViewController *mapPOISearch = [[MAPPOISearchViewController alloc] initWithNibName:@"MAPPOISearchViewController" bundle:nil];
    // locationWithLatitude:39.990459 longitude:116.481476
    mapPOISearch.defaultLatitude = [[RCDLoginInfo shareLoginInfo] mapLatitude];
    mapPOISearch.defaultLongitude = [[RCDLoginInfo shareLoginInfo] mapLongitude];
    mapPOISearch.dismisBlock = completionHandle;
    [self presentViewController:mapPOISearch animated:YES completion:nil];
}

#pragma mark-签到定位
- (void)signBtnAtion:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [self presentPOISearchViewControllerWithCompletionHandle:^(CGFloat la, CGFloat lo, NSString *address, NSString *name, BOOL hasChoose) {
        if (hasChoose) {
            //将发布要调起，传进当前选中地址
            IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
            vc.isNotHave = YES;
            vc.selectedAddressDict = @{@"latitude" : @(la), @"longitude" : @(lo), @"address" : address, @"name" : name};
            [weakSelf presentViewController:vc animated:YES completion:nil];
    
        } else {
            //                weakSelf.selectedAddressDict = nil;
        }
    }];
}

#pragma mark 改变颜色
- (void)colorAction:(NSNotification *)sender
{
    NSDictionary *userInfo = sender.userInfo;
    self.dynamicView.tableView.backgroundColor = userInfo[@"tableBacgroud"];
    [self.dynamicView.tableView reloadData];
    NSLog(@"%@", sender);
}
@end
