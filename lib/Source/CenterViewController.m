//
//  CenterViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/7/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CenterViewController.h"
#import "CalenderCantainerViewController.h"
#import "CenterViewTableViewCell.h"
//#import "UITableView+Wave.h"
#import "CHCircleGaugeView.h"
#import "NightTimeView.h"
#import "DayTimeView.h"
#import "TagShowViewController.h"
#import "DeviceManagerViewController.h"
#import "UDPAddProductViewController.h"
//
#import "GetDeviceStatusAPI.h"
#import "GetDefatultSleepAPI.h"
//
#import "NewTodayHeartViewController.h"
#import "NewTodayBreathViewController.h"
#import "NewTodayLeaveViewController.h"
#import "NewTodayTurnViewController.h"
#import "CalendarHomeViewController.h"
#import "URBAlertView.h"

@interface CenterViewController ()<SetScrollDateDelegate,SelectCalenderDate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *cellTableView;
@property (nonatomic, strong) UILabel *sleepTimeLabel;
@property (nonatomic, strong) CHCircleGaugeView *circleView;
@property (nonatomic, strong) NSArray *cellDataArr;
@property (nonatomic, strong) NightTimeView *nightView;
@property (nonatomic, strong) DayTimeView *dayView;
@property (nonatomic, strong) UITapGestureRecognizer *tapDayViewGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapNightViewGesture;
@property (nonatomic, strong) NSArray *dataViewArr;
//为了标签使用
@property (nonatomic, strong) NSString *tagFromDateAndEndDate;
//
@property (nonatomic, strong) NewTodayHeartViewController *todayHeartView;
@property (nonatomic, strong) NewTodayBreathViewController *todayBreathView;
@property (nonatomic, strong) NewTodayLeaveViewController *todayLeaveView;
@property (nonatomic, strong) NewTodayTurnViewController *todayTurnView;
//

@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setCalenderAndMenu];
    [self createTableView];
    [self createCircleView];
    [self setNotifationList];
    
}

- (void)initData
{
    self.cellDataArr = @[@"0次/分",@"0次/分",@"0次/天",@"0次/天"];
    self.dataViewArr = @[self.todayHeartView,self.todayBreathView,self.todayLeaveView,self.todayTurnView];
}
#pragma mark 创建消息监听

- (void)setNotifationList
{
   //监听登录成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccessAndQueryData:) name:LoginSuccessedNoti object:nil];
}

#pragma mark 消息监听方法

- (void)loginSuccessAndQueryData:(NSNotification *)noti
{
    [self getAllDeviceList];
}

#pragma mark 数据请求
//请求帐号下的设备列表
- (void)getAllDeviceList
{
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",thirdPartyLoginUserId];
    
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"用户%@下所有的设备%@",thirdPartyLoginUserId,resposeDic);
        [MMProgressHUD dismiss];
        NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
        if (arr.count == 0) {
            self.clearNaviTitleLabel.text = thirdHardDeviceName;
        }else{
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    HardWareUUID = [dic objectForKey:@"UUID"];
                    thirdHardDeviceUUID = [dic objectForKey:@"UUID"];
                    thirdHardDeviceName = [dic objectForKey:@"Description"];
                    self.clearNaviTitleLabel.text = thirdHardDeviceName;
                    [UserManager setGlobalOauth];
                    HaviLog(@"用户%@关联默认的uuid是%@",thirdPartyLoginUserId,HardWareUUID);
                    break;
                }
            }
        }
        if (![HardWareUUID isEqualToString:@""]) {
            NSString *nowDateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
            [self getTodaySleepQualityData:newString];
        }else{
            URBAlertView *alertView = [URBAlertView dialogWithTitle:@"注意" subtitle:@"您还没有绑定设备,是否现在去绑定？"];
            alertView.blurBackground = NO;
            [alertView addButtonWithTitle:@"取消"];
            [alertView addButtonWithTitle:@"确认"];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hideWithAnimation:URBAlertAnimationFade completionBlock:^{
                    if (buttonIndex == 1) {
                        DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
                        [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
                    }
                }];
                
            }];
            [alertView showWithAnimation:URBAlertAnimationFade];
        }
        
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
}

