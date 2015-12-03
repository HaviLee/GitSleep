//
//  CenterContainerViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/21.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "CenterContainerViewController.h"
#import "CenterViewTableViewCell.h"
#import "CHCircleGaugeView.h"
#import "GetDefatultSleepAPI.h"
#import "MMPopupItem.h"
#import "MMTwoListPickerView.h"
#import "MMPickerView.h"
#import "DeviceListViewController.h"
#import "StartTimeView.h"
#import "EndTimeView.h"

#import "NewSecondHeartViewController.h"
#import "NewSecondBreathViewController.h"
#import "SencondLeaveViewController.h"
#import "SencondTurnViewController.h"
#import "KxMenu.h"
#import "UploadTagAPI.h"

//
//#import "DoubleLeaveContainerViewController.h"
//#import "DoubleTurnContainerViewController.h"
#import "DoubleHeartViewController.h"
#import "DoubleBreathViewController.h"
#import "DoubleLeaveViewController.h"
#import "DoubleTurnViewController.h"

@interface CenterContainerViewController ()<SetScrollDateDelegate>

@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) UITableView *leftTableView;
@property (nonatomic,strong) UITableView *rightTableView;
@property (nonatomic, strong) UILabel *leftSleepTimeLabel;//睡眠时长
@property (nonatomic, strong) UILabel *rightSleepTimeLabel;//睡眠时长
@property (nonatomic, strong) CHCircleGaugeView *leftCircleView;
@property (nonatomic, strong) CHCircleGaugeView *rightCircleView;
@property (nonatomic, strong) NSArray *leftCellDataArr;
@property (nonatomic, strong) NSArray *subPageViewArr;
@property (nonatomic, strong) UIButton *leftMenuButton;
@property (nonatomic, strong) UIButton *rightMenuButton;
@property (nonatomic, strong) NSArray *leftTableData;
@property (nonatomic, strong) NSArray *rightTableData;
@property (nonatomic, strong) StartTimeView *leftStartView;
@property (nonatomic, strong) EndTimeView *leftEndView;
@property (nonatomic, strong) StartTimeView *rightStartView;
@property (nonatomic, strong) EndTimeView *rightEndView;
//为了标签使用
@property (nonatomic, strong) NSString *tagFromDateAndEndDate;
@property (nonatomic, strong) UIButton *leftIWantSleepLabel;
@property (nonatomic, strong) UIButton *rightIWantSleepLabel;

@property (nonatomic, strong) NSString *leftDeviceShowName;
@property (nonatomic, strong) UINavigationController *containerNavi;


//
@property (nonatomic, strong) SencondLeaveViewController *sendLeaveView;
@property (nonatomic, strong) SencondTurnViewController *sendTurnView;
@property (nonatomic, strong) NewSecondBreathViewController *secondBreathView;
@property (nonatomic, strong) NewSecondHeartViewController *secondHeartView;
//
@property (nonatomic, strong) DoubleLeaveViewController *doubleLeaveView;
@property (nonatomic, strong) DoubleTurnViewController *doubleTurnView;
@property (nonatomic, strong) DoubleHeartViewController *doubleHeartView;
@property (nonatomic, strong) DoubleBreathViewController *doubleBreathView;

@end

@implementation CenterContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setContainerNavigationAndBackImage];
    [self initDatePicker];
    [self setNotifationList];
    //前三个和UUID无关可以先加载
    /*
     关于该界面的逻辑思路
     1，首先判断DeviceUUID是不是为空，为空进行请求，否则
     2，判断UUID是单人还是双人的，并获取相应UUID名称
     3，请求数据
     */
    //这个是在UUID不为空的情况下
    [self checkDeviceInfo];
    [self setPageViewControllerWithDic:nil];
}

- (void)checkDeviceInfo
{
    if (thirdHardDeviceUUID.length>0) {
        [self getDeviceInfoWithUUID:thirdHardDeviceUUID];
    }
}

- (void)setContainerNavigationAndBackImage
{
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
    }
    _containerNavi = [[UINavigationController alloc]init];
    [self addChildViewController:_containerNavi];
    _containerNavi.navigationBarHidden = YES;
    [self.view addSubview:_containerNavi.view];
    CGRect rect = self.view.frame;
    int datePickerHeight = self.view.frame.size.height*0.202623;
    rect.size.height = rect.size.height- datePickerHeight;
    [_containerNavi.view setFrame:rect];
}

