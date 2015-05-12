//
//  QuarterViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "QuarterReportViewController.h"
#import "QuaterCalenderView.h"
#import "JT3DScrollView.h"
#import "MonthReportTableViewCell.h"
#import "QuaterReportView.h"
#import "NSDate+NSDateLogic.h"
//api
#import "HaviGetNewClient.h"

@interface QuarterReportViewController ()<SelectedQuater,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
//切换月份
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,strong) UILabel *monthTitleLabel;
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *monthLabel;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter1;

//
@property (nonatomic,strong) JT3DScrollView *jScrollView;
@property (nonatomic,strong) NSArray *views;
//
@property (nonatomic,strong) UITableView *tableView1;
@property (nonatomic,strong) NSArray *arr1;
@property (nonatomic,strong) NSArray *arr2;

@property (nonatomic,strong) UITableView *tableView2;
@property (nonatomic,strong) NSCalendar *calender;
@property (nonatomic,strong) NSTimeZone *tmZone;
@property (nonatomic,strong) NSDateComponents *dateComponents;


@property (nonatomic,strong) QuaterReportView *quaterView;


@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *endTime;

//保存数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSDictionary *suggestDic;
@property (nonatomic,strong) NSMutableArray *mutableArr;

@property (nonatomic,strong) UIImageView *backImage;

@end

@implementation QuarterReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arr1 = @[@"本季度睡眠质量:",@"心率平均值:",@"心率异常次数:",@"呼吸平均值:",@"呼吸异常次数:"];
    self.arr2 = @[@"还没有数据哦",@"75次/分钟",@"3次",@"25次/分钟",@"0"];
    _views = @[self.tableView1,self.tableView2];

    [self createCalenderView];
    //创建表哥
    [self createChartView];
    //
    [self.view addSubview:self.jScrollView];
    //
    [self createSubButton];
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getUserData];
    });

    
}
#pragma mark 获取用户数据

- (void)getUserData
{
    NSString *year = [self.monthTitleLabel.text substringWithRange:NSMakeRange(0, 4)];
    NSString *fromMonth = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    NSString *fromDateString = [NSString stringWithFormat:@"%@%@%@",year,fromMonth,@"01"];
    NSString *toMonth = [self.monthLabel.text substringWithRange:NSMakeRange(4, 2)];
    NSString *toDateString = [NSString stringWithFormat:@"%@%@%ld",year,toMonth,(long)[self getCurrentMonthDayNum:year month:toMonth]];
    [self getTodayUserData:fromDateString endDate:toDateString withCompareDate:nil];
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
    [KVNProgress showWithStatus:@"加载中..."];
    HaviGetNewClient *client = [HaviGetNewClient shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client querySensorDataOld:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [KVNProgress dismissWithCompletion:^{
            [self reloadUserUI:(NSDictionary *)resposeDic];
        }];
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

#pragma mark 更新界面

- (void)reloadUserUI:(NSDictionary *)dic
{
    self.reportData = dic;
    int sleepLevel = [[dic objectForKey:@"SleepQuality"]intValue];
    int averageHeart = [[dic objectForKey:@"AverageHeartRate"]intValue];
    int heartBad = [[dic objectForKey:@"FastHeartRateTimes"]intValue] + [[dic objectForKey:@"SlowHeartRateTimes"]intValue];
    int averageBreath = [[dic objectForKey:@"AverageRespiratoryRate"]intValue];
    int breathBad = [[dic objectForKey:@"FastRespiratoryRateTimes"]intValue] + [[dic objectForKey:@"SlowRespiratoryRateTimes"]intValue];
    self.arr2 = @[[NSString stringWithFormat:@"%@",[self changeNumToWord:sleepLevel]],[NSString stringWithFormat:@"%d次/分钟",averageHeart],[NSString stringWithFormat:@"%d次",heartBad],[NSString stringWithFormat:@"%d次/分钟",averageBreath],[NSString stringWithFormat:@"%d次",breathBad]];
    //
    [self.tableView1 reloadData];
    //
    self.suggestDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[dic objectForKey:@"AssessmentCode"]]];
    [self.tableView2 reloadData];
    //
    [self reloadReportChart:[self.reportData objectForKey:@"Data"]];
    
}