- (void)getTodaySleepQualityData:(NSString *)nowDateString
{
    //fromdate 是当天的日期
    if ([HardWareUUID isEqualToString:@""]) {
        URBAlertView *alertView = [URBAlertView dialogWithTitle:@"注意" subtitle:@"您还没有绑定设备"];
        alertView.blurBackground = NO;
        [alertView addButtonWithTitle:@"确认"];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hide];
            
        }];
        [alertView showWithAnimation:URBAlertAnimationFade];

        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!nowDateString) {
        
        return;
    }
    NSDate *newDate = [self.dateFormmatterBase dateFromString:nowDateString];
    NSString *urlString = @"";
    if (isTodayHourEqualSixteen<18) {
        self.dateComponentsBase.day = -1;
        NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,nowDateString];
    }else {
        self.dateComponentsBase.day = 1;
        NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
        NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,nowDateString,newNextDayString];
        
    }
    self.tagFromDateAndEndDate = urlString;
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDefatultSleepAPI *client = [GetDefatultSleepAPI shareInstance];
    /*
     增加了一个判断当前的是不是在进行，进行的话终止
     */
    if ([client isExecuting]) {
        [client stop];
    }
    [client queryDefaultSleep:header withDetailUrl:urlString];
    if ([client getCacheJsonWithDate:nowDateString]) {
        NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
        HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
        //为了异常报告
        [self refreshViewWithSleepData:resposeDic];
    }

    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10008){
            URBAlertView *alertView = [URBAlertView dialogWithTitle:@"注意" subtitle:@"不存在当前设备，请检查您的设备UUID"];
            alertView.blurBackground = NO;
            [alertView addButtonWithTitle:@"确认"];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hide];
                
            }];
            [alertView showWithAnimation:URBAlertAnimationFade];
        }else{
            
        }
        [self refreshViewWithSleepData:resposeDic];
        HaviLog(@"获取%@日睡眠质量:%@ \n url:%@ \n",nowDateString,resposeDic,urlString);
    } failure:^(YTKBaseRequest *request) {
        
    }];
}
#pragma mark 默认
- (void)getUserDefatultSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        
        NSString *urlString = @"";
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
            
        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetDefatultSleepAPI *client = [GetDefatultSleepAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client queryDefaultSleep:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
            //为了异常报告
            [self refreshViewWithSleepData:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self refreshViewWithSleepData:resposeDic];
                HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
                //为了异常报告
            } failure:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
            }];
        }
    }
}


- (void)refreshViewWithSleepData:(NSDictionary *)sleepDic
{
    
    self.cellDataArr = @[
                         [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageHeartRate"]intValue]],
                         [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageRespiratoryRate"]intValue]],
                         [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"OutOfBedTimes"]intValue]],
                         [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"BodyMovementTimes"]intValue]]
                         ];
    [self.cellTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int sleepLevel = [[sleepDic objectForKey:@"SleepQuality"]intValue];
        [self.circleView changeSleepQualityValue:sleepLevel*20];
        [self.circleView changeSleepTimeValue:sleepLevel*20];
        [self.circleView changeSleepLevelValue:[self changeNumToWord:sleepLevel]];
        [self setClockRoationValue];
    });
    
    //
    [self.circleView addSubview:self.nightView];
    self.nightView.nightTime = @"23:01PM";
    
    [self.circleView addSubview:self.dayView];
    self.dayView.dayTime = @"08:01AM";

}

#pragma mark 创建图表
- (void)createTableView
{
    [self.view addSubview:self.cellTableView];
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
    }
}

- (void)createCircleView
{
    [self.view addSubview:self.circleView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeValueAnimation:)];
    [self.circleView.cView addGestureRecognizer:tap];
}

