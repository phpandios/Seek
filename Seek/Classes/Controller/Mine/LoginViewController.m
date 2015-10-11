//
//  LoginViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "LoginViewController.h"


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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登陆";
    
    
    self.userTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userInput"]];
    self.userTextField.leftViewMode = UITextFieldViewModeAlways;

    
    self.pwdTextField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pwdInput"]];
    self.pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.userTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
#pragma mark - DISMIS
- (void)dismiss
{
    // 先执行block.mine切换到其他vc.再dismis login;
    //顺序颠倒,则dismis Login后,展现mine. 再执行mine的viewwillappear.判断到没登陆,在弹出login.重复了
    if (self.dismisBlock) {
        self.dismisBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userTextField) {
        [self.pwdTextField becomeFirstResponder];
    } else {
        [self loginButtonAction:nil];
    }
    return YES;
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
            User *loginUser = [User new];
            loginUser.userId = snsAccount.usid;
            loginUser.userName = snsAccount.userName;
            loginUser.iconUrl = snsAccount.iconURL;
            [[Common shareCommon] loginWithUser:loginUser];
            [self dismiss];
        }});
}

- (IBAction)loginByWeiChatButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"微信登陆");
}

- (IBAction)registButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"注册");
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"登陆");
}
- (IBAction)forgetPwdButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"忘记密码");
}

- (IBAction)exitButtonAction:(UIButton *)sender {
    [self dismiss];
}
@end