- (void)reloadReportChart:(NSArray *)dataArr
{
    if (self.mutableArr.count>0) {
        [self.mutableArr removeAllObjects];
    }
    for (int i=0; i<3; i++) {
        [self.mutableArr addObject:[NSString stringWithFormat:@"0"]];
    }
    NSString *monthFrom = [self.monthLabel.text substringWithRange:NSMakeRange(0, 2)];
    
    for (int i=0; i<dataArr.count; i++) {
        NSDictionary *dic = [dataArr objectAtIndex:i];
        NSString *dateString = [dic objectForKey:@"Date"];
        NSString *month = [dateString substringWithRange:NSMakeRange(5, 2)];
        int path = [month intValue]-[monthFrom intValue];
        [self.mutableArr replaceObjectAtIndex:path withObject:[NSString stringWithFormat:@"%@",[dic objectForKey:@"SleepQuality"]]];
        
    }
    self.quaterView.dataValues = self.mutableArr;
    [self.quaterView reloadChartView];
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
        button.tag = 10000+i;
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
    self.quaterView = [QuaterReportView QuaterReportView];
    self.quaterView.frame = CGRectMake(5, 69, self.view.frame.size.width-10, height);
    //设置警告值
    self.quaterView.horizonLine = 15;
    //设置坐标轴
    self.quaterView.xValues = @[@"0",@"一",@"二",@"三"];
    self.quaterView.yValues = @[@"20", @"40", @"60", @"80", @"100",];
//    NSArray *arr = @[@"0",@"0",@"0"
//                     ];
//    self.quaterView.dataValues = arr;
    self.quaterView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.view addSubview:self.quaterView];
//
}

#pragma mark setter meathod

- (NSMutableArray *)mutableArr
{
    if (!_mutableArr) {
        _mutableArr = [[NSMutableArray alloc]init];
    }
    return _mutableArr;
}

- (JT3DScrollView *)jScrollView
{
    if (!_jScrollView) {
        CGRect frame =CGRectMake(0, self.view.frame.size.height -244-64, self.view.frame.size.width, 195);
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


- (UIImageView *)backImage
{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"txtbox_report_%d",selectedThemeIndex]]];
        _backImage.frame = CGRectMake(20, 0, self.view.frame.size.width-40, 200);
    }
    return _backImage;
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
        _tableView1 = [[UITableView alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 200) style:UITableViewStylePlain];
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
        _tableView2 = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) style:UITableViewStylePlain];
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

- (NSCalendar *)calender
{
    if (!_calender) {
        _calender = [NSCalendar currentCalendar];
        _calender.timeZone = self.tmZone;
    }
    return _calender;
}

- (NSTimeZone *)tmZone
{
    if (!_tmZone) {
        _tmZone = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:_tmZone];
    }
    return _tmZone;
}


- (UILabel *)monthLabel
{
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc]init];
        _monthLabel.font = [UIFont systemFontOfSize:16];
        _monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        NSString *currentDate = [[NSString stringWithFormat:@"%@",[NSDate date]]substringToIndex:7];
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        NSString *monthLength = [self changeQuaterToMonth:[quater intValue]];
        _monthLabel.text = monthLength;
    }
    return _monthLabel;
}

- (void)lastQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年第"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *quater = [self.monthTitleLabel.text substringWithRange:NSMakeRange(range.length +range.location, 1)];
    int nowQuater = [quater intValue] - 1;
    int nowYear = [year intValue];
    if (nowQuater==0) {
        nowQuater = 4;
        nowYear = nowYear - 1;
    }
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%d年第%d季度",nowYear,nowQuater];
    //改变小标题
    NSString *subMonth = [self changeQuaterToMonth:nowQuater];
    self.monthLabel.text = subMonth;
    //改变
    [self getUserData];

}

- (void)nextQuater:(UIButton *)sender
{
    NSRange range = [self.monthTitleLabel.text rangeOfString:@"年第"];
    NSString *year = [self.monthTitleLabel.text substringToIndex:range.location];
    NSString *quater = [self.monthTitleLabel.text substringWithRange:NSMakeRange(range.length +range.location, 1)];
    int nowQuater = [quater intValue] + 1;
    int nowYear = [year intValue];
    if (nowQuater==5) {
        nowQuater = 1;
        nowYear = nowYear + 1;
    }
    self.monthTitleLabel.text = [NSString stringWithFormat:@"%d年第%d季度",nowYear,nowQuater];
    //改变小标题
    NSString *subMonth = [self changeQuaterToMonth:nowQuater];
    self.monthLabel.text = subMonth;
    //
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
        [_dateFormmatter setDateFormat:@"yyyy年MM月"];
    }
    return _dateFormmatter;
}

