//
//  TodayHeartViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/5/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TodayHeartViewController.h"
#import "CalenderCantainerViewController.h"//弹出日历
#import "DataShowChartTableViewCell.h"//心率那个
#import "HeartChartView.h"
#import "GetHeartDataAPI.h"
#import "GetHeartSleepDataAPI.h"
#import "GetExceptionAPI.h"
#import "GetUserDefaultDataAPI.h"
#import "GetDefatultSleepAPI.h"
#import "DiagnoseReportViewController.h"
#import "ModalAnimation.h"
#import "YTKChainRequest.h"

@interface TodayHeartViewController ()<SetScrollDateDelegate,SelectCalenderDate,UITableViewDataSource,UITableViewDelegate,ToggleViewDelegate,UIViewControllerTransitioningDelegate,YTKChainRequestDelegate>
{
    BOOL isUp;//控制两个tableview切换
    ModalAnimation *_modalAnimationController;
}

@property (nonatomic,assign) CGFloat viewHeight;
@property (nonatomic,strong) UITableView *upTableView;
@property (nonatomic,strong) UITableView *downTableView;
//
@property (nonatomic, strong) UIView *indicatorView;
//诊断
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *diagnoseConclutionLabel;
@property (nonatomic,strong) UILabel *diagnoseDescriptionLabel;
@property (nonatomic,strong) UILabel *diagnoseSuggestionLabel;
//表哥
@property (nonatomic,strong) HeartChartView *heartChartView;

//数据
@property (nonatomic,strong) NSDictionary *suggestDic;
@property (nonatomic,strong) NSArray *heartDic;
//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;


@end

@implementation TodayHeartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加日历滚动日历
    isUp = YES;
    self.viewHeight = self.view.frame.size.height;
    //
    _modalAnimationController = [[ModalAnimation alloc] init];
    self.datePicker.dateDelegate = self;
    CGRect rect = self.datePicker.frame;
    rect.origin.y = rect.origin.y - 64;
    self.datePicker.frame = rect;
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    //
    [self createSubView];
    //
    //设置点击背景
    self.indicatorView = [[UIView alloc]init];
    self.indicatorView.frame = CGRectMake(0, self.view.frame.size.height-64-self.datePicker.frame.size.height-20, self.view.frame.size.width, 20);
    self.indicatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.indicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTwoTableView:)];
    [self.indicatorView addGestureRecognizer:tapBack];
    [self.indicatorView addSubview:self.gifImageUp];
    [self.view addSubview:self.indicatorView];
    //
}

- (void)createSubView
{
    [self.view addSubview:self.upTableView];
    [self.view addSubview:self.downTableView];
    self.timeSwitchButton.toggleDelegate = self;
}

#pragma mark setter meahtod

- (HeartChartView*)heartChartView
{
    if (!_heartChartView) {
        _heartChartView = [HeartChartView charView];
        _heartChartView.frame = CGRectMake(5, 0, self.view.frame.size.width-15, self.upTableView.frame.size.height-140-60);
        //设置警告值
        _heartChartView.chartTitle = @"xinlv";
        _heartChartView.alarmMaxValue = @"80";
        _heartChartView.alarmMinValue = @"60";
        _heartChartView.horizonLine = 70;
        _heartChartView.backMinValue = 60;
        _heartChartView.backMaxValue = 80;
        //设置坐标轴
        if (isUserDefaultTime) {
            NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
            NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
            int startInt = [[startTime substringToIndex:2]intValue];
            int endInt = [[endTime substringToIndex:2]intValue];
            if ((startInt<endInt)&&(endInt-startInt>1)&&(endInt - startInt)<12) {
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = startInt; i<endInt +1; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d",i]];
                }
                _heartChartView.xValues = arr;
            }else if ((startInt<endInt)&&(endInt - startInt)>12){
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = 0; i<(int)(endInt -startInt)/2+1; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d",startInt +2*i]];
                    
                }
                [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
                _heartChartView.xValues = arr;
            }else if (startInt>endInt){
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = 0; i<(int)(endInt+ 24-startInt)/2+1; i++) {
                    int date = startInt +2*i;
                    if (date>24) {
                        date = date - 24;
                    }
                    [arr addObject:[NSString stringWithFormat:@"%d",date]];
                    
                }
                [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
                _heartChartView.xValues = arr;
            }else if ((endInt - startInt)==1){
                _heartChartView.xValues = @[[NSString stringWithFormat:@"%d:00",startInt],[NSString stringWithFormat:@"%d:10",startInt], [NSString stringWithFormat:@"%d:20",startInt],[NSString stringWithFormat:@"%d:30",startInt],[NSString stringWithFormat:@"%d:40",startInt],[NSString stringWithFormat:@"%d:50",startInt],[NSString stringWithFormat:@"%d:00",endInt]];
            }else if ((endInt - startInt)==0){
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = 0; i<12+1; i++) {
                    int date = startInt +2*i;
                    if (date>24) {
                        date = date - 24;
                    }
                    [arr addObject:[NSString stringWithFormat:@"%d",date]];
                    
                }
                _heartChartView.xValues = arr;
            }
            
        }else{
            _heartChartView.xValues = @[@"18",@"20", @"22", @"24", @"2", @"4", @"6", @"8", @"10", @"12",@"14",@"16",@"18"];
        }
        
        if (self.heartDic.count>0) {
            self.heartChartView.dataValues = self.heartDic;
        }
        _heartChartView.yValues = @[@"20", @"40", @"60", @"80", @"100",@"120",@"140"];
        _heartChartView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _heartChartView;
}


