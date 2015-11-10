//
//  NewCenterViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/19.
//  Copyright © 2015年 Havi. All rights reserved.
//
#import "UIBarButtonItem+Common.h"
#import "UIColor+expanded.h"
#import "AppDelegate.h"
#import "NewCenterViewController.h"
#import "CHCircleGaugeView.h"
#import "CenterViewTableViewCell.h"
#import "DeviceManagerViewController.h"
#import "GetDefatultSleepAPI.h"
#import "StartTimeView.h"
#import "EndTimeView.h"
#import "MMPopupItem.h"
#import "MMTwoListPickerView.h"
#import "MMPickerView.h"
#import "UploadTagAPI.h"

@interface NewCenterViewController ()<SetScrollDateDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
//数据
@property (nonatomic, strong) NSArray *cellDataArr;
@property (nonatomic, strong) NSArray *dataViewArr;
@property (nonatomic, strong) UITableView *cellTableView;//表格
@property (nonatomic, strong) CHCircleGaugeView *circleView;//gaugeView
@property (nonatomic, strong) UIButton *iWantSleepLabel;//睡觉标签
@property (nonatomic, strong) UILabel *sleepTimeLabel;//睡眠时长
@property (nonatomic, strong) StartTimeView *startView;//睡觉时间
@property (nonatomic, strong) EndTimeView *endView;//起床时间
@property (nonatomic, strong) NSString *tagFromDateAndEndDate;//标签时间

@end

@implementation NewCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self setNavigationbarItems];
    [self initData];
    [self createTableView];
    [self createCircleView];
    [self setCalenderAndMenu];
}

- (void)initData
{
    self.cellDataArr = @[@"0次/分",@"0次/分",@"0次/天",@"0次/天"];
//    self.dataViewArr = @[self.secondHeartView,self.secondBreathView,self.sendLeaveView,self.sendTurnView];
}

