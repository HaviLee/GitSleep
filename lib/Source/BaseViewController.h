//
//  BaseViewController.h
//  SleepRecoding
//
//  Created by Havi_li on 15/2/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerView.h"
#import "GifView.h"
#import "OTCover.h"
#import "CHTumblrMenuView.h"
//
#import "CalenderView.h"
#import "ToggleView.h"
#import "LabelLine.h"


@interface BaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) CHTumblrMenuView *shareMenuView;
//背景颜色
@property (nonatomic,strong) UIImageView *bgImageView;

//创建带有背景图片的导航栏
@property (nonatomic, strong) UIImageView *statusBarView;//状态栏
@property (nonatomic, strong) UIView *navView;//导航栏
@property (nonatomic, strong) UIView *rightV;//右侧button
//创建透明的导航栏
@property (nonatomic, strong) UIImageView *clearStatusBarView;//状态栏
@property (nonatomic, strong) UIView *clearNavView;//导航栏
@property (nonatomic, strong) UIView *clearRightV;//右侧button
//
@property (nonatomic,strong) OTCover *userInfoTableView;
//
@property (nonatomic,strong) UITableView *sideTableView;
@property (nonatomic ,strong) DatePickerView *datePicker;
@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,strong) UIButton *menuButton;
@property (nonatomic,strong) NSArray *sideArray;

//
@property (nonatomic,strong) UIImageView *gifbreath;
@property (nonatomic,strong) UIImageView *gifHeart;
@property (nonatomic,strong) UIImageView *gifLeave;
@property (nonatomic,strong) UIImageView *gifTurn;

//键盘
@property (nonatomic,strong) UIView * keybordView;
@property (nonatomic,assign) int keybordheight;
//
@property (nonatomic,strong) NSDateComponents *dateComponentsBase;
@property (nonatomic,strong) NSDateFormatter *dateFormmatterBase;
@property (nonatomic,strong) NSTimeZone *tmZoneBase;
//心率呼吸离床体动的
@property (nonatomic, strong) ToggleView *timeSwitchButton;
@property (nonatomic,strong) UIImageView *gifImageUp;//闪动的上
@property (nonatomic,strong) UIImageView *gifImageDown;//闪动的下
@property (nonatomic,strong) UIImageView *diagnoseImage;//诊断图标
@property (nonatomic,strong) LabelLine *diagonseTitle;//诊断的总结
@property (nonatomic,strong) LabelLine *diagnoseResult;//诊断的结果
@property (nonatomic,strong) LabelLine *diagnoseExplain;//诊断的解释
@property (nonatomic,strong) LabelLine *diagnoseChoice;//诊断的建议
@property (nonatomic,strong) UILabel *diagnoseShow;//待定
//背景
@property (nonatomic,strong) UIImageView *cellImage1;
//时间缓存监控
- (int)cacheFileDuration:(NSString *)path;

- (NSString *)cacheFilePathWithName:(NSString *)nameType;

- (void)reloadImage;
//将nsdata转换位字典
- (NSDictionary *)dataToDictionary:(NSData *)data;
//设置自定义导航栏
- (void)createNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem;
//创建透明背景的
- (void)createClearBgNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem;
- (void)createClearBgNavWithTitle:(NSString *)szTitle andTitleColor:(UIColor *)color createMenuItem:(UIView *(^)(int nIndex))menuItem;
- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
//进行日期时区的转换
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;
//检测网络的
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

- (NSDate*)getNowDate;
- (void)keyboardWillShow:(NSNotification *)notification;
@end