- (UILabel *)diagnoseConclutionLabel
{
    if (!_diagnoseConclutionLabel) {
        _diagnoseConclutionLabel = [[UILabel alloc]init];
        _diagnoseConclutionLabel.frame = CGRectMake(10, 40, self.view.frame.size.width-20,60);
        _diagnoseConclutionLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _diagnoseConclutionLabel.numberOfLines = 0;
        _diagnoseConclutionLabel.font = [UIFont systemFontOfSize:15];
    }
    return _diagnoseConclutionLabel;
}

- (UILabel *)diagnoseDescriptionLabel
{
    if (!_diagnoseDescriptionLabel) {
        _diagnoseDescriptionLabel = [[UILabel alloc]init];
        _diagnoseDescriptionLabel.frame = CGRectMake(10, 40, self.view.frame.size.width-20,60);
        _diagnoseDescriptionLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _diagnoseDescriptionLabel.numberOfLines = 0;
        _diagnoseDescriptionLabel.font = [UIFont systemFontOfSize:15];
    }
    return _diagnoseDescriptionLabel;
}

- (UILabel *)diagnoseSuggestionLabel
{
    if (!_diagnoseSuggestionLabel) {
        _diagnoseSuggestionLabel = [[UILabel alloc]init];
        _diagnoseSuggestionLabel.frame = CGRectMake(10, 40, self.view.frame.size.width-20,60);
        _diagnoseSuggestionLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _diagnoseSuggestionLabel.numberOfLines = 0;
        _diagnoseSuggestionLabel.font = [UIFont systemFontOfSize:15];
    }
    return _diagnoseSuggestionLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _titleLabel.text = @"诊断报告";
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.alpha = 1;
    }
    return _titleLabel;
}

- (UITableView *)upTableView
{
    if (!_upTableView) {
        int height = self.datePicker.frame.size.height;
        _upTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-height)];
        _upTableView.backgroundColor = [UIColor clearColor];
        _upTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _upTableView.delegate = self;
        _upTableView.dataSource = self;
    }
    return _upTableView;
}

- (UITableView *)downTableView
{
    if (!_downTableView) {
        int height = self.datePicker.frame.size.height;
        _downTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-64-height, self.view.frame.size.width, 0)];
        _downTableView.backgroundColor = [UIColor clearColor];
        _downTableView.delegate = self;
        _downTableView.dataSource = self;
        _downTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _downTableView;
}

#pragma mark 滚动日历代理
- (void)getScrollSelectedDate:(NSDate *)date
{
    HaviLog(@"滚动日历是%@",date);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:date];
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    self.currentDate = queryDate;
    selectedDateToUse = date;//为另一个界面
    //请求数据
    if (isUserDefaultTime) {
        [self getUserDefaultDaySensorData:queryDate toDate:queryDate];
    }else{
        [self getUserAllDaySensorData:queryDate toDate:queryDate];
    }
}

#pragma mark 弹出日历

