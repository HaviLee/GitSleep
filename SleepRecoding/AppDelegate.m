//
//  AppDelegate.m
//  SleepRecoding
//
//  Created by Havi on 15/2/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftSideViewController.h"
#import "RightSideViewController.h"
#import "CenterSideViewController.h"
#import "YTKNetworkConfig.h"
#import "LoginViewController.h"
#import "UIViewController+MLTransition.h"
#import "GetSuggestionList.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//
#import "LoginContainerViewController.h"//架构重构
#import "CenterViewController.h"//架构重构
@interface AppDelegate ()
@property (nonatomic,strong) LoginContainerViewController *loginView;
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
    //
    /*
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
    navi.navigationBarHidden = YES;
    self.window.rootViewController = navi;
     */
    [self getSuggestionList];
    //监听网络
    [self setWifiNotification];
    //默认注册一个不开启睡眠时间设置
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepSettingSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultStartTime:@"18:00"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultEndTime:@"06:00"}];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        isUserDefaultTime = NO;
    }else{
        isUserDefaultTime = YES;
    }
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CenterSideViewController alloc] init]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CenterViewController alloc] init]];
    LeftSideViewController *leftMenuViewController = [[LeftSideViewController alloc] init];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:leftMenuViewController
                                                                   rightMenuViewController:nil];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:[NSDate date]]];
    NSString *sub = [nowDateString substringWithRange:NSMakeRange(11, 2)];
    if ([sub intValue]>7 && [sub intValue]<18) {
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_day"];
    }else{
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_night"];
    }
    sideMenuViewController.menuPreferredStatusBarStyle = 0; // UIStatusBarStyleLightContent
    //    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    self.sideMenuController = sideMenuViewController;
    self.window.rootViewController = self.sideMenuController;
//    [UIViewController validatePanPackWithMLTransitionGestureRecognizerType:MLTransitionGestureRecognizerTypePan];
    [self.window makeKeyAndVisible];
    [self setLoginView];
    
    return YES;
}

//设置登录界面。
- (void)setLoginView
{
    self.loginView = [[LoginContainerViewController alloc]init];
    _loginView.view.frame = [UIScreen mainScreen].bounds;
    __block typeof(self) weakSelf = self;
    _loginView.loginSuccessed = ^(NSUInteger index) {
        [weakSelf hideLoginView];
        //发送登录成noti
        [[NSNotificationCenter defaultCenter]postNotificationName:LoginSuccessedNoti object:nil userInfo:nil];
    };
    [self.window addSubview:_loginView.view];
}

- (void)hideLoginView
{
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    theAnimation.delegate = self;
    theAnimation.duration = 0.5;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:0];
    theAnimation.toValue = [NSNumber numberWithFloat:-[UIScreen mainScreen].bounds.size.height];
    [self.loginView.view.layer addAnimation:theAnimation forKey:@"animateLayer"];
}
//
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self.loginView.view removeFromSuperview];
    }
}


-(void) setWifiNotification {
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
    [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
    {
        NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
    }];
    @try {
        
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        reach.reachableBlock = ^(Reachability * reachability)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Block Says Reachable");
            });
        };
        
        reach.unreachableBlock = ^(Reachability * reachability)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Block Says Unreachable");
            });
        };
        [reach startNotifier];
    }@catch (NSException *e) {
        ;
    }
}

-(void)reachabilityChanged:(NSNotification*)note
{
    @try {
        
        Reachability * reach = [note object];
        
        if ([reach isReachable]) {
            if ([reach isReachableViaWiFi]) {
                [[UIApplication sharedApplication].keyWindow makeToast:@"您已切换至Wifi网络" duration:3 position:@"center"];
//                [self.view makeToast:@"您已切换至Wifi网络" duration:3 position:@"center"];
            }else if ([reach isReachableViaWWAN]){
                if ([[reach currentReachabilityFrom234G]isEqualToString:@"2G"]) {
                    
                    [[UIApplication sharedApplication].keyWindow makeToast:@"您已切换至2G网络" duration:3 position:@"center"];
                }else if ([[reach currentReachabilityFrom234G]isEqualToString:@"3G"]) {
                    [[UIApplication sharedApplication].keyWindow makeToast:@"您已切换至3G网络" duration:3 position:@"center"];
                }else if ([[reach currentReachabilityFrom234G]isEqualToString:@"4G"]){
                    [[UIApplication sharedApplication].keyWindow makeToast:@"您已切换至4G网络" duration:3 position:@"center"];
                    
                }
            }
        }else {
//            [self.view makeToast:@"当前没有网络,请检查您的手机" duration:3 position:@"center"];
            [[UIApplication sharedApplication].keyWindow makeToast:@"没有网络,请检查您的网络！" duration:3 position:@"center"];
        }
    } @catch (NSException *e) {
        ;
    }
}
//监听

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    if (sourceTimeZone) {
        sourceTimeZone = nil;
    }
    if (destinationTimeZone) {
        destinationTimeZone = nil;
    }
    return destinationDateNow;
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