#pragma mark 创建消息监听

- (void)setNotifationList
{
    //监听登录成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccessAndQueryData:) name:LoginSuccessedNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changedDeviceUUID:) name:CHANGEDEVICEUUID object:nil];
}

#pragma mark 消息监听方法

- (void)changedDeviceUUID:(NSNotification *)noti
{
    [self getDeviceInfoWithUUID:thirdHardDeviceUUID];
}
#pragma mark 进行获取设备信息
- (void)getDeviceInfoWithUUID:(NSString *)deviceUUID
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorInfo?UUID=%@",deviceUUID];
    
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"当前用户%@设备信息%@",thirdPartyLoginUserId,resposeDic);
        NSArray *childArr = [_containerNavi childViewControllers];
        for (UIViewController *navi in childArr) {
            if ([navi isKindOfClass:[SLPagingViewController class]]) {
                [navi removeFromParentViewController];
            }
        }
        if ([[[resposeDic objectForKey:@"SensorInfo"]objectForKey:@"DetailSensorInfo"] count]>1) {
            isDoubleDevice = YES;
        }else{
            isDoubleDevice = NO;
        }
        //
        [self setPageViewControllerWithDic:[resposeDic objectForKey:@"SensorInfo"]];
        [self setController];
        
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
    }];
}
//这个是在登录成功之后进行调用，无论你是首次注册还是说自动登录
- (void)loginSuccessAndQueryData:(NSNotification *)noti
{
    //thirdHardDeviceUUID是从plist文件进行读取的。判断是不是为空
    if (thirdHardDeviceUUID.length==0) {
        [self getAllDeviceList];//获取
    }
}

#pragma mark 获取用户数据

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
        for (NSDictionary *dic in arr) {
            if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                thirdHardDeviceUUID = [dic objectForKey:@"UUID"];
                thirdHardDeviceName = [dic objectForKey:@"Description"];
                [UserManager setGlobalOauth];
                break;
            }
        }
        
        NSString *urlString = [NSString stringWithFormat:@"v1/user/FriendDeviceList?UserID=%@",thirdPartyLoginUserId];
        
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
            NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            HaviLog(@"朋友%@下所有的设备%@",thirdPartyLoginUserId,resposeDic);
            [MMProgressHUD dismiss];
            NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    thirdHardDeviceUUID = [dic objectForKey:@"UUID"];
                    thirdHardDeviceName = [dic objectForKey:@"Description"];
                    self.clearNaviTitleLabel.text = thirdHardDeviceName;
                    self.leftDeviceShowName = [dic objectForKey:@"Description"];
                    [UserManager setGlobalOauth];
                    
                    break;
                }
            }
            HaviLog(@"用户%@关联默认的uuid是%@",thirdPartyLoginUserId,thirdHardDeviceUUID);
            if (![thirdHardDeviceUUID isEqualToString:@""]) {
                //
                [self setPageViewControllerWithDic:nil];
                [self setController];
                NSString *nowDateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
                NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
                [self getTodaySleepQualityData:newString];
            }else{
                MMPopupItemHandler block = ^(NSInteger index){
                    HaviLog(@"clickd %@ button",@(index));
                    if(index==1){
                        DeviceListViewController *user = [[DeviceListViewController alloc]init];
                        [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
                    }
                };
                NSArray *items =
                @[MMItemMake(@"暂不绑定", MMItemTypeNormal, block),
                  MMItemMake(@"确定", MMItemTypeNormal, block)];
                
                MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                                     detail:@"您还没有绑定设备,是否现在去绑定？" items:items];
                alertView.attachedView = self.view;
                
                [alertView show];
                
            }
            
        } failed:^(NSURLResponse *response, NSError *error) {
            
        }];
        
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
}