- (NSDateFormatter *)dateFormmatter1
{
    if (!_dateFormmatter1) {
        _dateFormmatter1 = [[NSDateFormatter alloc]init];
        [_dateFormmatter1 setDateFormat:@"yyyy年MM月dd日"];
    }
    return _dateFormmatter1;
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
        NSString *month = [currentDate substringWithRange:NSMakeRange(5, 2)];
        NSString *quater = [self changeMonthToQuater:month];
        _monthTitleLabel.text = [NSString stringWithFormat:@"%@年第%@季度",year,quater];
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

#pragma mark user action

- (void)showMonthCalender:(UITapGestureRecognizer *)gesture
{
    HaviLog(@"展示日历");
    NSString *dateString = self.monthTitleLabel.text;
    QuaterCalenderView *monthView = [[QuaterCalenderView alloc]init];
    monthView.frame = [UIScreen mainScreen].bounds;
    NSRange range = [dateString rangeOfString:@"年第"];
    NSString *sub1 = [dateString substringToIndex:range.location];
    NSString *sub2 = [dateString substringWithRange:NSMakeRange(range.location +range.length, 1)];
    monthView.quaterTitle = sub1;
    monthView.currentQuaterNum = [sub2 intValue];
    monthView.delegate = self;
    [UIView animateWithDuration:1.5 animations:^{
        [[UIApplication sharedApplication].keyWindow addSubview:monthView];
    }];
}

- (NSString *)changeQuaterToMonth:(int)quater
{
    NSString *month ;
    switch (quater) {
        case 1:{
            month = @"01月到03月";
            return month;
            break;
        }
        case 2:{
            month = @"04月到06月";
            return month;
            break;
        }
        case 3:{
            month = @"07月到09月";
            return month;
            break;
        }
        case 4:{
            month = @"10月到12月";
            return month;
            break;
        }
            
        default:
            month = @"01月到03月";
            return month;
            break;
    }
}

- (NSString *)changeMonthToQuater:(NSString *)month
{
    int monthNum = [month intValue];
    if (monthNum>0 && monthNum<4) {
        return @"1";
    }else if (monthNum>3 && monthNum<7){
        return @"2";
    }else if (monthNum>6 && monthNum<10){
        return @"3";
    }else{
        return @"4";
    }
}

- (void)buttonTaped:(UIButton *)sender
{
    UIButton *button = (UIButton *)[self.view viewWithTag:10000];
    UIButton *button1 = (UIButton *)[self.view viewWithTag:10001];
    if (sender.tag == 10000) {
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [button1 setBackgroundImage:nil forState:UIControlStateNormal];
        [self.jScrollView loadPageIndex:0 animated:YES];
    }else{
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        [button1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_sleep_advice_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        [self.jScrollView loadPageIndex:1 animated:YES];
    }
}

#pragma mark 日历delegate

- (void)selectedQuater:(NSString *)monthString
{
    self.monthTitleLabel.text = monthString;
    NSRange range = [monthString rangeOfString:@"年第"];
    NSString *quater = [monthString substringWithRange:NSMakeRange(range.location + range.length, 1)];
    NSString *selectedMonth = [self changeQuaterToMonth:[quater intValue]];
    self.monthLabel.text = selectedMonth;
    //更新数据
    [self getUserData];
}

- (NSInteger)getCurrentMonthDayNum:(NSString *)year month:(NSString *)month
{
    NSString *dateString = [NSString stringWithFormat:@"%@年%@月01",year,month];
    NSDate *date = [self.dateFormmatter1 dateFromString:dateString];
    NSInteger dayNum = [date getdayNumsInOneMonth];
    return dayNum;
}

#pragma mark 滚动试图delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.jScrollView]) {
        UIButton *button = (UIButton *)[self.view viewWithTag:10000];
        UIButton *button1 = (UIButton *)[self.view viewWithTag:10001];
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
    if ([tableView isEqual:self.tableView1]) {
        
        return 5;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            
        }
        cell.textLabel.numberOfLines = 0;
        NSString *report = ([NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Suggestion"]].length) == 0 ? @"快躺到床上试试吧":[self.suggestDic objectForKey:@"Suggestion"];
        if (!report) {
            report = @"快躺到床上试试吧";
        }
        cell.textLabel.text = [NSString stringWithFormat:@"睡眠改进建议:\n%@",report];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView1]) {
        return 40;
    }else{
        return self.jScrollView.frame.size.height;
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
