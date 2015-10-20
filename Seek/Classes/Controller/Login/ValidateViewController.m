//
//  ValidateViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "ValidateViewController.h"
#import "SetPwdViewController.h"
@interface ValidateViewController ()
- (IBAction)resendButtonAction:(UIButton *)sender;
- (IBAction)dismisButtonAction:(UIButton *)sender;
- (IBAction)commitButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UITextField *validateTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@end

@implementation ValidateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipLabel.text = [NSString stringWithFormat:@"我们已经将验证码短信发送到  %@",_phoneNum];
    // Do any additional setup after loading the view from its nib.
    [self.validateTextField becomeFirstResponder];
    [self startTiming];
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
/**
 *  重新发送按钮的倒计时
 */
- (void)startTiming
{
    __block int timeout = 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    __weak __typeof(self) weakSelf = self;
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout <= 1)
        {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.resendButton setTitle:@"重新发送" forState:UIControlStateNormal];
                [weakSelf.resendButton setEnabled:YES];
            });
        }
        else
        {
            timeout--;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.resendButton setTitle:[NSString stringWithFormat:@"%d秒后重发",timeout] forState:UIControlStateDisabled];
                [weakSelf.resendButton setEnabled:NO];
            });
        }
    });
    dispatch_resume(timer);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* 
 验证的错误信息
 nil:代表没错误
*/
- (NSString *)errorByValidate
{
    if (1) {
        return nil;
    }
}

- (IBAction)resendButtonAction:(UIButton *)sender {
    [self startTiming];
}

- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitButtonAction:(UIButton *)sender {
    if (![self errorByValidate]) {
        SetPwdViewController *vc = [[SetPwdViewController alloc] initWithNibName:@"SetPwdViewController" bundle:nil];
        vc.phoneNum = self.phoneNum;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
