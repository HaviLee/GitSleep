//
//  WeekReportViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "WeekReportViewController.h"
#import "JT3DScrollView.h"
#import "MonthReportTableViewCell.h"
#import "WeekCalenderView.h"
#import "WeekReportView.h"
#import "HaviGetNewClient.h"
#import "ReportTableViewCell.h"

@interface WeekReportViewController ()<SelectedWeek,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
//切换月份
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,strong) UILabel *monthTitleLabel;
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *monthLabel;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter;
//
@property (nonatomic,strong) JT3DScrollView *jScrollView;
@property (nonatomic,strong) UITableView *reportTableView;

@property (nonatomic,strong) NSArray *views;
//
@property (nonatomic,strong) UITableView *tableView1;
@property (nonatomic,strong) NSArray *arr1;
@property (nonatomic,strong) NSArray *arr2;

@property (nonatomic,strong) UITableView *tableView2;
//
@property (nonatomic,strong) NSCalendar *calender;
@property (nonatomic,strong) NSTimeZone *tmZone;
@property (nonatomic,strong) NSDateComponents *dateComponents;

@property (nonatomic,strong) WeekReportView *weekReport;
//保存数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSDictionary *suggestDic;
@property (nonatomic,strong) NSMutableArray *mutableArr;
//table背景
@property (nonatomic,strong) UIImageView *backImage;

@end

@implementation WeekReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arr1 = @[@"本周睡眠质量:",@"心率平均值:",@"心率异常次数:",@"呼吸平均值:",@"呼吸异常次数:"];
    self.arr2 = @[@"还没有数据哦",@"0次/分钟",@"0次",@"0次/分钟",@"0次"];
    _views = @[self.tableView1,self.tableView2];
    
    [self createCalenderView];
    //创建表哥
    [self createChartView];
    [self.view addSubview:self.reportTableView];
//    [self.view addSubview:self.jScrollView];
//    [self createSubButton];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getUserData];
    });
}

#pragma mark 获取用户数据

- (void)getUserData
{
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *fromMonth = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    NSString *fromDay = [self.monthLabel.text substringWithRange:NSMakeRange(3, 2)];
    NSString *toMonth = [self.monthLabel.text substringWithRange:NSMakeRange(7, 2)];
    NSString *toDay = [self.monthLabel.text substringWithRange:NSMakeRange(10, 2)];
    NSString *fromDate = [NSString stringWithFormat:@"%@%@%@",year,fromMonth,fromDay];
    NSString *toDate = [NSString stringWithFormat:@"%@%@%@",year,toMonth,toDay];
    [self getTodayUserData:fromDate endDate:toDate withCompareDate:nil];
}
- (void)getTodayUserData:(NSString *)fromDate endDate:(NSString *)endTime withCompareDate:(NSDate *)compDate
{
    
    if (!fromDate) {
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",HardWareUUID,fromDate,endTime];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"加载中..."];
    HaviGetNewClient *client = [HaviGetNewClient shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client querySensorDataOld:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self reloadUserUI:(NSDictionary *)resposeDic];
            }];
            [MMProgressHUD dismissAfterDelay:0.3];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:2];
    }];
}

#pragma mark 更新界面

