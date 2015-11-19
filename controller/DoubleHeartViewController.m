//
//  DoubleHeartViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/17.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleHeartViewController.h"
#import "ReportTableViewCell.h"
#import "DoubleShowChartTableViewCell.h"
#import "SleepTimeTagView.h"
#import "GetHeartDataAPI.h"
#import "GetHeartSleepDataAPI.h"
#import "NewHeartGrapheView.h"
#import "DoubleFloatLayerView.h"
#import "GetExceptionAPI.h"
#import "DiagnoseReportViewController.h"
#import "ModalAnimation.h"
#import "DoubleReportTableViewCell.h"
#import "DoubleChartTableViewCell.h"

@interface DoubleHeartViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate>
{
    ModalAnimation *_modalAnimationController;
    
}

@property (nonatomic,strong) UITableView *reportTableView;
@property (nonatomic,strong) SleepTimeTagView *leftLongSleepView;
@property (nonatomic,strong) SleepTimeTagView *rightLongSleepView;
@property (nonatomic,strong) UIView *sleepNightBottomLine;
@property (nonatomic,strong) UIView *sleepNightBottomLine1;
@property (nonatomic,strong) NSArray *sleepQualityTitleArr;
@property (nonatomic,strong) NSArray *sleepQualityDataArr;
@property (nonatomic,strong) NSArray *heartDic;
@property (nonatomic,assign) CGFloat viewHeight;
//
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NewHeartGrapheView *heartGraphView;
@property (nonatomic,strong) UIScrollView *heartContainerView;
@property (nonatomic,strong) DoubleFloatLayerView *layerFloatView;
@property (nonatomic,strong) UIView *yCoorBackView;
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;
//
@property (nonatomic,strong) UILabel *cellDateTitleLabel;

@end

@implementation DoubleHeartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigationView];
    [self.view addSubview:self.reportTableView];
    self.viewHeight = self.view.frame.size.width;
    self.sleepQualityTitleArr = @[@"心率平均值",@"心率异常数",@"心率异常数高于"];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showHeartEmercenyView:) name:PostHeartEmergencyNoti object:nil];
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
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetHeartDataAPI *client = [GetHeartDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getHeartData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"缓存请求的心率数据%@和url%@",resposeDic,urlString);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                HaviLog(@"请求的心率数据%@和url%@",resposeDic,urlString);
                [self reloadUserViewWithData:resposeDic];
                [self getUserSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
            }];
        }
    }
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    //    NSArray *arr1 = @[[NSNumber numberWithInt:23],[NSNumber numberWithInt:33]];
    //    self.heartGraphView.heartView.values = arr1;
    //    [self.heartGraphView.heartView animate];
    self.heartDic = nil;
    for (NSDictionary *dic in arr) {
        self.heartDic = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        
    }
    if (arr.count==0) {
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr1 addObject:[NSNumber numberWithFloat:60]];
        }
        self.heartGraphView.heartViewLeft.values = arr1;
        [self.heartGraphView.heartViewLeft animate];
        //
        self.heartGraphView.heartViewRight.values = arr1;
        [self.heartGraphView.heartViewRight animate];
    }
}

