//
//  NewSecondBreathViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/18.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NewSecondBreathViewController.h"
#import "ReportTableViewCell.h"
#import "NewDataShowChartTableViewCell.h"
#import "SleepTimeTagView.h"
#import "GetBreathDataAPI.h"
#import "GetBreathSleepDataAPI.h"
#import "NewHeartGrapheView.h"
#import "FloatLayerView.h"
#import "GetExceptionAPI.h"
#import "DiagnoseReportViewController.h"
#import "ModalAnimation.h"

@interface NewSecondBreathViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate>
{
    ModalAnimation *_modalAnimationController;
    
}

@property (nonatomic,strong) UITableView *reportTableView;
@property (nonatomic,strong) SleepTimeTagView *longSleepView;
@property (nonatomic,strong) UIView *sleepNightBottomLine;
@property (nonatomic,strong) UIView *sleepNightBottomLine1;
@property (nonatomic,strong) NSArray *sleepQualityTitleArr;
@property (nonatomic,strong) NSArray *sleepQualityDataArr;
@property (nonatomic,strong) NSArray *breathDic;
@property (nonatomic,assign) CGFloat viewHeight;
//
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NewHeartGrapheView *breathGraphView;
@property (nonatomic,strong) UIScrollView *heartContainerView;
@property (nonatomic,strong) FloatLayerView *layerFloatView;
@property (nonatomic,strong) UIView *yCoorBackView;
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;

@end

@implementation NewSecondBreathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationView];
    [self.view addSubview:self.reportTableView];
    self.viewHeight = self.view.frame.size.width;
    self.sleepQualityTitleArr = @[@"呼吸平均值",@"呼吸异常数",@"呼吸异常数高于"];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showBreatheEmercenyView:) name:PostBreatheEmergencyNoti object:nil];
    [self getData];
}

- (void)getData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:selectedDateToUse];
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    self.currentDate = queryDate;
    //请求数据
    [self getUserAllDaySensorData:queryDate toDate:queryDate];
}

#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    //    [MMProgressHUD showWithStatus:@"请求中..."];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetBreathDataAPI *client = [GetBreathDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getBreathData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            //            [MMProgressHUD dismiss];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"缓存的呼吸数据%@和url:%@",resposeDic,urlString);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                //                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                HaviLog(@"请求的呼吸数据%@和url:%@",resposeDic,urlString);                [self reloadUserViewWithData:resposeDic];
                [self getUserSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
            }];
        }
    }
}

- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,thirdPartyLoginUserId,newString,fromDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetBreathSleepDataAPI *client = [GetBreathSleepDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getBreathSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率是%@",resposeDic);
            //为了异常报告
            self.reportData = resposeDic;
            self.currentSleepQulitity = resposeDic;
            NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
            NSString *subString = [selectString substringToIndex:10];
            NSDictionary *dataDic=nil;
            for (NSDictionary *dic in [resposeDic objectForKey:@"Data"]) {
                if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
                    dataDic = dic;
                }
            }
            self.longSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
            if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                self.longSleepView.sleepYearMonthDayString = @"";
            }else{
                self.longSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
            }
            float duration = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
            double second = 0.0;
            double subsecond = modf(duration, &second);
            self.longSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)ceilf(subsecond*60)];
            
            self.sleepQualityDataArr = @[[NSString stringWithFormat:@"%d次/分",[[resposeDic objectForKey:@"AverageHeartRate"]intValue]],[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastRespiratoryRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowRespiratoryRateTimes"] intValue]],[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalRespiratoryRatePercent"] intValue],@"%用户"]];
            [self.reportTableView reloadData];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"呼吸是%@",resposeDic);
                //为了异常报告
                self.reportData = resposeDic;
                self.currentSleepQulitity = resposeDic;
                NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
                NSString *subString = [selectString substringToIndex:10];
                NSDictionary *dataDic=nil;
                for (NSDictionary *dic in [resposeDic objectForKey:@"Data"]) {
                    if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
                        dataDic = dic;
                    }
                }
                self.longSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
                if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                    self.longSleepView.sleepYearMonthDayString = @"";
                }else{
                    self.longSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
                }
                float duration = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
                double second = 0.0;
                double subsecond = modf(duration, &second);
                self.longSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)ceilf(subsecond*60)];
                
                self.sleepQualityDataArr = @[[NSString stringWithFormat:@"%d次/分",[[resposeDic objectForKey:@"AverageHeartRate"]intValue]],[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]],[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"]];
                [self.reportTableView reloadData];
            } failure:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
            }];
        }
    }
}


- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.breathDic = nil;
    for (NSDictionary *dic in arr) {
        self.breathDic = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        
    }
    if (arr.count==0) {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr1 addObject:[NSNumber numberWithFloat:15]];
        }
        self.breathGraphView.heartView.values = arr1;
        [self.breathGraphView.heartView animate];
    }
}

//#pragma mark 转换数据

- (NSMutableArray *)changeSeverDataToChartData:(NSArray *)severDataArr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr addObject:[NSNumber numberWithFloat:15]];
        }
        for (int i = 0; i<severDataArr.count; i++) {
            NSDictionary *dic = [severDataArr objectAtIndex:i];
            NSString *date = [dic objectForKey:@"At"];
            NSString *hourDate1 = [date substringWithRange:NSMakeRange(11, 2)];
            NSString *minuteDate2 = [date substringWithRange:NSMakeRange(14, 2)];
            int indexIn = 0;
            if ([hourDate1 intValue]<18) {
                indexIn = (int)((24 -18)*60 + [hourDate1 intValue]*60 + [minuteDate2 intValue])/5;
            }else {
                indexIn = (int)(([hourDate1 intValue]-18)*60 + [minuteDate2 intValue])/5;
            }
            [arr replaceObjectAtIndex:indexIn withObject:[NSNumber numberWithFloat:[[dic objectForKey:@"Value"] floatValue]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.breathDic = arr;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.breathGraphView.heartView.values = self.breathDic;
                [self.breathGraphView.heartView animate];
                int xValue = [[self.breathDic objectAtIndex:0] intValue];
                if (xValue==15) {
                    xValue = xValue-15;
                }
                self.layerFloatView.dataString = [NSString stringWithFormat:@"%d",xValue];
            });
        });
    });
    return nil;
    //    return arr;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark setter

- (UIView*)yCoorBackView
{
    if (!_yCoorBackView) {
        _yCoorBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 160)];
        _yCoorBackView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
        UILabel *sixLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 20, 20)];
        sixLabel.text = @"15";
        sixLabel.textAlignment = NSTextAlignmentLeft;
        sixLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        sixLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:sixLabel];
        UIView *sixLine = [[UIView alloc]initWithFrame:CGRectMake(17, 79.5, self.view.frame.size.width-17, 1)];
        sixLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:sixLine];
        
        UILabel *fiveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 104, 20, 20)];
        fiveLabel.text = @"10";
        fiveLabel.textAlignment = NSTextAlignmentLeft;
        fiveLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor colorWithWhite:1 alpha:1];
        fiveLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:fiveLabel];
        UIView *fiveLine = [[UIView alloc]initWithFrame:CGRectMake(17, 114, self.view.frame.size.width-17, 1)];
        fiveLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:fiveLine];
        
        UILabel *sevenLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, 20, 20)];
        sevenLabel.text = @"20";
        sevenLabel.textAlignment = NSTextAlignmentLeft;
        sevenLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor colorWithWhite:1 alpha:1];
        sevenLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:sevenLabel];
        UIView *sevenLine = [[UIView alloc]initWithFrame:CGRectMake(17, 43, self.view.frame.size.width-17, 1)];
        sevenLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:sevenLine];
    }
    return _yCoorBackView;
}

- (FloatLayerView *)layerFloatView
{
    if (!_layerFloatView) {
        _layerFloatView = [[FloatLayerView alloc]initWithFrame:CGRectMake(0, 0, 20, 15)];
        CGFloat xCoor = self.view.frame.size.width*4/25/2;
        CGPoint xPoint = CGPointMake(xCoor, 180-20-7.5);
        self.layerFloatView.center = xPoint;
        
    }
    return _layerFloatView;
}