- (void)reloadUserUI:(NSDictionary *)dic
{
    HaviLog(@"周报数据是%@",dic);
    self.reportData = dic;
//    int sleepLevel = [[dic objectForKey:@"SleepQuality"]intValue];
//    int averageHeart = [[dic objectForKey:@"AverageHeartRate"]intValue];
//    int heartBad = [[dic objectForKey:@"FastHeartRateTimes"]intValue] + [[dic objectForKey:@"SlowHeartRateTimes"]intValue];
//    int averageBreath = [[dic objectForKey:@"AverageRespiratoryRate"]intValue];
//    int breathBad = [[dic objectForKey:@"FastRespiratoryRateTimes"]intValue] + [[dic objectForKey:@"SlowRespiratoryRateTimes"]intValue];
//    self.arr2 = @[[NSString stringWithFormat:@"%@",[self changeNumToWord:sleepLevel]],[NSString stringWithFormat:@"%d次/分钟",averageHeart],[NSString stringWithFormat:@"%d次",heartBad],[NSString stringWithFormat:@"%d次/分钟",averageBreath],[NSString stringWithFormat:@"%d次",breathBad]];
//    //
//    [self.tableView1 reloadData];
//    //
//    self.suggestDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[dic objectForKey:@"AssessmentCode"]]];
//    [self.tableView2 reloadData];
    //
    [self.reportTableView reloadData];
    [self reloadReportChart:[self.reportData objectForKey:@"Data"]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

#pragma mark 更新表格

- (void)reloadReportChart:(NSArray *)dataArr
{
    if (self.mutableArr.count>0) {
        [self.mutableArr removeAllObjects];
    }
    for (int i=0; i<7; i++) {
        [self.mutableArr addObject:[NSString stringWithFormat:@"0"]];
    }
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [self.monthLabel.text substringWithRange:NSMakeRange(0, 5)];
    NSString *fromDateString = [NSString stringWithFormat:@"%@年%@",year,month];
    NSDate *fromDate = [self.dateFormmatter dateFromString:fromDateString];
    for (int i=0; i<dataArr.count; i++) {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *dateString = [dic objectForKey:@"Date"];
        NSString *toDateString = [NSString stringWithFormat:@"%@年%@月%@日",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
        NSDate *toDate = [self.dateFormmatter dateFromString:toDateString];
        NSDateComponents *dayComponents = [self.calender components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
        [self.mutableArr replaceObjectAtIndex:dayComponents.day withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepQuality"]]];
        
    }
    self.weekReport.dataValues = self.mutableArr;
    [self.weekReport reloadChartView];
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

- (void)createCalenderView
{
    UIView *calenderBackView = [[UIView alloc]init];
    [self.view addSubview:calenderBackView];
    [calenderBackView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.top).offset(0);
        make.height.equalTo(69);
    }];
    calenderBackView.backgroundColor = [UIColor clearColor];
    //
    [calenderBackView addSubview:self.monthTitleLabel];
    [self.monthTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(calenderBackView.centerX).offset(-10);
        make.height.equalTo(34.5);
        make.top.equalTo(calenderBackView.top);
        
    }];
    //
    [calenderBackView addSubview:self.calenderImage];
    [self.calenderImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthTitleLabel.right).offset(10);
        make.width.height.equalTo(15);
        make.centerY.equalTo(self.monthTitleLabel.centerY);
    }];
    //
    [calenderBackView addSubview:self.leftCalButton];
    [self.leftCalButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.monthTitleLabel.left).offset(-30);
        make.centerY.equalTo(self.monthTitleLabel.centerY);
        make.width.height.equalTo(15);
    }];
    //
    [calenderBackView addSubview:self.rightCalButton];
    [self.rightCalButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.calenderImage.right).offset(30);
        make.centerY.equalTo(self.monthTitleLabel.centerY);
        make.height.width.equalTo(15);
    }];
    //
    [calenderBackView addSubview:self.monthLabel];
    [self.monthLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(calenderBackView);
        make.top.equalTo(self.monthTitleLabel.bottom);
        make.height.equalTo(34.5);
    }];
    
    
}

- (UIImageView *)backImage
{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"txtbox_report_%d",selectedThemeIndex]]];
        _backImage.frame = CGRectMake(20, 0, self.view.frame.size.width-40, 200);
    }
    return _backImage;
}

- (void)createSubButton
{
    UIImageView *imageLine = [[UIImageView alloc]init];
    imageLine.frame = CGRectMake(0, self.view.frame.size.height-64.5-44, self.view.frame.size.width, 0.5);
    imageLine.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageLine];
    for (int i=0; i<2; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*self.view.frame.size.width/2, self.view.frame.size.height-44-64, self.view.frame.size.width/2, 44);
        [self.view addSubview:button];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(buttonTaped:) forControlEvents:UIControlEventTouchUpInside];
        if (i==0) {
            [button setTitle:@"报告分析" forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        }else{
            [button setTitle:@"睡眠改进建议" forState:UIControlStateNormal];
        }
        [button setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:20]];
        
    }
}

- (void)createChartView
{
    CGFloat height = self.view.frame.size.height- 69 - 210-64-44;
    self.weekReport = [WeekReportView weekReportView];
    self.weekReport.frame = CGRectMake(5, 69, self.view.frame.size.width-10, height);
    //设置警告值
    self.weekReport.horizonLine = 15;
    //设置坐标轴
    self.weekReport.xValues = @[@"0",@"一",@"二",@"三",@"四",@"五",@"六",@"七"];
    self.weekReport.yValues = @[@"20", @"40", @"60", @"80", @"100",];

    self.weekReport.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.view addSubview:self.weekReport];
}

