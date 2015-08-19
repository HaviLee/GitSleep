//
//  NewTodayLeaveViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NewTodayLeaveViewController.h"
#import "HaviBarView.h"
#import "DataShowChartTableViewCell.h"
#import "CalenderCantainerViewController.h"
#import "GetLeaveBedSleepAPI.h"
#import "GetLeaveDataAPI.h"
#import "GetUserDefaultDataAPI.h"
#import "GetDefatultSleepAPI.h"

@interface NewTodayLeaveViewController ()<SetScrollDateDelegate,SelectCalenderDate,ToggleViewDelegate>
{
    BOOL isUp;//控制两个tableview切换
    //    ModalAnimation *_modalAnimationController;
}

@property (nonatomic,assign) CGFloat viewHeight;
@property (nonatomic,strong) DatePickerView *subDatePicker;
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
@property (nonatomic,strong) HaviBarView *leaveView;

//数据
@property (nonatomic,strong) NSDictionary *suggestDic;
@property (nonatomic,strong) NSArray *leaveDic;
//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;
@end

@implementation NewTodayLeaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCalenderView];
    [self createNavigationView];
    [self createSubView];
}

#pragma mark 创建view
- (void)createNavigationView
{
    isUp = YES;
    self.viewHeight = self.view.frame.size.height;
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        else if (nIndex == 0){
            self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
            [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
            return self.rightButton;
        }
        return nil;
    }];
}

- (void)createCalenderView
{
    self.datePicker.dateDelegate = self;
    CGRect rect = self.datePicker.frame;
    rect.origin.y = rect.origin.y;
    self.datePicker.frame = rect;
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",1]] forState:UIControlStateNormal];
    [self.datePicker.calenderButton addTarget:self action:@selector(showCalender:) forControlEvents:UIControlEventTouchUpInside];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?[UIColor whiteColor]:[UIColor whiteColor];
}

- (void)createSubView
{
    [self.view addSubview:self.upTableView];
    [self.view addSubview:self.downTableView];
    self.timeSwitchButton.toggleDelegate = self;
    //
    self.indicatorView = [[UIView alloc]init];
    self.indicatorView.frame = CGRectMake(0, self.view.frame.size.height-self.datePicker.frame.size.height-20, self.view.frame.size.width, 20);
    self.indicatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.indicatorView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTwoTableView:)];
    [self.indicatorView addGestureRecognizer:tapBack];
    [self.indicatorView addSubview:self.gifImageUp];
    [self.view addSubview:self.indicatorView];
}

#pragma mark setter meathod

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
        _upTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-height)];
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

- (HaviBarView *)leaveView
{
    if (!_leaveView) {
        _leaveView = [HaviBarView barView];
        _leaveView.frame = CGRectMake(5, 0, self.view.frame.size.width-15, self.upTableView.frame.size.height-140-60);
        //设置警告值
        _leaveView.horizonLine = 15;
        //设置坐标轴
        //设置坐标轴
        if (isUserDefaultTime) {
            NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
            NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
            int startInt = [[startTime substringToIndex:2]intValue];
            int endInt = [[endTime substringToIndex:2]intValue];
            if ((startInt<endInt)&&(endInt-startInt>1)&&((endInt - startInt)<12||(endInt - startInt)==12)) {
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = startInt; i<endInt +1; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d",i]];
                }
                _leaveView.xValues = arr;
            }else if ((startInt<endInt)&&(endInt - startInt)>12){
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = 0; i<(int)(endInt -startInt)/2+1; i++) {
                    [arr addObject:[NSString stringWithFormat:@"%d",startInt +2*i]];
                    
                }
                [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
                _leaveView.xValues = arr;
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
                _leaveView.xValues = arr;
            }else if ((endInt - startInt)==1){
                _leaveView.xValues = @[[NSString stringWithFormat:@"%d:00",startInt],[NSString stringWithFormat:@"%d:10",startInt], [NSString stringWithFormat:@"%d:20",startInt],[NSString stringWithFormat:@"%d:30",startInt],[NSString stringWithFormat:@"%d:40",startInt],[NSString stringWithFormat:@"%d:50",startInt],[NSString stringWithFormat:@"%d:00",endInt]];
            }else if ((endInt - startInt)==0){
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (int i = 0; i<12+1; i++) {
                    int date = startInt +2*i;
                    if (date>24) {
                        date = date - 24;
                    }
                    [arr addObject:[NSString stringWithFormat:@"%d",date]];
                    
                }
                _leaveView.xValues = arr;
            }
            
        }else{
            _leaveView.xValues = @[@"18",@"20", @"22", @"24", @"2", @"4", @"6", @"8", @"10", @"12",@"14",@"16",@"18"];
        }
        
        if (self.leaveDic.count>0) {
            self.leaveView.dataValues = self.leaveDic;
            [self.leaveView reloadChartView];
        }
        _leaveView.yValues = @[@"10", @"20", @"30", @"40",];
        _leaveView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    }
    return _leaveView;
}

