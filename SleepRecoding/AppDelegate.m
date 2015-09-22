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
#import "YTKNetworkConfig.h"
#import "LoginViewController.h"
#import "UIViewController+MLTransition.h"
#import "GetSuggestionList.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "WeiXinAPI.h"
#import "WeiboSDK.h"
#import "ThirdRegisterAPI.h"
#import "CheckUserIsRegister.h"
#import "WeiBoAPI.h"
#import "SHGetClient.h"
#import "MMPopupWindow.h"
#import "MMAlertView.h"
#import "MMSheetView.h"

//
#import "LoginContainerViewController.h"//架构重构
#import "CenterViewController.h"//架构重构
@interface AppDelegate ()<WXApiDelegate,WeiboSDKDelegate,TencentSessionDelegate>
@property (nonatomic,strong) LoginContainerViewController *loginView;
@property (nonatomic,strong) NSDictionary *ThirdPlatformInfoDic;
@property (nonatomic,strong) NSString *thirdPlatform;
@property (nonatomic,strong) NSString *tencentID;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104815310" andDelegate:self];
    //微博注册
    [WeiboSDK registerApp:WBAPPKey];
    [WeiboSDK enableDebugMode:YES];
    //向微信注册
    [WXApi registerApp:WXAPPKey];
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
    config.baseUrl = BaseUrl;
//    config.baseUrl = @"http://sdk4report.eucp.b2m.cn:8080/";
    /*
     设置状态栏的字体颜色
     同时设置状态栏的字体的颜色要在info.plist文件中设置一个key: UIViewControllerBasedStatusBarAppearance 为NO
     */
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background1.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    //
    [self getSuggestionList];
    [self setThirdLoginNoti];
    
    //默认注册一个不开启睡眠时间设置
//    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepSettingSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultStartTime:@"18:00"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultEndTime:@"06:00"}];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        isUserDefaultTime = NO;
    }else{
        isUserDefaultTime = YES;
    }
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CenterSideViewController alloc] init]];
    if ([UserManager IsUserLogged]) {
        [UserManager GetUserObj];
    }
    self.centerViewController = [[CenterViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.centerViewController];
    LeftSideViewController *leftMenuViewController = [[LeftSideViewController alloc] init];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:leftMenuViewController
                                                                   rightMenuViewController:nil];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:[NSDate date]]];
    NSString *sub = [nowDateString substringWithRange:NSMakeRange(11, 2)];
    if ([sub intValue]>7 && [sub intValue]<18) {
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_day"];
    }else{
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_night_0"];
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
    [self configAlertView];
    return YES;
}

- (void)configAlertView
{
    [[MMPopupWindow sharedWindow] cacheWindow];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    MMSheetViewConfig *sheetConfig = [MMSheetViewConfig globalConfig];
    
    alertConfig.defaultTextOK = @"确认";
    alertConfig.backgroundColor = [UIColor colorWithRed:0.000f green:0.024f blue:0.047f alpha:1.00f];
    alertConfig.titleColor = [UIColor whiteColor];
    alertConfig.detailColor = [UIColor whiteColor];
    alertConfig.itemNormalColor = [UIColor whiteColor];
    alertConfig.itemHighlightColor = [UIColor whiteColor];
    alertConfig.splitColor = [UIColor whiteColor];
    
    alertConfig.defaultTextCancel = @"取消";
    alertConfig.defaultTextConfirm = @"确认";
    
    sheetConfig.defaultTextCancel = @"Cancel";
}

- (void)setThirdLoginNoti
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(thirdUserPhoneNoti:) name:ThirdGetPhoneSuccessedNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setLoginView) name:ThirdUserLogoutNoti object:nil];
}

