//
//  CalenderCantainerViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/5/1.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CalenderCantainerViewController.h"
#import "JTCalendar.h"

@interface CalenderCantainerViewController ()<JTCalendarDataSource,UIScrollViewDelegate>

@property (strong, nonatomic) JTCalendarMenuView *calendarMenuView;
@property (strong, nonatomic) JTCalendarContentView *calendarContentView;
@property (strong, nonatomic) JTCalendar *calendar;

@end

@implementation CalenderCantainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.calendarMenuView = [[JTCalendarMenuView alloc]initWithFrame:CGRectMake(0, 69, self.view.frame.size.width, 49)];
    [self.view addSubview:self.calendarMenuView];
    //
    UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLeft setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    buttonLeft.frame = CGRectMake(20, 59, 60, 69);
    [buttonLeft setTitleColor:[UIColor colorWithRed:0.024f green:0.133f blue:0.271f alpha:1.00f] forState:UIControlStateNormal];
    [buttonLeft addTarget:self action:@selector(showLastMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonLeft];
    //
    UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRight setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_right1_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    buttonRight.frame = CGRectMake(self.view.frame.size.width-20-60, 69, 60, 49);
    [buttonRight setTitleColor:[UIColor colorWithRed:0.024f green:0.133f blue:0.271f alpha:1.00f] forState:UIControlStateNormal];
    [buttonRight addTarget:self action:@selector(showNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRight];
    
    self.calendarContentView = [[JTCalendarContentView alloc]initWithFrame:CGRectMake(0, 113, self.view.frame.size.width, 230)];
    [self.view addSubview:self.calendarContentView];
    self.calendarContentView.delegate = self;
    self.calendar = [JTCalendar new];
    self.calendarContentView.backgroundColor = [UIColor whiteColor];
    self.calendarContentView.layer.cornerRadius = 5;
    self.calendarContentView.layer.masksToBounds = YES;
    self.calendarMenuView.backgroundColor= [UIColor whiteColor];
    self.calendarMenuView.layer.cornerRadius = 5;
    self.calendarMenuView.layer.masksToBounds = YES;
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 1; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 1.;
        self.calendar.calendarAppearance.menuMonthTextColor = [UIColor colorWithRed:0.059f green:0.733f blue:0.969f alpha:1.00f];//月份的颜色
        self.calendar.calendarAppearance.dayCircleColorSelected = [UIColor orangeColor];
        self.calendar.calendarAppearance.dayTextColorSelected = [UIColor whiteColor];//月份的
        self.calendar.calendarAppearance.dayTextColor = [UIColor colorWithRed:0.059f green:0.733f blue:0.969f alpha:1.00f];
        self.calendar.calendarAppearance.dayTextColorOtherMonth = [UIColor colorWithWhite:0.3 alpha:0.3];
        self.calendar.calendarAppearance.dayTextFont = [UIFont systemFontOfSize:18];
        self.calendar.calendarAppearance.weekDayFormat = JTCalendarWeekDayFormatSingle;
        self.calendar.calendarAppearance.weekDayTextFont = [UIFont systemFontOfSize:18];
        self.calendar.calendarAppearance.weekDayTextColor = [UIColor colorWithRed:0.059f green:0.733f blue:0.969f alpha:1.00f];
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
}

- (void)showLastMonth:(UIButton *)button
{
    [self.calendarMenuView loadPreviousMonth];
    [self.calendarContentView loadPreviousMonth];
}

- (void)showNextMonth:(UIButton *)button
{
    [self.calendarMenuView loadNextMonth];
    [self.calendarContentView loadNextMonth];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.calendar reloadData]; // Must be call in viewDidAppear

}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
//    return (rand() % 10) == 1;
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSLog(@"Date: %@", date);
    [self.calenderDelegate selectedCalenderDate:date];//先将时间更该了
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if (touchPoint.y>343 || touchPoint.y<64) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