- (NSMutableArray *)changeSeverDataToChartData:(NSArray *)severDataArr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr addObject:[NSNumber numberWithFloat:60]];
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
        self.heartDic = arr;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartGraphView.heartViewLeft.values = self.heartDic;
            [self.heartGraphView.heartViewLeft animate];
            //
            self.heartGraphView.heartViewRight.values = self.heartDic;
            [self.heartGraphView.heartViewRight animate];
            int xValue = [[self.heartDic objectAtIndex:0] intValue];
            if (xValue==60) {
                xValue = xValue-60;
            }
            self.layerFloatView.leftDataString = [NSString stringWithFormat:@"%d",xValue];
            self.layerFloatView.rightDataString = [NSString stringWithFormat:@"%d",xValue];
        });
    });
    return nil;
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
        GetHeartSleepDataAPI *client = [GetHeartSleepDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getHeartSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            [MMProgressHUD dismiss];
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"缓存心率是%@和url%@",resposeDic,urlString);
            //为了异常报告,和更新
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
            //
            self.leftLongSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
            if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                self.leftLongSleepView.sleepYearMonthDayString = @"";
            }else{
                self.leftLongSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
            }
            float duration = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
            double second = 0.0;
            double subsecond = modf(duration, &second);
            self.leftLongSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)ceilf(subsecond*60)];
            //
            self.rightLongSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
            if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                self.rightLongSleepView.sleepYearMonthDayString = @"";
            }else{
                self.rightLongSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
            }
            float duration1 = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
            double second1 = 0.0;
            double subsecond1 = modf(duration1, &second1);
            self.rightLongSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration1,(int)ceilf(subsecond1*60)];
            self.rightLongSleepView.grade = 0.5;
            //
            self.sleepQualityDataArr = @[[NSString stringWithFormat:@"%@次/分",[resposeDic objectForKey:@"AverageHeartRate"]],[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]],[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"]];
            [self.reportTableView reloadData];
            
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"心率是%@和url%@",resposeDic,urlString);
                //为了异常报告,和更新
                self.reportData = resposeDic;
                NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
                self.currentSleepQulitity = resposeDic;
                NSString *subString = [selectString substringToIndex:10];
                NSDictionary *dataDic=nil;
                for (NSDictionary *dic in [resposeDic objectForKey:@"Data"]) {
                    if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
                        dataDic = dic;
                    }
                }
                //
                self.leftLongSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
                if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                    self.leftLongSleepView.sleepYearMonthDayString = @"";
                }else{
                    self.leftLongSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
                }
                float duration = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
                double second = 0.0;
                double subsecond = modf(duration, &second);
                self.leftLongSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration,(int)ceilf(subsecond*60)];
                //
                self.rightLongSleepView.grade = [[dataDic objectForKey:@"SleepDuration"]floatValue]/24;
                if ([[NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]]isEqualToString:@"(null)"]) {
                    self.rightLongSleepView.sleepYearMonthDayString = @"";
                }else{
                    self.rightLongSleepView.sleepYearMonthDayString = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"Date"]];
                }
                float duration1 = [[dataDic objectForKey:@"SleepDuration"]floatValue]<0?-[[dataDic objectForKey:@"SleepDuration"]floatValue]:[[dataDic objectForKey:@"SleepDuration"]floatValue];
                double second1 = 0.0;
                double subsecond1 = modf(duration1, &second1);
                self.rightLongSleepView.sleepTimeLongString = [NSString stringWithFormat:@"%d小时%d分",(int)duration1,(int)ceilf(subsecond1*60)];

                self.rightLongSleepView.grade = 0.5;
                self.leftLongSleepView.grade = 0.5;
                //
                self.sleepQualityDataArr = @[[NSString stringWithFormat:@"%d次/分",[[resposeDic objectForKey:@"AverageHeartRate"]intValue]],[NSString stringWithFormat:@"%d次",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]],[NSString stringWithFormat:@"%d%@",[[self.reportData objectForKey:@"AbnormalHeartRatePercent"] intValue],@"%用户"]];
                [self.reportTableView reloadData];
                
            } failure:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [self.view makeToast:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]] duration:2 position:@"center"];
            }];
        }
    }
}


#pragma mark setter

- (UILabel *)cellDateTitleLabel
{
    if (_cellDateTitleLabel ==nil) {
        _cellDateTitleLabel = [[UILabel alloc]init];
        _cellDateTitleLabel.frame = CGRectMake(20, 5, 200, 20);
        NSString *dateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
        _cellDateTitleLabel.text = [NSString stringWithFormat:@"%@  %@",[dateString substringToIndex:10],@"睡眠时长"];
        _cellDateTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _cellDateTitleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cellDateTitleLabel;
}

- (UIView*)yCoorBackView
{
    if (!_yCoorBackView) {
        _yCoorBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 160)];
        _yCoorBackView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.075f green:0.149f blue:0.290f alpha:1.00f]:[UIColor colorWithRed:0.408f green:0.616f blue:0.757f alpha:1.00f];
        UILabel *sixLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 20, 20)];
        sixLabel.text = @"60";
        sixLabel.textAlignment = NSTextAlignmentLeft;
        sixLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        sixLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:sixLabel];
        UIView *sixLine = [[UIView alloc]initWithFrame:CGRectMake(17, 79.5, self.view.frame.size.width-17, 0.7)];
        sixLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:sixLine];
        
        UILabel *fiveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 104, 20, 20)];
        fiveLabel.text = @"50";
        fiveLabel.textAlignment = NSTextAlignmentLeft;
        fiveLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor colorWithWhite:1 alpha:1];
        fiveLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:fiveLabel];
        UIView *fiveLine = [[UIView alloc]initWithFrame:CGRectMake(17, 114, self.view.frame.size.width-17, 0.7)];
        fiveLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:fiveLine];
        
        UILabel *sevenLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, 20, 20)];
        sevenLabel.text = @"70";
        sevenLabel.textAlignment = NSTextAlignmentLeft;
        sevenLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor colorWithWhite:1 alpha:1];
        sevenLabel.font = [UIFont systemFontOfSize:14];
        [_yCoorBackView addSubview:sevenLabel];
        UIView *sevenLine = [[UIView alloc]initWithFrame:CGRectMake(17, 43, self.view.frame.size.width-17, 0.7)];
        sevenLine.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.133f green:0.698f blue:0.914f alpha:.30f]:[UIColor colorWithWhite:1 alpha:0.3];
        [_yCoorBackView addSubview:sevenLine];
    }
    return _yCoorBackView;
}

