//
//  LoginViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "LoginViewController.h"

#import "CheckPhoneViewController.h"
#import "UMSocial.h"
#import "UMSocialData.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSnsService.h"
@interface LoginViewController ()<UITextFieldDelegate>
- (IBAction)loginByQQButtonAction:(UIButton *)sender;
- (IBAction)loginByWeiChatButtonAction:(UIButton *)sender;
- (IBAction)registButtonAction:(UIButton *)sender;
- (IBAction)loginButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
- (IBAction)forgetPwdButtonAction:(UIButton *)sender;
- (IBAction)exitButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *userInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pwdInputImageView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登陆";
    
    
    
    [self.userTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
//#pragma mark - DISMIS
//- (void)loginCompletion
//{
//    // 先执行block.mine切换到其他vc.再dismis login;
//    // 顺序颠倒,则dismis Login后,展现mine. 再执行mine的viewwillappear.判断到没登陆,在弹出login.重复了
//    if (self.loginBlock) {
//        self.loginBlock();
//    }
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userTextField) {
        [self.pwdTextField becomeFirstResponder];
    }
    if (textField == self.pwdTextField){
        [self loginButtonAction:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.userTextField) {
        self.userInputImageView.highlighted = YES;
        self.pwdInputImageView.highlighted = NO;
    }
    if (textField == self.pwdTextField) {
        self.pwdInputImageView.highlighted = YES;
        self.userInputImageView.highlighted = NO;
    }
}

#pragma mark - 触摸其他位置隐藏键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.pwdTextField resignFirstResponder];
    [self.userTextField resignFirstResponder];
}

#pragma mark - 控件
- (IBAction)loginByQQButtonAction:(UIButton *)sender {
    // QQ登陆 NO
    [UMSocialQQHandler setQQWithAppId:kUMQQAppID appKey:kUMQQAppKey url:kUMUrl];

    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];

    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){

        // 获取微博用户名、uid、token等
        
        // QQ头像大小 100 * 100
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            [[Common shareCommon] loginWithQQID:snsAccount.usid nick_name:snsAccount.userName head_portrait:snsAccount.iconURL completionHandle:nil];
        }});
}

- (IBAction)loginByWeiChatButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"微信登陆");
}

- (IBAction)registButtonAction:(UIButton *)sender {
    CheckPhoneViewController *vc = [[CheckPhoneViewController alloc] initWithNibName:@"CheckPhoneViewController" bundle:nil];
    vc.type = CheckPhoneTypeForRegister;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    if ([self.userTextField.text isEmpty]) {
        SHOWERROR(@"请输入用户名!");
        return;
    }
    if ([self.pwdTextField.text isEmpty]) {
        SHOWERROR(@"请输入密码!");
        return;
    }
    [KVNProgress show];
    [[Common shareCommon] loginWithTelPhone:self.userTextField.text password:self.pwdTextField.text completionHandle:^(BOOL isSuccess) {
        if (isSuccess) {
            SHOWSUCCESS(@"登录成功");
        }
    }];
}
- (IBAction)forgetPwdButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"忘记密码");
}

- (IBAction)exitButtonAction:(UIButton *)sender {
//    [self dismiss];
}
@end
