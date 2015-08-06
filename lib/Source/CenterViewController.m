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

@interface CenterViewController ()<SetScrollDateDelegate,SelectCalenderDate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *cellTableView;
@property (nonatomic, strong) UILabel *sleepTimeLabel;
@property (nonatomic, strong) CHCircleGaugeView *circleView;

@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCalenderAndMenu];
    [self createTableView];
    [self createCircleView];
}

- (void)createTableView
{
    [self.view addSubview:self.cellTableView];
    
}

- (void)createCircleView
{
    [self.view addSubview:self.circleView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeValueAnimation:)];
    [self.circleView addGestureRecognizer:tap];
}
//setter meathod
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
        _circleView.trackTintColor = [UIColor blueColor];
        _circleView.trackWidth = 1;
        _circleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _circleView.gaugeTintColor = [UIColor blackColor];
        _circleView.gaugeWidth = 15;
        _circleView.textColor = [UIColor whiteColor];
        _circleView.responseColor = [UIColor greenColor];
        _circleView.font = [UIFont systemFontOfSize:38];
        _circleView.rotationValue = 100;
        _circleView.value = 0.0;
        _circleView.backgroundColor = [UIColor lightGrayColor];
    }
    return _circleView;
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

- (void)changeValueAnimation:(UITapGestureRecognizer *)gesture
{
    //在这里请求最新的当日数据或者仅仅是更新数据。
//    [self.cellTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
    [self.circleView changeValue:70];
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
        NSArray *dataArr = @[@"60次/分",@"15次/分",@"2次/天",@"4次/天"];
        NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
        cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
        cell.cellData = [dataArr objectAtIndex:indexPath.row];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cellTableView reloadDataAnimateWithWave:RightToLeftWaveAnimation];
    });
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
