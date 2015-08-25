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
#import "CalendarHomeViewController.h"

//
#import "CalenderView.h"
#import "ToggleView.h"
#import "LabelLine.h"


@interface BaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) CHTumblrMenuView *shareMenuView;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic, strong) CalendarHomeViewController *chvc;
@property (nonatomic, strong) UIImageView *statusBarView;//状态栏
@property (nonatomic, strong) UIView *navView;//导航栏
@property (nonatomic, strong) UIView *rightV;//右侧button
@property (nonatomic, strong) UIImageView *clearStatusBarView;//状态栏
@property (nonatomic, strong) UIView *clearNavView;//导航栏
@property (nonatomic, strong) UIView *clearRightV;//右侧button
@property (nonatomic, strong) UILabel *clearNaviTitleLabel;//title
@property (nonatomic,strong) OTCover *userInfoTableView;
@property (nonatomic,strong) UITableView *sideTableView;
@property (nonatomic ,strong) DatePickerView *datePicker;
@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,strong) UIButton *menuButton;
@property (nonatomic,strong) NSArray *sideArray;
@property (nonatomic,strong) UIImageView *gifbreath;
@property (nonatomic,strong) UIImageView *gifHeart;
@property (nonatomic,strong) UIImageView *gifLeave;
@property (nonatomic,strong) UIImageView *gifTurn;
@property (nonatomic,strong) UIView * keybordView;
@property (nonatomic,assign) int keybordheight;
@property (nonatomic,strong) NSDateComponents *dateComponentsBase;
@property (nonatomic,strong) NSDateFormatter *dateFormmatterBase;
@property (nonatomic,strong) NSTimeZone *tmZoneBase;
@property (nonatomic, strong) ToggleView *timeSwitchButton;
@property (nonatomic,strong) UIImageView *gifImageUp;//闪动的上
@property (nonatomic,strong) UIImageView *gifImageDown;//闪动的下
@property (nonatomic,strong) UIImageView *diagnoseImage;//诊断图标
@property (nonatomic,strong) LabelLine *diagonseTitle;//诊断的总结
@property (nonatomic,strong) LabelLine *diagnoseResult;//诊断的结果
@property (nonatomic,strong) LabelLine *diagnoseExplain;//诊断的解释
@property (nonatomic,strong) LabelLine *diagnoseChoice;//诊断的建议
@property (nonatomic,strong) UILabel *diagnoseShow;//待定
@property (nonatomic,strong) UIImageView *cellImage1;
/**
 *  缓存文件时间
 *
 *  @param path 缓存路径
 *
 *  @return 返回缓存时间
 */
- (int)cacheFileDuration:(NSString *)path;
/**
 *  根据名字缓存文件
 *
 *  @param nameType 文件名
 *
 *  @return 缓存路径
 */
- (NSString *)cacheFilePathWithName:(NSString *)nameType;
/**
 *  进行换肤
 */
- (void)reloadThemeImage;
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
- (UIImage *) captureScreen;
//下载头像
- (NSData *)downloadWithImage:(UIImageView *)imageview;
- (BOOL)isThirdAppAllInstalled;
@end