#pragma mark user action
- (void)buttonTaped:(UIButton *)sender
{
    UIButton *button = (UIButton *)[self.view viewWithTag:1000];
    UIButton *button1 = (UIButton *)[self.view viewWithTag:1001];
    if (sender.tag == 1000) {
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [button1 setBackgroundImage:nil forState:UIControlStateNormal];
        [self.jScrollView loadPageIndex:0 animated:YES];
    }else{
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [self.jScrollView loadPageIndex:1 animated:YES];
    }
}

#pragma mark setter meathod

- (UITableView *)reportTableView
{
    if (_reportTableView == nil) {
        _reportTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height -224-64, self.view.frame.size.width-40, 194) style:UITableViewStylePlain];
        _reportTableView.backgroundColor = [UIColor clearColor];
        _reportTableView.delegate = self;
        _reportTableView.dataSource = self;
        [_reportTableView setBackgroundView:self.backImage];
        _reportTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _reportTableView.scrollEnabled = NO;
    }
    return _reportTableView;
}

- (NSMutableArray *)mutableArr
{
    if (!_mutableArr) {
        _mutableArr = [[NSMutableArray alloc]init];
    }
    return _mutableArr;
}

- (NSDateComponents*)dateComponents
{
    if (!_dateComponents) {
        _dateComponents = [[NSDateComponents alloc] init];
        _dateComponents.timeZone = self.tmZone;
    }
    return _dateComponents;
}

- (NSTimeZone *)tmZone
{
    if (!_tmZone) {
        _tmZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:_tmZone];
    }
    return _tmZone;
}

- (NSCalendar *)calender
{
    if (!_calender) {
        _calender = [NSCalendar currentCalendar];
        _calender.timeZone = self.tmZone;
    }
    return _calender;
}

- (JT3DScrollView *)jScrollView
{
    if (!_jScrollView) {
        CGRect frame =CGRectMake(0, self.view.frame.size.height -224-64, self.view.frame.size.width, 150);
        _jScrollView = [[JT3DScrollView alloc]initWithFrame:frame];
        self.jScrollView.effect = JT3DScrollViewEffectNone;
        self.jScrollView.backgroundColor = [UIColor clearColor];
        self.jScrollView.delegate = self;
        for (int i = 0; i<_views.count; i++) {
            [self createCardWithColorWithArr:[_views objectAtIndex:i]];
        }
    }
    return _jScrollView;
}

- (void)createCardWithColorWithArr:(UIView *)aView
{
    CGFloat width = CGRectGetWidth(self.jScrollView.bounds);
    CGFloat height = CGRectGetHeight(self.jScrollView.frame);
    
    CGFloat x = self.jScrollView.subviews.count * width;
    
    aView.frame = CGRectMake(x+20, 0, width-40, height);
    //    aView.backgroundColor = [UIColor clearColor];
    [self.jScrollView addSubview:aView];
    self.jScrollView.contentSize = CGSizeMake(x + width, height);
}

- (UITableView *)tableView1
{
    if (!_tableView1) {
        _tableView1 = [[UITableView alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 160) style:UITableViewStylePlain];
        _tableView1.backgroundColor = [UIColor clearColor];
        _tableView1.delegate = self;
        _tableView1.dataSource = self;
        [_tableView1 setBackgroundView:self.backImage];
        _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView1.scrollEnabled = NO;

    }
    return _tableView1;
}

- (UITableView *)tableView2
{
    if (!_tableView2) {
        _tableView2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160) style:UITableViewStylePlain];
        _tableView2.backgroundColor = [UIColor clearColor];
        _tableView2.delegate = self;
        _tableView2.dataSource = self;
        UIImageView * sub2backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"txtbox_report_%d",selectedThemeIndex]]];
        sub2backImage.frame = CGRectMake(20, 0, self.view.frame.size.width-40, 200);
        [_tableView2 setBackgroundView:sub2backImage];
        _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView2.scrollEnabled = NO;

    }
    return _tableView2;
}


