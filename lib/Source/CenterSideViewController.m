//
//  CenterSideViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CenterSideViewController.h"
#import "GifView.h"
#import "LoginViewController.h"
#import "AMBlurView.h"
#import "DeviceManagerViewController.h"
#import "UDPAddProductViewController.h"
//
#import "CalenderCantainerViewController.h"
//api
#import "GetDefatultSleepAPI.h"
#import "GetDeviceStatusAPI.h"
#import "CheckDeviceStatusAPI.h"
//
#import "TodayDataViewController.h"
#import "YTKChainRequest.h"
#import "UIViewController+TopBarMessage.h"
#import "MTStatusBarOverlay.h"

#define SleepWidthAndHeightScale    1.47884187  //old 1.47884187/1.3848
#define DatePickerHeight            self.view.frame.size.height*0.252623
#define DatePickerWithSleepCirclePadding 60
#define SleepCircleHeight           (self.view.frame.size.height-DatePickerHeight-30-DatePickerWithSleepCirclePadding-64)

#define SleepCircleWidth            (SleepCircleHeight/SleepWidthAndHeightScale)
#define PeopleCenterToLeftPadding   (SleepCircleHeight - SleepCircleWidth)
#define PeopleToLeftPadding1        (SleepCircleHeight/2-PeopleCenterToLeftPadding)
#define PeoplePadding               (SleepCircleWidth/2 - PeopleToLeftPadding1)

@interface CenterSideViewController ()<SetScrollDateDelegate,SelectCalenderDate,UIAlertViewDelegate>
{
    UIImageView *sleepCircle;
    BOOL deviceStatus;
}
@property (nonatomic, copy) NSString *correctPin;//验证密码
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic, assign) int remainingPinEntries;//验证次数

//@property (nonatomic,strong) NSDateComponents *dateComponents;
//@property (nonatomic,strong) NSDateFormatter *dateFormmatter;
//@property (nonatomic,strong) NSTimeZone *tmZone;


@end

@implementation CenterSideViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    deviceStatus = YES;
    //添加日历
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.dateDelegate = self;
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    //自定义导航栏
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            return self.menuButton;
        }
        return nil;
    }];
    //UUid更新时候检测
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDeviceUUID:) name:POSTDEVICEUUIDCHANGENOTI object:nil];
//    //登出
    //重新登录时，切换新的设备id
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getDeviceStatusWithUserId:) name:CHANGEUSERID object:nil];
    //更改默认uuid之后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceUUIDChangeed:) name:CHANGEDEVICEUUID object:nil];
    //观察这个值是否发生变化。
    //创建子视图
    [self creatSubView];
    //检测用户下的设备列表在进入app首先获取id
    
    //
    //获取时间
    if (!selectedDateToUse) {
        NSDate *date = [NSDate date];
        //系统时区
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        //和格林尼治时间差
        NSInteger timeOff = [zone secondsFromGMT];
        //视察转化
        selectedDateToUse = [date dateByAddingTimeInterval:timeOff];
    }
    //
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"yindao":@"YES"}];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"yindao"] isEqualToString:@"YES"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self createYinDaoView];
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"yindao"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //检测用户下的设备列表在进入app首先获取id；
    //获取用户相关联的设备uuid
    if ([HardWareUUID isEqualToString:@""]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self getDeviceStatusWithUserNewAPI:thirdPartyLoginUserId];
    }else {
        
//        [self checkDeviceStatus];
    }
}

#pragma mark 测试新的api

- (void)getDeviceStatusWithUserNewAPI:(NSString *)userID
{
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",thirdPartyLoginUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDeviceStatusAPI *client = [GetDeviceStatusAPI shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client getActiveDeviceUUID:header withDetailUrl:urlString];
    YTKChainRequest *chainRequest = [[YTKChainRequest alloc]init];
    [chainRequest addRequest:client callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary *resposeDic = (NSDictionary *)baseRequest.responseJSONObject;
        HaviLog(@"获取硬件信息是%@",resposeDic);
        NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
        if (arr.count == 0) {
            HardWareUUID = @"";
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 900;
            [alert show];
            [self reloadStatusImage:NO];
        }else{
            HardWareUUID = @"";
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    HardWareUUID = [dic objectForKey:@"UUID"];
                    HaviLog(@"关联默认的uuid是%@",HardWareUUID);
                    break;
                }
            }
            if ([HardWareUUID isEqualToString:@""]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 901;
                [alert show];
                [self reloadStatusImage:NO];
            }else{
                [self reloadStatusImage:NO];
//                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//                [self checkDeviceStatus];
            }
        }
    }];
    [chainRequest start];
}

