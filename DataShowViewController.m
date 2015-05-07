//
//  DataShowViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DataShowViewController.h"
#import "XLScrollViewer.h"
#import "HeartView.h"
#import "BreatheView.h"
#import "LeaveBedView.h"
#import "TurnroundView.h"
#import "JT3DScrollView.h"
#import "DiagnoseReportViewController.h"
#import "ModalAnimation.h"
#import "HaviGetNewClient.h"
#import "GetSleepReport.h"
#import "GetExceptionAPI.h"
#import "GetUserDefaultDataAPI.h"
#import "GetDefatultSleepAPI.h"

@interface DataShowViewController ()<SelectedDate,SetScrollDateDelegate,UIViewControllerTransitioningDelegate>
{
    //诊断报告
    ModalAnimation *_modalAnimationController;
//    SlideAnimation *_slideAnimationController;
//    ShuffleAnimation *_shuffleAnimationController;
//    ScaleAnimation *_scaleAnimationController;
}
@property (nonatomic,strong) HeartView *heartView;
@property (nonatomic,strong) BreatheView *breatheView;
@property (nonatomic,strong) LeaveBedView *leaveBedView;
@property (nonatomic,strong) TurnroundView *turnView;

@property (nonatomic,strong) JT3DScrollView *jScrollView;
@property (nonatomic,strong) NSArray *views;
//测试数据
@property (nonatomic,strong) NSMutableArray *affHeart;
@property (nonatomic,strong) NSArray *affLeaveBed;
@property (nonatomic,strong) NSMutableArray *affBreathe;
@property (nonatomic,strong) NSArray *affMoveBed;
//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;
//

@end

@implementation DataShowViewController

- (void)loadView
{
    [super loadView];
//    self.affHeart = [[NSMutableArray alloc]init];
//    for (int i=0; i<288; i++) {
//        [_affHeart addObject:[NSNumber numberWithFloat:(float)[self getRandomNumber:13 to:17]]];
//    }
//    
//    
//    //
//    //    chartView.startTime = @"2";
//    //    chartView.endTime = @"4";
//            for (int i=101; i<151; i++) {
//                [_affHeart replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
//            }
//    
//            for (int i=50; i<70; i++) {
//                [_affHeart replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
//            }
//    
//            for (int i=180; i<230; i++) {
//                [_affHeart replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
//            }
//    
//    [_affHeart insertObject:[NSNumber numberWithFloat:5] atIndex:7];
//    [_affHeart insertObject:[NSNumber numberWithFloat:5] atIndex:50];
//    [_affHeart insertObject:[NSNumber numberWithFloat:5] atIndex:100];
//    [_affHeart insertObject:[NSNumber numberWithFloat:30] atIndex:80];
//    
//
//    self.affLeaveBed = @[
//                         @{@"At":@"2013-03-19 20:00:10",@"Value":@"0"},//上
//                         @{@"At":@"2013-03-19 20:14:10",@"Value":@"1"},//下
//                         @{@"At":@"2013-03-19 20:19:10",@"Value":@"0"},//上
//                         @{@"At":@"2013-03-19 22:14:10",@"Value":@"1"},//下
//                         @{@"At":@"2013-03-20 04:44:10",@"Value":@"0"},//上
//                         @{@"At":@"2013-03-20 09:14:10",@"Value":@"1"},//下
//                         @{@"At":@"2013-03-20 09:16:10",@"Value":@"0"},
//                         @{@"At":@"2013-03-20 10:14:10",@"Value":@"1"},//下
//                         @{@"At":@"2013-03-20 11:44:10",@"Value":@"0"},
//                         @{@"At":@"2013-03-20 11:54:10",@"Value":@"1"},//下
//                         ];
    
    _modalAnimationController = [[ModalAnimation alloc] init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(show24HourData:) name:TwtityFourHourNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showDefatultHourData:) name:UserDefaultHourNoti object:nil];

}