- (UIButton *)leftCalButton
{
    if (!_leftCalButton) {
        _leftCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_leftCalButton addTarget:self action:@selector(lastQuater:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftCalButton;
}

- (UIButton *)rightCalButton
{
    if (!_rightCalButton) {
        _rightCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_right_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [_rightCalButton addTarget:self action:@selector(nextQuater:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightCalButton;
}

- (UILabel *)monthLabel
{
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc]init];
        _monthLabel.font = [UIFont systemFontOfSize:16];
        _monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        NSDate *dateOut = nil;
        NSTimeInterval count = 0;
        BOOL b = [self.calender rangeOfUnit:NSWeekCalendarUnit startDate:&dateOut interval:&count forDate:[NSDate date]];
        
        self.dateComponents.day = 6;
        NSDate *new = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:dateOut options:0];
        NSString *start = [[NSString stringWithFormat:@"%@",dateOut] substringWithRange:NSMakeRange(5, 5)];
        NSString *newStart = [NSString stringWithFormat:@"%@月%@日",[start substringWithRange:NSMakeRange(0, 2)],[start substringWithRange:NSMakeRange(3, 2)]];
        NSString *end = [[NSString stringWithFormat:@"%@",new] substringWithRange:NSMakeRange(5, 5)];
        NSString *newEnd = [NSString stringWithFormat:@"%@月%@日",[end substringWithRange:NSMakeRange(0, 2)],[end substringWithRange:NSMakeRange(3, 2)]];
        if (b) {
            _monthLabel.text = [NSString stringWithFormat:@"%@到%@",newStart,newEnd];
        }
        
        HaviLog(@"开始时间%@",dateOut);
    }
    return _monthLabel;
}

- (void)lastQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *subMonth = self.monthLabel.text;
    NSRange range1 = [subMonth rangeOfString:@"到"];
    NSString *now = [NSString stringWithFormat:@"%@年%@",year,[subMonth substringToIndex:range1.location]];
    NSDate *nowdate = [self.dateFormmatter dateFromString:now];
    self.dateComponents.day = -7;
    NSDate *nextWeekStart = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:nowdate options:0];//下周的日期
    NSInteger weekNum = [self getCurrentWeekInOneYear:nextWeekStart];//周
    //
    NSDate *dateOut = nil;
    NSTimeInterval count = 0;
    BOOL b = [self.calender rangeOfUnit:NSWeekCalendarUnit startDate:&dateOut interval:&count forDate:nextWeekStart];
    
    self.dateComponents.day = 6;
    NSDate *nextWeekEnd = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:dateOut options:0];
    NSString *start = [[NSString stringWithFormat:@"%@",dateOut] substringWithRange:NSMakeRange(5, 5)];
    NSString *newStart = [NSString stringWithFormat:@"%@月%@日",[start substringWithRange:NSMakeRange(0, 2)],[start substringWithRange:NSMakeRange(3, 2)]];
    NSString *end = [[NSString stringWithFormat:@"%@",nextWeekEnd] substringWithRange:NSMakeRange(5, 5)];
    NSString *newEnd = [NSString stringWithFormat:@"%@月%@日",[end substringWithRange:NSMakeRange(0, 2)],[end substringWithRange:NSMakeRange(3, 2)]];
    if (b) {
        _monthLabel.text = [NSString stringWithFormat:@"%@到%@",newStart,newEnd];
    }
    NSString *nextString = [NSString stringWithFormat:@"%@",nextWeekStart];
    
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%ld周",[nextString substringToIndex:4],(long)weekNum];
    //改变小标题
    //刷新数据
    [self getUserData];
//    [self reloadReportChart:nil];
}

- (void)nextQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *subMonth = self.monthLabel.text;
    NSRange range1 = [subMonth rangeOfString:@"到"];
    NSString *now = [NSString stringWithFormat:@"%@年%@",year,[subMonth substringToIndex:range1.location]];
    NSDate *nowdate = [self.dateFormmatter dateFromString:now];
    self.dateComponents.day = 7;
    NSDate *nextWeekStart = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:nowdate options:0];//下周的日期
    NSInteger weekNum = [self getCurrentWeekInOneYear:nextWeekStart];//周
    //
    NSDate *dateOut = nil;
    NSTimeInterval count = 0;
    BOOL b = [self.calender rangeOfUnit:NSWeekCalendarUnit startDate:&dateOut interval:&count forDate:nextWeekStart];
    
    self.dateComponents.day = 6;
    NSDate *nextWeekEnd = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:dateOut options:0];
    NSString *start = [[NSString stringWithFormat:@"%@",dateOut] substringWithRange:NSMakeRange(5, 5)];
    NSString *newStart = [NSString stringWithFormat:@"%@月%@日",[start substringWithRange:NSMakeRange(0, 2)],[start substringWithRange:NSMakeRange(3, 2)]];
    NSString *end = [[NSString stringWithFormat:@"%@",nextWeekEnd] substringWithRange:NSMakeRange(5, 5)];
    NSString *newEnd = [NSString stringWithFormat:@"%@月%@日",[end substringWithRange:NSMakeRange(0, 2)],[end substringWithRange:NSMakeRange(3, 2)]];
    if (b) {
        _monthLabel.text = [NSString stringWithFormat:@"%@到%@",newStart,newEnd];
    }
    NSString *nextString = [NSString stringWithFormat:@"%@",nextWeekStart];
    
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%ld周",[nextString substringToIndex:4],(long)weekNum];
    //改变小标题
    //刷新数据
    [self getUserData];
}