- (void)showCalender:(UIButton *)sender
{
    CalenderCantainerViewController *calender = [[CalenderCantainerViewController alloc]init];
    calender.calenderDelegate = self;
    [self presentViewController:calender animated:YES completion:nil];
}
#pragma mark 弹出日历代理
- (void)selectedCalenderDate:(NSDate *)date
{
    HaviLog(@"弹出日历是%@",date);
//    [self.datePicker updateCalenderSelectedDate:date];
    if (selectedDateToUse) {
        selectedDateToUse = nil;
    }
    selectedDateToUse = date;
}

#pragma mark tableview 代理函数

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.upTableView]) {
        return 3;
    }else{
        return 3;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.upTableView]) {
        
        if (indexPath.row == 0) {
            static NSString *cellIndentifier = @"cell0";
            DataShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[DataShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            //timeSwitchButton
            cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
            cell.cellTitleName = @"心率";
            
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",[[self.currentSleepQulitity objectForKey:@"AverageHeartRate"] intValue]];
//            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",50];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:self.timeSwitchButton];
            return cell;
            
        }else if(indexPath.row == 2){
            static NSString *indentifier = @"cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //
            [cell addSubview:self.diagnoseImage];
            [cell addSubview:self.diagonseTitle];
//            NSDictionary *dic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[self.dicToShow objectForKey:@"AssessmentCode"]]];
            if (self.suggestDic.count==0) {
                self.diagnoseShow.text = [NSString stringWithFormat:@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseShow.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Conclusion"]];
            }
            [cell addSubview:self.diagnoseShow];
            return cell;
        }else{//无用
            static NSString *indentifier = @"cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            }
            [cell addSubview:self.heartChartView];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }else{
        static NSString *subIndentifier = @"subIndentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subIndentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subIndentifier];
        }
        if (indexPath.row == 0) {
            [cell addSubview:self.diagnoseResult];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic_diagnostic_tint_%d",selectedThemeIndex]]];
            [cell addSubview:self.diagnoseConclutionLabel];
            if (self.suggestDic.count == 0) {
                self.diagnoseConclutionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseConclutionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Conclusion"]];
            }
        }else if(indexPath.row == 1){
            [cell addSubview:self.diagnoseExplain];
            [cell addSubview:self.diagnoseDescriptionLabel];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic_diagnostic_centre_%d",selectedThemeIndex]]];
            if (self.suggestDic.count == 0) {
                self.diagnoseDescriptionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseDescriptionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Description"]];
            }
        }else if (indexPath.row == 2){
            [cell addSubview:self.diagnoseChoice];
            [cell addSubview:self.diagnoseSuggestionLabel];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic_diagnostic_deep_%d",selectedThemeIndex]]];
            if (self.suggestDic.count == 0) {
                self.diagnoseSuggestionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseSuggestionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Suggestion"]];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.upTableView]) {
        
        if (indexPath.row == 0) {
            return 60;
        }else if (indexPath.row == 2){
            return 140;
        }else if(indexPath.row == 1){
            return self.upTableView.frame.size.height-140-60;
        }
    }else{
        return 100;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.downTableView]) {
        return 0;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.downTableView]) {
        UIView *headerView = [[UIView alloc]init];
        headerView.backgroundColor = [UIColor clearColor];
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
        [headerView addSubview:self.titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(headerView);
            make.height.equalTo(30);
            make.top.equalTo(headerView);
        }];
        [self.view bringSubviewToFront:_titleLabel];
        return headerView;
    }
    return nil;
}

#pragma mark 切换报表和总结

- (void)changeTwoTableView:(UITapGestureRecognizer *)gesture
{
    int height = self.datePicker.frame.size.height;
    if (isUp) {
        [UIView animateWithDuration:1 animations:^{
            self.upTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
            self.downTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight-64-height-20);
//            self.indicatorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
        } completion:^(BOOL finished) {
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.diagnoseImage.alpha = 0;
            self.diagonseTitle.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                self.titleLabel.alpha = 1;
            }];
        }];
        [self.gifImageUp removeFromSuperview];
        self.gifImageUp = nil;
        [self.indicatorView addSubview:self.gifImageDown];
        
        isUp = NO;
        
    }else{
        [UIView animateWithDuration:1.0 animations:^(void){
            self.upTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight-64-height);
            self.downTableView.frame = CGRectMake(0, self.viewHeight-64-height, self.view.frame.size.width, 0);
//            self.indicatorView.frame = CGRectMake(0, self.viewHeight-64-height-20, self.view.frame.size.width, 20);
            
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.diagnoseImage.alpha = 1;
            self.diagonseTitle.alpha = 1;
            [UIView animateWithDuration:0.5 animations:^{
                self.titleLabel.alpha = 0;
            }];
        }];
        [self.gifImageDown removeFromSuperview];
        self.gifImageDown = nil;
        [self.indicatorView addSubview:self.gifImageUp];
        isUp = YES;
    }
}

