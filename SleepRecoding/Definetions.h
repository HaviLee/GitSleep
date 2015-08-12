//
//  Definetions.h
//  FeiMi_Express
//
//  Created by Apple MBP on 14-7-9.
//  Copyright (c) 2014年 Havi_li. All rights reserved.
//
#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif



#define ViewWidth ([UIScreen mainScreen].bounds.size.width - 80)/7
#define CircleWidth                 ([UIScreen mainScreen].bounds.size.height)*0.091454273
#define ButtonViewWidth [UIScreen mainScreen].bounds.size.width - 40
#define ISIPHON4 [UIScreen mainScreen].bounds.size.height==480 ? YES:NO
#define ISIPHON6 [UIScreen mainScreen].bounds.size.height>568 ? YES:NO

#define StatusbarSize 20

//设置统一字号
#define DefaultWordFont      [UIFont systemFontOfSize:17]         
//[UIFont fontWithName:@"Helvetica Bold" size:20]
//app进入后台运行的最长时间
#define RUNTIME                  60*60
#define KDismissKexMenu                     @"dismissKxMenu"

#define heightView             [UIScreen mainScreen].bounds.size.height //屏幕的高度
#define IOS7_OR_LATER          ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define ButtonHeight           44
#define NavigationBarHeight    44
#define TableViewCellHeight    60
//定义日历中的view
#define ViewWidth ([UIScreen mainScreen].bounds.size.width - 80)/7
//定义gif的半径
#define CircleWidth                 ([UIScreen mainScreen].bounds.size.height)*0.091454273
//定义button的宽度
#define ButtonViewWidth [UIScreen mainScreen].bounds.size.width - 40

#if DEBUG
#define HaviLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define HaviLog(tmt, ...)

#endif

#define AppPassWordKey          @"appPassWordKey"
#define AppPassWorkSetOkNoti    @"AppPassWorkSetOkNoti"
#define AppPassWordCancelNoti   @"AppPassWordCancelNoti"
#define RELOADIMAGE             @"reloadImage"
#define ThemeDefaultColor              @"themeColor"
#define PostHeartEmergencyNoti  @"PostHeartEmergencyNoti"
#define PostBreatheEmergencyNoti @"PostBreatheEmergencyNoti"
#define POSTDEVICEUUIDCHANGENOTI @"POSTDEVICEUUIDCHANGENOTI"
#define POSTLOGOUTNOTI           @"POSTLOGOUTNOTI"
#define CHANGEUSERID             @"CHANGEUSERID"
#define CHANGEDEVICEUUID         @"CHANGEDEVICEUUID"
#define TwtityFourHourNoti       @"TwtityFourHourNoti"
#define UserDefaultHourNoti      @"UserDefaultHourNoti"
#define SleepSettingSwitchKey @"isSleepSetting"
#define UserDefaultStartTime   @"defaultStartTime"
#define UserDefaultEndTime   @"defaultEndTime"
/**
 *  登录成功的noti
 */
//第三方appkey
#define WXPlatform @"wx9.com"
#define SinaPlatform @"sina.com"
#define TXPlatform @"qq.com"
#define WXAPPKey @"wx7be2e0c9ebd9e161"
#define WXAPPSecret @"8fc579120ceceae54cb43dc2a17f1d54"

#define LoginSuccessedNoti @"LoginSuccessedNoti"
#define ShowPhoneInputViewNoti  @"ShowPhoneInputViewNoti"
#define ThirdGetPhoneSuccessedNoti  @"ThirdGetPhoneSuccessed"
#define ThirdUserLogoutNoti @"ThirdUserLogoutNoti"
//四个界面noti
#define HeartViewNoti   @"HeartViewNoti"
#define BreathViewNoti  @"BreathViewNoti"
#define LeaveBedViewNoti @"LeaveBedViewNoti"
#define TurnRoundViewNoti @"TurnRoundViewNoti"

#define NOBINDUUID @"NOBINDUUID"
#define NOUSEUUID  @"NOUSEUUID"

#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]
#define DefaultColor [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:1.00f]

#define TimeCacheTime 3*60

@interface Definetions : NSObject

@end
