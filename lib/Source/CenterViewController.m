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
#import "UITableView+Wave.h"
#import "CHCircleGaugeView.h"
//
#import "GetDeviceStatusAPI.h"
#import "GetDefatultSleepAPI.h"

@interface CenterViewController ()<SetScrollDateDelegate,SelectCalenderDate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, assign) NSInteger todayHour;
@property (nonatomic, strong) UITableView *cellTableView;
@property (nonatomic, strong) UILabel *sleepTimeLabel;
@property (nonatomic, strong) CHCircleGaugeView *circleView;
@property (nonatomic, strong) NSArray *cellDataArr;

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
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",GloableUserId];
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
        HaviLog(@"用户%@下所有的设备%@",GloableUserId,resposeDic);
        [MMProgressHUD dismiss];
        NSArray *arr = [resposeDic objectForKey:@"DeviceList"];
        if (arr.count == 0) {
            HardWareUUID = NOBINDUUID;
        }else{
            HardWareUUID = NOUSEUUID;
            for (NSDictionary *dic in arr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    HardWareUUID = [dic objectForKey:@"UUID"];
                    HaviLog(@"用户%@关联默认的uuid是%@",GloableUserId,HardWareUUID);
                    break;
                }
            }
        }
        
        NSDate *nowDate = [self getNowDate];
        NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
        [self getTodaySleepQualityData:newString];
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)getActiveDeviceUUID
{
    
}

- (void)getTodaySleepQualityData:(NSString *)nowDateString
{
    //fromdate 是当天的日期
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!nowDateString) {
        
        return;
    }
    NSDate *newDate = [self.dateFormmatterBase dateFromString:nowDateString];
    NSString *urlString = @"";
    if (self.todayHour<18) {
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
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定默认设备，是否现在绑定默认设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 900;
            [alert show];
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
                         [NSString stringWithFormat:@"%@次/小时",[sleepDic objectForKey:@"AverageHeartRate"]],
                         [NSString stringWithFormat:@"%@次/小时",[sleepDic objectForKey:@"AverageRespiratoryRate"]],
                         [NSString stringWithFormat:@"%@次/天",[sleepDic objectForKey:@"OutOfBedTimes"]],
                         [NSString stringWithFormat:@"%@次/天",[sleepDic objectForKey:@"BodyMovementTimes"]]
                         ];
    [self.cellTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cellTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int sleepLevel = [[sleepDic objectForKey:@"SleepQuality"]intValue];
        [self.circleView changeSleepQualityValue:sleepLevel*20];
        [self.circleView changeSleepTimeValue:sleepLevel*20];
        [self.circleView changeSleepLevelValue:[self changeNumToWord:sleepLevel]];
        [self setClockRoationValue];
    });

}

#pragma mark 创建图表
- (void)createTableView
{
    [self.view addSubview:self.cellTableView];
    self.bgImageView.image = [UIImage imageNamed:@"pic_bg_night"];
}

- (void)createCircleView
{
    [self.view addSubview:self.circleView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeValueAnimation:)];
    [self.circleView addGestureRecognizer:tap];
}

- (void)setCalenderAndMenu
{
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
}

#pragma mark  setter meathod

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
        _sleepTimeLabel.textColor = [UIColor whiteColor];
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
        _circleView.trackTintColor = [UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f];
        _circleView.trackWidth = 1;
        _circleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _circleView.gaugeTintColor = [UIColor blackColor];
        _circleView.gaugeWidth = 15;
        _circleView.textColor = [UIColor whiteColor];
        _circleView.responseColor = [UIColor greenColor];
        _circleView.font = [UIFont systemFontOfSize:38];
        _circleView.rotationValue = 100;
        _circleView.value = 0.0;
//        _circleView.backgroundColor = [UIColor lightGrayColor];
    }
    return _circleView;
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
        NSDate *nowDate = [self getNowDate];
        NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]];
        [self getTodaySleepQualityData:newString];
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
    CalenderCantainerViewController *calender = [[CalenderCantainerViewController alloc]init];
    calender.calenderDelegate = self;
    [self presentViewController:calender animated:YES completion:nil];
}

- (void)selectedCalenderDate:(NSDate *)date
{
    [self.datePicker updateCalenderSelectedDate:date];
    //更新日历
}

#pragma mark 滚动日历

- (void)getScrollSelectedDate:(NSDate *)date
{
    if (date) {
        selectedDateToUse = date;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
        NSString *dateString = [formatter stringFromDate:date];
        HaviLog(@"当前选中的日期是%@",dateString);
        NSString *subString = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
//        [self getTodayUserData:subString endDate:subString withCompareDate:date];
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
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
        [cell addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.left).offset(5);
            make.right.equalTo(cell.right).offset(-5);
            make.bottom.equalTo(cell.bottom).offset(-1);
            make.height.equalTo(0.5);
        }];
    }
    cell.backgroundColor = [UIColor clearColor];
    
//    cell.textLabel.text = [NSString stringWithFormat:@"li%ld",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 3) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [tableView reloadDataAnimateWithWave:LeftToRightWaveAnimation];
//        });
//    }
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
            return @"还没有数据哦";
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //每次都判断一下当前的时间是不是18：00；
    NSDate *nowDate = [self getNowDate];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",nowDate];
    self.todayHour = [[nowDateString substringWithRange:NSMakeRange(11, 2)] intValue];
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
