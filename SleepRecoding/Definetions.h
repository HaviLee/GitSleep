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


#define BaseUrl @"http://webservice.meddo99.com:9000/"
#define ViewWidth ([UIScreen mainScreen].bounds.size.width - 80)/7
#define CircleWidth                 ([UIScreen mainScreen].bounds.size.height)*0.091454273
#define ButtonViewWidth [UIScreen mainScreen].bounds.size.width - 40
#define ISIPHON4 [UIScreen mainScreen].bounds.size.height==480 ? YES:NO
#define ISIPHON6 [UIScreen mainScreen].bounds.size.height>568 ? YES:NO

#define kScreen_Bounds [UIScreen mainScreen].bounds
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define kScaleFrom_iPhone5_Desgin(_X_) (_X_ * (kScreen_Width/320))
#define StatusbarSize 20

#define kFlagButtonColor        [UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:0/255.0 alpha:1]
#define kMoreButtonColor        [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1]
#define kArchiveButtonColor     [UIColor colorWithRed:60.0/255.0 green:112.0/255.0 blue:168/255.0 alpha:1]
#define kUnreadButtonColor      [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]

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
#define  kBadgeTipStr @"badgeTip"

#define ThemeDefaultColor              @"themeColor"
#define PostHeartEmergencyNoti  @"PostHeartEmergencyNoti"
#define PostBreatheEmergencyNoti @"PostBreatheEmergencyNoti"
#define POSTDEVICEUUIDCHANGENOTI @"POSTDEVICEUUIDCHANGENOTI"
#define POSTLOGOUTNOTI           @"POSTLOGOUTNOTI"
#define CHANGEUSERID             @"CHANGEUSERID"
#define CHANGEDEVICEUUID         @"CHANGEDEVICEUUID"
#define CHANGEDEVICNAME         @"CHANGEDEVICNAME"
#define SleepSettingSwitchKey @"isSleepSetting"
#define UserDefaultStartTime   @"defaultStartTime"
#define UserDefaultEndTime   @"defaultEndTime"

#define LoginSuccessedNoti @"LoginSuccessedNoti"
#define ShowPhoneInputViewNoti  @"ShowPhoneInputViewNoti"
#define ThirdGetPhoneSuccessedNoti  @"ThirdGetPhoneSuccessed"
#define ThirdUserLogoutNoti @"ThirdUserLogoutNoti"
//四个界面noti
#define HeartViewNoti   @"HeartViewNoti"
#define BreathViewNoti  @"BreathViewNoti"
#define LeaveBedViewNoti @"LeaveBedViewNoti"
#define TurnRoundViewNoti @"TurnRoundViewNoti"

#define ShowLeaveBedAlertNoti @"ShowLeaveBedAlertNoti"
#define ShowLeaveBedAfterTime @"ShowLeaveBedAfterTime"
/**
 *  登录成功的noti
 */
//第三方appkey
#define WXPlatform @"wx.com"
#define SinaPlatform @"sina.com"
#define TXPlatform @"qq.com"
#define MeddoPlatform @"meddo99.com"
#define WXAPPKey @"wx7be2e0c9ebd9e161"
#define WXAPPSecret @"8fc579120ceceae54cb43dc2a17f1d54"
//
#define WBAPPKey @"2199355574"
#define WBRedirectURL @"http://www.meddo.com"

#define NOBINDUUID @"NOBINDUUID"
#define NOUSEUUID  @"NOUSEUUID"

#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]
#define DefaultColor [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:1.00f]

#define TimeCacheTime 3*60

@interface Definetions : NSObject

@end
