//
//  DiagnoseReportViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DiagnoseReportViewController.h"
#import "DiagnoseReportTableViewCell.h"
@interface DiagnoseReportViewController ()
{
    UILabel *dateLabel;
    UILabel *reportLabel;
    //
    NSString *dateLabelString;
    NSString *titleString;//心率还是呼吸
    NSDictionary *sleepQualityDic;
    NSDictionary *exceptionDataDic;
    
}
@property (nonatomic,strong) UILabel *detailTitleLabel;
@property (nonatomic,strong) NSArray *dataArr;
@end

@implementation DiagnoseReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //对界面进行处理
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    self.view.layer.shadowOpacity = 0.3;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.cornerRadius = 4.0;
    self.view.layer.masksToBounds = YES;
    // Do any additional setup after loading the view.
    [self setSubView];
}

- (void)setSubView
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelButton];
    [cancelButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_x_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelView:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.width.height.equalTo(24);
    }];
    //title
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.text = @"异常明细";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor= selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton.centerY);
        make.height.equalTo(40);
        make.centerX.equalTo(self.view.centerX);
    }];
    //
    UIView *backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backView];
    [backView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(titleLabel.bottom);
        make.height.equalTo(200);
    }];
    dateLabel = [[UILabel alloc]init];
    dateLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    dateLabel.font = [UIFont systemFontOfSize:17];
    dateLabel.text = dateLabelString;
    [backView addSubview:dateLabel];
    [dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.centerX);
        make.height.equalTo(30);
        make.top.equalTo(backView.top);
    }];
    //
    UILabel *reportTitle = [[UILabel alloc]init];
    reportTitle.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    reportTitle.font = [UIFont systemFontOfSize:18];
    reportTitle.text = @"异常报告:";
    [backView addSubview:reportTitle];
    [reportTitle makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(10);
        make.top.equalTo(dateLabel.bottom);
        make.right.equalTo(backView);
        make.height.equalTo(30);
    }];
    //
    reportLabel = [[UILabel alloc]init];
    reportLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    reportLabel.font = [UIFont systemFontOfSize:15];
    reportLabel.numberOfLines = 0;
    NSString *timeNum = @"";
    if ([titleString isEqualToString:@"心率"]) {
        timeNum = @"50-100次/分钟";
    }else{
        timeNum = @"10-20次/分钟";
    }
    reportLabel.text = [NSString stringWithFormat:@"系统检测到您在此时间段内%@出现异常，超出%@正常范围:%@",titleString,titleString,timeNum];
    [backView addSubview:reportLabel];
    [reportLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.left).offset(10);
        make.right.equalTo(backView.right).offset(-10);
        make.top.equalTo(reportTitle.bottom);
        make.height.equalTo(60);
    }];
    //
    UILabel *badLabel = [[UILabel alloc]init];
    [backView addSubview:badLabel];
    badLabel.text = @"极差";
    badLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    badLabel.font = [UIFont systemFontOfSize:17];
    [badLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).offset(10);
        make.top.equalTo(reportLabel.bottom);
        make.height.equalTo(30);
    }];
    //
    UILabel *goodLabel = [[UILabel alloc]init];
    [backView addSubview:goodLabel];
    goodLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    goodLabel.text = @"极好";
    goodLabel.font = [UIFont systemFontOfSize:17];
    [goodLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backView.right).offset(-10);
        make.top.equalTo(reportLabel.bottom);
        make.height.equalTo(30);
    }];
    //
    UIImageView *statusImage = [[UIImageView alloc]init];
    [backView addSubview:statusImage];
    [statusImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.left).offset(10);
        make.top.equalTo(goodLabel.bottom).offset(-5);
        make.right.equalTo(backView.right).offset(-10);
        make.height.equalTo(statusImage.width).multipliedBy(0.2607);
    }];
    int index = [[sleepQualityDic objectForKey:@"SleepQuality"]intValue];
    switch (index) {
        case 1:{
            statusImage.image = [UIImage imageNamed:@"pic_bad_1"];
            break;
        }
        case 2:{
            statusImage.image = [UIImage imageNamed:@"pic_bad_2"];
            break;
        }
        case 3:{
            statusImage.image = [UIImage imageNamed:@"pic_bad_3"];
            break;
        }
        case 4:{
            statusImage.image = [UIImage imageNamed:@"pic_bad_4"];
            break;
        }
        case 5:{
            statusImage.image = [UIImage imageNamed:@"pic_bad_5"];
            break;
        }
            
        default:
            break;
    }
    
    

    //
    [self.view addSubview:self.sideTableView];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
//    self.sideTableView.backgroundColor = [UIColor colorWithPatternImage:self.bgImageView.image];
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sideTableView.frame = CGRectMake(0, 242, self.view.frame.size.width, self.view.frame.size.height-242);
//    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.bottom.equalTo(self.view);
//        make.top.equalTo(backView.bottom).offset(5);
//    }];
    self.dataArr = [[[exceptionDataDic objectForKey:@"SensorData"] objectAtIndex:0] objectForKey:@"Data"];
    
}

#pragma mark setter method

- (UILabel *)detailTitleLabel
{
    if (!_detailTitleLabel) {
        _detailTitleLabel = [[UILabel alloc]init];
        _detailTitleLabel.textColor = [UIColor clearColor];
        _detailTitleLabel.font = [UIFont systemFontOfSize:18];
        _detailTitleLabel.text = [NSString stringWithFormat:@"%@异常详细数据",titleString];
    }
    return _detailTitleLabel;
}

- (void)setDateTime:(NSString *)dateTime
{
    
    NSString *timeString = [NSString stringWithFormat:@"%@年%@月%@日",[dateTime substringWithRange:NSMakeRange(0, 4)],[dateTime substringWithRange:NSMakeRange(4, 2)],[dateTime substringWithRange:NSMakeRange(6, 2)]];
    dateLabelString = timeString;
}

- (void)setReportTitleString:(NSString *)reportTitleString
{
    titleString = reportTitleString;
}

- (void)setSleepDic:(NSDictionary *)sleepDic
{
    sleepQualityDic = sleepDic;
}

- (void)setExceptionDic:(NSDictionary *)exceptionDic{
    exceptionDataDic = exceptionDic;
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
//            NSArray *arr0 = [[self.dataArr objectAtIndex:0] objectForKey:@"Data"];
            return self.dataArr.count;
            break;
        }
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    DiagnoseReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[DiagnoseReportTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_abnormal_%d",selectedThemeIndex]]];
        [cell addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell).offset(10);
            make.right.equalTo(cell).offset(-10);
            make.top.equalTo(cell).offset(1);
            make.height.equalTo(1);
        }];
    }
//    if (indexPath.row == 0) {
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *time = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"At"];
    cell.reportTimeString = [time substringWithRange:NSMakeRange(11, 8)];
    cell.reportNumString = [NSString stringWithFormat:@"%@次/分钟",[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"Value"]];
    cell.reportResultString = [self getAccessMentWithCode:[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"AssessmentCode"]];
    cell.reportTypeString = [NSString stringWithFormat:@"%@:",titleString];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSString *)getAccessMentWithCode:(NSString *)code
{
    NSDictionary *dic = (NSDictionary *)[[NSUserDefaults standardUserDefaults]objectForKey:code];
    NSString *result = [dic objectForKey:@"Conclusion"];
    return result;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
    self.detailTitleLabel.frame = CGRectMake(10, 0, self.view.frame.size.width-20, 40);
    [view addSubview:_detailTitleLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)cancelView:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    HaviLog(@"测试");
    
//    self.sideTableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.01];
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