#pragma mark 请求数据
- (void)getTodaySleepQualityData:(NSString *)nowDateString
{
    //fromdate 是当天的日期
    if ([HardWareUUID isEqualToString:@""]) {
        MMPopupItemHandler block = ^(NSInteger index){
            HaviLog(@"clickd %@ button",@(index));
            if(index==1){
                DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
                [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
            }
        };
        NSArray *items =
        @[MMItemMake(@"暂不绑定", MMItemTypeNormal, block),
          MMItemMake(@"确定", MMItemTypeNormal, block)];
        
        MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                             detail:@"您还没有绑定设备,是否现在去绑定？" items:items];
        alertView.attachedView = self.navigationController.view;
        
        [alertView show];
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!nowDateString) {
        return;
    }
    NSDate *newDate = [self.dateFormmatterBase dateFromString:nowDateString];
    NSString *urlString = @"";
    self.dateComponentsBase.day = -1;
    NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
    urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,thirdPartyLoginUserId,newString,nowDateString];
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
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10008){
            MMPopupItemHandler block = ^(NSInteger index){
                HaviLog(@"clickd %@ button",@(index));
            };
            NSArray *items =
            @[MMItemMake(@"确定", MMItemTypeNormal, block)];
            
            MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                                 detail:@"不存在当前设备，请检查您的设备UUID" items:items];
            alertView.attachedView = self.navigationController.view;
            
            [alertView show];
        }else{
            
        }
        [self refreshViewWithSleepData:resposeDic];
        HaviLog(@"获取%@日睡眠质量:%@ \n url:%@ \n",nowDateString,resposeDic,urlString);
    } failure:^(YTKBaseRequest *request) {
        
    }];
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
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[sleepDic objectForKey:@"Data"]];
    NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
    NSString *subString = [selectString substringToIndex:10];
    NSDictionary *dataDic=nil;
    for (NSDictionary *dic in arr) {
        if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
            dataDic = dic;
        }
    }
    
    //    NSDictionary *dataDic = [[sleepDic objectForKey:@"Data"] lastObject];
    NSString *sleepStartTime = [dataDic objectForKey:@"SleepStartTime"];
    NSString *sleepEndTime = [dataDic objectForKey:@"SleepEndTime"];
    NSString *sleepDuration = [dataDic objectForKey:@"SleepDuration"];
    int sleepLevel = [[sleepDic objectForKey:@"SleepQuality"]intValue];
    [self.circleView changeSleepQualityValue:sleepLevel*20];//睡眠指数
    [self.circleView changeSleepTimeValue:sleepLevel*20];
    //    [self.circleView changeSleepTimeValue:([sleepDuration floatValue]>0?[sleepDuration floatValue]:-[sleepDuration floatValue])/12*100];//睡眠时长
    [self.circleView changeSleepLevelValue:[self changeNumToWord:sleepLevel]];
    self.circleView.rotationValue = 88;
    
    //    [self setClockRoationValueWithStartTime:sleepStartTime];
    int hour = [sleepDuration intValue];
    double second2 = 0.0;
    double subsecond2 = modf([sleepDuration floatValue], &second2);
    NSString *sleepTimeDuration= @"";
    if((int)round(subsecond2*60)<10){
        sleepTimeDuration = [NSString stringWithFormat:@"睡眠时长:%@小时0%d分",hour<10?[NSString stringWithFormat:@"0%d",hour]:[NSString stringWithFormat:@"%d",hour],(int)round(subsecond2*60)];
    }else{
        sleepTimeDuration = [NSString stringWithFormat:@"睡眠时长:%@小时%d分",hour<10?[NSString stringWithFormat:@"0%d",hour]:[NSString stringWithFormat:@"%d",hour],(int)round(subsecond2*60)];
    }
    self.sleepTimeLabel.text= sleepTimeDuration;
    if (sleepStartTime) {
        
        [self.circleView addSubview:self.startView];
        self.startView.startTime = [sleepStartTime substringWithRange:NSMakeRange(11, 5)];
        self.startView.center = CGPointMake(90, 5);
    }else{
        [self.startView removeFromSuperview];
    }
    if (sleepEndTime) {
        [self.circleView addSubview:self.endView];
        self.endView.endTime = [sleepEndTime substringWithRange:NSMakeRange(11, 5)];
        self.endView.center = CGPointMake(self.view.frame.size.width-60, 5);
        //        self.endView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showEndTimePicker)];
        [self.endView addGestureRecognizer:tap];
    }else
    {
        [self.endView removeFromSuperview];
    }
}

#pragma mark 其他方法

- (void)showEndTimePicker
{
    NSMutableArray *hour1 = [[NSMutableArray alloc]init];
    NSMutableArray *minute1 = [[NSMutableArray alloc]init];
    for (int i=0; i<60; i++) {
        if (i<10) {
            [minute1 addObject:[NSString stringWithFormat:@"0%d分",i]];
        }else{
            [minute1 addObject:[NSString stringWithFormat:@"%d分",i]];
        }
    }
    for (int i=0; i<24; i++) {
        if (i<10) {
            [hour1 addObject:[NSString stringWithFormat:@"0%d点",i]];
        }else{
            [hour1 addObject:[NSString stringWithFormat:@"%d点",i]];
        }
    }
    
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[hour1,minute1]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                       }else{
                                           NSString *titleString = [NSString stringWithFormat:@"%@:%@",[selectedString substringWithRange:NSMakeRange(0, 2)],[selectedString substringWithRange:NSMakeRange(3, 2)]];
                                           self.endView.endTime = titleString;
                                           [self sendSleepEndTime:titleString];
                                       }
                                   }];
    
}

#pragma mark 提交用户睡眠时间