#pragma mark 滚动视图

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int height = self.datePicker.frame.size.height;
    if ([scrollView isEqual:self.downTableView]) {
        CGFloat offset = scrollView.contentOffset.y;
        if (offset<-30) {
            [UIView animateWithDuration:1.0 animations:^(void){
                self.upTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight-64-height);
                self.downTableView.frame = CGRectMake(0, self.viewHeight-64-height, self.view.frame.size.width, 0);
//                self.indicatorView.frame = CGRectMake(0, self.viewHeight-64-height-20, self.view.frame.size.width, 20);
            }];
            [UIView animateWithDuration:0.5 animations:^{
                self.diagnoseImage.alpha = 1;
                self.diagonseTitle.alpha = 1;
                [UIView animateWithDuration:0.5 animations:^{
                    self.titleLabel.alpha = 0;
                }];
            }];
            [self.gifImageDown removeFromSuperview];
            self.gifImageDown = nil;
            [self.indicatorView addSubview:self.gifImageUp];
            isUp = YES;
        }
    }else{
        CGFloat offset = scrollView.contentOffset.y;
        if (offset>30 && isUp) {
            [UIView animateWithDuration:1 animations:^{
                self.upTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
                self.downTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewHeight-64-height);
//                self.indicatorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
            } completion:^(BOOL finished) {
            }];
            [UIView animateWithDuration:0.5 animations:^{
                self.diagnoseImage.alpha = 0;
                self.diagonseTitle.alpha = 0;
                [UIView animateWithDuration:0.5 animations:^{
                    self.titleLabel.alpha = 1;
                }];
            }];
            [self.gifImageUp removeFromSuperview];
            self.gifImageUp = nil;
            [self.indicatorView addSubview:self.gifImageDown];
            
            isUp = NO;
            
        }
    }
}

#pragma mark 自定义和24进行切换
- (void)selectLeftButton
{
    HaviLog(@"左侧");
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [self.timeSwitchButton changeLeftImageWithTime:0];
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
    }else{
        isUserDefaultTime = NO;
        [self getUserAllDaySensorData:self.currentDate toDate:self.currentDate];
    }
}

- (void)selectRightButton
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [self.timeSwitchButton changeLeftImageWithTime:0];
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
    }else{
        isUserDefaultTime = YES;
        [self getUserDefaultDaySensorData:self.currentDate toDate:self.currentDate];
        HaviLog(@"右侧");
    }
}

#pragma mark 获取自定义数据
- (void)getUserDefaultDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        
        NSString *urlString = @"";
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
            
        }
        
        [KVNProgress showWithStatus:@"请求中..."];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetUserDefaultDataAPI *client = [GetUserDefaultDataAPI shareInstance];
        [client getUserDefaultData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            [KVNProgress dismiss];
            HaviLog(@"缓存的心率默认数据是%@",resposeDic);
            [self reloadUserViewWithDefaultData:resposeDic];
            [self getUserDefatultSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [KVNProgress dismiss];
                HaviLog(@"请求的默认心率数据是%@",resposeDic);
                [self reloadUserViewWithDefaultData:resposeDic];
                [self getUserDefatultSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [KVNProgress dismissWithCompletion:^{
                    [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
                }];
            }];
        }
    }
}

- (void)getUserDefatultSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        
        NSString *urlString = @"";
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
            
        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetDefatultSleepAPI *client = [GetDefatultSleepAPI shareInstance];
        [client queryDefaultSleep:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
            //为了异常报告
            self.currentSleepQulitity = nil;
            self.currentSleepQulitity = resposeDic;
            [self reloadSleepView:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"心率，呼吸，离床，体动界面的睡眠质量是%@",resposeDic);
                //为了异常报告
                self.currentSleepQulitity = nil;
                self.currentSleepQulitity = resposeDic;
                [self reloadSleepView:resposeDic];
            } failure:^(YTKBaseRequest *request) {
                [KVNProgress dismissWithCompletion:^{
                    [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
                }];
            }];
        }
    }
}

#pragma mark 获取完数据之后进行更新界面