- (NSDate*)dayInTheLastMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    dateComponents.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}

- (NSDate *)dayInTheFollowingMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 1;
    dateComponents.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
}


- (NSDateFormatter *)dateFormmatter
{
    if (!_dateFormmatter) {
        _dateFormmatter = [[NSDateFormatter alloc]init];
        [_dateFormmatter setDateFormat:@"yyyy年MM月dd日"];
    }
    return _dateFormmatter;
}

- (UILabel *)monthTitleLabel
{
    if (!_monthTitleLabel) {
        _monthTitleLabel = [[UILabel alloc]init];
        _monthTitleLabel.font = [UIFont systemFontOfSize:18];
        _monthTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _monthTitleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *year = [currentDate substringToIndex:4];
        _monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%ld周",year,(long)[self getCurrentWeekInOneYear:[NSDate date]]];
    }
    return _monthTitleLabel;
}

- (UIImageView *)calenderImage
{
    if (!_calenderImage) {
        _calenderImage = [[UIImageView alloc]init];
        _calenderImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]];
        _calenderImage.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMonthCalender:)];
        [_calenderImage addGestureRecognizer:tapImage];
    }
    return _calenderImage;
}

#pragma mark user action

- (void)showMonthCalender:(UITapGestureRecognizer *)gesture
{
    NSString *dateString = self.monthTitleLabel.text;
    WeekCalenderView *monthView = [[WeekCalenderView alloc]init];
    monthView.frame = [UIScreen mainScreen].bounds;
    NSRange range = [dateString rangeOfString:@"年第"];
    NSString *sub1 = [dateString substringToIndex:range.location];
    NSString *sub2 = [dateString substringFromIndex:range.location + range.length];
    NSRange range1 = [sub2 rangeOfString:@"周"];
    NSString *sub3 = [sub2 substringToIndex:range1.location];
    monthView.weekTitle = sub1;
    monthView.currentWeekNum = [sub3 intValue];
    monthView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:monthView];
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    theAnimation.delegate = self;
    theAnimation.duration = 0.5;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:-[UIScreen mainScreen].bounds.size.height];
    theAnimation.toValue = [NSNumber numberWithFloat:0];
    [monthView.layer addAnimation:theAnimation forKey:@"animateLayer"];
}


- (NSInteger)getCurrentWeekInOneYear:(NSDate *)nowDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //获取当前日期
    unsigned unitFlags = NSYearCalendarUnit | NSWeekOfYearCalendarUnit;
    NSDateComponents* comp = [gregorian components: unitFlags fromDate:nowDate];
    return comp.weekOfYear;
}