#pragma mark 获取自定义数据
- (void)getUserDefaultDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    
    [KVNProgress showWithStatus:@"请求中..."];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=0&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetUserDefaultDataAPI *client = [GetUserDefaultDataAPI shareInstance];
    [client getUserDefaultData:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [KVNProgress dismiss];
        HaviLog(@"请求的心率，呼吸，离床，体动数据是%@",resposeDic);
        [self reloadUserViewWithDefaultData:resposeDic];
        [self getUserDefatultSleepReportData:fromDate toDate:toDate];
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress dismissWithCompletion:^{
            [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
        }];
    }];
}

- (void)getUserDefatultSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDefatultSleepAPI *client = [GetDefatultSleepAPI shareInstance];
    [client queryDefaultSleep:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
        [self reloadSleepView:resposeDic];
        //为了异常报告
        self.currentSleepQulitity = resposeDic;
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress dismissWithCompletion:^{
            [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
        }];
    }];
}

#pragma mark 获取完数据之后进行更新界面

- (void)reloadUserViewWithDefaultData:(NSDictionary *)dataDic
{
    self.affMoveBed = nil;
    self.affLeaveBed = nil;
    self.heartView.aff = nil;
    self.breatheView.aff = nil;
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    for (NSDictionary *dic in arr) {
        if ([[dic objectForKey:@"PropertyCode"]intValue]==1) {
            self.affMoveBed = [dic objectForKey:@"Data"];
            self.turnView.aff = self.affMoveBed;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==2){
            self.affLeaveBed = [dic objectForKey:@"Data"];
            self.leaveBedView.aff = self.affLeaveBed;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==3){
            self.heartView.aff = [self changeSeverDataToDefaultChartData:[dic objectForKey:@"Data"]];;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==4){
            self.breatheView.aff = [self changeSeverDataToDefaultChartData:[dic objectForKey:@"Data"]];
        }
    }
    [self.turnView layoutOutSubViewWithNewData];
    [self.leaveBedView layoutOutSubViewWithNewData];
    [self.heartView layoutOutSubViewWithNewData];
    [self.breatheView layoutOutSubViewWithNewData];

    /*
     //体动
     self.affMoveBed = [[[dataDic objectForKey:@"SensorData"]objectAtIndex:0] objectForKey:@"Data"];
     self.turnView.aff = self.affMoveBed;
     [self.turnView layoutOutSubViewWithNewData];
     //离床
     self.affLeaveBed = [[[dataDic objectForKey:@"SensorData"]objectAtIndex:1] objectForKey:@"Data"];
     self.leaveBedView.aff = self.affLeaveBed;
     [self.leaveBedView layoutOutSubViewWithNewData];
     //心率
     
     self.heartView.aff = [self changeSeverDataToChartData:[[[dataDic objectForKey:@"SensorData"]objectAtIndex:2] objectForKey:@"Data"]];;
     [self.heartView layoutOutSubViewWithNewData];
     //呼吸
     self.breatheView.aff = [self changeSeverDataToChartData:[[[dataDic objectForKey:@"SensorData"]objectAtIndex:3] objectForKey:@"Data"]];
     [self.breatheView layoutOutSubViewWithNewData];
     */
}

#pragma mark 转换数据

- (NSMutableArray *)changeSeverDataToDefaultChartData:(NSArray *)severDataArr
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i=0; i<288; i++) {
        [arr addObject:[NSNumber numberWithFloat:0]];
    }
    for (int i = 0; i<severDataArr.count; i++) {
        NSDictionary *dic = [severDataArr objectAtIndex:i];
        NSString *date = [dic objectForKey:@"At"];
        NSString *hourDate1 = [date substringWithRange:NSMakeRange(11, 2)];
        NSString *minuteDate2 = [date substringWithRange:NSMakeRange(14, 2)];
        int indexIn = 0;
        if ([hourDate1 intValue]<6) {
            indexIn = (int)((24 -6)*60 + [hourDate1 intValue]*60 + [minuteDate2 intValue])/5;
        }else {
            indexIn = (int)(([hourDate1 intValue]-6)*60 + [minuteDate2 intValue])/5;
        }
        [arr replaceObjectAtIndex:indexIn withObject:[NSNumber numberWithFloat:[[dic objectForKey:@"Value"] floatValue]]];
    }
    return arr;
}