#pragma mark end

- (void)createYinDaoView
{
    UIView *subView = [[UIView alloc]initWithFrame:self.view.bounds];
    subView.tag = 11111;
    subView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:subView];
    subView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideView:)];
    [subView addGestureRecognizer:tap];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_Prompt"]];
    [subView addSubview:imageView];
    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subView.left).offset(0);
        make.bottom.equalTo(subView.bottom).offset(0);
        make.left.equalTo(subView.left);
        make.right.equalTo(subView.right);
    }];
    
    
}

- (void)hideView:(UITapGestureRecognizer *)gesture
{
    UIView *view = (UIView *)[[UIApplication sharedApplication].keyWindow viewWithTag:11111];
    [view removeFromSuperview];
}

#pragma mark noti method

- (void)changeDeviceUUID:(NSNotification *)noti
{
    
//    [self checkDeviceStatus];
}

////登出时进行此操作
//- (void)showLoginView:(NSNotification *)noti
//{
//    LoginViewController *login = [[LoginViewController alloc]init];
//    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
//    navi.navigationBarHidden = YES;
//    [self presentViewController:navi animated:YES completion:^{
////        [self tapImage:nil];
//        [self.datePicker removeFromSuperview];
//        self.datePicker = nil;
//        [self.view addSubview:self.datePicker];
//        [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
//        [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
//        self.datePicker.dateDelegate = self;
//        self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
////        self.view = nil;
//    }];
//
//}
#pragma mark 获取用户数据

- (void)getTodayUserData:(NSString *)fromDate endDate:(NSString *)endDate withCompareDate:(NSDate *)compDate
{
    //fromdate 是当天的日期
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!fromDate) {
        
//        [ShowAlertView showAlert:@"CenterSideViewController:214,line开始时间为空"];
        return;
    }
//    [MMProgressHUD showWithStatus:@"请求中..."];
    NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
    NSString *urlString = @"";
    if (isUserDefaultTime) {
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,endDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            self.dateComponentsBase.day = 1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newStringToend = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newStringToend,startTime,endTime];
            
        }
    }else{
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,endDate];
    }
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
            [self reloadUserUI:(NSDictionary *)resposeDic];
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10008){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 900;
            [alert show];
            [self reloadStatusImage:NO];
        }else{
            
        }
        HaviLog(@"获取当日睡眠质量:%@",resposeDic);
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)deviceUUIDChangeed:(NSNotification *)noti
{
    [self reloadUserUI:nil];
}

- (void)reloadUserUI:(NSDictionary *)dic
{
    int heart = [[dic objectForKey:@"AverageHeartRate"]intValue];
    int bodyMovementTimes = [[dic objectForKey:@"BodyMovementTimes"]intValue];
    int breath = [[dic objectForKey:@"AverageRespiratoryRate"]intValue];
    int outBed = [[dic objectForKey:@"OutOfBedTimes"]intValue];
    UILabel *heartLabel = (UILabel *)[self.view viewWithTag:1001];
    UILabel *breathLabel = (UILabel *)[self.view viewWithTag:1002];
    UILabel *bodyLabel = (UILabel *)[self.view viewWithTag:1003];
    UILabel *moveLabel = (UILabel *)[self.view viewWithTag:1004];
    heartLabel.text = [NSString stringWithFormat:@"%d次/分钟",heart];
    breathLabel.text = [NSString stringWithFormat:@"%d次/分钟",breath];
    bodyLabel.text = [NSString stringWithFormat:@"%d次/天",outBed];
    moveLabel.text = [NSString stringWithFormat:@"%d次/天",bodyMovementTimes];
}

- (void)showDifferentAlertWithDeviceStatus
{
    if ([HardWareUUID isEqualToString:NOBINDUUID]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 900;
        [alert show];
        [self reloadStatusImage:NO];
    }else if ([HardWareUUID isEqualToString:NOUSEUUID]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 901;
        [alert show];
        [self reloadStatusImage:NO];
    }else{
        [self checkDeviceStatus];
        
    }

}

- (void)shareApp:(UIButton *)sender
{
    
    [self.shareMenuView show];
}

