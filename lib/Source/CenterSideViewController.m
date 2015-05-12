//
//  CenterSideViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CenterSideViewController.h"
#import "GifView.h"
#import "DataShowViewController.h"
#import "THPinViewController.h"
#import "LoginViewController.h"
#import "AMBlurView.h"
#import "DeviceManagerViewController.h"
//
#import "TodayDataContainerViewController.h"
#import "CalenderCantainerViewController.h"
//api
#import "GetDefatultSleepAPI.h"
#import "GetDeviceStatusAPI.h"
#import "CheckDeviceStatusAPI.h"
//
#import "TodayDataViewController.h"
#import "YTKChainRequest.h"

#define SleepWidthAndHeightScale    1.47884187  //old 1.47884187/1.3848
#define DatePickerHeight            self.view.frame.size.height*0.252623
#define DatePickerWithSleepCirclePadding 60
#define SleepCircleHeight           (self.view.frame.size.height-DatePickerHeight-30-DatePickerWithSleepCirclePadding-64)

#define SleepCircleWidth            (SleepCircleHeight/SleepWidthAndHeightScale)
#define PeopleCenterToLeftPadding   (SleepCircleHeight - SleepCircleWidth)
#define PeopleToLeftPadding1        (SleepCircleHeight/2-PeopleCenterToLeftPadding)
#define PeoplePadding               (SleepCircleWidth/2 - PeopleToLeftPadding1)

@interface CenterSideViewController ()<SetScrollDateDelegate,THPinViewControllerDelegate,SelectCalenderDate,UIAlertViewDelegate,YTKChainRequestDelegate>
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

//- (NSDateFormatter *)dateFormmatter
//{
//    if (!_dateFormmatter) {
//        _dateFormmatter = [[NSDateFormatter alloc]init];
//        [_dateFormmatter setDateFormat:@"yyyyMMdd"];
//        _dateFormmatter.timeZone = self.tmZone;
//    }
//    return _dateFormmatter;
//}
//
//- (NSDateComponents*)dateComponents
//{
//    if (!_dateComponents) {
//        _dateComponents = [[NSDateComponents alloc] init];
//        _dateComponents.timeZone = self.tmZone;
//    }
//    return _dateComponents;
//}
//
//- (NSTimeZone *)tmZone
//{
//    if (!_tmZone) {
//        _tmZone = [NSTimeZone timeZoneWithName:@"GMT"];
//        [NSTimeZone setDefaultTimeZone:_tmZone];
//    }
//    return _tmZone;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{AppPassWordKey:@"NO"}];
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
            _btn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
            [_btn setImage:i forState:UIControlStateNormal];
            [_btn setFrame:CGRectMake(5, 0, 44, 44)];
            [_btn addTarget:self action:@selector(left) forControlEvents:UIControlEventTouchUpInside];
            return _btn;
        }
        /*
        else if (nIndex == 0){
            self.rightButton.frame = CGRectMake(self.view.frame.size.width-46, 0, 44, 44);
            [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
            return self.rightButton;
        }
        */
        return nil;
    }];
    //检测设置APP密码
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isShowAppSettingPassWord) name:AppPassWorkSetOkNoti object:nil];
    //移除检测
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAppSettingPassWord) name:AppPassWordCancelNoti object:nil];
    //UUid更新时候检测
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDeviceUUID:) name:POSTDEVICEUUIDCHANGENOTI object:nil];
    //登出
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showLoginView:) name:POSTLOGOUTNOTI object:nil];
    //重新登录时，切换新的设备id
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getDeviceStatusWithUserId:) name:CHANGEUSERID object:nil];
    //更改默认uuid之后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceUUIDChangeed:) name:CHANGEDEVICEUUID object:nil];
    //进行检测是不是有app 密码
    [self isShowAppSettingPassWord];
    //观察这个值是否发生变化。
    //创建子视图
    [self creatSubView];
    //检测用户下的设备列表在进入app首先获取id；
    [KVNProgress showWithStatus:@"获取设备信息中..."];
    //获取用户相关联的设备uuid
//    [self getDeviceStatusWithUserId:GloableUserId];
    //新的api测试
    
    [self getDeviceStatusWithUserNewAPI:GloableUserId];
    //
    /*
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    dayTimeToUse = dateString;
     */
    //获取时间
    selectedDateToUse = [NSDate date];
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

#pragma mark 测试新的api