#pragma mark 根据日历获取相应的数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    [KVNProgress showWithStatus:@"请求中..."];
    NSString *newString = [NSString stringWithFormat:@"%@%d",[fromDate substringToIndex:6],[[fromDate substringFromIndex:6] intValue]-1];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=0&FromDate=%@&EndDate=%@&FromTime=06:00&EndTime=06:00",HardWareUUID,newString,toDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    HaviGetNewClient *client = [HaviGetNewClient shareInstance];
    [client querySensorDataOld:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [KVNProgress dismiss];
        HaviLog(@"请求的心率，呼吸，离床，体动数据是%@",resposeDic);
        [self reloadUserViewWithData:resposeDic];
        [self getUserSleepReportData:fromDate toDate:toDate];
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress dismissWithCompletion:^{
            [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
        }];
    }];
}

- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",HardWareUUID,fromDate,toDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetSleepReport *client = [GetSleepReport shareInstance];
    [client querySleepReport:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
        [self reloadSleepView:resposeDic];
        //为了异常报告
        self.currentSleepQulitity = resposeDic;
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress dismissWithCompletion:^{
            [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
        }];
    }];
}

#pragma mark 获取完数据之后进行更新界面

- (void)reloadSleepView:(NSDictionary *)dic
{
    //心率
    self.heartView.infoDic = dic;
    self.breatheView.infoDic = dic;
    self.leaveBedView.infoDic = dic;
    self.turnView.infoDic = dic;
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    self.affMoveBed = nil;
    self.affLeaveBed = nil;
    self.heartView.aff = nil;
    self.breatheView.aff = nil;
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    for (NSDictionary *dic in arr) {
        if ([[dic objectForKey:@"PropertyCode"]intValue]==1) {
            self.affMoveBed = [dic objectForKey:@"Data"];
            self.turnView.aff = self.affMoveBed;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==2){
            self.affLeaveBed = [dic objectForKey:@"Data"];
            self.leaveBedView.aff = self.affLeaveBed;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==3){
            self.heartView.aff = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];;
        }else if ([[dic objectForKey:@"PropertyCode"]intValue]==4){
            self.breatheView.aff = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        }
        
    }
    [self.turnView layoutOutSubViewWithNewData];
    [self.leaveBedView layoutOutSubViewWithNewData];
    [self.heartView layoutOutSubViewWithNewData];
    [self.breatheView layoutOutSubViewWithNewData];
    /*
    //体动
    self.affMoveBed = [[[dataDic objectForKey:@"SensorData"]objectAtIndex:0] objectForKey:@"Data"];
    self.turnView.aff = self.affMoveBed;
    [self.turnView layoutOutSubViewWithNewData];
    //离床
    self.affLeaveBed = [[[dataDic objectForKey:@"SensorData"]objectAtIndex:1] objectForKey:@"Data"];
    self.leaveBedView.aff = self.affLeaveBed;
    [self.leaveBedView layoutOutSubViewWithNewData];
    //心率
    
    self.heartView.aff = [self changeSeverDataToChartData:[[[dataDic objectForKey:@"SensorData"]objectAtIndex:2] objectForKey:@"Data"]];;
    [self.heartView layoutOutSubViewWithNewData];
    //呼吸
    self.breatheView.aff = [self changeSeverDataToChartData:[[[dataDic objectForKey:@"SensorData"]objectAtIndex:3] objectForKey:@"Data"]];
    [self.breatheView layoutOutSubViewWithNewData];
     */
}

#pragma mark 转换数据

- (NSMutableArray *)changeSeverDataToChartData:(NSArray *)severDataArr
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i=0; i<288; i++) {
        [arr addObject:[NSNumber numberWithFloat:0]];
    }
    for (int i = 0; i<severDataArr.count; i++) {
        NSDictionary *dic = [severDataArr objectAtIndex:i];
        NSString *date = [dic objectForKey:@"At"];
        NSString *hourDate1 = [date substringWithRange:NSMakeRange(11, 2)];
        NSString *minuteDate2 = [date substringWithRange:NSMakeRange(14, 2)];
        int indexIn = 0;
        if ([hourDate1 intValue]<6) {
            indexIn = (int)((24 -6)*60 + [hourDate1 intValue]*60 + [minuteDate2 intValue])/5;
        }else {
            indexIn = (int)(([hourDate1 intValue]-6)*60 + [minuteDate2 intValue])/5;
        }
        [arr replaceObjectAtIndex:indexIn withObject:[NSNumber numberWithFloat:[[dic objectForKey:@"Value"] floatValue]]];
    }
    return arr;
}

