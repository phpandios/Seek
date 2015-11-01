//
//  DynamicViewController.m
//  Seek
//
//  Created by apple on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "DynamicViewController.h"
#import "KnowPersonCell.h"
#import "OnePhotoCell.h"
#import "PulishCell.h"
#import "towPhotoCell.h"
#import "ThreePhotoCell.h"
#import "NoPhotoCell.h"

#import "DynamicDetailViewController.h"
#import "AddFriendViewController.h"
#import "Dynamic.h"
#import "Comment.h"

#import "NSString+textHeightAndWidth.h"
#import "IssueViewController.h"
@interface DynamicViewController ()
@property (nonatomic, retain)NSMutableArray *dynamicArr;
@property (nonatomic, retain)Dynamic *dynamicObj;
@end
static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"twoCell";
static NSString *pulishIdentifier = @"pulishCell";
static NSString *noPhotolIdentifier = @"noCell";
@implementation DynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"动态";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(issueBarButtonItemAction:)];
    
    [self loadRemmondData];
    // 加载数据
    [self loadData];
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSMutableArray *)dynamicArr
{
    if (!_dynamicArr) {
        self.dynamicArr = [NSMutableArray new];
    }
    return _dynamicArr;
}
#pragma mark -请求数据
- (void)loadData
{
    NSInteger page = 0, limit = 10, permission = 3, promote_state=0, state = 2;
    __weak typeof(self) weakSelf = self;
    [AFHttpTool getDynamicWithPage:page limit:limit permissions:permission promote_state:promote_state state:state success:^(id response) {
        if ([response[@"result"] count] == 0) {
            return;
        }
        for (int i=0; i < [response[@"result"] count]; i++) {
            NSLog(@"%@", response[@"result"][i]);
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"][i]];
            [weakSelf.dynamicArr addObject:dynamic];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.dynamicArr] forKey:@"dynamic"];
        [self.tableView reloadData];
    } failure:^(NSError *err) {
        
    }];
}
#pragma mark -请求推荐数据
- (void)loadRemmondData
{
    NSInteger page = 0, limit = 1, permission = 3, promote_state=1, state = 2;
    __weak typeof(self) weakSelf = self;
    [AFHttpTool getDynamicWithPage:page limit:limit permissions:permission promote_state:promote_state state:state success:^(id response) {
        if (!response) {
            return;
        }
        if ([response[@"result"] count] != 0) {
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"]];
            weakSelf.dynamicObj = dynamic;
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:dynamic] forKey:@"recommend_dynamic"];
            [self.tableView reloadData];
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
#pragma mark-点击编辑按钮模态发布页面
- (void)issueEditBtnAction:(UIButton *)sender
{
    IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
        CGFloat height = [NSString calcWithTextHeightStr:_dynamicObj.content width:kScreenWidth font:[UIFont systemFontOfSize:17.0]];
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
                return 136 + height;
                break;
            case 3:
                return 507 + height;
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
        Dynamic *dynamic = self.dynamicArr[num1];
        CGFloat height = [NSString calcWithTextHeightStr:dynamic.content width:self.tableView.bounds.size.width font:[UIFont systemFontOfSize:18.0]];
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
                NSLog(@"%f", 136 + height);
                return 136 + height;
                break;
            case 3:
                NSLog(@"%f", 507 + height);
                return 507 + height;
                break;
            default:
                NSLog(@"%f", 352 + height);
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
    if(indexPath.section == 0)
    {
        if(!pulishCell)
        {
            pulishCell = [[NSBundle mainBundle] loadNibNamed:@"PulishCell" owner:nil options:nil].firstObject;
        }
        [pulishCell.edit_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.share_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
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
                if(!oneCell)
                {
                    oneCell = [[NSBundle mainBundle] loadNibNamed:@"OnePhotoCell" owner:nil options:nil].firstObject;
                }
                oneCell.dynamicObj = _dynamicObj;
                oneCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(_dynamicObj.userId), _dynamicObj.nick_name, _dynamicObj.head_portrait, nil];
                [oneCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                
                return oneCell;
                break;
            case 2:
                if(!twoCell)
                {
                    twoCell = [[NSBundle mainBundle] loadNibNamed:@"towPhotoCell" owner:nil options:nil].firstObject;
                }
                twoCell.dynamicObj = _dynamicObj;
                twoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(_dynamicObj.userId), _dynamicObj.nick_name, _dynamicObj.head_portrait, nil];
                [twoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                return twoCell;
                break;
            case 3:
                if(!threeCell)
                {
                    threeCell = [[NSBundle mainBundle] loadNibNamed:@"ThreePhotoCell" owner:nil options:nil].firstObject;
                }
                threeCell.dynamicObj = _dynamicObj;
                [threeCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                return threeCell;
                break;
            default:
                if(!noPhotoCell)
                {
                    noPhotoCell = [[NSBundle mainBundle] loadNibNamed:@"NoPhotoCell" owner:nil options:nil].firstObject;
                }
                noPhotoCell.dynamicObj = _dynamicObj;
                [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
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
                if(!oneCell)
                {
                    oneCell = [[NSBundle mainBundle] loadNibNamed:@"OnePhotoCell" owner:nil options:nil].firstObject;
                }
                oneCell.dynamicObj = dynamic;
                oneCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [oneCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
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
                return threeCell;
                break;
            default:
                if(!noPhotoCell)
                {
                    noPhotoCell = [[NSBundle mainBundle] loadNibNamed:@"NoPhotoCell" owner:nil options:nil].firstObject;
                }
                noPhotoCell.dynamicObj = dynamic;
                noPhotoCell.attention.accessibilityElements = [NSArray arrayWithObjects:@(dynamic.userId), dynamic.nick_name, dynamic.head_portrait, nil];
                [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DynamicDetailViewController *vc = [[DynamicDetailViewController alloc] initWithNibName:@"DynamicDetailViewController" bundle:nil];
        vc.dynamicId = @"dynamicId";
        [self.navigationController pushViewController:vc animated:YES];
}

@end
