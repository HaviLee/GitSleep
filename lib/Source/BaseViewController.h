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
#import "CalenderView.h"
#import "ToggleView.h"
#import "LabelLine.h"


@interface BaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) CHTumblrMenuView *shareMenuView;//第三方分享
@property (nonatomic, strong) UIImageView *bgImageView;//背景图片
@property (nonatomic, strong) CalendarHomeViewController *chvc;//日历包括农历
@property (nonatomic, strong) UIImageView *statusBarView;//状态栏
@property (nonatomic, strong) UIView *navView;//导航栏
@property (nonatomic, strong) UIView *rightV;//右侧button
@property (nonatomic, strong) UIImageView *clearStatusBarView;//状态栏
@property (nonatomic, strong) UIView *clearNavView;//透明导航栏
@property (nonatomic, strong) UIView *clearRightV;//透明右侧button
@property (nonatomic, strong) UILabel *clearNaviTitleLabel;//透明导航栏title
@property (nonatomic, strong) OTCover *userInfoTableView;
@property (nonatomic, strong) UITableView *sideTableView;//左侧栏tableview
@property (nonatomic, strong) DatePickerView *datePicker;//水平滑动日历
@property (nonatomic, strong) UIButton *leftButton;//自定义左侧按钮
@property (nonatomic, strong) UIButton *rightButton;//自定义右侧按钮
@property (nonatomic, strong) UIButton *menuButton;//自定义详细按钮
@property (nonatomic, strong) NSArray *sideArray;//左侧栏数据
@property (nonatomic, strong) UIImageView *gifbreath;//gif
@property (nonatomic, strong) UIImageView *gifHeart;
@property (nonatomic, strong) UIImageView *gifLeave;
@property (nonatomic, strong) UIImageView *gifTurn;
@property (nonatomic, strong) NSDateComponents *dateComponentsBase;//
@property (nonatomic, strong) NSDateFormatter *dateFormmatterBase;//格式化日期
@property (nonatomic, strong) NSTimeZone *tmZoneBase;
@property (nonatomic, strong) ToggleView *timeSwitchButton;
@property (nonatomic, strong) UIImageView *gifImageUp;//闪动的上
@property (nonatomic, strong) UIImageView *gifImageDown;//闪动的下
@property (nonatomic, strong) UIImageView *diagnoseImage;//诊断图标
@property (nonatomic, strong) LabelLine *diagonseTitle;//诊断的总结
@property (nonatomic, strong) LabelLine *diagnoseResult;//诊断的结果
@property (nonatomic, strong) LabelLine *diagnoseExplain;//诊断的解释
@property (nonatomic, strong) LabelLine *diagnoseChoice;//诊断的建议
@property (nonatomic, strong) UILabel *diagnoseShow;//待定
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
/**
 *  data转换为dictionary
 *
 *  @param data 需要转换的data
 *
 *  @return 转换成功的字典
 */
- (NSDictionary *)dataToDictionary:(NSData *)data;
/**
 *  创建自定义导航栏
 *
 *  @param szTitle  导航栏title
 *  @param menuItem 自定义导航栏返回键和有侧键
 */
- (void)createNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem;
/**
 *  自定义透明背景的导航栏
 *
 *  @param szTitle  导航栏title
 *  @param menuItem 自定义导航栏返回键和有侧键
 */
- (void)createClearBgNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem;
/**
 *  自定义透明背景的导航栏和titile颜色
 *
 *  @param szTitle  title内容
 *  @param color    title颜色
 *  @param menuItem 自定义导航栏返回键和有侧键
 */
- (void)createClearBgNavWithTitle:(NSString *)szTitle andTitleColor:(UIColor *)color createMenuItem:(UIView *(^)(int nIndex))menuItem;
/**
 *  16进制颜色转换
 *
 *  @param hexValue   16进制颜色
 *  @param alphaValue 透明度
 *
 *  @return 返回UIColor
 */
- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
/**
 *  对日期进行时区转换
 */
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;
/**
 *  检查网络状况2g，3g，4g，wifi
 *
 *  @return 返回网络状况
 */
+ (NSInteger)networkStatus;
/**
 *  检查网络是否存在
 *
 *  @return bool
 */
+ (BOOL)isNetworkExist;
/**
 *  获取当前时间
 *
 *  @return 加过时区的时间
 */
- (NSDate*)getNowDate;
/**
 *  截屏功能，为分享使用
 *
 *  @return 返回截屏图片
 */
- (UIImage *) captureScreen;
/**
 *  下载迈动平台用户头像
 *
 *  @param imageview 展示的imageview
 *
 *  @return 返回头像的数据
 */
- (NSData *)downloadWithImage:(UIImageView *)imageview;
/**
 *  检测微信，qq，微博是否全部安装
 *
 *  @return bool
 */
- (BOOL)isThirdAppAllInstalled;
@end