#pragma mark 水平日历代理方法
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

#pragma mark 弹出日历代理
- (void)selectedCalenderDate:(NSDate *)date
{
    HaviLog(@"弹出日历是%@",date);
    [self.datePicker updateCalenderSelectedDate:date];
    if (selectedDateToUse) {
        selectedDateToUse = nil;
    }
    selectedDateToUse = date;
}


#pragma mark 弹出整屏日历

- (void)showCalender:(UIButton *)sender
{
    CalenderCantainerViewController *calender = [[CalenderCantainerViewController alloc]init];
    calender.calenderDelegate = self;
    [self presentViewController:calender animated:YES completion:nil];
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
            cell.iconTitleName = [NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex];
            cell.cellTitleName = @"离床";
            cell.cellData = [NSString stringWithFormat:@"%d次/天",[[self.currentSleepQulitity objectForKey:@"OutOfBedTimes"] intValue]];
            [cell addSubview:self.timeSwitchButton];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            //            [self.heartChartView removeFromSuperview];
            [cell addSubview:self.leaveView];
            
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
            [cell addSubview:self.diagnoseConclutionLabel];
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic_diagnostic_tint_%d",selectedThemeIndex]]];
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
        return 0.0;
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
            self.downTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.viewHeight-64-height-20);
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
            self.upTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.viewHeight-64-height);
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
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
                self.upTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.viewHeight-64-height);
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
            [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
                self.downTableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.viewHeight-64-height);
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

#pragma mark button 实现方法

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
}

#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        //        [MMProgressHUD showWithStatus:@"请求中..."];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        if (isTodayHourEqualSixteen<18) {
            self.dateComponentsBase.day = -1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=2&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
        }else{
            self.dateComponentsBase.day = 1;
            NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
            NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=2&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,fromDate,newNextDayString];
        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetLeaveDataAPI *client = [GetLeaveDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getLeaveData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            //            [MMProgressHUD dismiss];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"缓存的离床数据%@和%@",resposeDic,urlString);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                //                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                HaviLog(@"请求的离床数据%@和%@",resposeDic,urlString);
                [self reloadUserViewWithData:resposeDic];
                [self getUserSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [ShowAlertView showAlert:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]]];
                //                [MMProgressHUD dismiss];
                //                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                //
                //                }];
            }];
        }
    }
}

- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        if (isTodayHourEqualSixteen<18) {
            self.dateComponentsBase.day = -1;
            NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,fromDate];
        }else {
            self.dateComponentsBase.day = 1;
            NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
            NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
            urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,fromDate,newNextDayString];
            
        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetLeaveBedSleepAPI *client = [GetLeaveBedSleepAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getLeaveSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"心率是%@",resposeDic);
            //为了异常报告
            self.currentSleepQulitity = nil;
            self.currentSleepQulitity = resposeDic;
            [self reloadSleepView:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"心率是%@",resposeDic);
                //为了异常报告
                self.currentSleepQulitity = nil;
                self.currentSleepQulitity = resposeDic;
                [self reloadSleepView:resposeDic];
            } failure:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [ShowAlertView showAlert:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]]];
                //                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                //
                //                }];
            }];
        }
    }
}

- (void)reloadSleepView:(NSDictionary *)dic
{
    self.suggestDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[dic objectForKey:@"AssessmentCode"]]];
    [self.downTableView reloadData];
    if (self.upTableView.frame.size.height>0) {
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.leaveDic = nil;
    for (NSDictionary *dic in arr) {
        self.leaveDic = [dic objectForKey:@"Data"];
        
    }
    self.leaveView.dataValues = self.leaveDic;
    [self.leaveView reloadChartView];
}

