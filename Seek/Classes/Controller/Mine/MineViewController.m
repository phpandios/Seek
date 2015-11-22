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
#import "FriendListViewController.h"
#import "AppDelegate.h"
#import "RCDLoginInfo.h"
#import "CheckPhoneViewController.h"
#import "PhotoCutViewController.h"
#import "AddressBookViewController.h"
#import "AFPickerView.h"
#import "WFFDropdownList.h"
#import "SuggestionsViewController.h"
@interface MineViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate,PhotoCueDelegate, WFFDropdownListDelegate>
{
    MBProgressHUD *HUD;
}


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *canSelectedArray; // 标识允许选中的项

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"我的";
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    self.canSelectedArray = @[@[@(NO)], @[@(YES), @(YES)], @[@(YES), @(YES), @(YES)], @[@(YES), @(YES)], @[@(NO)]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"headerCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserLogoutTableViewCell" bundle:nil] forCellReuseIdentifier:@"logoutCell"];
    
//    self.navigationItem.rightBarButtonItem = ({
//        UIBarButtonItem *addFriendItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend:)];
//        addFriendItem;
//    });
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
//    __weak typeof(self) weakSelf = self;
//    
//    if (![Common shareCommon].loginUser) { // 没登陆
//        [AppDelegate presentLoginVCWithDismisBlock:^(){
//            if ([Common shareCommon].loginUser) { // 已经登陆
//                
//            } else { // 登陆失败
//                UITabBarController *tab = (UITabBarController *)weakSelf.navigationController.parentViewController;
//                tab.selectedIndex = weakSelf.preIndex;
//            }
//        }];
//    }
}

// 到该方法.说明已经登陆了.设置界面的值
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //
    [self loadUserDataCompletionHandle:nil];
}

#pragma mark - WFFDropdownListDelegate - 性别选择
- (void)dropdownList:(WFFDropdownList *)dropdownList didSelectedIndex:(NSInteger)selectedIndex
{
    [KVNProgress show];
    [AFHttpTool modifyGender:selectedIndex success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        [[RCDLoginInfo shareLoginInfo] setGender:selectedIndex];
    } failure:^(NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"网络故障"];
            [dropdownList setSelectedIndex:[[RCDLoginInfo shareLoginInfo] gender]];
        });
    }];
}