- (void)reloadUserViewWithDefaultData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.heartDic = nil;
    for (NSDictionary *dic in arr) {
        self.heartDic = [self changeSeverDataToDefaultChartData:[dic objectForKey:@"Data"]];
        
    }
    if (self.heartChartView) {
        [self.heartChartView removeFromSuperview];
        self.heartChartView = nil;
    }
    [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark 转换数据

- (NSMutableArray *)changeSeverDataToDefaultChartData:(NSArray *)severDataArr
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    int num = 0;
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    int startInt = [[startTime substringToIndex:2]intValue];
    int endInt = [[endTime substringToIndex:2]intValue];
    if (startInt<endInt) {
        num = (endInt - startInt)*12;
    }else if (startInt>endInt ){
        num = (24-startInt +endInt)*12;
    }else if (startInt==endInt){
        num = 288;
    }
    for (int i=0; i<num; i++) {
        [arr addObject:[NSNumber numberWithFloat:0]];
    }
    for (int i = 0; i<severDataArr.count; i++) {
        NSDictionary *dic = [severDataArr objectAtIndex:i];
        NSString *date = [dic objectForKey:@"At"];
        NSString *hourDate1 = [date substringWithRange:NSMakeRange(11, 2)];
        NSString *minuteDate2 = [date substringWithRange:NSMakeRange(14, 2)];
        int indexIn = 0;
        if ([hourDate1 intValue]<startInt) {
            indexIn = (int)((24 -startInt)*60 + [hourDate1 intValue]*60 + [minuteDate2 intValue])/5;
        }else {
            indexIn = (int)(([hourDate1 intValue]-startInt)*60 + [minuteDate2 intValue])/5;
        }
        if (indexIn>arr.count-1) {
            indexIn = (int)arr.count-1;
        }
        [arr replaceObjectAtIndex:indexIn withObject:[NSNumber numberWithFloat:[[dic objectForKey:@"Value"] floatValue]]];
    }
    self.heartDic = arr;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.heartChartView) {
            [self.heartChartView removeFromSuperview];
            self.heartChartView = nil;
        }
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
    return arr;
}


#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    [KVNProgress showWithStatus:@"请求中..."];
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetHeartDataAPI *client = [GetHeartDataAPI shareInstance];
        [client getHeartData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            [KVNProgress dismiss];
            HaviLog(@"请求的心率数据%@",resposeDic);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [KVNProgress dismiss];
                HaviLog(@"请求的心率数据%@",resposeDic);
                [self reloadUserViewWithData:resposeDic];
                [self getUserSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [KVNProgress dismissWithCompletion:^{
                    [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
                }];
            }];
        }
    }
}

- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        NSString *urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetHeartSleepDataAPI *client = [GetHeartSleepDataAPI shareInstance];
        [client getHeartSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率是%@",resposeDic);
            //为了异常报告,和更新
            self.currentSleepQulitity = resposeDic;
            [self reloadSleepView:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"心率是%@",resposeDic);
                //为了异常报告,和更新
                self.currentSleepQulitity = resposeDic;
                [self reloadSleepView:resposeDic];
            } failure:^(YTKBaseRequest *request) {
                [KVNProgress dismissWithCompletion:^{
                    [KVNProgress showErrorWithStatus:@"请求失败,稍后重试"];
                }];
            }];
        }
    }
}