#pragma mark view load

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//
    int height = self.datePicker.frame.size.height;
    CGRect frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -20 - height);
    self.heartView = [[HeartView alloc]initWithFrame:frame];
    self.heartView.aff = self.affHeart;
    self.breatheView = [[BreatheView alloc]initWithFrame:frame];
    self.breatheView.aff = self.affBreathe;
    self.leaveBedView = [[LeaveBedView alloc]initWithFrame:frame];
    self.leaveBedView.aff = self.affLeaveBed;
    self.turnView = [[TurnroundView alloc]initWithFrame:frame];
    self.turnView.aff = self.affLeaveBed;
    //
    self.views = @[self.heartView,self.breatheView,self.leaveBedView,self.turnView];
    [self.view addSubview:self.jScrollView];
    [self.jScrollView loadPageIndex:self.selectedIndex animated:YES];
    //注意添加的先后顺序
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }else if (nIndex == 0){
            self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
            [self.rightButton setImage:[UIImage imageNamed:@"btn_share"] forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
            return self.rightButton;
        }
        
        return nil;
    }];
    // Do any additional setup after loading the view.
    self.datePicker.dateDelegate = self;
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:@"menology"] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.monthLabel.textColor = [UIColor whiteColor];
    //和首页保持一致
    if (dayTimeToUse.length>0) {
        [self.datePicker updateSelectedDate:dayTimeToUse];
        NSString *useDate = [NSString stringWithFormat:@"%@%@%@",[dayTimeToUse substringToIndex:4],[dayTimeToUse substringWithRange:NSMakeRange(5, 2)],[dayTimeToUse substringWithRange:NSMakeRange(8, 2)]];
        self.currentDate = useDate;
    }else{
        //进行请求数据
        NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        NSString *query = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
        //为了请求异常数据时间
        self.currentDate = query;//20150425
        [self getUserAllDaySensorData:query toDate:query];
    }
}

//- (void)setSelectedIndex:(NSInteger)selectedIndex
//{
//    [self.jScrollView loadPageIndex:selectedIndex animated:YES];
//}

- (JT3DScrollView *)jScrollView
{
    if (!_jScrollView) {
        int height = self.datePicker.frame.size.height;
        CGRect frame =CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height -20 - height);
        _jScrollView = [[JT3DScrollView alloc]initWithFrame:frame];
        self.jScrollView.effect = JT3DScrollViewEffectNone;
        self.jScrollView.backgroundColor = [UIColor clearColor];
        for (int i = 0; i<4; i++) {
            [self createCardWithColorWithArr:[_views objectAtIndex:i]];
        }
    }
    return _jScrollView;
}



//- (void)showCalender:(UIButton *)sender
//{
//    HaviLog(@"日历");
//    [UIView animateWithDuration:1.5 animations:^{
//        self.calenderNewView.delegate = self;
//        [[UIApplication sharedApplication].keyWindow addSubview:self.calenderNewView];
//    }];
//    
//}

////弹出式日历
//- (void)selectedDate:(NSDate *)selectedDate
//{
//    NSString *date = [NSString stringWithFormat:@"%@",selectedDate];
//    HaviLog(@"弹出日历选中的日期是%@",date);
//    NSString *subString = [NSString stringWithFormat:@"%@%@%@",[date substringWithRange:NSMakeRange(0, 4)],[date substringWithRange:NSMakeRange(5, 2)],[date substringWithRange:NSMakeRange(8, 2)]];
//    [self.datePicker caculateCurrentYearDate:selectedDate];
//    //获取相应的数据
//    self.currentDate = subString;
////    [self getUserAllDaySensorData:subString toDate:subString];
//    [self.calenderNewView removeFromSuperview];
//    //更新日历
//    [self.datePicker updateSelectedDate:date ];
//    self.calenderNewView = nil;
//}

#pragma mark 异常报告

- (void)showHeartEmercenyView:(NSNotification *)noti
{
    [self showDiagnoseReportHeart];
}