- (void)getTodaySleepQualityData:(NSString *)nowDateString
{
    //fromdate 是当天的日期
    if ([thirdHardDeviceUUID isEqualToString:@""]) {
        MMPopupItemHandler block = ^(NSInteger index){
            HaviLog(@"clickd %@ button",@(index));
            if(index==1){
                DeviceListViewController *user = [[DeviceListViewController alloc]init];
                [self.navigationController.topViewController.navigationController pushViewController:user animated:YES];
            }
        };
        NSArray *items =
        @[MMItemMake(@"暂不绑定", MMItemTypeNormal, block),
          MMItemMake(@"确定", MMItemTypeNormal, block)];
        
        MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                             detail:@"您还没有绑定设备,是否现在去绑定？" items:items];
        alertView.attachedView = self.view;
        
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
    urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",thirdHardDeviceUUID,thirdPartyLoginUserId,newString,nowDateString];
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
            alertView.attachedView = self.view;
            
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
    //左侧床垫数据
    self.leftTableData = @[
                         [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageHeartRate"]intValue]],
                         [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageRespiratoryRate"]intValue]],
                         [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"OutOfBedTimes"]intValue]],
                         [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"BodyMovementTimes"]intValue]]
                         ];
    [self.leftTableView reloadData];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[sleepDic objectForKey:@"Data"]];
    NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
    NSString *subString = [selectString substringToIndex:10];
    NSDictionary *dataDic=nil;
    for (NSDictionary *dic in arr) {
        if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
            dataDic = dic;
        }
    }
    NSString *sleepStartTime = [dataDic objectForKey:@"SleepStartTime"];
    NSString *sleepEndTime = [dataDic objectForKey:@"SleepEndTime"];
    NSString *sleepDuration = [dataDic objectForKey:@"SleepDuration"];
    int sleepLevel = [[sleepDic objectForKey:@"SleepQuality"]intValue];
    [self.leftCircleView changeSleepQualityValue:sleepLevel*20];//睡眠指数
    [self.leftCircleView changeSleepTimeValue:sleepLevel*20];
    [self.leftCircleView changeSleepLevelValue:[self changeNumToWord:sleepLevel]];
    self.leftCircleView.rotationValue = 88;
    
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
    self.leftSleepTimeLabel.text= sleepTimeDuration;
    if (sleepStartTime) {
        
        [self.leftCircleView addSubview:self.leftStartView];
        self.leftStartView.startTime = [sleepStartTime substringWithRange:NSMakeRange(11, 5)];
        self.leftStartView.center = CGPointMake(90, 10);
    }else{
        [self.leftStartView removeFromSuperview];
    }
    if (sleepEndTime) {
        [self.leftCircleView addSubview:self.leftEndView];
        self.leftEndView.endTime = [sleepEndTime substringWithRange:NSMakeRange(11, 5)];
        self.leftEndView.center = CGPointMake(self.view.frame.size.width-60, 10);
        //        self.endView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showEndTimePicker)];
        [self.leftEndView addGestureRecognizer:tap];
    }else
    {
        [self.leftEndView removeFromSuperview];
    }

    //
    self.rightTableData = @[
                           [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageHeartRate"]intValue]],
                           [NSString stringWithFormat:@"%d次/分",[[sleepDic objectForKey:@"AverageRespiratoryRate"]intValue]],
                           [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"OutOfBedTimes"]intValue]],
                           [NSString stringWithFormat:@"%d次/天",[[sleepDic objectForKey:@"BodyMovementTimes"]intValue]]
                           ];
    [self.rightTableView reloadData];
    //
        //
    NSMutableArray *arrR = [NSMutableArray arrayWithArray:[sleepDic objectForKey:@"Data"]];
    NSString *selectStringR = [NSString stringWithFormat:@"%@",selectedDateToUse];
    NSString *subStringR = [selectStringR substringToIndex:10];
    NSDictionary *dataDicR=nil;
    for (NSDictionary *dic in arrR) {
        if ([[dic objectForKey:@"Date"]isEqualToString:subStringR]) {
            dataDicR = dic;
        }
    }
    NSString *sleepStartTimeR = [dataDicR objectForKey:@"SleepStartTime"];
    NSString *sleepEndTimeR = [dataDicR objectForKey:@"SleepEndTime"];
    NSString *sleepDurationR = [dataDicR objectForKey:@"SleepDuration"];
    int sleepLevelR = [[sleepDic objectForKey:@"SleepQuality"]intValue];
    [self.rightCircleView changeSleepQualityValue:sleepLevelR*20];//睡眠指数
    [self.rightCircleView changeSleepTimeValue:sleepLevelR*20];
    [self.rightCircleView changeSleepLevelValue:[self changeNumToWord:sleepLevelR]];
    self.rightCircleView.rotationValue = 88;
    
    //    [self setClockRoationValueWithStartTime:sleepStartTime];
    int hourR = [sleepDurationR intValue];
    double second2R = 0.0;
    double subsecond2R = modf([sleepDuration floatValue], &second2R);
    NSString *sleepTimeDurationR= @"";
    if((int)round(subsecond2R*60)<10){
        sleepTimeDurationR = [NSString stringWithFormat:@"睡眠时长:%@小时0%d分",hourR<10?[NSString stringWithFormat:@"0%d",hourR]:[NSString stringWithFormat:@"%d",hourR],(int)round(subsecond2R*60)];
    }else{
        sleepTimeDurationR = [NSString stringWithFormat:@"睡眠时长:%@小时%d分",hourR<10?[NSString stringWithFormat:@"0%d",hourR]:[NSString stringWithFormat:@"%d",hourR],(int)round(subsecond2R*60)];
    }
    self.rightSleepTimeLabel.text= sleepTimeDurationR;
    if (sleepStartTimeR) {
        
        [self.rightCircleView addSubview:self.rightStartView];
        self.rightStartView.startTime = [sleepStartTimeR substringWithRange:NSMakeRange(11, 5)];
        self.rightStartView.center = CGPointMake(90, 10);
    }else{
        [self.rightStartView removeFromSuperview];
    }
    if (sleepEndTimeR) {
        [self.rightCircleView addSubview:self.rightEndView];
        self.rightEndView.endTime = [sleepEndTimeR substringWithRange:NSMakeRange(11, 5)];
        self.rightEndView.center = CGPointMake(self.view.frame.size.width-60, 10);
        //        self.endView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showEndTimePicker)];
        [self.rightEndView addGestureRecognizer:tap];
    }else
    {
        [self.rightEndView removeFromSuperview];
    }
    
}