- (void)sendSleepTime
{
    if (HardWareUUID.length>0) {
        /*
         [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
         [MMProgressHUD showWithStatus:@"保存中..."];
         */
        NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                            [UIImage imageNamed:@"havi1_1"],
                            [UIImage imageNamed:@"havi1_2"],
                            [UIImage imageNamed:@"havi1_3"],
                            [UIImage imageNamed:@"havi1_4"],
                            [UIImage imageNamed:@"havi1_5"]];
        [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:nil status:nil images:images];
        NSDate *date = [[NSDate date]dateByAddingHours:8];
        NSString *dateString = [NSString stringWithFormat:@"%@",date];
        //        NSDate *date1 = [selectedDateToUse dateByAddingDays:0];
        //        NSString *dateString = [NSString stringWithFormat:@"%@",date1];
        //        NSString *date = [NSString stringWithFormat:@"%@%@:00",[dateString substringToIndex:11],@"22:07"];
        NSDictionary *dic = @{
                              @"UUID" : HardWareUUID,
                              @"UserID" : thirdPartyLoginUserId,
                              @"Tags" : @[@{
                                              @"Tag": @"<%睡眠时间记录%>",
                                              @"TagType": @"-1",
                                              @"UserTagDate": dateString,
                                              }],
                              };
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        UploadTagAPI *client = [UploadTagAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [MMProgressHUD dismiss];
        
        [client uploadTagWithHeader:header andWithPara:dic];
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
                [MMProgressHUD dismiss];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    [self.view makeToast:@"做个好梦喽" duration:3 position:@"center"];
                }];
            }else{
                HaviLog(@"%@",resposeDic);
                [MMProgressHUD dismissWithError:@"出错啦" afterDelay:1];
            }
        } failure:^(YTKBaseRequest *request) {
            
        }];
    }else{
        [self.view makeToast:@"请先绑定设备ID" duration:2 position:@"center"];
    }
}

- (void)sendSleepEndTime:(NSString *)endString
{
    if (HardWareUUID.length>0) {
        /*
         [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
         [MMProgressHUD showWithStatus:@"保存中..."];
         */
        NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                            [UIImage imageNamed:@"havi1_1"],
                            [UIImage imageNamed:@"havi1_2"],
                            [UIImage imageNamed:@"havi1_3"],
                            [UIImage imageNamed:@"havi1_4"],
                            [UIImage imageNamed:@"havi1_5"]];
        [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:nil status:nil images:images];
        NSDate *date1 = [selectedDateToUse dateByAddingDays:0];
        NSString *dateString = [NSString stringWithFormat:@"%@",date1];
        NSString *date = [NSString stringWithFormat:@"%@%@:00",[dateString substringToIndex:11],endString];
        NSDictionary *dic = @{
                              @"UUID" : HardWareUUID,
                              @"UserID" : thirdPartyLoginUserId,
                              @"Tags" :@[ @{
                                              @"Tag": @"<%睡眠时间记录%>",
                                              @"TagType": @"1",
                                              @"UserTagDate": date,
                                              }],
                              };
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        UploadTagAPI *client = [UploadTagAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [MMProgressHUD dismiss];
        
        [client uploadTagWithHeader:header andWithPara:dic];
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
                [MMProgressHUD dismiss];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    //                    [self.view makeToast:@"做个好梦喽" duration:3 position:@"center"];
                    NSString *selctString = [NSString stringWithFormat:@"%@",selectedDateToUse];
                    NSString *subString = [NSString stringWithFormat:@"%@%@%@",[selctString substringWithRange:NSMakeRange(0, 4)],[selctString substringWithRange:NSMakeRange(5, 2)],[selctString substringWithRange:NSMakeRange(8, 2)]];
                    [self getTodaySleepQualityData:subString];
                }];
            }else{
                HaviLog(@"%@",resposeDic);
                [MMProgressHUD dismissWithError:@"出错啦" afterDelay:1];
            }
        } failure:^(YTKBaseRequest *request) {
            
        }];
    }else{
        [self.view makeToast:@"请先绑定设备ID" duration:2 position:@"center"];
    }
    
}

#pragma mark 创建图表

- (void)setCalenderAndMenu
{
    [self.view addSubview:self.datePicker];
    NSDate *nowDate = [self getNowDate];
    selectedDateToUse = nowDate;
    
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",1]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.dateDelegate = self;
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCalender:)];
    self.datePicker.monthLabel.userInteractionEnabled = YES;
    [self.datePicker.monthLabel addGestureRecognizer:tap];
    
    self.datePicker.backLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
}

- (void)createCircleView
{
    [self.view addSubview:self.circleView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeValueAnimation:)];
    [self.circleView.cView addGestureRecognizer:tap];
    [self.view addSubview:self.iWantSleepLabel];
}
- (void)createTableView
{
    [self.view addSubview:self.cellTableView];
    
}