- (UIScrollView *)heartContainerView
{
    if (!_heartContainerView) {
        _heartContainerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
        [_heartContainerView addSubview:self.breathGraphView];
        _heartContainerView.contentSize = CGSizeMake(self.view.frame.size.width*4, 180);
        _heartContainerView.showsHorizontalScrollIndicator = NO;
        _heartContainerView.delegate = self;
        [_heartContainerView addSubview:self.yCoorBackView];
        //增加坐标
        
        //        [_heartContainerView addSubview:sixLabel];
    }
    return _heartContainerView;
}

- (NewHeartGrapheView *)breathGraphView
{
    if (!_breathGraphView) {
        _breathGraphView = [[NewHeartGrapheView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*4, 180)];
        _breathGraphView.xValues = @[@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00",@"24:00",@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00"];
        _breathGraphView.heartView.maxValue = 20;
        _breathGraphView.heartView.minValue = 10;
        _breathGraphView.heartView.horizonValue = 40;
        _breathGraphView.heartView.graphColor = selectedThemeIndex==0?[UIColor colorWithRed:0.008f green:0.839f blue:0.573f alpha:.70f]:[UIColor colorWithRed:0.008f green:0.839f blue:0.573f alpha:.70f];
        _breathGraphView.heartView.graphTitle = @"huxi";
        [_breathGraphView addSubview:self.layerFloatView];
        
    }
    return _breathGraphView;
}

- (SleepTimeTagView *)longSleepView
{
    if (_longSleepView == nil) {
        _longSleepView = [[SleepTimeTagView alloc]init ];
        _longSleepView.frame = CGRectMake(0, 1, self.view.frame.size.width, 58);
        _longSleepView.sleepNightCategoryColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _longSleepView.sleepNightCategoryString = @"睡眠时长";
    }
    return _longSleepView;
}


- (UITableView *)reportTableView
{
    if (_reportTableView == nil) {
        _reportTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _reportTableView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.012f green:0.082f blue:0.184f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        _reportTableView.delegate = self;
        _reportTableView.dataSource = self;
        _reportTableView.showsVerticalScrollIndicator = NO;
        _reportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _reportTableView;
}

- (UIView *)sleepNightBottomLine
{
    if (!_sleepNightBottomLine) {
        _sleepNightBottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 59, self.view.frame.size.width, 0.5)];
        _sleepNightBottomLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        
    }
    return _sleepNightBottomLine;
}
- (UIView *)sleepNightBottomLine1
{
    if (!_sleepNightBottomLine1) {
        _sleepNightBottomLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, 59, self.view.frame.size.width, 0.5)];
        _sleepNightBottomLine1.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    }
    return _sleepNightBottomLine1;
}