- (DoubleFloatLayerView *)layerFloatView
{
    if (!_layerFloatView) {
        _layerFloatView = [[DoubleFloatLayerView alloc]initWithFrame:CGRectMake(0, 0, 20, 25)];
        CGFloat xCoor = self.view.frame.size.width*4/25/2;
        CGPoint xPoint = CGPointMake(xCoor, 180-20-12.5);
        self.layerFloatView.center = xPoint;
        
    }
    return _layerFloatView;
}

- (UIScrollView *)heartContainerView
{
    if (!_heartContainerView) {
        _heartContainerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
        [_heartContainerView addSubview:self.heartGraphView];
        _heartContainerView.contentSize = CGSizeMake(self.view.frame.size.width*4, 180);
        _heartContainerView.showsHorizontalScrollIndicator = NO;
        _heartContainerView.delegate = self;
        
        [_heartContainerView addSubview:self.yCoorBackView];
        //增加坐标
        
        //        [_heartContainerView addSubview:sixLabel];
    }
    return _heartContainerView;
}

- (NewHeartGrapheView *)heartGraphView
{
    if (!_heartGraphView) {
        _heartGraphView = [[NewHeartGrapheView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*4, 180)];
        _heartGraphView.xValues = @[@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00",@"24:00",@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00"];
        _heartGraphView.heartViewLeft.maxValue = 100;
        _heartGraphView.heartViewLeft.minValue = 50;
        _heartGraphView.heartViewLeft.horizonValue = 140;
        _heartGraphView.heartViewLeft.graphColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f];
        _heartGraphView.heartViewLeft.graphTitle = @"xinlv";
        //
        _heartGraphView.heartViewRight.maxValue = 100;
        _heartGraphView.heartViewRight.minValue = 50;
        _heartGraphView.heartViewRight.horizonValue = 140;
        _heartGraphView.heartViewRight.graphColor = selectedThemeIndex==0?[UIColor colorWithRed:0.514f green:0.447f blue:0.820f alpha:1.00f]:[UIColor colorWithRed:0.514f green:0.447f blue:0.820f alpha:1.00f];
        _heartGraphView.heartViewRight.graphTitle = @"xinlv";
        [_heartGraphView addSubview:self.layerFloatView];
        
    }
    return _heartGraphView;
}

- (SleepTimeTagView *)leftLongSleepView
{
    if (_leftLongSleepView == nil) {
        _leftLongSleepView = [[SleepTimeTagView alloc]init ];
        _leftLongSleepView.frame = CGRectMake(0, 10, self.view.frame.size.width, 42);
//        _leftLongSleepView.backgroundColor = [UIColor redColor];
        _leftLongSleepView.sleepNightCategoryColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.867f blue:0.596f alpha:1.00f]:[UIColor whiteColor];
        _leftLongSleepView.sleepLongTimeColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.867f blue:0.596f alpha:1.00f]:[UIColor whiteColor];
        _leftLongSleepView.sleepNightCategoryString = @"左侧哈维";
        _leftLongSleepView.lineColorArr = @[(__bridge id)[UIColor colorWithRed:0.200f green:0.443f blue:0.545f alpha:1.00f].CGColor,(__bridge id)[UIColor colorWithRed:0.000f green:0.855f blue:0.573f alpha:1.00f].CGColor];
    }
    return _leftLongSleepView;
}