- (void)setController
{
    if (thirdHardDeviceUUID.length>0) {
        if (!isDoubleDevice) {
            self.subPageViewArr = @[self.secondHeartView,self.secondBreathView,self.doubleLeaveView,self.doubleTurnView];
        }else{
            self.subPageViewArr = @[self.doubleHeartView,self.doubleBreathView,self.doubleLeaveView,self.doubleTurnView];
        }
        
    }
    
}

- (void)setPageViewControllerWithDic:(NSArray*)deviceArr
{
    if (thirdHardDeviceUUID.length>0) {
        if (isDoubleDevice) {
            UILabel *navTitleLabel1 = [UILabel new];
            navTitleLabel1.text = @"梧桐植树";
            navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
            navTitleLabel1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            
            UILabel *navTitleLabel2 = [UILabel new];
            navTitleLabel2.text = @"哈维之家";
            navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:17];
            navTitleLabel2.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            
            SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1, navTitleLabel2]
                                                                                            navBarBackground:[UIColor clearColor]
                                                                                                       views:@[self.leftTableView, self.rightTableView]
                                                                                             showPageControl:YES];
            [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
            [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
            [pageViewController updateUserInteractionOnNavigation:NO];
            pageViewController.tintPageControlColor = [UIColor grayColor];
            pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
            
            
            // Twitter Like
            pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
                float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
                float width = [UIScreen mainScreen].bounds.size.width;
                CGFloat xOffset = scrollView.contentOffset.x;
                int i = 0;
                for(UILabel *v in subviews){
                    CGFloat alpha = 0.0;
                    if(v.frame.origin.x < mid)
                        alpha = 1 - (xOffset - i*width) / width;
                    else if(v.frame.origin.x >mid)
                        alpha=(xOffset - i*width) / width + 1;
                    else if(v.frame.origin.x == mid-5)
                        alpha = 1.0;
                    i++;
                    v.alpha = alpha;
                }
            };
            
            pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
                // Do something
                NSLog(@"index %ld", (long)currentPageIndex);
            };
            pageViewController.navigationBarView.image = [UIImage imageNamed:@"navi_pg_night_0"];
            [pageViewController.navigationBarView addSubview:self.leftMenuButton];
            [pageViewController.navigationBarView addSubview:self.rightMenuButton];
            [_containerNavi setViewControllers:@[pageViewController]];
            
        }else{
            UILabel *navTitleLabel1 = [UILabel new];
            navTitleLabel1.text = thirdHardDeviceName;
            navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
            navTitleLabel1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            
            SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1]
                                                                                            navBarBackground:[UIColor clearColor]
                                                                                                       views:@[self.leftTableView]
                                                                                             showPageControl:YES];
            [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
            [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
            [pageViewController updateUserInteractionOnNavigation:NO];
            pageViewController.tintPageControlColor = [UIColor grayColor];
            pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
            
            
            // Twitter Like
            pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
                float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
                float width = [UIScreen mainScreen].bounds.size.width;
                CGFloat xOffset = scrollView.contentOffset.x;
                int i = 0;
                for(UILabel *v in subviews){
                    CGFloat alpha = 0.0;
                    if(v.frame.origin.x < mid)
                        alpha = 1 - (xOffset - i*width) / width;
                    else if(v.frame.origin.x >mid)
                        alpha=(xOffset - i*width) / width + 1;
                    else if(v.frame.origin.x == mid-5)
                        alpha = 1.0;
                    i++;
                    v.alpha = alpha;
                }
            };
            
            pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
                // Do something
                NSLog(@"index %ld", (long)currentPageIndex);
            };
            pageViewController.navigationBarView.image = [UIImage imageNamed:@"navi_pg_night_0"];
            [pageViewController.navigationBarView addSubview:self.leftMenuButton];
            [pageViewController.navigationBarView addSubview:self.rightMenuButton];
            [_containerNavi setViewControllers:@[pageViewController]];
        }
        NSString *nowDateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
        [self getTodaySleepQualityData:newString];

    }else{
        UILabel *navTitleLabel1 = [UILabel new];
        navTitleLabel1.text = @"";
        navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
        navTitleLabel1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        
        SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1]
                                                                                        navBarBackground:[UIColor clearColor]
                                                                                                   views:@[self.leftTableView]
                                                                                         showPageControl:YES];
        [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
        [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
        [pageViewController updateUserInteractionOnNavigation:NO];
        pageViewController.tintPageControlColor = [UIColor grayColor];
        pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
        
        
        // Twitter Like
        pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
            float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
            float width = [UIScreen mainScreen].bounds.size.width;
            CGFloat xOffset = scrollView.contentOffset.x;
            int i = 0;
            for(UILabel *v in subviews){
                CGFloat alpha = 0.0;
                if(v.frame.origin.x < mid)
                    alpha = 1 - (xOffset - i*width) / width;
                else if(v.frame.origin.x >mid)
                    alpha=(xOffset - i*width) / width + 1;
                else if(v.frame.origin.x == mid-5)
                    alpha = 1.0;
                i++;
                v.alpha = alpha;
            }
        };
        
        pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
            // Do something
            NSLog(@"index %ld", (long)currentPageIndex);
        };
        pageViewController.navigationBarView.image = [UIImage imageNamed:@"navi_pg_night_0"];
        [pageViewController.navigationBarView addSubview:self.leftMenuButton];
        [pageViewController.navigationBarView addSubview:self.rightMenuButton];
        [_containerNavi setViewControllers:@[pageViewController]];
    }
    
    // Do any additional setup after loading the view.
    
}

