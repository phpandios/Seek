//
//  CheckPhoneViewController.m
//  Seek
//
//  Created by 吴非凡 on 15/10/14.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "CheckPhoneViewController.h"
#import "ValidateViewController.h"
@interface CheckPhoneViewController () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
- (IBAction)commitButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblTips;
- (IBAction)dismisButtonAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;

@end

@implementation CheckPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_type == CheckPhoneTypeForRegister) {
        self.titleLabel.text = @"手机注册";
        [self setupLabel];
    } else {
        self.titleLabel.text = @"找回密码";
    }
    [self.phoneNumTextField becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupLabel
{
    //隐私条款
    NSString *strTipsMessage = @"轻触上方注册按钮,即表示同意《用户协议》";
    _lblTips.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _lblTips.backgroundColor  = [UIColor clearColor];
    _lblTips.textColor = [UIColor colorFromHexRGB:@"999999"];
    _lblTips.font = [UIFont systemFontOfSize:13.f];
    _lblTips.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[kNavBgColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    _lblTips.activeLinkAttributes = mutableActiveLinkAttributes;
    _lblTips.verticalAlignment = TTTAttributedLabelVerticalAlignmentCenter;
    _lblTips.delegate = self;

    NSRange linkRange = [strTipsMessage rangeOfString:@"《用户协议》"];
    [_lblTips setText:strTipsMessage afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
     {
         UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:13.f];
         CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
         if (boldFont)
         {
             [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:linkRange];
             [mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:linkRange];
             CFRelease(boldFont);
         }
         [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:@(kCTUnderlineStyleSingle) range:linkRange];
         [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[kNavBgColor CGColor] range:linkRange];
         
         [mutableAttributedString replaceCharactersInRange:linkRange withString:[[mutableAttributedString string] substringWithRange:linkRange]];
         
         return mutableAttributedString;
     }];
    [_lblTips addLinkToURL:[NSURL URLWithString:@"aaa"] withRange:linkRange];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    SHOWMESSAGE(@"跳转用户协议页面[webView]");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 验证手机号
/*
 验证手机号的错误信息
 nil代表验证通过
 */
- (NSString *)erroByCheckPhoneNum
{
    return nil;
}
- (IBAction)commitButtonAction:(UIButton *)sender {
    if ([self erroByCheckPhoneNum]) {
        return;
    }
    ValidateViewController *vc = [[ValidateViewController alloc] initWithNibName:@"ValidateViewController" bundle:nil];
    
    vc.phoneNum = self.phoneNumTextField.text;
    
    if (_type == CheckPhoneTypeForRegister) { // 注册
        
        [self.navigationController pushViewController:vc animated:YES];
    } else {// 找回密码
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)dismisButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end