#pragma mark 创建view
- (void)createNavigationView
{
    _modalAnimationController = [[ModalAnimation alloc] init];
    [self createClearBgNavWithTitle:@"呼吸" andTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        else if (nIndex == 0){
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
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }else if (section==1) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            static NSString *cellIndentifier = @"cell0";
            NewDataShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[NewDataShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            //timeSwitchButton
            cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
            
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageRespiratoryRate"] intValue]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else if (indexPath.row==1) {
            static NSString *cellIndentifier = @"cell1";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            [self.heartContainerView removeFromSuperview];
            [cell addSubview:self.heartContainerView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }else if (indexPath.section==1) {
        if (indexPath.row == 0) {
            static NSString *cellIndentifier = @"cell2";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            cell.textLabel.text = @"呼吸分析";
            cell.textLabel.font = [UIFont systemFontOfSize:18];
            cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.sleepNightBottomLine1 removeFromSuperview];
            [cell addSubview:self.sleepNightBottomLine1];
            return cell;
        }else if (indexPath.row==1){
            static NSString *cellIndentifier = @"cell3";
            UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell addSubview:self.longSleepView];
            [self.sleepNightBottomLine removeFromSuperview];
            [cell addSubview:self.sleepNightBottomLine];
            return cell;
        }else{
            static NSString *cellIndentifier = @"cell4";
            ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
            cell.cellFont = [UIFont systemFontOfSize:16];
            cell.leftDataString = [self.sleepQualityTitleArr objectAtIndex:indexPath.row-2];
            cell.rightDataString = [self.sleepQualityDataArr objectAtIndex:indexPath.row-2];
            cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.855f blue:0.576f alpha:1.00f]:[UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellColor = selectedThemeIndex == 0? DefaultColor:[UIColor whiteColor];
            if (indexPath.row==4) {
                cell.bottomColor = [UIColor clearColor];
            }
            
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.reportTableView]) {
        if (indexPath.section == 0) {
            if (indexPath.row==0) {
                return 60;
            }else{
                return 180;
            }
        }else {
            return 60;
        }
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0.01;
    }else{
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==1) {
        return 0.00001;
    }
    return 0.00001;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.012f green:0.082f blue:0.184f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    return view;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.012f green:0.082f blue:0.184f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    return view;
}
//防止scrollview向下拉
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.reportTableView]) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
            return;
        }
        if (scrollView.contentSize.height>scrollView.frame.size.height&&scrollView.contentOffset.y>0) {
            if (scrollView.contentSize.height-scrollView.contentOffset.y < scrollView.frame.size.height) {
                scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height);
                return;
            }
        }
        if (scrollView.contentSize.height<scrollView.frame.size.height) {
            scrollView.contentOffset = CGPointMake(0, 0);
            return;
        }
        
    }else if ([scrollView isEqual:self.heartContainerView]){
        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
            return;
        }
        if (scrollView.contentSize.width>scrollView.frame.size.width&&scrollView.contentOffset.x>0) {
            if (scrollView.contentSize.width-scrollView.contentOffset.x < scrollView.frame.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.contentSize.width - scrollView.frame.size.width,0 );
                return;
            }
        }
        //纵坐标
        CGRect yRect = self.yCoorBackView.frame;
        yRect.origin.x = scrollView.contentOffset.x;
        self.yCoorBackView.frame = yRect;
        //浮标数据
        CGFloat xLeft = self.view.frame.size.width*4/25/2;
        CGFloat xWidth = ([[UIScreen mainScreen] applicationFrame].size.width*4-2*10)/288;
        
        //浮标的位置
        CGFloat xScaleValue = scrollView.contentOffset.x+(scrollView.contentOffset.x)*(self.view.frame.size.width-2*xLeft)/(self.view.frame.size.width*3)+xLeft;
        int xIndex = (int)(xScaleValue/xWidth)-5;
        if (xIndex<288) {
            int xValue = [[self.breathDic objectAtIndex:xIndex] intValue];
            if (xValue==15) {
                xValue = xValue-15;
            }
            HaviLog(@"index是%d值是%d",xIndex,xValue);
            self.layerFloatView.dataString = [NSString stringWithFormat:@"%d",xValue];
        }
        
        CGPoint point = CGPointMake(xScaleValue, 180-20-7.5);
        self.layerFloatView.center = point;
    }
}

#pragma mark 异常数据
- (void)showBreatheEmercenyView:(NSNotification*)noti
{
    [self showDiagnoseReportBreath];
}

- (void)showDiagnoseReportBreath
{
    NSString *urlString = @"";
        NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=4&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        [MMProgressHUD dismiss];
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self showExceptionView:resposeDic withTitle:@"呼吸"];
        }else{
            [self.view makeToast:[resposeDic objectForKey:@"ErrorMessage"] duration:2 position:@"center"];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismissWithError:@"网络出错啦" afterDelay:1];
    }];
    /*
    GetExceptionAPI *client = [GetExceptionAPI shareInstance];
    [client getException:header withDetailUrl:urlString];
    
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self showExceptionView:resposeDic withTitle:@"呼吸"];
        }else{
            [self.view makeToast:[resposeDic objectForKey:@"ErrorMessage"] duration:2 position:@"center"];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismissWithError:@"网络出错啦" afterDelay:1];
    }];
     */
    
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


#pragma mark - Transitioning Delegate (Modal)
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _modalAnimationController.type = AnimationTypePresent;
    return _modalAnimationController;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _modalAnimationController.type = AnimationTypeDismiss;
    return _modalAnimationController;
}


#pragma mark button 实现方法

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    //    [self.shareMenuView show];
    [self.shareNewMenuView showInView:self.view];
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