- (void)initDatePicker
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

#pragma mark setter

- (DoubleHeartViewController*)doubleHeartView
{
    if (!_doubleHeartView) {
        _doubleHeartView = [[DoubleHeartViewController alloc]init];
    }
    return _doubleHeartView;
}

- (DoubleBreathViewController*)doubleBreathView
{
    if (!_doubleBreathView) {
        _doubleBreathView = [[DoubleBreathViewController alloc]init];
    }
    return _doubleBreathView;
}

- (DoubleLeaveViewController *)doubleLeaveView
{
    if (!_doubleLeaveView) {
        _doubleLeaveView = [[DoubleLeaveViewController alloc]init];
    }
    return _doubleLeaveView;
}

- (DoubleTurnViewController *)doubleTurnView
{
    if (!_doubleTurnView) {
        _doubleTurnView = [[DoubleTurnViewController alloc]init];
    }
    return _doubleTurnView;
}


- (StartTimeView *)leftStartView
{
    if (_leftStartView==nil) {
        _leftStartView = [[StartTimeView alloc]init];
        
    }
    return _leftStartView;
}

- (EndTimeView *)leftEndView
{
    if (_leftEndView == nil) {
        _leftEndView = [[EndTimeView alloc]init];
    }
    return _leftEndView;
}