- (void)getDeviceStatusWithUserNewAPI:(NSString *)userID
{
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",GloableUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDeviceStatusAPI *client = [GetDeviceStatusAPI shareInstance];
    [client getActiveDeviceUUID:header withDetailUrl:urlString];
    YTKChainRequest *chainRequest = [[YTKChainRequest alloc]init];
    [chainRequest addRequest:client callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        NSDictionary *resposeDic = (NSDictionary *)baseRequest.responseJSONObject;
        HaviLog(@"获取硬件信息是%@",resposeDic);
        [KVNProgress dismiss];
        NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
        if (arr.count == 0) {
            HardWareUUID = NOBINDUUID;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 900;
            [alert show];
            [self reloadStatusImage:YES];
        }else{
            HardWareUUID = NOUSEUUID;
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    HardWareUUID = [dic objectForKey:@"UUID"];
                    HaviLog(@"关联默认的uuid是%@",HardWareUUID);
                    break;
                }
            }
            if ([HardWareUUID isEqualToString:NOUSEUUID]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 901;
                [alert show];
                [self reloadStatusImage:YES];
            }else{
                [self reloadStatusImage:YES];
                //获取数据
                NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
                NSString *subString = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
                [self getTodayUserData:subString endDate:subString withCompareDate:[NSDate date]];
                
                DeviceStatus = YES;

                /*
                NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorInfo?UUID=%@",HardWareUUID];
                NSDictionary *header = @{
                                         @"AccessToken":@"123456789"
                                         };
                CheckDeviceStatusAPI *client1 = [CheckDeviceStatusAPI shareInstance];
                [client1 checkStatus:header withDetailUrl:urlString];
                [chainRequest addRequest:client1 callback:nil];
                 */
            }
        }
    }];
    chainRequest.delegate = self;
    [chainRequest start];
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest
{
    //暂时不做处理
    /*
    if (chainRequest.requestArray.count>1) {
        CheckDeviceStatusAPI *API = (CheckDeviceStatusAPI *)[chainRequest.requestArray objectAtIndex:1];
        NSDictionary *resposeDic = (NSDictionary *)API.responseJSONObject;
        //    NSDictionary *resposeDic = (NSDictionary *)chainRequest.responseJSONObject;
        HaviLog(@"设备状态是%@",resposeDic);
        NSDictionary *dic = [resposeDic objectForKey:@"SensorInfo"];
        if ([[dic objectForKey:@"ActivationStatus"]isEqualToString:@"激活"]) {
            [self reloadStatusImage:YES];
            //获取数据
            NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
            NSString *subString = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
            [self getTodayUserData:subString endDate:subString withCompareDate:[NSDate date]];
            
            DeviceStatus = YES;
        }else{
            [self reloadStatusImage:NO];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的设备未处于工作状态,是否启动设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 902;
            [alert show];
        }
    }
     */
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest *)request
{
    
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
    [self checkDeviceStatus];
}
- (void)removeAppSettingPassWord
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
    }
}

- (void)isShowAppSettingPassWord
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
        self.remainingPinEntries = 6;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}
