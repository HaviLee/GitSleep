//
//  HeartView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "HeartView.h"
#import "DataShowChartTableViewCell.h"
#import "HeartChartView.h"
@interface HeartView ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL isUp;
}
@property (nonatomic,strong) UITableView *subTableView;
@property (assign,nonatomic) int rowHeight;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) HeartChartView *heartChartView;

@property (nonatomic,strong) NSDictionary *dicToShow;
@property (nonatomic,strong) NSDictionary *suggestDic;

@property (nonatomic,strong) UILabel *diagnoseConclutionLabel;
@property (nonatomic,strong) UILabel *diagnoseDescriptionLabel;
@property (nonatomic,strong) UILabel *diagnoseSuggestionLabel;

@end

@implementation HeartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//
        self.rowHeight = frame.size.height;
        isUp = YES;
        [self addSubview:self.chartTableView];
//        self.chartTableView.backgroundColor = [UIColor redColor];
        self.chartTableView.delegate = self;
        self.chartTableView.dataSource = self;
        self.chartTableView.frame = CGRectMake(0, 0, self.frame.size.width, frame.size.height);
//
        self.subTableView = [[UITableView alloc]init];
        self.subTableView.delegate = self;
        self.subTableView.dataSource = self;
        self.subTableView.backgroundColor = [UIColor clearColor];
        self.subTableView.frame = CGRectMake(0, self.frame.size.height +10, self.frame.size.width, 0);
        [self addSubview:self.subTableView];
        
        //设置点击背景
        self.indicatorView = [[UIView alloc]init];
        self.indicatorView.frame = CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20);
        self.indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        self.indicatorView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeChartView:)];
        [self.indicatorView addGestureRecognizer:tapBack];
        [self.indicatorView addSubview:self.gifImageUp];
        [self addSubview:self.indicatorView];

        //
    }
    return self;
}

- (ToggleView *)timeSwitchButton
{
    if (!_timeSwitchButton) {
        _timeSwitchButton = [[ToggleView alloc]initWithFrame:CGRectMake(self.frame.size.width - 130, 15, 120, 25) toggleViewType:ToggleViewTypeNoLabel toggleBaseType:ToggleBaseTypeDefault toggleButtonType:ToggleButtonTypeChangeImage];
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
            [self.timeSwitchButton changeLeftImageWithTime:0.5];;
        }else{
            [self.timeSwitchButton changeRightImageWithTime:0.5];
        }
        
    }
    return _timeSwitchButton;
}

- (HeartChartView*)heartChartView
{
    if (!_heartChartView) {
        _heartChartView = [HeartChartView charView];
        _heartChartView.frame = CGRectMake(5, 0, self.frame.size.width-15, self.frame.size.height-140-60);
        //设置警告值
        _heartChartView.chartTitle = @"xinlv";
        _heartChartView.alarmMaxValue = @"80";
        _heartChartView.alarmMinValue = @"60";
        _heartChartView.horizonLine = 70;
        _heartChartView.backMinValue = 60;
        _heartChartView.backMaxValue = 80;
        //设置坐标轴
        if (isUserDefaultTime) {
            _heartChartView.xValues = @[@"18", @"20", @"22", @"24",@"2",@"4",@"6"];
        }else{
            _heartChartView.xValues = @[@"18",@"20", @"22", @"24", @"2", @"4", @"6", @"8", @"10", @"12",@"14",@"16",@"18"];
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
        _diagnoseConclutionLabel.frame = CGRectMake(10, 40, self.frame.size.width-20,60);
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
        _diagnoseDescriptionLabel.frame = CGRectMake(10, 40, self.frame.size.width-20,60);
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
        _diagnoseSuggestionLabel.frame = CGRectMake(10, 40, self.frame.size.width-20,60);
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
        _titleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        _titleLabel.text = @"诊断报告";
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.alpha = 1;
    }
    return _titleLabel;
}

- (void)setInfoDic:(NSDictionary *)infoDic
{
    self.dicToShow = infoDic;
    //刷新
    [self.chartTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.chartTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

    self.suggestDic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[infoDic objectForKey:@"AssessmentCode"]]];
    [self.subTableView reloadData];
}

