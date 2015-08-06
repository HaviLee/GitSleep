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

@interface CenterViewController ()<SetScrollDateDelegate,SelectCalenderDate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *cellTableView;

@end

@implementation CenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCalenderAndMenu];
    [self createTableView];
    
}

- (void)createTableView
{
    [self.view addSubview:self.cellTableView];
}

- (UITableView *)cellTableView
{
    if (_cellTableView == nil) {
        _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44*4) style:UITableViewStylePlain];
        _cellTableView.backgroundColor = [UIColor clearColor];
        _cellTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _cellTableView.scrollEnabled = NO;
        _cellTableView.delegate = self;
        _cellTableView.dataSource = self;
        
    }
    return _cellTableView;
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifier = @"li";
    CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (cell == nil) {
        cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
    }
    NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
    NSArray *dataArr = @[@"60次/分",@"15次/分",@"2次/天",@"4次/天"];
    cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
    cell.cellData = [dataArr objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