#pragma mark - 网络相关
#pragma mark 根据当前登陆用户获取用户信息
- (void)loadUserDataCompletionHandle:(void(^)())completionHandle
{
    // 获取用户信息后,
    [self.tableView reloadData];
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
        case 1: // 关注 --------粉丝
            return 1;
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
    __weak typeof(self) weakSelf = self;
    UITableViewCell *cell = nil;
    NSLog(@"%ld", indexPath.section);
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
       
        NSString *loginUserPortrait = [[RCDLoginInfo shareLoginInfo] head_portrait];
        NSLog(@"%@", loginUserPortrait);
        [((UserHeaderTableViewCell *)cell).headerImageView sd_setImageWithURL:[NSURL URLWithString:loginUserPortrait] placeholderImage:[UIImage imageNamed:@"placeholderUserIcon"]];
        ((UserHeaderTableViewCell *)cell).userNameLabel.text = [[RCDLoginInfo shareLoginInfo] nick_name];
        ((UserHeaderTableViewCell *)cell).headerViewClickBlock = ^(){
            [weakSelf showImagePickerControllerWithTitle:@"更换头像" cancleHandle:nil];
//            SHOWMESSAGE(@"更换头像");
        };

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
//                case 1:
//                    cell.textLabel.text = @"关注请求";
//                    break;
            }
        } else if (indexPath.section == 2) {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"昵称";
                    cell.detailTextLabel.text = [[RCDLoginInfo shareLoginInfo] nick_name];
                    break;
                case 1:
                    cell.textLabel.text = @"手机";
                    if ([[[RCDLoginInfo shareLoginInfo] telephone] length] == 0) { // 没绑定手机
                        cell.detailTextLabel.text = @"点击绑定手机";
                    } else {
                        cell.detailTextLabel.text = [[RCDLoginInfo shareLoginInfo] telephone];
                    }
                    break;
                case 2:
                    cell.textLabel.text = @"性别";
                    if (!(WFFDropdownList *)[cell viewWithTag:indexPath.section * 10 + indexPath.row]) {
                        WFFDropdownList *dropdownList = [[WFFDropdownList alloc] initWithFrame:CGRectMake(kScreenWidth - 60 - 40    , (60 - 30) / 2, 60, 30) dataSource:@[@"请选择", @"男", @"女"]];
                        dropdownList.tag = indexPath.section * 10 + indexPath.row;
                        dropdownList.textColor = [UIColor lightGrayColor];
                        dropdownList.delegate = self;
                        [cell addSubview:dropdownList];
                    }
                    ((WFFDropdownList *)[cell viewWithTag:indexPath.section * 10 + indexPath.row]).selectedIndex = [[RCDLoginInfo shareLoginInfo] gender];
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
            ((UserLogoutTableViewCell *)cell).buttonClickBlock = ^(){
                [(AppDelegate *)ShareApplicationDelegate logout];
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
        return 5;
    }
    return 0.01;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // 我的好友
            AddressBookViewController *addressBookVC = [AddressBookViewController new];
            [self.navigationController pushViewController:addressBookVC animated:YES];
        }
    }
    
    if (indexPath.section == 2 && indexPath.row == 1) { // 手机
        if ([[[RCDLoginInfo shareLoginInfo] telephone] length] == 0) { // 没绑定手机,就绑定手机
            CheckPhoneViewController *vc = [[CheckPhoneViewController alloc] initWithNibName:@"CheckPhoneViewController" bundle:nil];
            vc.type = CheckPhoneTypeForBindingTelPhone;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    if (indexPath.section == 2 && indexPath.row == 2) { // 选择性别
        
    }
    
    if (indexPath.section == 3 && indexPath.row == 0) { // 修改密码
        CheckPhoneViewController *vc = [[CheckPhoneViewController alloc] initWithNibName:@"CheckPhoneViewController" bundle:nil];
        vc.type = CheckPhoneTypeForModifyPwd;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if (indexPath.section == 3 && indexPath.row == 1) { // 意见反馈
        SuggestionsViewController *vc = [[SuggestionsViewController alloc] initWithNibName:@"SuggestionsViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIPickerViewDelegate


#pragma mark - UIImagePickerController
- (void)showImagePickerControllerWithTitle:(NSString *)title cancleHandle:(void (^)())cancleHandle
{
    self.imagePickerController = [[UIImagePickerController alloc]init];
    _imagePickerController.delegate = self;
    
    // 判断支持来源类型(拍照,照片库,相册)
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL isPhotoLibrarySupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL isSavedPhotosAlbumSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
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
        //        self.currentMode = ActualModeTypeNormal;
        if (cancleHandle) {
            cancleHandle();
        }
    }]];
    
    if (!(isCameraSupport || isPhotoLibrarySupport || isSavedPhotosAlbumSupport)) { // 三种都不支持
        alertController.title = @"无法找到可用图片源,请检查设备后重试";
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage] ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    PhotoCutViewController *photoVc = [PhotoCutViewController new];
    photoVc.delegate = self;
    photoVc.image = image;
    self.imagePickerController = picker;
    [picker pushViewController:photoVc animated:YES];
}


#pragma mark - 图片回传协议方法头像更换图片
-(void)passImage:(UIImage *)image
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *imageOld = image;
    CGSize newSize = CGSizeMake(99, 99);
    UIImage *newImage = [UIImage imageWithImage:imageOld scaledToSize:newSize];
    NSData *imageData = UIImagePNGRepresentation(newImage);
    HUD.labelText = @"图片正在上传中...";
    [HUD show:YES];
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [UIImage uplodImageWithData:imageData method:@"POST" urlString:[kRequestUrl stringByAppendingString:@"update_photo"] mimeType:@"image/jpeg" inputName:@"upload_file" fileName:@"a.jpg" returnUrl:^(id obj) {
            if (obj != nil) {
                [HUD hide:YES];
            }
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [[RCDLoginInfo shareLoginInfo] setValue:dict[@"result"] forKey:@"head_portrait"];
            [weakSelf.tableView reloadData];
        }];
    });
    
    

    NSLog(@"%@", image);
}

#pragma mark- 缩放图片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//#pragma mark - 右上角添加好友
//- (void)addFriend:(UIBarButtonItem *)sender
//{
//    
//    [self showAlertControllerWithTitle:@"查找好友" hasTextField:YES okHandle:^(NSString *returnText) {
//        [KVNProgress show];
//        [[Common shareCommon] sendFriendRequestWithUserId:[returnText integerValue] message:@"加一下呗" completionHandle:^(BOOL isSuccess) {
//            if (isSuccess) {
//                SHOWSUCCESS(@"好友请求发送成功");
//            }
//        }];
//    } cancelHandle:^{
//    }];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
