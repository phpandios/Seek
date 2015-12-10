//
//  IssueViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//


#import "IssueViewController.h"
#import "WFFDropdownList.h"
#import "AutoHeightTextView.h"
#import "MAPPOISearchViewController.h"
#import "PermissionsViewController.h"
#import "AFHttpTool.h"
#import "CateViewController.h"

@interface IssueViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate>


- (IBAction)commitButtonAction:(UIButton *)sender;
- (IBAction)dismisButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet AutoHeightTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *permissionButton;
- (IBAction)permissionButtonAction:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *imagesArray;

@property (nonatomic, strong) NSMutableArray *publishImages;

@property (nonatomic, retain) NSMutableDictionary *currentPermission;
@property (weak, nonatomic) IBOutlet UIButton *perssionName;
@property (weak, nonatomic) IBOutlet UILabel *perssionDecrip;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

- (IBAction)cateGoryAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cateGoryBtn;


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
    //照相选择图片
    if (self.image != nil) {
        [self.imagesArray addObject:_image];
    }
    
    if ([[RCDLoginInfo shareLoginInfo] addressName]) {
        self.addressTextField.text = [[RCDLoginInfo shareLoginInfo] addressName];
    }
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isNotHave) {
        self.addressTextField.text = self.selectedAddressDict[@"name"];
    }
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
    printf("%p", textField);
    printf("%p", self.addressTextField);
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

#pragma mark -选中当前
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.imagesArray.count -1) {
        [self showImagePickerControllerWithTitle:@"上传图片" cancleHandle:nil];
    }
//    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.tag = 100;
        imageView.userInteractionEnabled = YES;
        [cell addSubview:imageView];
    }
    if (indexPath.row==self.imagesArray.count-1) {
        imageView.image = self.imagesArray[0];
    } else {
//        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imagesArray[indexPath.row+1]] placeholderImage:nil];
        NSLog(@"%@", self.imagesArray[indexPath.row + 1]);
        imageView.image = self.imagesArray[indexPath.row + 1];
    }
    
    
    return cell;
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
#pragma mark - 按钮点击
- (IBAction)commitButtonAction:(UIButton *)sender {
    NSArray *iDarr = self.cateGoryBtn.accessibilityElements;
    NSLog(@"%@", iDarr);
    if ([[iDarr objectAtIndex:1] integerValue] < 0 || [iDarr count] == 0) {
        [KVNProgress showErrorWithStatus:@"请选择分类!"];
        return;
    }
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
            //将图片编历
            NSString *images_arr = @"";
            CGFloat longitude=0,latitude=0;
            NSString *name=@"",*address = @"";
            //判断字典是否有值
            if (_selectedAddressDict != nil) {
                longitude = [[_selectedAddressDict objectForKey:@"longitude"] floatValue];
                latitude =[[_selectedAddressDict objectForKey:@"latitude"] floatValue];
                name = [_selectedAddressDict objectForKey:@"name"];
                address = [_selectedAddressDict objectForKey:@"address"];
            }
            
            __weak typeof(self) weakSelf = self;
            NSArray *IDArr = self.cateGoryBtn.accessibilityElements;
            
            [AFHttpTool publishMessageCate:[[IDArr objectAtIndex:0] integerValue]
                                 towCateId:[[IDArr objectAtIndex:1] integerValue]
                                     title:_titleTextField.text
                                   content:_contentTextView.text
                                    images:images_arr
                                 longitude:longitude
                                  latitude:latitude
                              locationName:name
                           locationAddress:address
                                permission:permission success:^(id response) {
                                    
                                    NSDictionary *dict = @{@"id":response[@"result"]};
                                    if (self.imagesArray.count > 1)
                                    {
                                        dispatch_queue_t queue = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
                                        for (int i=1; i < self.imagesArray.count; i++) {
                                            UIImage *image = self.imagesArray[i];
                                            CGSize oldSize = image.size;
                                            CGSize newSize = CGSizeMake(600, 600 / oldSize.width * oldSize.height);
                                            UIImage *newImage = [UIImage imageWithImage:image scaledToSize:newSize];
                                            //压缩尺寸
                                            NSData *imageData = UIImageJPEGRepresentation(newImage, 0.000001);
                                            //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                            //异步函数
                                            dispatch_async(queue, ^{
                                                [UIImage uplodImageWithData:imageData
                                                                     method:@"POST"
                                                                  urlString:[kRequestUrl stringByAppendingString:@"dynamic_image"]
                                                                 parameters:dict
                                                                   mimeType:@"image/jpeg"
                                                                  inputName:@"upload_file"
                                                                   fileName:@"a.jpg"
                                                                  returnUrl:^(id obj) {
                                                                      NSLog(@"%@", obj);
                                                }];
                                            });
                                        }
                                    }
                                    
                                    [KVNProgress showSuccessWithStatus:@"发布成功,请耐心等待审核"];
                                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                    }
                                   failure:^(NSError *err) {
                                       NSLog(@"%@", err);
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


#pragma mark - UIImagePickerController
- (void)showImagePickerControllerWithTitle:(NSString *)title cancleHandle:(void (^)())cancleHandle
{
    if (self.imagesArray.count >= 5) {
        [KVNProgress showErrorWithStatus:@"上传照片已经超过限制"];
    } else {
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
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage] ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
    [self.imagesArray addObject:image];
    [self.imageCollectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    self.actualImageView.image = [Common shareCommon].actualImage;
}
- (IBAction)cateGoryAction:(id)sender {
    CateViewController *cate = [[CateViewController alloc] initWithNibName:@"CateViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cate];
    __weak typeof(self) weakSelf=self;
    cate.cateCurrent = ^(NSString *cate_name, NSInteger ID, NSInteger twoID){
        [weakSelf.cateGoryBtn setTitle:cate_name forState:UIControlStateNormal];
        weakSelf.cateGoryBtn.accessibilityElements = [NSArray arrayWithObjects:@(ID),@(twoID), nil];
    };
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSMutableArray *)publishImages
{
    if (_publishImages) {
        self.publishImages = [NSMutableArray new];
    }
    return _publishImages;
}
@end
