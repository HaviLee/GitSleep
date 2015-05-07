//
//  BreathViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BreathViewController.h"
#import "BreatheView.h"
#import "GetBreathDataAPI.h"
#import "ToggleView.h"
#import "GetUserDefaultDataAPI.h"
#import "GetDefatultSleepAPI.h"
#import "DiagnoseReportViewController.h"
#import "GetSleepReport.h"
#import "GetExceptionAPI.h"
#import "ModalAnimation.h"
#import "GetBreathSleepDataAPI.h"

@interface BreathViewController ()<SetScrollDateDelegate,ToggleViewDelegate,SelectedDate,UIViewControllerTransitioningDelegate>
{
    ModalAnimation *_modalAnimationController;
    
}
@property (nonatomic,strong) BreatheView *breatheView;
//

//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;


@end

@implementation BreathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
    //
    self.datePicker.dateDelegate = self;
    CGRect rect = self.datePicker.frame;
    rect.origin.y = rect.origin.y - 64;
    self.datePicker.frame = rect;
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    //
    [self createBreathSubView];
    //
    _modalAnimationController = [[ModalAnimation alloc] init];

}

#pragma mark 展示日历

- (void)showCalender:(UIButton *)sender
{
//    HaviLog(@"日历");
//    [UIView animateWithDuration:1.5 animations:^{
//        self.calenderNewView.delegate = self;
//        [[UIApplication sharedApplication].keyWindow addSubview:self.calenderNewView];
//    }];
    
}

//弹出式日历
//- (void)selectedDate:(NSDate *)selectedDate
//{
//    NSString *date = [NSString stringWithFormat:@"%@",selectedDate];
//    HaviLog(@"弹出日历选中的日期是%@",date);
//    NSString *subString = [NSString stringWithFormat:@"%@%@%@",[date substringWithRange:NSMakeRange(0, 4)],[date substringWithRange:NSMakeRange(5, 2)],[date substringWithRange:NSMakeRange(8, 2)]];
//    [self.datePicker caculateCurrentYearDate:selectedDate];
//    //获取相应的数据
//    self.currentDate = subString;
//    //    [self getUserAllDaySensorData:subString toDate:subString];
//    [self.calenderNewView removeFromSuperview];
//    //更新日历
//    [self.datePicker updateSelectedDate:date ];
//    self.calenderNewView = nil;
//}

- (void)createBreathSubView
{
    int height = self.datePicker.frame.size.height;
    CGRect frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -64 - height);
    self.breatheView = [[BreatheView alloc]initWithFrame:frame];
    self.breatheView.breathTimeSwitchButton.toggleDelegate = self;
    [self.view addSubview:self.breatheView];
}

#pragma mark 水平滚动日历
//滑动日历的选中
- (void)getSelectedDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:date];
    HaviLog(@"滚动日历中的日期是%@",dateString);
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    self.currentDate = queryDate;
    dayTimeToUse = dateString;
    //请求数据
    if (isUserDefaultTime) {
        [self getUserDefaultDaySensorData:queryDate toDate:queryDate];
    }else{
        [self getUserAllDaySensorData:queryDate toDate:queryDate];
    }
    //获取相应的数据
    //    [self getUserSleepReportData:queryDate toDate:queryDate];
}

