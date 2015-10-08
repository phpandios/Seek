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
@interface LoginViewController ()
- (IBAction)loginByQQButtonAction:(UIButton *)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginByQQButtonAction:(UIButton *)sender {
    // QQ登陆 NO
    [UMSocialQQHandler setQQWithAppId:kUMQQAppID appKey:kUMQQAppKey url:kUMUrl];

    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];

    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){

        // 获取微博用户名、uid、token等

        if (response.responseCode == UMSResponseCodeSuccess) {

            NSLog(@"%@", [UMSocialAccountManager socialAccountDictionary]);
            NSLog(@"%d", [UMSocialAccountManager isLogin]);

            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];

            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
        }});
}
@end