#pragma mark 获取设备列表
- (void)getDeviceStatusWithUserId:(NSString *)userId
{
    
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",thirdPartyLoginUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDeviceStatusAPI *client = [GetDeviceStatusAPI shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client getActiveDeviceUUID:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"获取硬件信息是%@",resposeDic);
        [MMProgressHUD dismiss];
        NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
        if (arr.count == 0) {
            HardWareUUID = NOBINDUUID;
        }else{
            HardWareUUID = NOUSEUUID;
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    HardWareUUID = [dic objectForKey:@"UUID"];
                    HaviLog(@"关联默认的uuid是%@",HardWareUUID);
                    break;
                }
            }
        }
        [self showDifferentAlertWithDeviceStatus];
    } failure:^(YTKBaseRequest *request) {
        
    }];
    //获取数据
}


#pragma mark 检查设备是否在线
- (void)checkDeviceStatus
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorInfo?UUID=%@",HardWareUUID];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    CheckDeviceStatusAPI *client = [CheckDeviceStatusAPI shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client checkStatus:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"设备状态是%@",resposeDic);
        NSDictionary *dic = [resposeDic objectForKey:@"SensorInfo"];
        if ([[dic objectForKey:@"ActivationStatusCode"] intValue]==1) {
            [self reloadStatusImage:YES];
            //获取数据
            NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
            NSString *subString = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
            [self getTodayUserData:subString endDate:subString withCompareDate:[NSDate date]];

            DeviceStatus = YES;
        }else{
            [self reloadStatusImage:NO];
            /*
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的设备未处于工作状态,请确认设备处于工作状态。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 902;
            [alert show];
             */
            dispatch_async(dispatch_get_main_queue(), ^{
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                overlay.backgroundColor = [UIColor redColor];
                overlay.customTextColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
                [overlay postErrorMessage:@"您的设备未处于工作状态,请确认!" duration:5 animated:YES];
            });
//            [self showTopMessage:@"您的设备未处于工作状态,请确认设备处于工作状态!"];
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
    
}

- (void)reloadStatusImage:(BOOL)status
{
    if (status) {
        sleepCircle.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_on_line_%d",selectedThemeIndex]];
        deviceStatus = YES;
    }else{
        sleepCircle.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_off_line_%d",selectedThemeIndex]];
        deviceStatus = NO;
    }
}


#pragma 自定义delegate
- (void)getScrollSelectedDate:(NSDate *)date
{
    if (date) {
        selectedDateToUse = date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
        NSString *dateString = [formatter stringFromDate:date];
        HaviLog(@"当前选中的日期是%@",dateString);
        NSString *subString = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
        [self getTodayUserData:subString endDate:subString withCompareDate:date];
    }
}

- (void)creatSubView
{
    //岁屏幕变化的量
    sleepCircle = [[UIImageView alloc]init];
    sleepCircle.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_on_line_%d",selectedThemeIndex]];
    sleepCircle.userInteractionEnabled = YES;
    [self.view addSubview:sleepCircle];
    [sleepCircle makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(104);
        make.left.equalTo(self.view.left).offset(0);
        make.bottom.equalTo(self.view.bottom).offset(-DatePickerHeight-DatePickerWithSleepCirclePadding);
        make.height.equalTo(sleepCircle.width).multipliedBy(SleepWidthAndHeightScale);
    }];
//    心率
    UITapGestureRecognizer *tapCircle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [sleepCircle addGestureRecognizer:tapCircle];
    
    [self.view addSubview:self.gifHeart];
    self.gifHeart.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapHeartImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeartImage:)];
    [self.gifHeart addGestureRecognizer:tapHeartImage];
    [self.gifHeart makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(sleepCircle.centerX).multipliedBy(1.0);
//        make.centerY.equalTo(sleepCircle.centerY).offset(-SleepCircleHeight/2);
        make.centerX.equalTo(sleepCircle.centerX).offset(SleepCircleHeight/2*sin(M_PI/18)- PeoplePadding);
        make.centerY.equalTo(sleepCircle.centerY).offset(-SleepCircleHeight/2*cos(M_PI/18));
        
        make.height.width.equalTo(CircleWidth);
    }];
//label
    UILabel *heartLabel = [[UILabel alloc]init];
    [self.view addSubview:heartLabel];
    [heartLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifHeart.right).offset(20);
        make.centerY.equalTo(self.gifHeart.centerY).offset(10);
        make.height.equalTo(20);
    }];
    heartLabel.tag = 1005;
    heartLabel.text = @"心率";
    heartLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UILabel *heartLabelShow = [[UILabel alloc]init];
    [self.view addSubview:heartLabelShow];
    [heartLabelShow makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifHeart.right).offset(20);
        make.centerY.equalTo(self.gifHeart.centerY).offset(-10);
        make.height.equalTo(20);
    }];
    heartLabelShow.tag = 1001;
    heartLabelShow.text = @"0次/分钟";
    heartLabelShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