#pragma mark 滚动试图delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.jScrollView]) {
        UIButton *button = (UIButton *)[self.view viewWithTag:1000];
        UIButton *button1 = (UIButton *)[self.view viewWithTag:1001];
        if (self.jScrollView.currentPage == 0) {
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [button1 setBackgroundImage:nil forState:UIControlStateNormal];
        }else{
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark tableview delegate

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.reportTableView]) {
        
        return 7;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView1]) {
        static NSString *cellIndentifier = @"cell1";
        MonthReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[MonthReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.titleString = [self.arr1 objectAtIndex:indexPath.row];
        cell.dataString = [self.arr2 objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        static NSString *cellIndentifier = @"cell2";
        ReportTableViewCell *cell = (ReportTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[ReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            
        }
        if (indexPath.row == 0) {
            cell.cellFont = [UIFont systemFontOfSize:18];
            cell.leftDataString = @"心率分析";
            cell.rightDataString = @"呼吸分析";
        }else if(indexPath.row == 1){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = @"心率平均值";
            cell.rightDataString = @"呼吸平均值";
        }else if (indexPath.row == 2){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageHeartRate"] intValue]];
            cell.rightDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"AverageRespiratoryRate"] intValue]];
        }else if (indexPath.row == 3){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = @"心率异常数";
            cell.rightDataString = @"呼吸异常数";
        }else if (indexPath.row == 4){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"FastHeartRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]];
            cell.rightDataString = [NSString stringWithFormat:@"%d次/分钟",[[self.reportData objectForKey:@"SlowRespiratoryRateTimes"] intValue]+[[self.reportData objectForKey:@"SlowHeartRateTimes"] intValue]];
        }else if (indexPath.row == 5){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = @"心率异常数高于";
            cell.rightDataString = @"呼吸异常数高于";
        }else if (indexPath.row == 6){
            cell.cellFont = [UIFont systemFontOfSize:13];
            cell.leftDataString = @"5%用户";
            cell.rightDataString = @"10%用户";
        }
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.reportTableView]) {
        if (indexPath.row == 0) {
            return 40;
        }else{
            return (self.reportTableView.frame.size.height-40)/6;
        }
    }else{
        return self.jScrollView.frame.size.height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
#pragma mark week选中

- (void)selectedWeek:(NSString *)monthString
{
    NSString *oldTitle = self.monthTitleLabel.text;
    NSInteger oldYear = [[oldTitle substringToIndex:4] intValue];
    NSInteger newYear = [[monthString substringToIndex:4]intValue];
    //
    NSRange range = [oldTitle rangeOfString:@"年第"];
    NSString *sub2 = [oldTitle substringFromIndex:range.location + range.length];
    NSRange range1 = [sub2 rangeOfString:@"周"];
    NSString *sub3 = [sub2 substringToIndex:range1.location];
    NSInteger oldWeek = [sub3 integerValue];
    //
    NSRange rangeM = [monthString rangeOfString:@"年第"];
    NSString *sub2M = [monthString substringFromIndex:rangeM.location + rangeM.length];
    NSRange range1M = [sub2M rangeOfString:@"周"];
    NSString *sub3M = [sub2M substringToIndex:range1M.location];
    NSInteger newWeek = [sub3M integerValue];
    //
    NSDate *selectedDate = [self.dateFormmatter dateFromString:monthString];
    NSInteger weekInNewYear = [selectedDate getWeekNumsInOneYear];
    //
    NSInteger totalWeek = (newYear - oldYear)*weekInNewYear + (newWeek - oldWeek);
    //计算新的日期
    NSRange rangeN = [self.monthTitleLabel.text rangeOfString:@"年"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:rangeN.location];
    NSString *subMonth = self.monthLabel.text;
    NSRange range1N = [subMonth rangeOfString:@"到"];
    NSString *now = [NSString stringWithFormat:@"%@年%@",year,[subMonth substringToIndex:range1N.location]];
    NSDate *nowdate = [self.dateFormmatter dateFromString:now];
    self.dateComponents.day = 7*totalWeek;
    NSDate *nextWeekStart = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:nowdate options:0];//下周的日期
    NSInteger weekNum = [self getCurrentWeekInOneYear:nextWeekStart];//周
    //
    NSDate *dateOut = nil;
    NSTimeInterval count = 0;
    BOOL b = [self.calender rangeOfUnit:NSWeekCalendarUnit startDate:&dateOut interval:&count forDate:nextWeekStart];
    
    self.dateComponents.day = 6;
    NSDate *nextWeekEnd = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:dateOut options:0];
    NSString *start = [[NSString stringWithFormat:@"%@",dateOut] substringWithRange:NSMakeRange(5, 5)];
    NSString *newStart = [NSString stringWithFormat:@"%@月%@日",[start substringWithRange:NSMakeRange(0, 2)],[start substringWithRange:NSMakeRange(3, 2)]];
    NSString *end = [[NSString stringWithFormat:@"%@",nextWeekEnd] substringWithRange:NSMakeRange(5, 5)];
    NSString *newEnd = [NSString stringWithFormat:@"%@月%@日",[end substringWithRange:NSMakeRange(0, 2)],[end substringWithRange:NSMakeRange(3, 2)]];
    if (b) {
        _monthLabel.text = [NSString stringWithFormat:@"%@到%@",newStart,newEnd];
    }
    NSString *nextString = [NSString stringWithFormat:@"%@",nextWeekStart];
    
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%ld周",[nextString substringToIndex:4],(long)weekNum];
    self.monthTitleLabel.text = monthString;
    //刷新数据
    [self getUserData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.jScrollView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.view addSubview:self.jScrollView];
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