#pragma mark 更新clock
- (void)changeValueAnimation:(UITapGestureRecognizer *)gesture
{
    //在这里请求最新的当日数据或者仅仅是更新数据。
    //    [self.cellTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
    CGPoint point = [gesture locationInView:self.circleView];
    if (point.x>(self.circleView.frame.size.width- self.circleView.frame.size.height)/2 && point.x <self.circleView.frame.size.height+(self.circleView.frame.size.width- self.circleView.frame.size.height)/2) {
        [self.datePicker updateCalenderSelectedDate:[[NSDate date] dateByAddingHours:8]];
    }
}

- (void)setClockRoationValueWithStartTime:(NSString *)startTime
{
    //这里value是从左侧边缘算起
    if (startTime.length>0) {
        NSString *hour = [startTime substringWithRange:NSMakeRange(11, 2)];
        NSString *minute = [startTime substringWithRange:NSMakeRange(14, 2)];
        int hourInt = [hour intValue];
        int minuteInt = [minute intValue];
        if (hourInt>12) {
            hourInt = hourInt-12;
        }
        float rotation = (float)((hourInt+(float)minuteInt/60)*30 +3*29);
        self.circleView.rotationValue = rotation;
    }
    
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
//    [self getAllDeviceList];
}


- (void)setNavigationbarItems
{
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_pg_night_0"] forBarMetrics:UIBarMetricsDefault];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg_center_1"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    UIBarButtonItem *leftBarItem =[UIBarButtonItem itemWithIcon:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex] showBadge:NO target:self action:@selector(presentLeftMenuViewController:)];
    leftBarItem.tag = 1000;
    [self.parentViewController.navigationItem setLeftBarButtonItem:leftBarItem animated:NO];
    
    UIBarButtonItem *rightBarItem =[UIBarButtonItem itemWithIcon:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex] showBadge:NO target:self action:@selector(shareMenuView:)];
    rightBarItem.tag = 1001;
    [self.parentViewController.navigationItem setRightBarButtonItem:rightBarItem animated:NO];
    
}

#pragma mark setter meathod

- (StartTimeView *)startView
{
    if (_startView==nil) {
        _startView = [[StartTimeView alloc]init];
        
    }
    return _startView;
}

- (EndTimeView *)endView
{
    if (_endView == nil) {
        _endView = [[EndTimeView alloc]init];
    }
    return _endView;
}

- (UIButton *)iWantSleepLabel
{
    if (_iWantSleepLabel==nil) {
        _iWantSleepLabel = [[UIButton alloc]init];
        int datePickerHeight = self.view.frame.size.height*0.202623;
        
        _iWantSleepLabel.frame = CGRectMake((self.view.frame.size.width-90)/2, self.view.frame.size.height -datePickerHeight-30-64, 90,25);
        [_iWantSleepLabel setTitle:@"我要睡觉" forState:UIControlStateNormal];
        [_iWantSleepLabel setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_textbox_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_iWantSleepLabel setTitleColor:selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor] forState:UIControlStateNormal];
        [_iWantSleepLabel.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_iWantSleepLabel addTarget:self action:@selector(sendSleepTime) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iWantSleepLabel;
}

- (CHCircleGaugeView *)circleView
{
    if (_circleView == nil) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        if (ISIPHON4) {
            _circleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 4*34 +30, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35+60)];
        }else{
            _circleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 4*44 +30 + 10, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35)];
        }
        _circleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
        _circleView.trackWidth = 1;
        _circleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _circleView.gaugeTintColor = [UIColor blackColor];
        _circleView.gaugeWidth = 15;
        _circleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _circleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _circleView.responseColor = [UIColor greenColor];
        _circleView.font = [UIFont systemFontOfSize:30];
        _circleView.rotationValue = 100;
        _circleView.value = 0.0;
    }
    return _circleView;
}

- (UITableView *)cellTableView
{
    if (_cellTableView == nil) {
        if (ISIPHON4) {
            _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34*4+30) style:UITableViewStylePlain];
        }else{
            _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44*4+30) style:UITableViewStylePlain];
        }
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
        _sleepTimeLabel.text = @"睡眠时长:0小时0分";
    }
    return _sleepTimeLabel;
}