//    呼吸
    [self.view addSubview:self.gifbreath];
    [self.gifbreath makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(sleepCircle.centerX).multipliedBy(1.95).offset(0);
//        make.centerY.equalTo(sleepCircle.centerY).multipliedBy(0.75).offset(0);
        make.centerX.equalTo(sleepCircle.centerX).offset(SleepCircleHeight/2*sin(M_PI*63.3333/180)- PeoplePadding+1);
        make.centerY.equalTo(sleepCircle.centerY).offset(-SleepCircleHeight/2*cos(M_PI*63.3333/180));
        make.height.width.equalTo(CircleWidth);
    }];
    self.gifbreath.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBreatheImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeartImage:)];
    [self.gifbreath addGestureRecognizer:tapBreatheImage];
//    label
    UILabel *breatheLabel = [[UILabel alloc]init];
    [self.view addSubview:breatheLabel];
    [breatheLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifbreath.right).offset(20);
        make.centerY.equalTo(self.gifbreath.centerY).offset(10);
        make.height.equalTo(20);
    }];
    breatheLabel.text = @"呼吸";
    breatheLabel.tag = 1006;
    breatheLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UILabel *breatheLabelShow = [[UILabel alloc]init];
    [self.view addSubview:breatheLabelShow];
    [breatheLabelShow makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifbreath.right).offset(20);
        make.centerY.equalTo(self.gifbreath.centerY).offset(-10);
        make.height.equalTo(20);
    }];
    breatheLabelShow.text = @"0次/分钟";
    breatheLabelShow.tag = 1002;
    breatheLabelShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
//    离床
    [self.view addSubview:self.gifLeave];
    [self.gifLeave makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sleepCircle.centerX).offset(SleepCircleHeight/2*sin(M_PI*63.3333/180)- PeoplePadding+1);
        make.centerY.equalTo(sleepCircle.centerY).offset(SleepCircleHeight/2*cos(M_PI*63.3333/180));
        make.height.width.equalTo(CircleWidth);
    }];
    self.gifLeave.userInteractionEnabled = YES;
    UITapGestureRecognizer *leveaBedImageTaped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeartImage:)];
    [self.gifLeave addGestureRecognizer:leveaBedImageTaped];
    //    label
    UILabel *leveaBedLabel = [[UILabel alloc]init];
    [self.view addSubview:leveaBedLabel];
    [leveaBedLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifLeave.right).offset(20);
        make.centerY.equalTo(self.gifLeave.centerY).offset(10);
        make.height.equalTo(20);
    }];
    leveaBedLabel.tag = 1007;
    leveaBedLabel.text = @"离床";
    leveaBedLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UILabel *leveaBedLabelShow = [[UILabel alloc]init];
    [self.view addSubview:leveaBedLabelShow];
    [leveaBedLabelShow makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifLeave.right).offset(20);
        make.centerY.equalTo(self.gifLeave.centerY).offset(-10);
        make.height.equalTo(20);
    }];
    leveaBedLabelShow.text = @"0次/天";
    leveaBedLabelShow.tag = 1003;
    leveaBedLabelShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
//    体动
    [self.view addSubview:self.gifTurn];
    [self.gifTurn makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sleepCircle.centerX).offset(SleepCircleHeight/2*sin(M_PI/18)- PeoplePadding);
        make.centerY.equalTo(sleepCircle.centerY).offset(SleepCircleHeight/2*cos(M_PI/18));
        make.height.width.equalTo(CircleWidth);
    }];
    self.gifTurn.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapHeartImage3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeartImage:)];
    [self.gifTurn addGestureRecognizer:tapHeartImage3];
    
    //    label
    UILabel *moveBodyLabel = [[UILabel alloc]init];
    [self.view addSubview:moveBodyLabel];
    [moveBodyLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifTurn.right).offset(20);
        make.centerY.equalTo(self.gifTurn.centerY).offset(10);
        make.height.equalTo(20);
    }];
    moveBodyLabel.tag = 1008;
    moveBodyLabel.text = @"体动";
    moveBodyLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UILabel *moveBodyLabelShow = [[UILabel alloc]init];
    [self.view addSubview:moveBodyLabelShow];
    [moveBodyLabelShow makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifTurn.right).offset(20);
        make.centerY.equalTo(self.gifTurn.centerY).offset(-10);
        make.height.equalTo(20);
    }];
    moveBodyLabelShow.text = @"0次/天";
    moveBodyLabelShow.tag = 1004;
    moveBodyLabelShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
}

