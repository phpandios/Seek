//
//  OtherDynamicViewController.m
//  Seek
//
//  Created by apple on 15/11/15.
//  Copyright © 2015年 吴非凡. All rights reserved.
//
#define dynamicOtherList @"dynamicOther"
#import "OtherDynamicViewController.h"
#import "OnePhotoCell.h"
#import "towPhotoCell.h"
#import "ThreePhotoCell.h"
#import "NoPhotoCell.h"
#import "FourPhotoViewCell.h"
#import "Dynamic.h"
#import "NSString+textHeightAndWidth.h"
#import "DynamicDetailViewController.h"
#import "AddFriendViewController.h"
#import "NoMessage.h"

static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"threeCell";
static NSString *noPhotolIdentifier = @"noCell";
static NSString *fourPhotolIdentifier = @"fourCell";
@interface OtherDynamicViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)exitBtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *dynamicTableView;

@property (nonatomic, retain) NSMutableArray *otherArray;
@property (nonatomic, retain) UIView *noMessage;
@end

@implementation OtherDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dynamicTableView.delegate = self;
    self.dynamicTableView.dataSource = self;
    NSLog(@"%@", self.userID);
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"OnePhotoCell" bundle:nil] forCellReuseIdentifier:onePhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"towPhotoCell" bundle:nil] forCellReuseIdentifier:twoPhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"ThreePhotoCell" bundle:nil] forCellReuseIdentifier:threePhotoIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"FourPhotoViewCell" bundle:nil] forCellReuseIdentifier:fourPhotolIdentifier];
    [self.dynamicTableView registerNib:[UINib nibWithNibName:@"NoPhotoCell" bundle:nil] forCellReuseIdentifier:noPhotolIdentifier];
    
    self.noMessage= [[NSBundle mainBundle] loadNibNamed:@"NoMessage" owner:nil options:nil].firstObject;
    self.dynamicTableView.tableFooterView = _noMessage;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(exitAction:)];
    
    [self loadData];
}

- (NSMutableArray *)otherArray
{
    if (!_otherArray) {
        self.otherArray = [NSMutableArray new];
    }
    return _otherArray;
}

- (void)loadData
{
    __weak typeof(self) weakSelf = self;
    [AFHttpTool getOtherDynamicWithPage:0 limit:20 user_id:[self.userID integerValue] success:^(id response) {
        if ([response[@"result"] count] == 0) {
            return;
        }
        self.dynamicTableView.tableFooterView = nil;
        
        for (int i=0; i < [response[@"result"] count]; i++) {
            Dynamic *dynamic = [Dynamic new];
            [dynamic setValuesForKeysWithDictionary:response[@"result"][i]];
            [weakSelf.otherArray addObject:dynamic];
        }
        //判断本地缓存存在进行移除
        if ([[NSUserDefaults standardUserDefaults] objectForKey:dynamicOtherList]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:dynamicOtherList];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.otherArray] forKey:dynamicOtherList];
        [self.dynamicTableView reloadData];
    } failure:^(NSError *err) {
        NSLog(@"%@", err);
    }];
}
#warning tableView代理
#pragma mark - UITableViewDelegate && UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.otherArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark -每行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dynamic *dyamic = self.otherArray[indexPath.section];
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
            return 145 + height;
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
    
    Dynamic *dynamic = self.otherArray[indexPath.section];
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
            oneCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
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
            twoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
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
            threeCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
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
            fourCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
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
            noPhotoCell.comments_btn.accessibilityElements = [NSArray arrayWithObject:dynamic];
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
    DynamicDetailViewController *vc = [[DynamicDetailViewController alloc] initWithNibName:@"DynamicDetailViewController" bundle:nil];
    vc.dnamicObj = sender.accessibilityElements.firstObject;
    //    vc.dynamicId = sender.tag;
    [self.navigationController pushViewController:vc animated:YES];
    //    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exitAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)exitBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
