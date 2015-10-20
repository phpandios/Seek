//
//  AppDelegate.m
//  Seek
//
//  Created by 吴非凡 on 15/10/4.
//  Copyright © 2015年 吴非凡. All rights reserved.
//

#import "AppDelegate.h"

#import "MainTabBarViewController.h"

#import "UMSocial.h"
#import "UMSocialData.h"
#import <RongIMKit/RongIMKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import "LoginViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 友盟
    [UMSocialData setAppKey:kUMAppKey];
    [UMSocialData openLog:YES];
    
    // 融云
    [[RCIM sharedRCIM] initWithAppKey:kRCIMAppKey];
    
    // 地图
    [MAMapServices sharedServices].apiKey = kLBSAppKey;
    
    
    // 搜索
    [AMapSearchServices sharedServices].apiKey = kLBSAppKey;
    /**
     * 推送处理1
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
//    self.window.rootViewController = ({
//        UIViewController *vc = [MainTabBarViewController new];
//        vc.view.backgroundColor = [UIColor cyanColor];
//        vc;
//    });
    
    
    
    
    
    /*
     */
    self.window.rootViewController = ({
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        loginVC.loginBlock = ^(){
//            if ([Common shareCommon].loginUser) { // 成功登陆
//                [UIApplication sharedApplication].keyWindow.rootViewController = ({
//                            UIViewController *vc = [MainTabBarViewController new];
//                            vc.view.backgroundColor = [UIColor cyanColor];
//                            vc;
//                        });
//            }
//        };
        loginNav;
    });
     
     /*
     */
    [self.window makeKeyAndVisible];
    
    
    
//    [AppDelegate presentLoginVCWithDismisBlock:nil];
    
    
    
    
   
//    [self login];
    
    
    
    
    
//    //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
//    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
//        NSLog(@"SnsInformation is %@",response.data);
//        UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
//        
//        NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//    }];
    
    // 分享 OK
//    [UMSocialSnsService presentSnsIconSheetView:self.window.rootViewController
//                                         appKey:kUMAppKey
//                                      shareText:@"友盟社会化分享让您快速实现分享等社会化功能，http://umeng.com/social"
//                                     shareImage:[UIImage imageNamed:@"icon.png"]
//                                shareToSnsNames:@[UMShareToTencent]
//                                       delegate:nil];
    return YES;
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application

{
    
    // 登录需要编写
    
    [UMSocialSnsService applicationDidBecomeActive];
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - 弹出登陆
//+ (void)presentLoginVCWithDismisBlock:(void (^)())loginBlock
//{
//    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
//    loginVC.loginBlock = loginBlock;
//    
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:loginNav animated:YES completion:nil];
//}


- (void)login
{
    self.window.rootViewController = ({
        UIViewController *vc = [MainTabBarViewController new];
        [vc.view addTransitionWithType:kCATransitionReveal subType:kCATransitionFromTop duration:0.5 key:nil];
        vc.view.backgroundColor = [UIColor cyanColor];
        vc;
    });
}

- (void)logout
{
//    __weak typeof(self) weakSelf = self;
    self.window.rootViewController = ({
        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [loginNav.view addTransitionWithType:kCATransitionReveal subType:kCATransitionFromTop duration:0.5 key:nil];

//        loginVC.loginBlock = ^(){
//            [weakSelf login];
//        };
        loginNav;
    });
}
@end