- (void)tapHeartImage:(UITapGestureRecognizer *)gesture
{
    UIImageView *image = (UIImageView *)gesture.view;
    NSString *selectedIndex = @"心率";
    NSInteger seledtedIndexNum = 0;
    if ([image isEqual:self.gifHeart]) {
        selectedIndex = @"心率";
        seledtedIndexNum = 0;
    }else if([image isEqual:self.gifbreath]){
        selectedIndex = @"呼吸";
        seledtedIndexNum = 1;
    }else if ([image isEqual:self.gifLeave]){
        selectedIndex = @"离床";
        seledtedIndexNum = 2;
    }else if ([image isEqual:self.gifTurn]){
        selectedIndex = @"体动";
        seledtedIndexNum = 3;
    }
    TodayDataViewController *today = [[TodayDataViewController alloc]init];
    today.selectedIndex = seledtedIndexNum;
    [self.navigationController pushViewController:today animated:YES];

}
#pragma mark 更换皮肤
- (void)reloadImage
{
    //这样做可以保证父类不被覆盖
    [super reloadImage];
    HaviLog(@"center更换皮肤");
    [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [self.btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    self.datePicker.backLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    UILabel *heartLabel = (UILabel *)[self.view viewWithTag:1001];
    UILabel *breathLabel = (UILabel *)[self.view viewWithTag:1002];
    UILabel *bodyLabel = (UILabel *)[self.view viewWithTag:1003];
    UILabel *moveLabel = (UILabel *)[self.view viewWithTag:1004];
    UILabel *heartLabelT = (UILabel *)[self.view viewWithTag:1005];
    UILabel *breathLabelT = (UILabel *)[self.view viewWithTag:1006];
    UILabel *bodyLabelT = (UILabel *)[self.view viewWithTag:1007];
    UILabel *moveLabelT = (UILabel *)[self.view viewWithTag:1008];
    bodyLabelT.textColor = heartLabelT.textColor = moveLabelT.textColor = breathLabelT.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    heartLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    breathLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    bodyLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    moveLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    if (deviceStatus) {
        sleepCircle.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_on_line_%d",selectedThemeIndex]];
    }else{
        sleepCircle.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_off_line_%d",selectedThemeIndex]];

    }
    
//    self.view = nil;
//    self.gifbreath = nil;
//    self.gifHeart = nil;
//    self.gifLeave = nil;
//    self.gifTurn = nil;
//    [self.gifTurn removeFromSuperview];
//    [self.gifLeave removeFromSuperview];
//    [self.gifHeart removeFromSuperview];
//    [self.gifbreath removeFromSuperview];
//    [sleepCircle removeFromSuperview];
//    sleepCircle = nil;
//    [self creatSubView];
}

- (void)showCalender:(UIButton *)sender
{
    CalenderCantainerViewController *calender = [[CalenderCantainerViewController alloc]init];
    calender.calenderDelegate = self;
    [self presentViewController:calender animated:YES completion:nil];
}

//选中日历
- (void)selectedCalenderDate:(NSDate *)date
{
    [self.datePicker updateCalenderSelectedDate:date];
    //更新日历
}
#pragma mark 点击小人进行刷新
- (void)tapImage:(UITapGestureRecognizer *)gesture
{
    NSDate *nowDate = [self getNowDateFromatAnDate:[NSDate date]];
    //更新日历
    NSString *date = [NSString stringWithFormat:@"%@",nowDate];
    [self.datePicker updateSelectedDate:date];
    //为了下页的使用
    dayTimeToUse = date;
}

#pragma mark alertview 代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        DeviceStatus = YES;
    }
    if (alertView.tag == 900) {
        if (buttonIndex == 1) {
            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
            [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
        }
    }else if (alertView.tag == 901){
        if (buttonIndex == 1) {
            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
            [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
        }
    }else if (alertView.tag == 902){
        if (buttonIndex == 1) {
            UDPAddProductViewController *user = [[UDPAddProductViewController alloc]init];
            [self.navigationController pushViewController:user animated:YES];
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
