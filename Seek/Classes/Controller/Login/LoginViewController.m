//
//  LoginViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/8.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "LoginViewController.h"
#import <RongIMKit/RongIMKit.h>
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
    
    NSString *telephone = [DEFAULTS objectForKey:@"userName"];
    NSString *pwd = [DEFAULTS objectForKey:@"userPwd"];
    if ([telephone length] > 0 && [pwd length] > 0) {
        self.userTextField.text = telephone;
        self.pwdTextField.text = pwd;
    }
    
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
    [self.view endEditing:YES];
    // QQ登陆 NO
    [UMSocialQQHandler setQQWithAppId:kUMQQAppID appKey:kUMQQAppKey url:kUMUrl];

    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    [KVNProgress showWithStatus:@"授权中..."];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){

        // 获取微博用户名、uid、token等
        
        // QQ头像大小 100 * 100
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            [AFHttpTool loginWithQQID:snsAccount.usid nick_name:snsAccount.userName head_portrait:snsAccount.iconURL success:^(id response) {
                
                [KVNProgress showWithStatus:@"授权成功,登录中..."];
                RCDLoginInfo *loginInfo = [RCDLoginInfo shareLoginInfo];
//                NSLog(@"%@", response);
                loginInfo.isThirdLogin = YES;
                [loginInfo setValuesForKeysWithDictionary:response[@"result"]];
                [AFHttpTool getTokenWithUser:loginInfo success:^(id response) {
                    
                    NSString *token = response[@"result"][@"token"];
                    
                    // 三方登陆没有密码,因此本地没存密码.无法自动登陆,无需判断
                    [self loginRongCloud:loginInfo.nick_name token:token password:nil];
                } failure:^(NSError *err) {
                    
                    SHOWERROR(@"APP服务器错误,请联系客服人员!");
                }];
            } failure:^(NSError *err) {
                
            }];
        }});
}

- (IBAction)loginByWeiChatButtonAction:(UIButton *)sender {
    SHOWMESSAGE(@"微信登陆");
    [self.view endEditing:YES];
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
    
    [self login:self.userTextField.text password:self.pwdTextField.text];
    [self.view endEditing:YES];
}

/**
 *  登陆
 */
- (void)login:(NSString *)userName password:(NSString *)password
{
    RCNetworkStatus stauts=[[RCIMClient sharedRCIMClient]getCurrentNetworkStatus];
    
    if (RC_NotReachable == stauts) {
        SHOWERROR(@"当前网络不可用，请检查！");
        return;
    }
    
    [KVNProgress showWithStatus:@"登录中..."];
    [AFHttpTool loginWithTelPhone:userName password:password success:^(id response) {
        if ([response[@"code"] intValue] == 200) {
            RCDLoginInfo *loginInfo = [RCDLoginInfo shareLoginInfo];
            loginInfo.isThirdLogin = NO;
            [loginInfo setValuesForKeysWithDictionary:response[@"result"]];
            [AFHttpTool getTokenWithUser:loginInfo success:^(id response) {
                NSString *token = response[@"result"][@"token"];
                [self loginRongCloud:userName token:token password:password];
            } failure:^(NSError *err) {
                SHOWERROR(@"APP服务器错误,请联系客服人员!");
            }];
        } else {
            if (response[@"message"] && [response[@"message"] length] > 0) {
                NSString *message = response[@"message"];
                SHOWERROR(@"%@", message);
            }
        }
    } failure:^(NSError *err) {
        NSLog(@"NSError is %ld",(long)err.code);
        if (err.code == 3840) {
            SHOWERROR(@"用户名或密码错误！");
        }else{
            SHOWERROR(@"登陆失败");
        }
    }];
}

/**
 *  登录融云服务器
 *
 *  @param userName 用户名
 *  @param token    token
 *  @param password 密码
 */
- (void)loginRongCloud:(NSString *)userName token:(NSString *)token password:(NSString *)password
{
    //登陆融云服务器
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        [self loginSuccess:userName password:password token:token userId:userId];
    } error:^(RCConnectErrorCode status) {
        //关闭HUD
        SHOWERROR(@"Token无效！");
        
    } tokenIncorrect:^{
        NSLog(@"IncorrectToken");
        
    }];
}

- (void)loginSuccess:(NSString *)userName password:(NSString *)password token:(NSString *)token userId:(NSString *)userId
{
    if (![[RCDLoginInfo shareLoginInfo] isThirdLogin]) {
        //保存默认用户
        [DEFAULTS setObject:userName forKey:@"userName"];
        [DEFAULTS setObject:password forKey:@"userPwd"];
        [DEFAULTS setObject:token forKey:@"userToken"];
        [DEFAULTS setObject:userId forKey:@"userId"];
        [DEFAULTS synchronize];
    } else {
        //保存默认用户
        [DEFAULTS removeObjectForKey:@"userName"];
        [DEFAULTS removeObjectForKey:@"userPwd"];
        [DEFAULTS removeObjectForKey:@"userToken"];
        [DEFAULTS removeObjectForKey:@"userId"];
        [DEFAULTS synchronize];
    }
    
    
    //设置当前的用户信息
    RCUserInfo *_currentUserInfo = [[RCUserInfo alloc]initWithUserId:userId name:userName portrait:nil];
    [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
    
    [RCDHTTPTOOL getUserInfoByUserID:userId
                          completion:^(RCUserInfo* user) {
                              [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:userId];
                              
                          }];
    //同步群组
    [RCDDataSource syncGroups];
    [RCDDataSource syncFriendList:^(NSMutableArray *friends) {}];
    BOOL notFirstTimeLogin = [DEFAULTS boolForKey:@"notFirstTimeLogin"];
    if (!notFirstTimeLogin) {
        [RCDDataSource cacheAllData:^{ //auto saved after completion.
            //                                                   [DEFAULTS setBool:YES forKey:@"notFirstTimeLogin"];
            //                                                   [DEFAULTS synchronize];
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [ShareApplicationDelegate performSelector:@selector(login)];
    });
}


- (IBAction)forgetPwdButtonAction:(UIButton *)sender {
    CheckPhoneViewController *vc = [[CheckPhoneViewController alloc] initWithNibName:@"CheckPhoneViewController" bundle:nil];
    vc.type = CheckPhoneTypeForFindPwd;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)exitButtonAction:(UIButton *)sender {
//    [self dismiss];
}
@end