- (void)reloadSleepView:(NSDictionary *)dic
{
    
    self.suggestDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[dic objectForKey:@"AssessmentCode"]]];
    [self.downTableView reloadData];
    if (_upTableView.frame.size.height>0) {
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.heartDic = nil;
    for (NSDictionary *dic in arr) {
        self.heartDic = [self changeSeverDataToChartData:[dic objectForKey:@"Data"]];
        
    }
    if (!arr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.heartChartView) {
                [self.heartChartView removeFromSuperview];
                self.heartChartView = nil;
            }
            if (self.upTableView.frame.size.height>0) {
                [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
    /*
    if (self.heartChartView) {
        [self.heartChartView removeFromSuperview];
        self.heartChartView = nil;
    }
    [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
     */
    
}

// mark 转换数据

- (NSMutableArray *)changeSeverDataToChartData:(NSArray *)severDataArr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i=0; i<288; i++) {
            [arr addObject:[NSNumber numberWithFloat:0]];
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
            if (self.heartChartView) {
                [self.heartChartView removeFromSuperview];
                self.heartChartView = nil;
            }
            [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
    return nil;
//    return arr;
}


#pragma mark 数据请求

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showHeartEmercenyView:) name:PostHeartEmergencyNoti object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //保持统一的切换日期
        if (isUserDefaultTime) {
            [self.timeSwitchButton changeRightImageWithTime:0];
        }else{
            [self.timeSwitchButton changeLeftImageWithTime:0];
        }
        //和首页保持一致
        if (selectedDateToUse) {
            [self.datePicker updateCalenderSelectedDate:selectedDateToUse];
            NSString *selectDateString = [NSString stringWithFormat:@"%@",selectedDateToUse];
            NSString *useDate = [NSString stringWithFormat:@"%@%@%@",[selectDateString substringToIndex:4],[selectDateString substringWithRange:NSMakeRange(5, 2)],[selectDateString substringWithRange:NSMakeRange(8, 2)]];
            self.currentDate = useDate;
            //因为这个地方会调用到日历中的请求数据
        }else{
            //进行请求数据
            NSString *nowDate = [NSString stringWithFormat:@"%@",[NSDate date]];
            NSString *query = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
            //为了请求异常数据时间
            if (isUserDefaultTime) {
                self.currentDate = query;
                [self getUserDefaultDaySensorData:query toDate:query];
            }else{
                self.currentDate = query;//20150425
                [self getUserAllDaySensorData:query toDate:query];
            }
        }
        //写下文件
        [NSKeyedArchiver archiveRootObject:@{@"fileName":@"Heart"} toFile:[self cacheFilePathWithName:@"Heart"]];
    });
}


#pragma mark 异常报告

- (void)showHeartEmercenyView:(NSNotification *)noti
{
    [self showDiagnoseReportHeart];
}

- (void)showDiagnoseReportHeart
{
    NSString *urlString = @"";
    if (isUserDefaultTime) {
        NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
        NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
        int startInt = [[startTime substringToIndex:2]intValue];
        int endInt = [[endTime substringToIndex:2]intValue];
        if (startInt<endInt) {
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,self.currentDate,self.currentDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,self.currentDate,newString,startTime,endTime];
            
        }
    }else{
        NSDate *newDate = [self.dateFormmatterBase dateFromString:self.currentDate];
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataIrregular?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,self.currentDate];
    }
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [KVNProgress showWithStatus:@"异常数据请求中..."];
    GetExceptionAPI *client = [GetExceptionAPI shareInstance];
    [client getException:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [KVNProgress dismiss];
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [self showExceptionView:resposeDic withTitle:@"心率"];
        HaviLog(@"获取异常数据%@",resposeDic);
    } failure:^(YTKBaseRequest *request) {
        
    }];
    
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


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PostHeartEmergencyNoti object:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark 测试新的api

- (void)getUserAllDaySensorDataWithNewAPI:(NSString *)fromDate toDate:(NSString *)toDate
{
    [KVNProgress showWithStatus:@"请求中..."];
    NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
    self.dateComponentsBase.day = -1;
    NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
    NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
    NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=3&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
    NSString *urlString1 = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    GetHeartDataAPI *client = [GetHeartDataAPI shareInstance];
    [client getHeartData:header withDetailUrl:urlString];
    YTKChainRequest *chain = [[YTKChainRequest alloc]init];
    [chain addRequest:client callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        NSDictionary *resposeDic = (NSDictionary *)baseRequest.responseJSONObject;
        [KVNProgress dismiss];
        HaviLog(@"请求的心率数据%@",resposeDic);
        [self reloadUserViewWithData:resposeDic];
        GetHeartSleepDataAPI *client1 = [GetHeartSleepDataAPI shareInstance];
        [client1 getHeartSleepData:header withDetailUrl:urlString1];
        [chainRequest addRequest:client1 callback:nil];
    }];
    chain.delegate = self;
    [chain start];
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest
{
    if (chainRequest.requestArray.count>1) {
        GetHeartSleepDataAPI *API = (GetHeartSleepDataAPI *)[chainRequest.requestArray objectAtIndex:1];
        NSDictionary *resposeDic = (NSDictionary *)API.responseJSONObject;
        HaviLog(@"心率是%@",resposeDic);
        //为了异常报告,和更新
        self.currentSleepQulitity = resposeDic;
        [self reloadSleepView:resposeDic];
    }
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest *)request
{
    
}
#pragma mark 测试结束
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
