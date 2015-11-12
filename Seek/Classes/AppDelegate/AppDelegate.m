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
#import <AudioToolbox/AudioToolbox.h>

#import "LoginViewController.h"


#define iPhone6                                                                \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(750, 1334),                              \
[[UIScreen mainScreen] currentMode].size)           \
: NO)
#define iPhone6Plus                                                            \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(1242, 2208),                             \
[[UIScreen mainScreen] currentMode].size)           \
: NO)
@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    // 友盟
    int i = 0;
    NSLog(@"%d", i++);
    [UMSocialData setAppKey:kUMAppKey];
    NSLog(@"%d", i++);
    [UMSocialData openLog:YES];
    NSLog(@"%d", i++);
    
    // 融云
    [[RCIM sharedRCIM] initWithAppKey:kRCIMAppKey];
    NSLog(@"%d", i++);
    
    //设置会话列表头像和会话界面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    NSLog(@"%d", i++);
    if (iPhone6Plus) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    } else {
        NSLog(@"iPhone6 %d", iPhone6);
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    NSLog(@"%d", i++);
    //    [RCIM sharedRCIM].portraitImageViewCornerRadius = 10;
    //设置用户信息源和群组信息源
    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
    NSLog(@"%d", i++);
    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
    NSLog(@"%d", i++);
    [RCIM sharedRCIM].receiveMessageDelegate=self;
    NSLog(@"%d", i++);

    /**
     * 推送处理1
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, iOS 8
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
    /**
     * 统计推送打开率1
     */
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
//    /**
//     * 获取融云推送服务扩展字段1
//     */
//    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromLaunchOptions:launchOptions];
//    if (pushServiceData) {
//        NSLog(@"该启动事件包含来自融云的推送服务");
//        for (id key in [pushServiceData allKeys]) {
//            NSLog(@"%@", pushServiceData[key]);
//        }
//    } else {
//        NSLog(@"该启动事件不包含来自融云的推送服务");
//    }
//    
//
//
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    
    
    
    
    
    
    
    
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
    
    
    
    
    /// 默认登陆
    //登录
    NSString *token =[[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
    NSString *userId=[DEFAULTS objectForKey:@"userId"];
    NSString *userName = [DEFAULTS objectForKey:@"userName"];
    NSString *password = [DEFAULTS objectForKey:@"userPwd"];
    if (token.length && userId.length && password.length) {
        RCUserInfo *_currentUserInfo =
        [[RCUserInfo alloc] initWithUserId:userId
                                      name:userName
                                  portrait:nil];
        [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
        [[RCIM sharedRCIM] connectWithToken:token
                                    success:^(NSString *userId) {
                                        [AFHttpTool loginWithTelPhone:userName password:password success:^(id response) {
                                            if ([response[@"code"] intValue] == 200) {
                                                RCDLoginInfo *loginInfo = [RCDLoginInfo shareLoginInfo];
                                                [loginInfo setValuesForKeysWithDictionary:response[@"result"]];
                                                
                                                [RCDHTTPTOOL getUserInfoByUserID:userId
                                                                      completion:^(RCUserInfo *user) {
                                                                          [[RCIM sharedRCIM]
                                                                           refreshUserInfoCache:user
                                                                           withUserId:userId];
                                                                      }];
                                                //登陆demoserver成功之后才能调demo 的接口
//                                                [RCDDataSource syncGroups];
                                                [RCDDataSource syncFriendList:^(NSMutableArray * result) {}];
                                                self.window.rootViewController = ({
                                                    UIViewController *vc = [MainTabBarViewController new];
                                                    vc;
                                                });
                                                [self.window makeKeyAndVisible];
                                            } else {
                                                SHOWERROR(@"%@", response[@"message"]);
                                                self.window.rootViewController = ({
                                                    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                                    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                                                    loginNav;
                                                });
                                                [self.window makeKeyAndVisible];
                                            }
                                        } failure:^(NSError *err) {
                                            SHOWERROR(@"用户名密码失效,请重新登陆!");
                                            self.window.rootViewController = ({
                                                LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                                UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                                                loginNav;
                                            });
                                            [self.window makeKeyAndVisible];
                                        }];
                                    }
                                      error:^(RCConnectErrorCode status) {
                                          NSLog(@"connect error %ld", (long)status);
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              SHOWERROR(@"连接出错,请重新连接!");
                                              self.window.rootViewController = ({
                                                  LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                                  UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                                                  loginNav;
                                              });
                                              [self.window makeKeyAndVisible];
                                          });
                                      }
                             tokenIncorrect:^{
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     SHOWERROR(@"token失效,请重新登陆!");
                                     self.window.rootViewController = ({
                                         LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                                         UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];

                                         loginNav;
                                     });
                                     [self.window makeKeyAndVisible];
                                     UIAlertView *alertView =
                                     [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Token已过期，请重新登录"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
                                     ;
                                     [alertView show];
                                 });
                             }];
        
    } else {
        self.window.rootViewController = ({
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            loginNav;
        });
        [self.window makeKeyAndVisible];
    }
//
//    /*
//     */
//    self.window.rootViewController = ({
//        LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        loginNav;
//    });
    
     /*
     */
//    [self.window makeKeyAndVisible];
    
    
    
   
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

/**
 * 推送处理4
 * userInfo内容请参考官网文档
 */
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /**
     * 统计推送打开率2
     */
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
//    /**
//     * 获取融云推送服务扩展字段2
//     */
//    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
//    if (pushServiceData) {
//        NSLog(@"该远程推送包含来自融云的推送服务");
//        for (id key in [pushServiceData allKeys]) {
//            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
//        }
//    } else {
//        NSLog(@"该远程推送不包含来自融云的推送服务");
//    }
}


- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    /**
     * 统计推送打开率3
     */
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
    
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1007);
}



- (void)didReceiveMessageNotification:(NSNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
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
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_APPSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    application.applicationIconBadgeNumber = unreadMsgCount;

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
    
    [DEFAULTS removeObjectForKey:@"userName"];
    [DEFAULTS removeObjectForKey:@"userPwd"];
    [DEFAULTS removeObjectForKey:@"userToken"];
    [DEFAULTS removeObjectForKey:@"userCookie"];
    [[RCIM sharedRCIM] disconnect];
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
#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"您"
                              @"的帐号在别的设备上登录，您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        self.window.rootViewController = ({
            LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [loginNav.view addTransitionWithType:kCATransitionReveal subType:kCATransitionFromTop duration:0.5 key:nil];
            
            //        loginVC.loginBlock = ^(){
            //            [weakSelf login];
            //        };
            loginNav;
        });
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.window.rootViewController = ({
                LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [loginNav.view addTransitionWithType:kCATransitionReveal subType:kCATransitionFromTop duration:0.5 key:nil];
                
                //        loginVC.loginBlock = ^(){
                //            [weakSelf login];
                //        };
                loginNav;
            });
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:@"Token已过期，请重新登录"
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil, nil];
            ;
            [alertView show];
        });
    }
}

-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *msg=(RCInformationNotificationMessage *)message.content;
        //NSString *str = [NSString stringWithFormat:@"%@",msg.message];
        if ([msg.message rangeOfString:@"你已添加了"].location!=NSNotFound) {
            [RCDDataSource syncFriendList:^(NSMutableArray *friends) {
            }];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:RCKitDispatchMessageNotification
     object:nil];
}


@end
