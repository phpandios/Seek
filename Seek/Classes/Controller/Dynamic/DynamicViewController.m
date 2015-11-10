//
//  DynamicViewController.m
//  Seek
//
//  Created by apple on 15/10/9.
//  Copyright © 2015年 吴非凡. All rights reserved.
//
#define dynamicList @"dynamic"
#define dynamicRecommend @"recommend_dynamic"

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
#import "UMSocial.h"

@interface DynamicViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate,UMSocialUIDelegate>
{
     MBProgressHUD *HUD;
    UMSocialBar *_socialBar;
}

@property (nonatomic, retain)NSMutableArray *dynamicArr;
@property (nonatomic, retain)Dynamic *dynamicObj;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end
static NSString *onePhotoIdentifier = @"oneCell";
static NSString *twoPhotoIdentifier = @"twoCell";
static NSString *threePhotoIdentifier = @"threeCell";
static NSString *pulishIdentifier = @"pulishCell";
static NSString *noPhotolIdentifier = @"noCell";
static NSString *fourPhotolIdentifier = @"fourCell";
@implementation DynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"动态";
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(issueBarButtonItemAction:)];
    
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

#pragma mark -出的时候进行刷新
- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}
#pragma mark - 上拉下载
- (void)refreshHeaderFooer
{
    __weak typeof(self) weakSelf = self;
    // 下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loadRemmondData];
            [weakSelf.dynamicArr removeAllObjects];
            // 加载数据
            [weakSelf loadDataPage:0 limit:10 finish:^(id obj) {
                    NSLog(@"%@", obj);
                
                    weakSelf.dynamicArr = obj;
                    //重新加载
                    [weakSelf.tableView reloadData];
                    //取消
                    [HUD hide:YES];
                    // 结束刷新
                    [weakSelf.tableView.header endRefreshing];
            }];
            
            
        });
    }];
    
    
    // 上拉刷新
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            static NSInteger page = 1,offset=0,limit=10;
            offset = page * limit;
            page++;
            [weakSelf loadDataPage:offset limit:limit finish:^(id obj) {
                [weakSelf.tableView reloadData];
            }];
            // 结束刷新
            [weakSelf.tableView.footer endRefreshing];
            
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
    NSInteger permission = 3, promote_state=0, state = 2;
    static NSInteger first_state = 1;
    //判断第一次加载的时候清除内容
    if (first_state == 1) {
        [self.dynamicArr removeAllObjects];
    }
    [AFHttpTool getDynamicWithPage:page limit:limit permissions:permission promote_state:promote_state state:state success:^(id response) {
        if ([response[@"result"] count] == 0) {
            return;
        }
        
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.dynamicArr] forKey:dynamicList];
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
            if ([[NSUserDefaults standardUserDefaults] objectForKey:dynamicRecommend]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:dynamicRecommend];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:dynamic] forKey:dynamicRecommend];
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
        CGFloat height = [NSString calcWithTextHeightStr:_dynamicObj.content width:self.tableView.bounds.size.width font:[UIFont systemFontOfSize:18.0]];
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
        if(!pulishCell)
        {
            pulishCell = [[NSBundle mainBundle] loadNibNamed:@"PulishCell" owner:nil options:nil].firstObject;
        }
        [pulishCell.edit_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.share_btn addTarget:self action:@selector(issueEditBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [pulishCell.take_photo addTarget:self action:@selector(showImagePickerController:) forControlEvents:UIControlEventTouchUpInside];
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
                [oneCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                oneCell.comments_btn.tag = _dynamicObj.dynamicId;
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
                [twoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                twoCell.comments_btn.tag = _dynamicObj.dynamicId;
                return twoCell;
                break;
            case 3:
                if(!threeCell)
                {
                    threeCell = [[NSBundle mainBundle] loadNibNamed:@"ThreePhotoCell" owner:nil options:nil].firstObject;
                }
                threeCell.dynamicObj = _dynamicObj;
                [threeCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [threeCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                threeCell.comments_btn.tag = _dynamicObj.dynamicId;
                return threeCell;
                break;
            case 4:
                if(!fourCell)
                {
                    fourCell = [[NSBundle mainBundle] loadNibNamed:@"FourPhotoViewCell" owner:nil options:nil].firstObject;
                }
                fourCell.dynamicObj = _dynamicObj;
                [fourCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [fourCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                fourCell.comments_btn.tag = _dynamicObj.dynamicId;
                return fourCell;
                break;
            default:
                if(!noPhotoCell)
                {
                    noPhotoCell = [[NSBundle mainBundle] loadNibNamed:@"NoPhotoCell" owner:nil options:nil].firstObject;
                }
                noPhotoCell.dynamicObj = _dynamicObj;
                [noPhotoCell.attention addTarget:self action:@selector(attentionAction:) forControlEvents:UIControlEventTouchUpInside];
                [noPhotoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                noPhotoCell.comments_btn.tag = _dynamicObj.dynamicId;
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
                [oneCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                oneCell.comments_btn.tag = dynamic.dynamicId;
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
                twoCell.comments_btn.tag = dynamic.dynamicId;
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
                threeCell.comments_btn.tag = dynamic.dynamicId;
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
                [noPhotoCell.comments_btn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
                noPhotoCell.comments_btn.tag = dynamic.dynamicId;
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
    OnePhotoCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

#pragma mark - 点击效果
- (void)commentAction:(UIButton *)sender
{
    NSLog(@"%@", sender);
    DynamicDetailViewController *vc = [[DynamicDetailViewController alloc] initWithNibName:@"DynamicDetailViewController" bundle:nil];
    vc.dynamicId = sender.tag;
    [self.navigationController pushViewController:vc animated:YES];
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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    HUD.labelText = @"图片正在上传中...";
    [HUD show:YES];
    [UIImage uplodImageWithData:imageData method:@"POST" urlString:@"http://www.hzftjy.com/seek/seek.php/dynamic_image" mimeType:@"image/jpeg" inputName:@"upload_file" fileName:@"a.jpg" returnUrl:^(id obj) {
        if (obj != nil) {
            [HUD hide:YES];
        }
        NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        IssueViewController *vc = [[IssueViewController alloc] initWithNibName:@"IssueViewController" bundle:nil];
        vc.tokePhoto = dict[@"result"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