//登出时进行此操作
- (void)showLoginView:(NSNotification *)noti
{
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
    navi.navigationBarHidden = YES;
    [self presentViewController:navi animated:YES completion:^{
//        [self tapImage:nil];
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
        [self.view addSubview:self.datePicker];
        [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
        self.datePicker.dateDelegate = self;
        self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
//        self.view = nil;
    }];

}
#pragma mark 获取用户数据

- (void)getTodayUserData:(NSString *)fromDate endDate:(NSString *)endDate withCompareDate:(NSDate *)compDate
{
    //fromdate 是当天的日期
    if (!fromDate) {
        
        [ShowAlertView showAlert:@"CenterSideViewController:214,line开始时间为空"];
        return;
    }
    [KVNProgress showWithStatus:@"请求中..."];
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
        [KVNProgress dismiss];
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
    /*
    NSString *urlString = [NSString stringWithFormat:@"http://webservice.meddo99.com:9000/v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@",HardWareUUID,fromDate,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    if ([compDate timeIntervalSinceDate:[NSDate date]]<0) {
        [WTRequestCenter getWithURL:urlString headers:header parameters:nil option:WTRequestCenterCachePolicyCacheElseWeb finished:^(NSURLResponse *response, NSData *data) {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [self reloadUserUI:(NSDictionary *)obj];
            HaviLog(@"数据是%@",obj);
        } failed:^(NSURLResponse *response, NSError *error) {
            
        }];
    }else{
        [WTRequestCenter getWithURL:urlString headers:header parameters:nil option:WTRequestCenterCachePolicyCacheAndRefresh finished:^(NSURLResponse *response, NSData *data) {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [self reloadUserUI:(NSDictionary *)obj];
            HaviLog(@"数据是%@",obj);
        } failed:^(NSURLResponse *response, NSError *error) {
            
        }];
    }
     */
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (HardWareUUID.length>0) {
//        [self showDifferentAlertWithDeviceStatus];
//    }
    
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
//    CeshiViewController *jiekouceshi = [[CeshiViewController alloc]init];
//    [self.navigationController pushViewController:jiekouceshi animated:YES];
}

- (void)left {
    [self.drawerController toggleDrawerSide:XHDrawerSideLeft animated:YES completion:^(BOOL finished) {
        
    }];
}
#pragma mark 获取设备列表
- (void)getDeviceStatusWithUserId:(NSString *)userId
{
    
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",GloableUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetDeviceStatusAPI *client = [GetDeviceStatusAPI shareInstance];
    [client getActiveDeviceUUID:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"获取硬件信息是%@",resposeDic);
        [KVNProgress dismiss];
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
    [client checkStatus:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"设备状态是%@",resposeDic);
        NSDictionary *dic = [resposeDic objectForKey:@"SensorInfo"];
        if ([[dic objectForKey:@"ActivationStatus"]isEqualToString:@"激活"]) {
            [self reloadStatusImage:YES];
            //获取数据
            NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
            NSString *subString = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
            [self getTodayUserData:subString endDate:subString withCompareDate:[NSDate date]];

            DeviceStatus = YES;
        }else{
            [self reloadStatusImage:NO];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的设备未处于工作状态,是否启动设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 902;
            [alert show];
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
#pragma mark 设备锁
- (void)showPinViewAnimated:(BOOL)animated
{
    THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    self.correctPin = [[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey];
    pinViewController.promptTitle = @"密码验证";
    pinViewController.promptColor = [UIColor whiteColor];
    pinViewController.view.tintColor = [UIColor whiteColor];
    
    // for a solid background color, use this:
    pinViewController.backgroundColor = [UIColor colorWithRed:0.141f green:0.165f blue:0.208f alpha:1.00f];
    
    // for a translucent background, use this:
    self.view.tag = THPinViewControllerContentViewTag;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    pinViewController.translucentBackground = NO;
    
    [self presentViewController:pinViewController animated:animated completion:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self showPinViewAnimated:NO];
}

- (void)dealloc
{
    [self removeAppSettingPassWord];
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
//        dayTimeToUse = dateString;
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
    
//    TodayDataContainerViewController *todayContainer = [[TodayDataContainerViewController alloc]init];
//    todayContainer.title = selectedIndex;
//    [self.navigationController pushViewController:todayContainer animated:YES];
    /*
    DataShowViewController *dataShow = [[DataShowViewController alloc]init];
    dataShow.selectedIndex = selectedIndex;
    [self.navigationController pushViewController:dataShow animated:YES];
    //为了解决右滑失效
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
     */
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
    NSDate *nowdate = [NSDate date];
    //更新日历
    NSString *date = [NSString stringWithFormat:@"%@",nowdate];
    [self.datePicker updateSelectedDate:date];
    //为了下页的使用
    dayTimeToUse = date;
}

//弹出式日历
//- (void)selectedDate:(NSDate *)selectedDate
//{
//    NSString *date = [NSString stringWithFormat:@"%@",selectedDate];
//    HaviLog(@"选中的日期是%@",date);
////    NSString *subString = [NSString stringWithFormat:@"%@%@%@",[date substringWithRange:NSMakeRange(0, 4)],[date substringWithRange:NSMakeRange(5, 2)],[date substringWithRange:NSMakeRange(8, 2)]];
//    [self.datePicker caculateCurrentYearDate:selectedDate];
//    [self.calenderNewView removeFromSuperview];
//    //更新日历
//    [self.datePicker updateSelectedDate:date ];
//    //为了下页的使用
//    dayTimeToUse = date;
//    self.calenderNewView = nil;
//}

#pragma mark - THPinViewControllerDelegate

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 4;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
    if ([pin isEqualToString:self.correctPin]) {
        return YES;
    } else {
        self.remainingPinEntries--;
        HaviLog(@"还能输入%d次",self.remainingPinEntries);
        return NO;
    }
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    //f返回yes可以无限次的验证
    return YES;
}

- (void)incorrectPinEnteredInPinViewController:(THPinViewController *)pinViewController
{
    if (self.remainingPinEntries > 6 / 2) {
        return;
    }
    
}

- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //默认值改变
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:AppPassWordKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //移除后台检测
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                          object:nil];
        }
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
        navi.navigationBarHidden = YES;
        [self presentViewController:navi animated:YES completion:nil];
    });
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
            DeviceManagerViewController *user = [[DeviceManagerViewController alloc]init];
            [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
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