- (void)setCalenderAndMenu
{
    [self.view addSubview:self.datePicker];
    NSDate *nowDate = [self getNowDate];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
    isTodayHourEqualSixteen = [[nowDateString substringWithRange:NSMakeRange(11, 2)] intValue];
    if (isTodayHourEqualSixteen<18) {
        self.dateComponentsBase.day = -1;
        NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:nowDate options:0];
        [self.datePicker updateCalenderSelectedDate:yestoday];
        selectedDateToUse = yestoday;
    }else{
        selectedDateToUse = nowDate;
    }
    
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",1]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.dateDelegate = self;
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCalender:)];
    self.datePicker.monthLabel.userInteractionEnabled = YES;
    [self.datePicker.monthLabel addGestureRecognizer:tap];
    
    self.datePicker.backLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    //自定义导航栏
    [self createClearBgNavWithTitle:thirdHardDeviceName createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            return self.menuButton;
        }else if (nIndex == 0){
            if ([self isThirdAppAllInstalled]) {
                self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
                [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
                [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
                return self.rightButton;
            }
            return nil;
        }
        return nil;
    }];
    self.clearNaviTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];

}

#pragma mark  setter meathod


- (NewTodayTurnViewController*)todayTurnView
{
    if (_todayTurnView == nil) {
        _todayTurnView = [[NewTodayTurnViewController alloc]init];
        
    }
    return _todayTurnView;
}

- (NewTodayLeaveViewController*)todayLeaveView
{
    if (_todayLeaveView == nil) {
        _todayLeaveView = [[NewTodayLeaveViewController alloc]init];
    }
    return _todayLeaveView;
}

- (NewTodayBreathViewController *)todayBreathView
{
    if (_todayBreathView == nil) {
        _todayBreathView = [[NewTodayBreathViewController alloc]init];
    }
    return _todayBreathView;
}

- (NewTodayHeartViewController *)todayHeartView
{
    if (_todayHeartView==nil) {
        _todayHeartView = [[NewTodayHeartViewController alloc]init];
    }
    return _todayHeartView;
}

- (UITapGestureRecognizer *)tapDayViewGesture
{
    if (_tapDayViewGesture == nil) {
        _tapDayViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTagView:)];
    }
    return _tapDayViewGesture;
}

- (UITapGestureRecognizer *)tapNightViewGesture
{
    if (_tapNightViewGesture == nil) {
        _tapNightViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showTagView:)];
    }
    return _tapNightViewGesture;
}

- (DayTimeView *)dayView
{
    if (_dayView == nil) {
        _dayView = [[DayTimeView alloc]init];
        _dayView.center = CGPointMake(50, 120);
        _dayView.userInteractionEnabled = YES;
        [_dayView addGestureRecognizer:self.tapDayViewGesture];
    }
    return _dayView;
}

- (NightTimeView*)nightView
{
    if (_nightView==nil) {
        _nightView = [[NightTimeView alloc]init];
        _nightView.center = CGPointMake(50, 40);
        _nightView.userInteractionEnabled = YES;
        [_nightView addGestureRecognizer:self.tapNightViewGesture];
    }
    return _nightView;
}

- (UITableView *)cellTableView
{
    if (_cellTableView == nil) {
        _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44*4+30) style:UITableViewStylePlain];
        _cellTableView.backgroundColor = [UIColor clearColor];
        _cellTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _cellTableView.scrollEnabled = NO;
        _cellTableView.delegate = self;
        _cellTableView.dataSource = self;
        
    }
    return _cellTableView;
}

- (UILabel *)sleepTimeLabel
{
    if (_sleepTimeLabel == nil) {
        _sleepTimeLabel = [[UILabel alloc]init];
        _sleepTimeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        _sleepTimeLabel.textAlignment = NSTextAlignmentCenter;
        _sleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _sleepTimeLabel.backgroundColor = [UIColor clearColor];
        _sleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _sleepTimeLabel.text = @"睡眠时长:7小时36分";
    }
    return _sleepTimeLabel;
}

- (CHCircleGaugeView *)circleView
{
    if (_circleView == nil) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        _circleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 64 + 4*44 +30 + 10, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10)];
        _circleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
        _circleView.trackWidth = 1;
        _circleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _circleView.gaugeTintColor = [UIColor blackColor];
        _circleView.gaugeWidth = 15;
        _circleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _circleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _circleView.responseColor = [UIColor greenColor];
        _circleView.font = [UIFont systemFontOfSize:38];
        _circleView.rotationValue = 100;
        _circleView.value = 0.0;
    }
    return _circleView;
}