#pragma mark 自定义和24进行切换
- (void)selectLeftButton
{
    HaviLog(@"左侧");
    isUserDefaultTime = NO;
    NSArray *arr = @[@"18",@"20", @"22", @"24", @"2", @"4", @"6", @"8", @"10", @"12",@"14",@"16",@"18"];
    [self.leaveView reloadGraphXValueArr:arr];
    [self getUserAllDaySensorData:self.currentDate toDate:self.currentDate];
    //    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
    //        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
    //        [self.timeSwitchButton changeLeftImageWithTime:0];
    //    }else{
    //        isUserDefaultTime = NO;
    //        [self getUserAllDaySensorData:self.currentDate toDate:self.currentDate];
    //    }
}

- (void)selectRightButton
{
    isUserDefaultTime = YES;
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    int startInt = [[startTime substringToIndex:2]intValue];
    int endInt = [[endTime substringToIndex:2]intValue];
    if ((startInt<endInt)&&(endInt-startInt>1)&&((endInt - startInt)<12||(endInt - startInt)==12)) {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i = startInt; i<endInt +1; i++) {
            [arr addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.leaveView reloadGraphXValueArr:arr];
    }else if ((startInt<endInt)&&(endInt - startInt)>12){
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i = 0; i<(int)(endInt -startInt)/2+1; i++) {
            [arr addObject:[NSString stringWithFormat:@"%d",startInt +2*i]];
            
        }
        [arr replaceObjectAtIndex:arr.count-1 withObject:[NSString stringWithFormat:@"%d",endInt]];
        [self.leaveView reloadGraphXValueArr:arr];
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
        [self.leaveView reloadGraphXValueArr:arr];
    }else if ((endInt - startInt)==1){
        [self.leaveView reloadGraphXValueArr:@[[NSString stringWithFormat:@"%d:00",startInt],[NSString stringWithFormat:@"%d:10",startInt], [NSString stringWithFormat:@"%d:20",startInt],[NSString stringWithFormat:@"%d:30",startInt],[NSString stringWithFormat:@"%d:40",startInt],[NSString stringWithFormat:@"%d:50",startInt],[NSString stringWithFormat:@"%d:00",endInt]]];
    }else if ((endInt - startInt)==0){
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        for (int i = 0; i<12+1; i++) {
            int date = startInt +2*i;
            if (date>24) {
                date = date - 24;
            }
            [arr addObject:[NSString stringWithFormat:@"%d",date]];
            
        }
        [self.leaveView reloadGraphXValueArr:arr];
    }
    [self getUserDefaultDaySensorData:self.currentDate toDate:self.currentDate];
    HaviLog(@"右侧");
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
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=2&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,toDate,startTime,endTime];
        }else if (startInt>endInt || startInt==endInt){
            NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
            self.dateComponentsBase.day = +1;
            NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
            NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
            NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
            //        NSString *newString = [NSString stringWithFormat:@"%@%d",[toDate substringToIndex:6],[[toDate substringFromIndex:6] intValue]+1];
            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=2&FromDate=%@&EndDate=%@&FromTime=%@&EndTime=%@",HardWareUUID,fromDate,newString,startTime,endTime];
            
        }
        
        
        //        [MMProgressHUD showWithStatus:@"请求中..."];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetUserDefaultDataAPI *client = [GetUserDefaultDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getUserDefaultData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            [MMProgressHUD dismiss];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"缓存的离床默认数据是%@",resposeDic);
            [self reloadUserViewWithDefaultData:resposeDic];
            [self getUserDefatultSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                //                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                HaviLog(@"请求的默认离床数据是%@",resposeDic);
                [self reloadUserViewWithDefaultData:resposeDic];
                [self getUserDefatultSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [ShowAlertView showAlert:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]]];
                //                [MMProgressHUD dismiss];
                //                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                //
                //                }];
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
        if ([client isExecuting]) {
            [client stop];
        }
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
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                [ShowAlertView showAlert:[NSString stringWithFormat:@"%@",[resposeDic objectForKey:@"ErrorMessage"]]];
                //                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                //
                //                }];
            }];
        }
    }
}

//pragma mark 获取完数据之后进行更新界面

- (void)reloadUserViewWithDefaultData:(NSDictionary *)dataDic
{
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    self.leaveDic = nil;
    for (NSDictionary *dic in arr) {
        self.leaveDic = [dic objectForKey:@"Data"];
        
    }
    self.leaveView.dataValues = self.leaveDic;
    [self.leaveView reloadChartView];
    
}

#pragma mark view will

- (void)viewWillAppear:(BOOL)animated
{
    if (animated) {
        if (isUserDefaultTime) {
            [self.timeSwitchButton changeRightImageWithTime:0];
            [self selectRightButton];
        }else{
            [self.timeSwitchButton changeLeftImageWithTime:0];
            [self selectLeftButton];
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