- (SleepTimeTagView *)rightLongSleepView
{
    if (_rightLongSleepView == nil) {
        _rightLongSleepView = [[SleepTimeTagView alloc]init ];
        _rightLongSleepView.frame = CGRectMake(0, 42, self.view.frame.size.width, 42);
        _rightLongSleepView.sleepNightCategoryColor = selectedThemeIndex==0?[UIColor colorWithRed:0.537f green:0.475f blue:0.827f alpha:1.00f]:[UIColor whiteColor];
        _rightLongSleepView.sleepNightCategoryString = @"右侧小白";
        _rightLongSleepView.sleepLongTimeColor = selectedThemeIndex==0?[UIColor colorWithRed:0.537f green:0.475f blue:0.827f alpha:1.00f]:[UIColor whiteColor];
        _rightLongSleepView.lineColorArr = @[(__bridge id)[UIColor colorWithRed:0.200f green:0.443f blue:0.545f alpha:1.00f].CGColor,(__bridge id)[UIColor colorWithRed:0.537f green:0.475f blue:0.827f alpha:1.00f].CGColor];
    }
    return _rightLongSleepView;
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

- (UIView *)sleepNightBottomLineWithBottomY:(NSInteger)y;
{
    UIView *_sleepNightBottomLiney = [[UIView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 0.5)];
    _sleepNightBottomLiney.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    return _sleepNightBottomLiney;
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
    [self createClearBgNavWithTitle:@"心率" andTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] createMenuItem:^UIView *(int nIndex) {
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
    return 3;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }else if (section==1) {
        return 4;
    }else if (section ==2){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            static NSString *cellIndentifier = @"cell0";
            DoubleShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[DoubleShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            //timeSwitchButton
            cell.leftCellName = @"左侧哈维之家";
            cell.rightCellName = @"右侧大笔";
            cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
            
            cell.leftCellData = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]];
            cell.rightCellData = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]];
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
            cell.textLabel.text = @"心率分析";
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
            [self.cellDateTitleLabel removeFromSuperview];
            [cell addSubview:self.cellDateTitleLabel];
            NSString *dateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
            _cellDateTitleLabel.text = [NSString stringWithFormat:@"%@  %@",[dateString substringToIndex:10],@"睡眠时长"];
            [self.leftLongSleepView removeFromSuperview];
            [self.rightLongSleepView removeFromSuperview];
            [cell addSubview:self.leftLongSleepView];
            [cell addSubview:self.rightLongSleepView];
            [self.sleepNightBottomLine removeFromSuperview];
            [cell addSubview:[self sleepNightBottomLineWithBottomY:99]];
            return cell;
        }else{
            static NSString *cellIndentifier = @"cell4";
            DoubleReportTableViewCell *cell = (DoubleReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[DoubleReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
                
            }
            cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
            cell.cellFont = [UIFont systemFontOfSize:16];
            cell.leftDataString = [self.sleepQualityDataArr objectAtIndex:indexPath.row-2];
            cell.rightDataString = [self.sleepQualityDataArr objectAtIndex:indexPath.row-2];
            cell.middleDataString = [self.sleepQualityTitleArr objectAtIndex:indexPath.row-2];
            cell.cellDataColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.537f green:0.475f blue:0.827f alpha:1.00f]:[UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellColor = selectedThemeIndex == 0? [UIColor colorWithRed:0.000f green:0.867f blue:0.596f alpha:1.00f]:[UIColor whiteColor];
            if (indexPath.row==4) {
                cell.bottomColor = [UIColor clearColor];
            }            
            return cell;
        }
    }else if (indexPath.section ==2){
        NSString *cellindentifer = @"cellChart";
        DoubleChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindentifer ];
        if (!cell) {
            cell = [[DoubleChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindentifer];
        }
        cell.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.middleDataString = @"心率异常数高于";
        cell.leftPieGrade = 40;
        return cell;
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
        }else if(indexPath.section==1){
            if (indexPath.row==1) {
                return 100;
            }else{
                return 60;
            }
        }else{
            return 100;
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
        CGFloat xLeft = self.view.frame.size.width*4/25/2;
        //浮标的位置
        CGFloat xScaleValue = scrollView.contentOffset.x+(scrollView.contentOffset.x)*(self.view.frame.size.width-2*xLeft)/(self.view.frame.size.width*3)+xLeft;
        CGPoint point = CGPointMake(xScaleValue, 180-20-12.5);
        self.layerFloatView.center = point;
        //浮标数据
        CGFloat xWidth = ([[UIScreen mainScreen] applicationFrame].size.width*4-2*20)/289;
        int xIndex = (int)(xScaleValue/xWidth)-5;
        if (xIndex<288) {
            int xValue = [[self.heartDic objectAtIndex:xIndex] intValue];
            if (xValue==60) {
                xValue = xValue-60;
            }
            self.layerFloatView.leftDataString = [NSString stringWithFormat:@"%d",xValue];
            self.layerFloatView.rightDataString = [NSString stringWithFormat:@"%d",xValue];
        }
        
        
    }
}

#pragma mark 异常报告

- (void)showHeartEmercenyView:(NSNotification *)noti
{
    [self showDiagnoseReportHeart];
}

- (void)showDiagnoseReportHeart
{
    NSString *urlString = @"";
    NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    /*
     [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
     [MMProgressHUD showWithStatus:@"异常数据请求中..."];
     */
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
            [self showExceptionView:resposeDic withTitle:@"心率"];
        }else{
            [self.view makeToast:[resposeDic objectForKey:@"ErrorMessage"] duration:2 position:@"center"];
        }    } failed:^(NSURLResponse *response, NSError *error) {
            [MMProgressHUD dismissWithError:@"网络出错啦" afterDelay:1];
        }];
    /*
     GetExceptionAPI *client = [GetExceptionAPI shareInstance];
     [client getException:header withDetailUrl:urlString];
     [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
     [MMProgressHUD dismiss];
     NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
     if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
     [self showExceptionView:resposeDic withTitle:@"心率"];
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