- (void)showBreatheEmercenyView:(NSNotification*)noti
{
    [self showDiagnoseReportBreath];
}
#pragma mark 获取异常数据
- (void)showDiagnoseReportHeart
{
    NSString *newString = [NSString stringWithFormat:@"%@%d",[self.currentDate substringToIndex:6],[[self.currentDate substringFromIndex:6] intValue]-1];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=06:00&EndTime=06:00",HardWareUUID,newString,self.currentDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [KVNProgress showWithStatus:@"异常数据请求中..."];
    GetExceptionAPI *client = [GetExceptionAPI shareInstance];
    [client getException:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [KVNProgress dismiss];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [self showExceptionView:resposeDic withTitle:@"心率"];
        HaviLog(@"获取异常数据%@",resposeDic);
    } failure:^(YTKBaseRequest *request) {
        
    }];
    
}

- (void)showDiagnoseReportBreath
{
    if (isUserDefaultTime) {
        
    }else{
    }
    NSString *newString = [NSString stringWithFormat:@"%@%d",[self.currentDate substringToIndex:6],[[self.currentDate substringFromIndex:6] intValue]-1];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [KVNProgress showWithStatus:@"异常数据请求中..."];
    GetExceptionAPI *client = [GetExceptionAPI shareInstance];
    [client getException:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [KVNProgress dismiss];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [self showExceptionView:resposeDic withTitle:@"呼吸"];
        HaviLog(@"获取异常数据%@",resposeDic);
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)showExceptionView:(NSDictionary *)dic withTitle:(NSString *)exceptionTitle
{
    DiagnoseReportViewController *modal = [[DiagnoseReportViewController alloc] init];
    modal.transitioningDelegate = self;
    modal.dateTime = self.currentDate;
    modal.reportTitleString = exceptionTitle;
    modal.modalPresentationStyle = UIModalPresentationCustom;
    modal.exceptionDic = dic;
    modal.sleepDic = self.currentSleepQulitity;
    [self presentViewController:modal animated:YES completion:nil];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
}
#pragma mark 滚动视图
- (void)createCardWithColorWithArr:(UIView *)aView
{
    CGFloat width = CGRectGetWidth(self.jScrollView.bounds);
    CGFloat height = CGRectGetHeight(self.jScrollView.frame);
    
    CGFloat x = self.jScrollView.subviews.count * width;
    
    aView.frame = CGRectMake(x, 0, width, height);
//    aView.backgroundColor = [UIColor clearColor];
    [self.jScrollView addSubview:aView];
    self.jScrollView.contentSize = CGSizeMake(x + width, height);
}

#pragma mark view method
- (void)viewWillDisappear:(BOOL)animated
{
    [self.jScrollView removeFromSuperview];
    _jScrollView = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PostBreatheEmergencyNoti object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PostHeartEmergencyNoti object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_jScrollView) {
        [self.view addSubview:self.jScrollView];
        [self.view insertSubview:self.jScrollView aboveSubview:self.bgImageView];
        
        
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showHeartEmercenyView:) name:PostHeartEmergencyNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showBreatheEmercenyView:) name:PostBreatheEmergencyNoti object:nil];
}

#pragma 自定义delegate
//滑动日历的选中
- (void)getSelectedDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:date];
    HaviLog(@"滚动日历中的日期是%@",dateString);
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    //请求数据
    self.currentDate = queryDate;
    if (isUserDefaultTime) {
        [self getUserDefaultDaySensorData:queryDate toDate:queryDate];
    }else{
        [self getUserAllDaySensorData:queryDate toDate:queryDate];
    }
    //获取相应的数据
//    [self getUserSleepReportData:queryDate toDate:queryDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToHomeView:(UIButton*)button
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 自定义和24切换

- (void)show24HourData:(NSNotification *)noti
{
//    NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
//    NSString *query = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
    //为了请求异常数据时间
//    self.currentDate = query;
    [self getUserAllDaySensorData:self.currentDate toDate:self.currentDate];
}

- (void)showDefatultHourData:(NSNotification*)noti
{
//    NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
//    NSString *query = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
    //为了请求异常数据时间
//    self.currentDate = query;
    [self getUserDefaultDaySensorData:self.currentDate toDate:self.currentDate];
}

#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}

@end