//设置登录界面。
- (void)setLoginView
{
    self.loginView = [[LoginContainerViewController alloc]init];
    _loginView.view.frame = [UIScreen mainScreen].bounds;
    __block typeof(self) weakSelf = self;
    _loginView.loginSuccessed = ^(NSUInteger index) {
        [weakSelf hideLoginView];
        //监听网络
        [weakSelf setWifiNotification];
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
    [self getDefaultTime];
}

- (void)getDefaultTime
{
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@v1/user/UserInfo?UserID=%@",BaseUrl,[dic objectForKey:@"UserID"] ] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            NSDictionary *dic = [resposeDic objectForKey:@"UserInfo"];
            NSString *startString = [dic objectForKey:@"SleepStartTime"];
            NSString *endString = [dic objectForKey:@"SleepStartTime"];
            if (startString.length!=0&&endString.length!=0) {
                [[NSUserDefaults standardUserDefaults]setObject:[[resposeDic objectForKey:@"UserInfo"] objectForKey:@"SleepStartTime"] forKey:UserDefaultStartTime ];
                [[NSUserDefaults standardUserDefaults]setObject:[[resposeDic objectForKey:@"UserInfo"] objectForKey:@"SleepEndTime"] forKey:UserDefaultEndTime ];
            }
            
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10029){
            [[NSNotificationCenter defaultCenter]postNotificationName:ShowPhoneInputViewNoti object:nil userInfo:nil];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
}
//
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self.loginView.view removeFromSuperview];
    }
}

#pragma mark 网络监听
-(void) setWifiNotification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
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
    });
}

-(void)reachabilityChanged:(NSNotification*)note
{
    @try {
        
        Reachability * reach = [note object];
        
        if ([reach isReachable]) {
            if ([reach isReachableViaWiFi]) {
                [[UIApplication sharedApplication].keyWindow makeToast:@"您已切换至Wifi网络" duration:3 position:@"center"];
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
#pragma mark 获取专家建议表
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
    //
    
}

#pragma mark 第三方回调函数
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //wb2199355574://response?id=C332B448-99AA-48CB-9588-D18D3F122F9D&sdkversion=2.5
    //
    NSRange range = [[NSString stringWithFormat:@"%@",url]rangeOfString:@"://"];
    if ([[[NSString stringWithFormat:@"%@",url] substringToIndex:range.location]isEqualToString:@"wb2199355574"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if([[[NSString stringWithFormat:@"%@",url] substringToIndex:range.location]isEqualToString:@"wx7be2e0c9ebd9e161"]){
        return  [WXApi handleOpenURL:url delegate:self];
    }else{
        return YES;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //从第三方回来
    isThirdLogin = NO;
    HaviLog(@"tengxunis %@,%@",url,sourceApplication);
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return  [WXApi handleOpenURL:url delegate:self];
    }else if ([sourceApplication isEqualToString:@"com.sina.weibo"]){
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if ([sourceApplication isEqualToString:@"com.tencent.mqq"]){
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

#pragma mark 微信回调函数

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        /*
        GetMessageFromWXReq *temp = (GetMessageFromWXReq *)req;
        */
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
       
        
        
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        /*
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n附加消息:%@\n", temp.openID, msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length, msg.messageExt];
        */
       
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        /*

        LaunchFromWXReq *temp = (LaunchFromWXReq *)req;
        WXMediaMessage *msg = temp.message;
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", temp.openID, msg.messageExt];
        */
       
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (resp.errCode == 0) {
            [self.window makeToast:@"分享成功" duration:2 position:@"center"];
        }else{
            [self.window makeToast:@"取消分享" duration:2 position:@"center"];
        }
        
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        if (temp.code) {
            [WeiXinAPI getWeiXinInfoWith:temp.code parameters:nil finished:^(NSURLResponse *response, NSData *data) {
                NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //第三方登录
                self.ThirdPlatformInfoDic = obj;
                [self checkUseridIsRegister:obj andPlatform:WXPlatform];
                NSLog(@"用户信息是%@",obj);
            } failed:^(NSURLResponse *response, NSError *error) {
                
            }];
        }else{
            [self.window makeToast:@"取消登录" duration:1 position:@"center"];
        }
        
    }
    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]])
    {
        AddCardToWXCardPackageResp* temp = (AddCardToWXCardPackageResp*)resp;
        NSMutableString* cardStr = [[NSMutableString alloc] init];
        for (WXCardItem* cardItem in temp.cardAry) {
            [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
        }
        
    }
}

#pragma mark 新浪回调

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        if ((int)response.statusCode ==0) {
            [self.window makeToast:@"分享成功" duration:2 position:@"center"];
        }else{
            [self.window makeToast:@"取消分享" duration:2 position:@"center"];
        }
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        if (self.wbtoken) {
            self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
            NSDictionary *dic = @{
                                  @"access_token" : self.wbtoken,
                                  @"uid" : self.wbCurrentUserID,
                                  };
            [WeiBoAPI getWeiBoInfoWith:nil parameters:dic finished:^(NSURLResponse *response, NSData *data) {
                NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                self.ThirdPlatformInfoDic = obj;
                [self checkUseridIsRegister:obj andPlatform:SinaPlatform];
                NSLog(@"获取到微博个人信息%@",obj);
                
            } failed:^(NSURLResponse *response, NSError *error) {
                
            }];
        }else{
            [self.window makeToast:@"取消登录" duration:1 position:@"center"];
        }
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        /*
        NSString *title = NSLocalizedString(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        */
    }
}

#pragma mark qq回调

///**
// 处理来至QQ的请求
// */
//- (void)onReq:(QQBaseReq *)req
//{
//}
//
///**
// 处理来至QQ的响应
// */
//- (void)onResp:(QQBaseResp *)resp
//{
//}


- (void)tencentDidLogin
{
    HaviLog(@"qq登录成功");
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        if ([self.tencentOAuth getUserInfo]) {
            //检测帐号
            self.tencentID = self.tencentOAuth.openId;
            HaviLog(@"用户的信息是%@",self.tencentOAuth.passData);
            
        }
    }
    else
    {
    }

    
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        [self.window makeToast:@"登录取消" duration:2 position:@"center"];
    }
    else
    {
        [self.window makeToast:@"登录失败" duration:2 position:@"center"];
    }

}