- (StartTimeView *)rightStartView
{
    if (_rightStartView==nil) {
        _rightStartView = [[StartTimeView alloc]init];
        
    }
    return _rightStartView;
}

- (EndTimeView *)rightEndView
{
    if (_rightEndView == nil) {
        _rightEndView = [[EndTimeView alloc]init];
    }
    return _rightEndView;
}


- (UIButton *)leftIWantSleepLabel
{
    if (_leftIWantSleepLabel==nil) {
        _leftIWantSleepLabel = [[UIButton alloc]init];
        _leftIWantSleepLabel.frame = CGRectMake((self.view.frame.size.width-90)/2, 10, 90,25);
        [_leftIWantSleepLabel setTitle:@"我要睡觉" forState:UIControlStateNormal];
        [_leftIWantSleepLabel setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_textbox_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_leftIWantSleepLabel setTitleColor:selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftIWantSleepLabel.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_leftIWantSleepLabel addTarget:self action:@selector(sendSleepTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftIWantSleepLabel;
}

- (UIButton *)rightIWantSleepLabel
{
    if (_rightIWantSleepLabel==nil) {
        _rightIWantSleepLabel = [[UIButton alloc]init];
        _rightIWantSleepLabel.frame = CGRectMake((self.view.frame.size.width-90)/2, 10, 90,25);
        [_rightIWantSleepLabel setTitle:@"我要睡觉" forState:UIControlStateNormal];
        [_rightIWantSleepLabel setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_textbox_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_rightIWantSleepLabel setTitleColor:selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightIWantSleepLabel.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_rightIWantSleepLabel addTarget:self action:@selector(sendSleepTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightIWantSleepLabel;
}

- (UIButton *)leftMenuButton
{
    if (!_leftMenuButton) {
        _leftMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
        [_leftMenuButton setImage:i forState:UIControlStateNormal];
        [_leftMenuButton setFrame:CGRectMake(0, 20, 44, 44)];
        [_leftMenuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftMenuButton;
}

- (UIButton *)rightMenuButton
{
    if (!_rightMenuButton) {
        _rightMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_ellipse"]];
        [_rightMenuButton setImage:i forState:UIControlStateNormal];
        [_rightMenuButton setFrame:CGRectMake(self.view.frame.size.width-50, 20, 44, 44)];
        [_rightMenuButton addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightMenuButton;
}


- (NewSecondHeartViewController*)secondHeartView
{
    if (!_secondHeartView) {
        _secondHeartView = [[NewSecondHeartViewController alloc]init];
    }
    return _secondHeartView;
}

- (NewSecondBreathViewController*)secondBreathView
{
    if (!_secondBreathView) {
        _secondBreathView = [[NewSecondBreathViewController alloc]init];
    }
    return _secondBreathView;
}

- (SencondLeaveViewController*)sendLeaveView
{
    if (_sendLeaveView == nil) {
        _sendLeaveView = [[SencondLeaveViewController alloc]init];
    }
    return _sendLeaveView;
}

- (SencondTurnViewController*)sendTurnView
{
    if (_sendTurnView == nil) {
        _sendTurnView = [[SencondTurnViewController alloc]init];
    }
    return _sendTurnView;
}


- (CHCircleGaugeView *)leftCircleView
{
    if (_leftCircleView == nil) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        if (ISIPHON4) {
            _leftCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35+60)];
            
        }else{
            _leftCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35)];
        }
//        _leftCircleView.backgroundColor = [UIColor redColor];
        _leftCircleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
        _leftCircleView.trackWidth = 1;
        _leftCircleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _leftCircleView.gaugeTintColor = [UIColor blackColor];
        _leftCircleView.gaugeWidth = 15;
        _leftCircleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftCircleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftCircleView.responseColor = [UIColor greenColor];
        _leftCircleView.font = [UIFont systemFontOfSize:30];
        _leftCircleView.rotationValue = 100;
        _leftCircleView.value = 0.0;
    }
    return _leftCircleView;
}

- (CHCircleGaugeView *)rightCircleView
{
    if (_rightCircleView == nil) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        if (ISIPHON4) {
            _rightCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35+60)];
        }else{
            _rightCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35)];
        }
        _rightCircleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
        _rightCircleView.trackWidth = 1;
        _rightCircleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _rightCircleView.gaugeTintColor = [UIColor blackColor];
        _rightCircleView.gaugeWidth = 15;
        _rightCircleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _rightCircleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _rightCircleView.responseColor = [UIColor greenColor];
        _rightCircleView.font = [UIFont systemFontOfSize:30];
        _rightCircleView.rotationValue = 100;
        _rightCircleView.value = 0.0;
    }
    return _rightCircleView;
}



