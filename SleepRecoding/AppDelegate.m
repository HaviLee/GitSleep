//
//  AppDelegate.m
//  SleepRecoding
//
//  Created by Havi on 15/2/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "AppDelegate.h"
#import "XHDrawerController.h"
#import "LeftSideViewController.h"
#import "RightSideViewController.h"
#import "CenterSideViewController.h"
#import "YTKNetworkConfig.h"
#import "LoginViewController.h"
#import "UIViewController+MLTransition.h"
#import "GetSuggestionList.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //因为有闹钟的印象，清楚闹钟。
    int picIndex = [QHConfiguredObj defaultConfigure].nThemeIndex;
    selectedThemeIndex = picIndex;
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"firstInApp":@"YES"}];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"firstInApp"] isEqualToString:@"YES"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    //udp启动
    //注册本地通知
    //获取权限
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    self.udpController = [[UDPController alloc]init];
    //网络配置
    YTKNetworkConfig *config = [YTKNetworkConfig sharedInstance];
    config.baseUrl = @"http://webservice.meddo99.com:9000/";
//    config.baseUrl = @"http://sdk4report.eucp.b2m.cn:8080/";
    /*
     设置状态栏的字体颜色
     同时设置状态栏的字体的颜色要在info.plist文件中设置一个key: UIViewControllerBasedStatusBarAppearance 为NO
     */
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background1.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    /*
    XHDrawerController *drawerController = [[XHDrawerController alloc] init];
    drawerController.springAnimationOn = YES;
    
    LeftSideViewController *leftSideController = [[LeftSideViewController alloc]init];
    RightSideViewController *rightSideController = [[RightSideViewController alloc]init];
    CenterSideViewController *centerSideController = [[CenterSideViewController alloc]init];
    
    drawerController.leftViewController = leftSideController;
    drawerController.rightViewController = rightSideController;
    drawerController.centerViewController = [[UINavigationController alloc] initWithRootViewController:centerSideController];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuBackground"]];
    [backgroundImageView setContentMode:UIViewContentModeCenter];
    drawerController.backgroundView = backgroundImageView;
    self.window.rootViewController = drawerController;
    //using it for size debug设置placeHolder
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
        navi.navigationBarHidden = YES;
        [drawerController presentViewController:navi animated:YES completion:nil];
    });
     */
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
    navi.navigationBarHidden = YES;
    self.window.rootViewController = navi;
    [self getSuggestionList];
    //默认注册一个不开启睡眠时间设置
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepSettingSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultStartTime:@"18:00"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultEndTime:@"06:00"}];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        isUserDefaultTime = NO;
    }else{
        isUserDefaultTime = YES;
    }

    sleep(1);
//    [UIViewController validatePanPackWithMLTransitionGestureRecognizerType:MLTransitionGestureRecognizerTypePan];
//
    [self.window makeKeyAndVisible];

    return YES;
}
//获取专家建议表
- (void)getSuggestionList
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/AssessmentList"];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetSuggestionList *client = [GetSuggestionList shareInstance];
    [client getSuggestionList:header withDetailUrl:urlString];
    if ([client cacheJson]) {
        NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
        NSArray *arrList = [resposeDic objectForKey:@"Assessments"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i = 0; i<arrList.count; i++) {
                NSDictionary *dic = [arrList objectAtIndex:i];
                [[NSUserDefaults standardUserDefaults]setObject:dic forKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"Code"]]];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        });
    }else{
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            NSArray *arrList = [resposeDic objectForKey:@"Assessments"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (int i = 0; i<arrList.count; i++) {
                    NSDictionary *dic = [arrList objectAtIndex:i];
                    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:[NSString stringWithFormat:@"%@",[dic objectForKey:@"Code"]]];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            });
        } failure:^(YTKBaseRequest *request) {
            
        }];
    }
    
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
