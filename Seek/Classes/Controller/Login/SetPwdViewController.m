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
        SHOWMESSAGE(@"请输入密码");
        isValid = NO;
    }
    if ([password rangeOfString:@"[a-zA-Z0-9]+" options:NSRegularExpressionSearch].length < password.length)
    {
        SHOWMESSAGE(@"密码应为6-16位字母或数字，不包含其他字符");
        
        isValid = NO;
    }
    else if (password == nil || password.length < 6 || password.length > 16)
    {
        SHOWMESSAGE(@"密码长度不正确，应为6-16位字母或数字");

        isValid = NO;
    }
    else if (![password isEqualToString:surePassword])
    {
        SHOWMESSAGE(@"两次输入密码不一致");
        isValid = NO;
    }
    
    return isValid;
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)commitButtonAction:(UIButton *)sender {
    if ([self verifyDataValid]) {
        SHOWMESSAGE(@"注册成功");
        
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end