#pragma mark 其他方法

- (void)showTagView:(UITapGestureRecognizer *)gesture
{
    TagShowViewController *tag = [[TagShowViewController alloc]init];
    tag.timeDate = self.tagFromDateAndEndDate;
    [self presentViewController:tag animated:YES completion:nil];
}

#pragma mark 更新clock
- (void)changeValueAnimation:(UITapGestureRecognizer *)gesture
{
    //在这里请求最新的当日数据或者仅仅是更新数据。
//    [self.cellTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
    CGPoint point = [gesture locationInView:self.circleView];
    if (point.x>(self.circleView.frame.size.width- self.circleView.frame.size.height)/2 && point.x <self.circleView.frame.size.height+(self.circleView.frame.size.width- self.circleView.frame.size.height)/2) {
        //changevalue是睡眠时长。
        [self.circleView changeSleepQualityValue:0];
        [self.circleView changeSleepTimeValue:0];
        [self setClockRoationValue];
//        NSString *nowDateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
//        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
        [self.datePicker updateCalenderSelectedDate:[[NSDate date] dateByAddingHours:8]];
    }
}

- (void)setClockRoationValue
{
    //这里value是从左侧边缘算起
    self.circleView.rotationValue = 1;
}

#pragma mark 日历展示和代理
- (void)showCalender:(UIButton *)sender
{
    __block typeof(self) weakSelf = self;
    self.chvc.calendarblock = ^(CalendarDayModel *model){
        NSDate *selectedDate = [model date];
        NSDate *newSelect = [selectedDate dateByAddingDays:1];
        [weakSelf.datePicker updateCalenderSelectedDate:newSelect];
        
    };
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor= selectedThemeIndex==0?[UIColor colorWithRed:0.020f green:0.118f blue:0.247f alpha:1.00f]:[UIColor colorWithRed:0.408f green:0.643f blue:0.784f alpha:1.00f];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.navigationController pushViewController:self.chvc animated:YES];

}

- (void)selectedCalenderDate:(NSDate *)date
{
    [self.datePicker updateCalenderSelectedDate:date];
    //更新日历
}

#pragma mark 水平滚动日历

- (void)getScrollSelectedDate:(NSDate *)date
{
    if (date) {
        if ([[[NSDate date] dateByAddingHours:8]isEarlierThan:date]) {
            [self.datePicker updateCalenderSelectedDate:[[NSDate date] dateByAddingHours:8]];
            URBAlertView *alertView = [URBAlertView dialogWithTitle:nil subtitle:@"不要着急,明天才会有数据！"];
            alertView.blurBackground = NO;
//            [alertView addButtonWithTitle:@"确认"];
//            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
//                [alertView hide];
//                
//            }];
            [alertView showWithAnimation:URBAlertAnimationFade];
//            [self.view makeToast:@"将来时间不可以选择" duration:2.3 position:@"center"];
        }else{
            selectedDateToUse = date;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
            NSString *dateString = [formatter stringFromDate:date];
            HaviLog(@"当前选中的日期是%@",dateString);
            NSString *subString = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
            if (isUserDefaultTime) {
                [self getUserDefatultSleepReportData:subString toDate:subString];
            }else{
                [self getTodaySleepQualityData:subString];
            }
        }
    }
}

#pragma mark tableview 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==4) {
        return 30;
    }else{
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifier = @"li";
    CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (cell == nil) {
        cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }
    if (indexPath.row==4) {
        [cell addSubview:self.sleepTimeLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
        NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
        cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
        cell.cellData = [self.cellDataArr objectAtIndex:indexPath.row];
        cell.cellImageName = [cellImage objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        for (UIImageView*imageLine in cell.subviews) {
            if (imageLine.tag == 100) {
                [imageLine removeFromSuperview];
            }
        }
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
        imageLine.tag = 100;
        [cell addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.left).offset(5);
            make.right.equalTo(cell.right).offset(-5);
            make.bottom.equalTo(cell.bottom).offset(-1);
            make.height.equalTo(0.5);
        }];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<4) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:[self.dataViewArr objectAtIndex:indexPath.row] animated:YES];
    }
}