- (void)tencentDidNotNetWork
{
    HaviLog(@"网络出错");
    [self.window makeToast:@"网络错误" duration:2 position:@"center"];
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    HaviLog(@"用户回调%@",response.jsonResponse);
    self.ThirdPlatformInfoDic = response.jsonResponse;
    [self checkUseridIsRegister:response.jsonResponse andPlatform:TXPlatform];
}

#pragma mark 自身帐号注册检查

- (void)checkUseridIsRegister:(NSDictionary *)infoDic andPlatform:(NSString *)platfrom
{
    NSString *thirdID;
    NSString *thirdName;
    if ([platfrom isEqualToString:WXPlatform]) {
        thirdName = [infoDic objectForKey:@"nickname"];
    }else if ([platfrom isEqualToString:SinaPlatform]){
        thirdName = [infoDic objectForKey:@"name"];
    }else{
        thirdName = [infoDic objectForKey:@"nickname"];
    }
    if ([platfrom isEqualToString:WXPlatform]) {
        thirdID = [infoDic objectForKey:@"unionid"];
    }else if ([platfrom isEqualToString:SinaPlatform]){
        thirdID = [infoDic objectForKey:@"id"];
    }else{
        thirdID = self.tencentID;
    }
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSDictionary *dic = @{
                          @"UserID": [NSString stringWithFormat:@"%@$%@",platfrom,thirdID], //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@v1/user/UserInfo?UserID=%@",BaseUrl,[dic objectForKey:@"UserID"] ] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"检测结果是userid 是%@：%@",[dic objectForKey:@"UserID"],resposeDic);
        [MMProgressHUD dismiss];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            NSDictionary *dic = [resposeDic objectForKey:@"UserInfo"];
            NSString *startString = [dic objectForKey:@"SleepStartTime"];
            NSString *endString = [dic objectForKey:@"SleepStartTime"];
            if (startString.length!=0&&endString.length!=0) {
                [[NSUserDefaults standardUserDefaults]setObject:[[resposeDic objectForKey:@"UserInfo"] objectForKey:@"SleepStartTime"] forKey:UserDefaultStartTime ];
                [[NSUserDefaults standardUserDefaults]setObject:[[resposeDic objectForKey:@"UserInfo"] objectForKey:@"SleepEndTime"] forKey:UserDefaultEndTime ];
            }

            thirdPartyLoginPlatform = platfrom;
            thirdPartyLoginUserId = [[resposeDic objectForKey:@"UserInfo"] objectForKey:@"UserID"];
            thirdPartyLoginNickName = thirdName;
            if ([platfrom isEqualToString:WXPlatform]) {
                thirdPartyLoginIcon = [self.ThirdPlatformInfoDic objectForKey:@"headimgurl"];
            }else if ([platfrom isEqualToString:SinaPlatform]){
                thirdPartyLoginIcon = [self.ThirdPlatformInfoDic objectForKey:@"profile_image_url"];
            }else {
                thirdPartyLoginIcon = [self.ThirdPlatformInfoDic objectForKey:@"figureurl_qq_2"];
            }
            thirdPartyLoginToken = @"";
            [UserManager setGlobalOauth];
            [[NSNotificationCenter defaultCenter]postNotificationName:LoginSuccessedNoti object:nil userInfo:nil];
            [self hideLoginView];
            //发现第三方帐号没有注册过
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10029){
            self.thirdPlatform = platfrom;
            [[NSNotificationCenter defaultCenter]postNotificationName:ShowPhoneInputViewNoti object:nil userInfo:nil];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.window makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}
#pragma mark 第三方输入手机号完成后的消息
- (void)thirdUserPhoneNoti:(NSNotification*)noti
{
    NSDictionary *dic = (NSDictionary *)noti.userInfo;
    if ([self.thirdPlatform isEqualToString:WXPlatform]) {
        [self thirdUserRegister:self.ThirdPlatformInfoDic andPhoneDic:dic andPlatform:WXPlatform];
    }else if ([self.thirdPlatform isEqualToString:SinaPlatform]){
        [self thirdUserRegister:self.ThirdPlatformInfoDic andPhoneDic:dic andPlatform:SinaPlatform];
    }else{
        [self thirdUserRegister:self.ThirdPlatformInfoDic andPhoneDic:dic andPlatform:TXPlatform];
    }
}
#pragma mark 向我们自己的后台完成注册
- (void)thirdUserRegister:(NSDictionary *)infoDic andPhoneDic:(NSDictionary *)phoneDic andPlatform:(NSString*)platform
{
    NSString *thirdID;
    NSString *thirdName;
    if ([platform isEqualToString:WXPlatform]) {
        thirdName = [infoDic objectForKey:@"nickname"];
    }else if ([platform isEqualToString:SinaPlatform]){
        thirdName = [infoDic objectForKey:@"name"];
    }else{
        thirdName = [infoDic objectForKey:@"nickname"];
    }
    if ([platform isEqualToString:WXPlatform]) {
        thirdID = [infoDic objectForKey:@"unionid"];
    }else if ([platform isEqualToString:SinaPlatform]){
        thirdID = [infoDic objectForKey:@"id"];
    }else{
        thirdID = self.tencentID;
    }
    NSDictionary *dic = @{
                          @"CellPhone": [phoneDic objectForKey:@"phone"], //手机号码
                          @"Email": @"", //邮箱地址，可留空，扩展注册用
                          @"Password": @"" ,//传递明文，服务器端做加密存储
                          @"UserValidationServer" : platform,
                          @"UserIdOriginal":thirdID
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    /*
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"注册中..."];
     */
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    [WTRequestCenter postWithURL:[NSString stringWithFormat:@"%@v1/user/UserRegister",BaseUrl] header:header parameters:dic finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"注册成功%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            thirdPartyLoginPlatform = platform;
            thirdPartyLoginOriginalId = thirdID;//
            thirdPartyLoginUserId = [resposeDic objectForKey:@"UserID"];
            thirdPartyLoginNickName = thirdName;
            if ([platform isEqualToString:WXPlatform]) {
                thirdPartyLoginIcon = [NSString stringWithFormat:@"%@",[self.ThirdPlatformInfoDic objectForKey:@"headimgurl"]];
            }else if ([platform isEqualToString:SinaPlatform]){
                thirdPartyLoginIcon = [NSString stringWithFormat:@"%@",[self.ThirdPlatformInfoDic objectForKey:@"avatar_hd"]];
            }else {
                thirdPartyLoginIcon = [NSString stringWithFormat:@"%@",[self.ThirdPlatformInfoDic objectForKey:@"figureurl_qq_2"]];
            }
            
            thirdPartyLoginToken = @"";
            [[NSNotificationCenter defaultCenter]postNotificationName:LoginSuccessedNoti object:nil userInfo:nil];
            [UserManager setGlobalOauth];
            [self hideLoginView];
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10005){
            [MMProgressHUD dismiss];
            [self.window makeToast:@"该帐号已注册" duration:2 position:@"center"];
        }else {
            [MMProgressHUD dismiss];
            [self.window makeToast:[resposeDic objectForKey:@"ErrorMessage"] duration:2 position:@"center"];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.window makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
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
