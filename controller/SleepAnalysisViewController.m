//
//  SleepAnalysisViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/7.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepAnalysisViewController.h"
#import "WeekCalenderView.h"
#import "SleepAnalisis.h"
#import "SleepTimeTagView.h"

@interface SleepAnalysisViewController ()
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,strong) UILabel *monthTitleLabel;
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *monthLabel;
@property (nonatomic,strong) NSCalendar *calender;
@property (nonatomic,strong) NSTimeZone *tmZone;
@property (nonatomic,strong) NSDateComponents *dateComponents;
@property (nonatomic,strong) SleepAnalisis *sleepAnalysisView;
@property (nonatomic,strong) NSMutableArray *mutableArr;
//
@property (nonatomic,strong) SleepTimeTagView *longSleepView;
@property (nonatomic,strong) SleepTimeTagView *shortSleepView;

@property (nonatomic,strong) UILabel *sleepLongTimeLabel;

@end

@implementation SleepAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createClearBgNavWithTitle:@"睡眠分析" createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            return self.menuButton;
        }
        return nil;
    }];
    [self createCalenderView];
    [self createChartView];
    [self creatSubView];
}

- (void)creatSubView
{
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor clearColor];
    backView.frame = CGRectMake(0,self.view.frame.size.height-254, self.view.frame.size.width, 254);
    [self.view addSubview:backView];
    UILabel *sleepTimeLabel = [[UILabel alloc]init];
    sleepTimeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    sleepTimeLabel.textAlignment = NSTextAlignmentCenter;
    sleepTimeLabel.text = @"周平均睡眠时长";
    [backView addSubview:sleepTimeLabel];
    [backView addSubview:self.sleepLongTimeLabel];
    
    self.longSleepView = [[SleepTimeTagView alloc]init ];
    self.longSleepView.frame = CGRectMake(0, 60, self.view.frame.size.width, 98);
    [backView addSubview:self.longSleepView];
    TagObject *tag1 = [[TagObject alloc]init];
    tag1.tagName = @"噩梦过多";
    tag1.isSelect = NO;
    
    TagObject *tag2 = [[TagObject alloc]init];
    tag2.tagName = @"离床过频";
    tag2.isSelect = NO;
    self.longSleepView.sleepTitleLabel.tags = [@[tag1]mutableCopy];
    [self.longSleepView.sleepTitleLabel reloadTagSubviews];
    self.longSleepView.sleepTagLabel.tags = [@[tag2]mutableCopy];
    [self.longSleepView.sleepTagLabel reloadTagSubviews];
    
    self.shortSleepView = [[SleepTimeTagView alloc]init ];
    //    self.longSleepView.backgroundColor = [UIColor redColor];
    self.shortSleepView.frame = CGRectMake(0, 158, self.view.frame.size.width, 98);
    [backView addSubview:self.shortSleepView];
    self.shortSleepView.sleepTitleLabel.tags = [@[tag1,tag2]mutableCopy];
    [self.shortSleepView.sleepTitleLabel reloadTagSubviews];
}

- (void)createCalenderView
{
    UIView *calenderBackView = [[UIView alloc]init];
    [self.view addSubview:calenderBackView];
    [calenderBackView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view.top).offset(64);
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

- (void)createChartView
{
    CGFloat height = self.view.frame.size.height- 69 - 210-64-44;
    self.sleepAnalysisView = [SleepAnalisis sleepAnalysisView];
    self.sleepAnalysisView.frame = CGRectMake(5, 69+64, self.view.frame.size.width-10, height);
    //设置警告值
    self.sleepAnalysisView.horizonLine = 15;
    //设置坐标轴
    self.sleepAnalysisView.xValues = @[@"0",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    self.sleepAnalysisView.yValues = @[@"2h", @"4h", @"6h", @"8h", @"10h",@"12h"];
    
    self.sleepAnalysisView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.view addSubview:self.sleepAnalysisView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(changeImage) userInfo:nil repeats:NO];
        
    });
}
#pragma mark 测试使用
- (void)changeImage
{
    if (self.mutableArr.count>0) {
        [self.mutableArr removeAllObjects];
    }
    for (int i=0; i<7; i++) {
        [self.mutableArr addObject:[NSString stringWithFormat:@"0"]];
    }
    
    for (int i=0; i<7; i++) {
        [self.mutableArr replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d",[self getRandomNumber:1 to:5]]];
        
    }
    self.sleepAnalysisView.yValues = @[@"2h", @"4h", @"6h", @"8h", @"10h",@"12h",@"14h"];
    self.sleepAnalysisView.dataValues = self.mutableArr;
    [self.sleepAnalysisView reloadChartView];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}
//end

#pragma mark setter

- (UILabel *)sleepLongTimeLabel
{
    if (_sleepLongTimeLabel == nil) {
        _sleepLongTimeLabel = [[UILabel alloc]init];
        _sleepLongTimeLabel.frame = CGRectMake(0, 30, self.view.frame.size.width, 30);
        _sleepLongTimeLabel.text = @"7时50分";
        _sleepLongTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sleepLongTimeLabel;
}

- (NSMutableArray *)mutableArr
{
    if (!_mutableArr) {
        _mutableArr = [[NSMutableArray alloc]init];
    }
    return _mutableArr;
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

- (NSCalendar *)calender
{
    if (!_calender) {
        _calender = [NSCalendar currentCalendar];
        _calender.timeZone = self.tmZone;
    }
    return _calender;
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

- (NSInteger)getCurrentWeekInOneYear:(NSDate *)nowDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //获取当前日期
    unsigned unitFlags = NSYearCalendarUnit | NSWeekOfYearCalendarUnit;
    NSDateComponents* comp = [gregorian components: unitFlags fromDate:nowDate];
    return comp.weekOfYear;
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
