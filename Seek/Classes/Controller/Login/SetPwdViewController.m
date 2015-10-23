//
//  SetPwdViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "SetPwdViewController.h"

@interface SetPwdViewController ()
- (IBAction)dismisButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPwdTextField;
- (IBAction)commitButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *pwdInputImageView;
@property (weak, nonatomic) IBOutlet UIImageView *confirmPwdInputImageView;

@end

@implementation SetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pwdTextField becomeFirstResponder];
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
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.pwdTextField) {
        [self.confirmPwdTextField becomeFirstResponder];
    }
    if (textField == self.confirmPwdTextField){
        [self commitButtonAction:nil];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.pwdTextField) {
        self.pwdInputImageView.highlighted = YES;
        self.confirmPwdInputImageView.highlighted = NO;
    }
    if (textField == self.confirmPwdTextField) {
        self.confirmPwdInputImageView.highlighted = YES;
        self.pwdInputImageView.highlighted = NO;
    }
}

/**
    *  密码有效性校验
    *
    *  @return YES/NO
    */
- (BOOL)verifyDataValid
{
    BOOL isValid = YES;
    NSString *password = self.pwdTextField.text;
    NSString *surePassword = self.confirmPwdTextField.text;
    
    //数据校验
    if (password.length == 0 && surePassword.length == 0)
    {
        SHOWERROR(@"请输入密码");
        isValid = NO;
    }
    if ([password rangeOfString:@"[a-zA-Z0-9]+" options:NSRegularExpressionSearch].length < password.length)
    {
        SHOWERROR(@"密码应为6-16位字母或数字，不包含其他字符");
        
        isValid = NO;
    }
    else if (password == nil || password.length < 6 || password.length > 16)
    {
        SHOWERROR(@"密码长度不正确，应为6-16位字母或数字");

        isValid = NO;
    }
    else if (![password isEqualToString:surePassword])
    {
        SHOWERROR(@"两次输入密码不一致");
        isValid = NO;
    }
    
    return isValid;
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)commitButtonAction:(UIButton *)sender {
    RCNetworkStatus stauts=[[RCIMClient sharedRCIMClient]getCurrentNetworkStatus];
    
    if (RC_NotReachable == stauts) {
        SHOWERROR(@"当前网络不可用，请检查！");
        return;
    }
    
    if ([self verifyDataValid]) {
        __weak typeof(self) weakSelf = self;
        [KVNProgress showWithStatus:@"注册中..."];
        [AFHttpTool regWithTelPhone:self.phoneNum password:self.pwdTextField.text success:^(id response) {
            if (response[@"code"]) {
                NSInteger code = [response[@"code"] integerValue];
                if (code == 200) {
                    SHOWSUCCESS(@"注册成功");
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    if (response[@"message"] && [response[@"message"] length] > 0) {
                        NSString *message = response[@"message"];
                        SHOWERROR(@"%@", message);
                    } else {
                        SHOWERROR(@"注册失败!");
                    }
                }
            } else {
                SHOWERROR(@"注册失败!");
            }
        } failure:^(NSError *err) {
            SHOWERROR(@"注册失败!");
        }];
        
        
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