- (void)changeChartView:(UITapGestureRecognizer *)tap
{
    if (isUp) {
        [UIView animateWithDuration:1 animations:^{
            
            self.chartTableView.frame = CGRectMake(0, 0, self.frame.size.width, 0);
            self.subTableView.frame = CGRectMake(0, -44, self.frame.size.width, self.frame.size.height-20);
            self.indicatorView.frame = CGRectMake(0, 0, self.frame.size.width, 20);
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
            self.chartTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-44);
            self.subTableView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
            self.indicatorView.frame = CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20);
            
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


- (void)setAff:(NSMutableArray *)aff
{
    self.dataArr = aff;

    self.heartChartView.dataValues = aff;
}
- (void)layoutOutSubViewWithNewData
{
    if (self.heartChartView) {
        [self.heartChartView removeFromSuperview];
        self.heartChartView = nil;
//        [self.dataArr removeAllObjects];
    }
    self.heartChartView.frame = CGRectMake(5, 0, self.frame.size.width-15, self.rowHeight-140-60);
    //设置警告值
    self.heartChartView.alarmMaxValue = @"80";
    self.heartChartView.alarmMinValue = @"50";
    self.heartChartView.horizonLine = 65;
    self.heartChartView.backMinValue = 50;
    self.heartChartView.backMaxValue = 80;
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
    self.heartChartView.yValues = @[@"20", @"40", @"60", @"80", @"100",@"120",@"140"];
    if (self.dataArr.count>0) {
        
        self.heartChartView.dataValues = self.dataArr;
    }
    self.heartChartView.chartColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
    [self.chartTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.chartTableView]) {
        
        return 3;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.chartTableView]) {
        
        if (indexPath.row == 0) {
            static NSString *cellIndentifier = @"cell0";
            DataShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
            if (!cell) {
                cell = [[DataShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            }
            //timeSwitchButton
            cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
            cell.cellTitleName = @"心率";
            
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",[[self.dicToShow objectForKey:@"AverageHeartRate"] intValue]];
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
//            if (self.dicToShow.count) {
//                <#statements#>
//            }
            NSDictionary *dic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:[ NSString stringWithFormat:@"%@",[self.dicToShow objectForKey:@"AssessmentCode"]]];
            if (dic.count==0) {
                self.diagnoseShow.text = [NSString stringWithFormat:@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseShow.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"Conclusion"]];
            }
            [cell addSubview:self.diagnoseShow];
            
            return cell;
        }else{//无用
            static NSString *indentifier = @"cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
            }
            [self.heartChartView removeFromSuperview];
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
            [cell addSubview:self.diagnoseConclutionLabel];
            if (self.suggestDic.count == 0) {
                self.diagnoseConclutionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseConclutionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Conclusion"]];
            }
        }else if(indexPath.row == 1){
            [cell addSubview:self.diagnoseExplain];
            [cell addSubview:self.diagnoseDescriptionLabel];
            if (self.suggestDic.count == 0) {
                self.diagnoseDescriptionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseDescriptionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Description"]];
            }
        }else if (indexPath.row == 2){
            [cell addSubview:self.diagnoseChoice];
            [cell addSubview:self.diagnoseSuggestionLabel];
            if (self.suggestDic.count == 0) {
                self.diagnoseSuggestionLabel.text = [NSString stringWithFormat:@"%@",@"还没有数据哦,快躺到床上试试吧！"];
            }else{
                self.diagnoseSuggestionLabel.text = [NSString stringWithFormat:@"%@",[self.suggestDic objectForKey:@"Suggestion"]];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.chartTableView]) {
        
        if (indexPath.row == 0) {
            return 60;
        }else if (indexPath.row == 2){
            return 140;
        }else if(indexPath.row == 1){
            return self.rowHeight-140-60;
        }
    }else{
        return 100;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.subTableView]) {
        return 64;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.subTableView]) {
        UIView *headerView = [[UIView alloc]init];
        headerView.backgroundColor = [UIColor clearColor];
        headerView.frame = CGRectMake(0, 0, self.frame.size.width, 64);
        [headerView addSubview:self.titleLabel];
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(headerView);
            make.height.equalTo(44);
            make.top.equalTo(headerView);
        }];
        return headerView;
    }
    return nil;
}

#pragma mark 滚动视图

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.subTableView]) {
        CGFloat offset = scrollView.contentOffset.y;
        if (offset<-30) {
            [UIView animateWithDuration:1.0 animations:^(void){
                self.chartTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                self.subTableView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
                self.indicatorView.frame = CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20);
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
                
                self.chartTableView.frame = CGRectMake(0, 0, self.frame.size.width, 0);
                self.subTableView.frame = CGRectMake(0, -44, self.frame.size.width, self.frame.size.height-20);
                self.indicatorView.frame = CGRectMake(0, 0, self.frame.size.width, 20);
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

//#pragma mark defualt meahtod
//- (void)show24Hour:(NSNotification *)noti
//{
//    [self.timeSwitchButton changeLeftImageWithTime:1.5];
//}
//
//- (void)showDefatultHour:(NSNotification*)noti
//{
//    [self.timeSwitchButton changeRightImageWithTime:1.5];
//}

- (void)dealloc
{
    self.gifImageUp = nil;
    self.gifImageDown = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:TwtityFourHourNoti object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UserDefaultHourNoti object:nil];
}

@end