- (UILabel *)leftSleepTimeLabel
{
    if (_leftSleepTimeLabel == nil) {
        _leftSleepTimeLabel = [[UILabel alloc]init];
        _leftSleepTimeLabel.frame = CGRectMake(0,0, self.view.frame.size.width, 30);
        _leftSleepTimeLabel.textAlignment = NSTextAlignmentCenter;
        _leftSleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftSleepTimeLabel.backgroundColor = [UIColor clearColor];
        _leftSleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _leftSleepTimeLabel.text = @"睡眠时长:0小时0分";
    }
    return _leftSleepTimeLabel;
}

- (UILabel *)rightSleepTimeLabel
{
    if (_rightSleepTimeLabel == nil) {
        _rightSleepTimeLabel = [[UILabel alloc]init];
        _rightSleepTimeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        _rightSleepTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rightSleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _rightSleepTimeLabel.backgroundColor = [UIColor clearColor];
        _rightSleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _rightSleepTimeLabel.text = @"睡眠时长:0小时0分";
    }
    return _rightSleepTimeLabel;
}

- (UITableView *)leftTableView
{
    if (!_leftTableView) {
        CGRect rect = self.view.frame;
        _leftTableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
        _leftTableView.scrollEnabled = NO;
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.backgroundColor = [UIColor clearColor];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView
{
    if (!_rightTableView) {
        CGRect rect = self.view.frame;
        _rightTableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
        _rightTableView.scrollEnabled = NO;
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.backgroundColor = [UIColor clearColor];
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _rightTableView;
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<5) {
        
        if (indexPath.row==4) {
            return 40;
        }else{
            if (ISIPHON4) {
                return 34;
            }else
            {
                return 44;
            }
        }
    }else{
        if (indexPath.row==5) {
            int datePickerHeight = self.view.frame.size.height*0.202623;
            return self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35;
        }else{
            return 44;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.leftTableView]) {
        if (indexPath.row<5) {
            
            static NSString *cellIndetifier = @"leftCell";
            CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
            if (cell == nil) {
                cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
            }
            if (indexPath.row==4) {
                [cell addSubview:self.leftSleepTimeLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
                NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
                cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
                cell.cellData = [self.leftTableData objectAtIndex:indexPath.row];
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
            [cell layoutSubviews];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else{
            static NSString *cellIndentifier1 = @"leftCellLast";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier1];
            }
            cell.backgroundColor = [UIColor clearColor];
            if (indexPath.row==5) {
                [cell addSubview:self.leftCircleView];
            }else{
                [cell addSubview:self.leftIWantSleepLabel];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            [cell layoutSubviews];
            return cell;
            
        }
        
    }else{
        if (indexPath.row<5) {
            
            static NSString *cellIndetifier = @"rightCell";
            CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
            if (cell == nil) {
                cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
            }
            if (indexPath.row==4) {
                [cell addSubview:self.rightSleepTimeLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
                NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
                cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
                cell.cellData = [self.rightTableData objectAtIndex:indexPath.row];
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
            [cell layoutSubviews];
            return cell;
        }else{
            static NSString *cellIndentifier1 = @"rightCellLast";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier1];
            }
            if (indexPath.row==5) {
                [cell addSubview:self.rightCircleView];
            }else{
                [cell addSubview:self.rightIWantSleepLabel];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            [cell layoutSubviews];
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<4) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:[self.subPageViewArr objectAtIndex:indexPath.row] animated:YES];
    }
}

#pragma mark user action

#pragma mark 日历展示和代理
- (void)showCalender:(UIButton *)sender
{
    __block typeof(self) weakSelf = self;
    self.chvc.calendarblock = ^(CalendarDayModel *model){
        NSDate *selectedDate = [model date];
        [weakSelf.datePicker updateCalenderSelectedDate:selectedDate];
        
    };
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor= selectedThemeIndex==0?[UIColor colorWithRed:0.020f green:0.118f blue:0.247f alpha:1.00f]:[UIColor colorWithRed:0.408f green:0.643f blue:0.784f alpha:1.00f];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.navigationController pushViewController:self.chvc animated:YES];
    
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

#pragma mark 水平滚动日历

- (void)getScrollSelectedDate:(NSDate *)date
{
    NSString *dateString =[NSString stringWithFormat:@"%@",[[NSDate date] dateByAddingHours:8]];
    NSString *slectDateString = [NSString stringWithFormat:@"%@",date];
    if (![[dateString substringWithRange:NSMakeRange(5, 5)]isEqualToString:[slectDateString substringWithRange:NSMakeRange(5, 5)]]) {
        self.leftIWantSleepLabel.alpha = 0;
        self.rightIWantSleepLabel.alpha = 0;
//        [self.leftIWantSleepLabel removeFromSuperview];
    }else {
        self.leftIWantSleepLabel.alpha = 1;
        self.rightIWantSleepLabel.alpha = 1;
//        [self.view addSubview:self.iWantSleepLabel];
    }
    if ([[[NSDate date] dateByAddingHours:8]daysFrom:date]>7) {
        self.leftEndView.endImageString = @"";
        self.leftEndView.userInteractionEnabled = NO;
        self.rightEndView.endImageString = @"";
        self.rightEndView.userInteractionEnabled = NO;
    }else{
        self.leftEndView.endImageString = [NSString stringWithFormat: @"ic_compile_%d",selectedThemeIndex];
        self.leftEndView.userInteractionEnabled = YES;
        self.rightEndView.endImageString = [NSString stringWithFormat: @"ic_compile_%d",selectedThemeIndex];
        self.rightEndView.userInteractionEnabled = YES;
    }
    
    if (date) {
        if ([[[NSDate date] dateByAddingHours:8]isEarlierThan:date]) {
            [self.datePicker updateCalenderSelectedDate:[[NSDate date] dateByAddingHours:8]];
            [self.view makeToast:@"不要着急呦，明天睡后就会有数据啦！" duration:2.3 position:@"center"];
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
                                           self.leftEndView.endTime = titleString;
                                           [self sendSleepEndTime:titleString];
                                       }
                                   }];
    
}

#pragma mark showMoreInfo

- (void)showMoreInfo:(UIButton *)sender
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"我的设备"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"分享应用"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    CGRect popUpPos = sender.frame;
    popUpPos.origin.y -= 10;
    [KxMenu showMenuInView:self.view
                  fromRect:popUpPos
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    KxMenuItem *item = (KxMenuItem *)sender;
    if ([item.title isEqualToString:@"我的应用"]) {
        HaviLog(@"周报");
    }else if ([item.title isEqualToString:@"分享应用"]){
        HaviLog(@"月报");
        [self shareApp:nil];
    }
}

- (void)shareApp:(UIButton *)sender
{
    //    [self.shareMenuView show];
    [self.shareNewMenuView showInView:self.view];
    
}

#pragma mark 提交用户睡眠时间

- (void)sendSleepTime:(UIButton *)sender
{
    if (thirdHardDeviceUUID.length>0) {
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
                              @"UUID" : thirdHardDeviceUUID,
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
    if (thirdHardDeviceUUID.length>0) {
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
                              @"UUID" : thirdHardDeviceUUID,
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