#pragma mark user Action

- (void)shareMenuView:(UIButton *)sender
{
    [self.shareNewMenuView showInView:self.view];
}

- (void)reloadThemeImage
{
    [super reloadThemeImage];
    
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_pg_night_0"] forBarMetrics:UIBarMetricsDefault];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg_center_1"] forBarMetrics:UIBarMetricsDefault];
    }
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    app.nav_tweet.navigationView = selectedThemeIndex ==0?DefaultColor:[UIColor whiteColor];
    UIBarButtonItem *left = (UIBarButtonItem *)[self.navigationController.navigationBar viewWithTag:1000];
    left.customView = nil;
    UIBarButtonItem *right = (UIBarButtonItem *)[self.navigationController.navigationBar viewWithTag:1000];
    right.customView = nil;
    
    UIBarButtonItem *leftBarItem =[UIBarButtonItem itemWithIcon:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex] showBadge:NO target:self action:@selector(presentLeftMenuViewController:)];
    leftBarItem.tag = 1000;
    [self.parentViewController.navigationItem setLeftBarButtonItem:leftBarItem animated:NO];
    
    UIBarButtonItem *rightBarItem =[UIBarButtonItem itemWithIcon:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex] showBadge:NO target:self action:@selector(shareMenuView:)];
    rightBarItem.tag = 1001;
    [self.parentViewController.navigationItem setRightBarButtonItem:rightBarItem animated:NO];
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
    [_iWantSleepLabel setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_textbox_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [_iWantSleepLabel setTitleColor:selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    _sendLeaveView = nil;
//    _sendTurnView = nil;
//    _secondBreathView = nil;
//    _secondHeartView = nil;
    _dataViewArr = nil;
//    self.dataViewArr = @[self.secondHeartView,self.secondBreathView,self.sendLeaveView,self.sendTurnView];
    [self.datePicker updateCalenderSelectedDate:selectedDateToUse];
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
        if (ISIPHON4) {
            return 34;
        }else
        {
            return 44;
        }
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

#pragma mark 日历展示和代理
- (void)showCalender:(UIButton *)sender
{
    __block typeof(self) weakSelf = self;
    self.chvc.calendarblock = ^(CalendarDayModel *model){
        NSDate *selectedDate = [model date];
        //        NSDate *newSelect = [selectedDate dateByAddingDays:1];
        [weakSelf.datePicker updateCalenderSelectedDate:selectedDate];
        
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
    NSString *dateString =[NSString stringWithFormat:@"%@",[[NSDate date] dateByAddingHours:8]];
    NSString *slectDateString = [NSString stringWithFormat:@"%@",date];
    if (![[dateString substringWithRange:NSMakeRange(5, 5)]isEqualToString:[slectDateString substringWithRange:NSMakeRange(5, 5)]]) {
        [self.iWantSleepLabel removeFromSuperview];
    }else {
        [self.view addSubview:self.iWantSleepLabel];
    }
    if ([[[NSDate date] dateByAddingHours:8]daysFrom:date]>7) {
        self.endView.endImageString = @"";
        self.endView.userInteractionEnabled = NO;
    }else{
        self.endView.endImageString = [NSString stringWithFormat: @"ic_compile_%d",selectedThemeIndex];
        self.endView.userInteractionEnabled = YES;
    }
    
    if (date) {
        if ([[[NSDate date] dateByAddingHours:8]isEarlierThan:date]) {
            [self.datePicker updateCalenderSelectedDate:[[NSDate date] dateByAddingHours:8]];
            [self.view makeToast:@"不要着急呦，明天睡后就会有数据啦！" duration:2.3 position:@"center"];
            selectedDateToUse = [[NSDate date] dateByAddingHours:8];
        }else{
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
            NSString *dateString = [formatter stringFromDate:date];
            HaviLog(@"当前选中的日期是%@",dateString);
            NSString *subString = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
            if ([self isNetworkExist]) {
                [self getTodaySleepQualityData:subString];
            }else{
                [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
            }
            selectedDateToUse = date;
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
