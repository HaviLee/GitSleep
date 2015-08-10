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

@interface SleepAnalysisViewController ()<SelectedWeek>
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,strong) UILabel *monthTitleLabel;
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *monthLabel;
@property (nonatomic,strong) NSCalendar *calender;
@property (nonatomic,strong) NSTimeZone *tmZone;
@property (nonatomic,strong) NSDateFormatter *dateFormmatter;
@property (nonatomic,strong) NSDateComponents *dateComponents;
@property (nonatomic,strong) SleepAnalisis *sleepAnalysisView;
@property (nonatomic,strong) NSMutableArray *mutableArr;
//
@property (nonatomic,strong) SleepTimeTagView *longSleepView;
@property (nonatomic,strong) SleepTimeTagView *shortSleepView;

@property (nonatomic,strong) UILabel *sleepLongTimeLabel;
@property (nonatomic,strong) UIView *backView;

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
    self.backView = [[UIView alloc]init];
    _backView.backgroundColor = [UIColor clearColor];
    _backView.frame = CGRectMake(0,self.view.frame.size.height-254, self.view.frame.size.width, 254);
    [self.view addSubview:_backView];
    UILabel *sleepTimeLabel = [[UILabel alloc]init];
    sleepTimeLabel.frame = CGRectMake(0, 5, self.view.frame.size.width, 20);
    sleepTimeLabel.textAlignment = NSTextAlignmentCenter;
    sleepTimeLabel.text = @"周平均睡眠时长";
    sleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    sleepTimeLabel.font = [UIFont systemFontOfSize:12];
    [_backView addSubview:sleepTimeLabel];
    [_backView addSubview:self.sleepLongTimeLabel];
    
    [_backView addSubview:self.longSleepView];
    [_backView addSubview:self.shortSleepView];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(5, 145, self.view.frame.size.width-10, 0.7)];
    lineView.backgroundColor = [UIColor colorWithRed:0.082f green:0.192f blue:0.310f alpha:1.00f];
    [_backView addSubview:lineView];
    _longSleepView.sleepNightCategoryString = @"最长的夜晚";
    _shortSleepView.sleepNightCategoryString = @"最短的夜晚";
    //
    
    //测试数据
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
    self.shortSleepView.sleepTitleLabel.tags = [@[tag1,tag2]mutableCopy];
    [self.shortSleepView.sleepTitleLabel reloadTagSubviews];
    
    self.longSleepView.grade = 0.75;
    self.shortSleepView.grade = 0.4;
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
    self.sleepAnalysisView.yValues = @[@"2h", @"6h", @"10h",@"14h"];
    self.sleepAnalysisView.dataValues = self.mutableArr;
    [self.sleepAnalysisView reloadChartView];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}
//end

#pragma mark setter

- (SleepTimeTagView *)shortSleepView
{
    if (_shortSleepView == nil) {
        _shortSleepView = [[SleepTimeTagView alloc]init ];
        self.shortSleepView.frame = CGRectMake(0, 158, self.view.frame.size.width, 98);
    }
    return _shortSleepView;
}

- (SleepTimeTagView *)longSleepView
{
    if (_longSleepView == nil) {
        _longSleepView = [[SleepTimeTagView alloc]init ];
        _longSleepView.frame = CGRectMake(0, 60, self.view.frame.size.width, 98);
    }
    return _longSleepView;
}

- (UILabel *)sleepLongTimeLabel
{
    if (_sleepLongTimeLabel == nil) {
        _sleepLongTimeLabel = [[UILabel alloc]init];
        _sleepLongTimeLabel.frame = CGRectMake(0, 25, self.view.frame.size.width, 30);
        _sleepLongTimeLabel.text = @"7时50分";
        _sleepLongTimeLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
        _sleepLongTimeLabel.font = [UIFont systemFontOfSize:20];
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

- (NSDateFormatter *)dateFormmatter
{
    if (!_dateFormmatter) {
        _dateFormmatter = [[NSDateFormatter alloc]init];
        [_dateFormmatter setDateFormat:@"yyyy年MM月dd日"];
    }
    return _dateFormmatter;
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

#pragma mark userAction

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
}

- (void)showMonthCalender:(UITapGestureRecognizer *)gesture
{
    NSString *dateString = self.monthTitleLabel.text;
    WeekCalenderView *monthView = [[WeekCalenderView alloc]init];
    CGRect rect = [UIScreen mainScreen].bounds;
    monthView.frame = rect;
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

#pragma mark 日历选中
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