#pragma mark 获取自定义数据
- (void)getUserDefaultDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    int startInt = [[startTime substringToIndex:2]intValue];
    int endInt = [[endTime substringToIndex:2]intValue];
    
    NSString *urlString = @"";
    if (startInt<endInt) {
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
    }else if (startInt>endInt || startInt==endInt){
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        self.dateComponentsBase.day = +1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
        
    }
    [KVNProgress showWithStatus:@"请求中..."];
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
        //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
        
    }
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
    self.breatheView.aff = nil;
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    for (NSDictionary *dic in arr) {
        self.breatheView.aff = [self changeSeverDataToDefaultChartData:[dic objectForKey:@"Data"]];;
        
    }
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
    int num = 0;
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    int startInt = [[startTime substringToIndex:2]intValue];
    int endInt = [[endTime substringToIndex:2]intValue];
    if (startInt<endInt) {
        num = (endInt - startInt)*12;
    }else if (startInt>endInt ){
        num = (24-startInt +endInt)*12;
    }else if (startInt==endInt){
        num = 288;
    }
    for (int i=0; i<num; i++) {
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

#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    [KVNProgress showWithStatus:@"请求中..."];
    NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetBreathDataAPI *client = [GetBreathDataAPI shareInstance];
    [client getBreathData:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [KVNProgress dismiss];
        HaviLog(@"请求的心率数据%@",resposeDic);
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
    NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetBreathSleepDataAPI *client = [GetBreathSleepDataAPI shareInstance];
    [client getBreathSleepData:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"心率是%@",resposeDic);
        [self reloadSleepView:resposeDic];
        //为了异常报告
        self.currentSleepQulitity = resposeDic;
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress dismissWithCompletion:^{
            [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
        }];
    }];
}

- (void)reloadSleepView:(NSDictionary *)dic
{
    //心率
    self.breatheView.infoDic = dic;
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    self.breatheView.aff = nil;
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    for (NSDictionary *dic in arr) {
        self.breatheView.aff = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        
    }
    [self.breatheView layoutOutSubViewWithNewData];
    
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showBreatheEmercenyView:) name:PostBreatheEmergencyNoti object:nil];

    //保持统一的切换日期
    if (isUserDefaultTime) {
        [self.breatheView.breathTimeSwitchButton changeRightImageWithTime:0];
    }else{
        [self.breatheView.breathTimeSwitchButton changeLeftImageWithTime:0];
    }
    //和首页保持一致
    if (dayTimeToUse.length>0) {
        [self.datePicker updateSelectedDate:dayTimeToUse];
        NSString *useDate = [NSString stringWithFormat:@"%@%@%@",[dayTimeToUse substringToIndex:4],[dayTimeToUse substringWithRange:NSMakeRange(5, 2)],[dayTimeToUse substringWithRange:NSMakeRange(8, 2)]];
        self.currentDate = useDate;
        //因为这个地方会调用到日历中的请求数据
    }else{
        //进行请求数据
        NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        NSString *query = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
        //为了请求异常数据时间
        if (isUserDefaultTime) {
            self.currentDate = query;
            [self getUserDefaultDaySensorData:query toDate:query];
        }else{
            self.currentDate = query;//20150425
            [self getUserAllDaySensorData:query toDate:query];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PostBreatheEmergencyNoti object:nil];

}
#pragma mark 异常数据
- (void)showBreatheEmercenyView:(NSNotification*)noti
{
    [self showDiagnoseReportBreath];
}

- (void)showDiagnoseReportBreath
{
    NSString *urlString = @"";
    if (isUserDefaultTime) {
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,self.currentDate,self.currentDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,self.currentDate,newString,startTime,endTime];
            
        }
    }else{
        NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    }
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

#pragma mark 自定义和24
- (void)selectLeftButton
{
    HaviLog(@"左侧");
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [self.breatheView.breathTimeSwitchButton changeLeftImageWithTime:0];
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
    }else{
        isUserDefaultTime = NO;
        [self getUserAllDaySensorData:self.currentDate toDate:self.currentDate];
        //        [[NSNotificationCenter defaultCenter]postNotificationName:TwtityFourHourNoti object:nil];
    }
}

- (void)selectRightButton
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [self.breatheView.breathTimeSwitchButton changeLeftImageWithTime:0];
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
    }else{
        isUserDefaultTime = YES;
        [self getUserDefaultDaySensorData:self.currentDate toDate:self.currentDate];
        //        [[NSNotificationCenter defaultCenter]postNotificationName:UserDefaultHourNoti object:nil];
        HaviLog(@"右侧");
    }
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