- (NSString *)changeNumToWord:(int)level
{
    switch (level) {
        case 1:{
            return @"非常差";
            break;
        }
        case 2:{
            return @"差";
            break;
        }
        case 3:{
            return @"一般";
            break;
        }
        case 4:{
            return @"好";
            break;
        }
        case 5:{
            return @"非常好";
            break;
        }
            
        default:
            return @"没有数据哦";
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //每次都判断一下当前的时间是不是18：00；
    NSDate *nowDate = [self getNowDate];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
    isTodayHourEqualSixteen = [[nowDateString substringWithRange:NSMakeRange(11, 2)] intValue];
}

//#pragma mark alertview 代理
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex ==0) {
//        DeviceStatus = YES;
//    }
//    if (alertView.tag == 900) {
//        if (buttonIndex == 1) {
//            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
//            [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
//        }
//    }else if (alertView.tag == 901){
//        if (buttonIndex == 1) {
//            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
//            [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
//        }
//    }else if (alertView.tag == 902){
//        if (buttonIndex == 1) {
//            UDPAddProductViewController *user = [[UDPAddProductViewController alloc]init];
//            [self.navigationController pushViewController:user animated:YES];
//        }
//    }
//    
//}

#pragma mark 换肤

- (void)reloadThemeImage
{
    [super reloadThemeImage];
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
    }
    self.clearNaviTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [self.menuButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    _circleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
    _circleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    self.datePicker.backLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",1]] forState:UIControlStateNormal];
    [self.cellTableView reloadData];
    _circleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [_circleView.cView.gradientLayer1 setColors:selectedThemeIndex ==0?[NSArray arrayWithObjects:(id)[[self colorWithHex:0x356E8B alpha:1]CGColor],[[self colorWithHex:0x3e608d alpha:1]CGColor ],(id)[[self colorWithHex:0x00C790 alpha:1]CGColor ],nil]:[NSArray arrayWithObjects:(id)[[self colorWithHex:0x1C7A59 alpha:1]CGColor],[[self colorWithHex:0x0F705C alpha:1]CGColor ],(id)[[self colorWithHex:0x51AD4A alpha:1]CGColor ],nil]];
    [_circleView.cView.gradientLayer2 setColors:selectedThemeIndex==0?[NSArray arrayWithObjects:(id)[[self colorWithHex:0x1cd98d alpha:1]CGColor],(id)[[self colorWithHex:0x21c88d alpha:1]CGColor ],(id)[[self colorWithHex:0x00C790 alpha:1]CGColor ],nil]:[NSArray arrayWithObjects:(id)[[self colorWithHex:0x8DEC45 alpha:1]CGColor],(id)[[self colorWithHex:0x85E445 alpha:1]CGColor ],(id)[[self colorWithHex:0x51AD4A alpha:1]CGColor ],nil]];
    self.sleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    _todayHeartView = nil;
    _todayBreathView = nil;
    _todayLeaveView = nil;
    _todayTurnView = nil;
    _dataViewArr = nil;
    self.dataViewArr = @[self.todayHeartView,self.todayBreathView,self.todayLeaveView,self.todayTurnView];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];

}
#pragma mark view出现

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.clearNaviTitleLabel.text = thirdHardDeviceName;
    if (![HardWareUUID isEqualToString:thirdHardDeviceUUID]&&![HardWareUUID isEqualToString:@""]&&![thirdHardDeviceName isEqualToString:@""]) {
        [self getAllDeviceList];
        HaviLog(@"hard UUID出现不同");
    }
    if (selectedDateToUse&&![HardWareUUID isEqualToString:@""]) {
        [self.datePicker updateCalenderSelectedDate:selectedDateToUse];
    }else{
        //为了请求异常数据时间
        if (isUserDefaultTime) {
        }else{
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
