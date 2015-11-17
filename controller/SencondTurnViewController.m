//
//  SencondTurnViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SencondTurnViewController.h"
#import "DataTableViewCell.h"
#import "GetTurnDataAPI.h"
#import "GetTurnSleepDataAPI.h"

@interface SencondTurnViewController ()
@property (nonatomic, strong) UIImageView *leaveImage;
@property (nonatomic, strong) UILabel *sleepTimeLabel;
@property (nonatomic, strong) UIView *circleSleepView;
@property (nonatomic, strong) UILabel *timesLabel;
@property (nonatomic, strong) UILabel *circleTitle;
@property (nonatomic, strong) UILabel *circleSubTitle;
@property (nonatomic, strong) UITableView *bottomTableView;
@property (nonatomic,strong) NSArray *turnDic;

@end

@implementation SencondTurnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self createNavigationView];
    [self createSubView];
    [self.view addSubview:self.bottomTableView];
    [self getData];
    
}

- (void)getData
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH时mm分ss秒"];
    NSString *dateString = [formatter stringFromDate:selectedDateToUse];
    NSString *queryDate = [NSString stringWithFormat:@"%@%@%@",[dateString substringWithRange:NSMakeRange(0, 4)],[dateString substringWithRange:NSMakeRange(5, 2)],[dateString substringWithRange:NSMakeRange(8, 2)]];
    //请求数据
    [self getUserAllDaySensorData:queryDate toDate:queryDate];
}

#pragma mark 获取24小时用户数据

- (void)getUserAllDaySensorData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                            [UIImage imageNamed:@"havi1_1"],
                            [UIImage imageNamed:@"havi1_2"],
                            [UIImage imageNamed:@"havi1_3"],
                            [UIImage imageNamed:@"havi1_4"],
                            [UIImage imageNamed:@"havi1_5"]];
        [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:nil status:nil images:images];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *lastDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *lastDayString = [NSString stringWithFormat:@"%@",lastDay];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[lastDayString substringWithRange:NSMakeRange(0, 4)],[lastDayString substringWithRange:NSMakeRange(5, 2)],[lastDayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=1&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,newString,toDate];
//        if (isTodayHourEqualSixteen<18) {
//        }else{
//            self.dateComponentsBase.day = 1;
//            NSDate *nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
//            NSString *nextDayString = [NSString stringWithFormat:@"%@",nextDay];
//            NSString *newNextDayString = [NSString stringWithFormat:@"%@%@%@",[nextDayString substringWithRange:NSMakeRange(0, 4)],[nextDayString substringWithRange:NSMakeRange(5, 2)],[nextDayString substringWithRange:NSMakeRange(8, 2)]];
//            urlString = [NSString stringWithFormat:@"v1/app/SensorDataHistory?UUID=%@&DataProperty=1&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,fromDate,newNextDayString];
//        }
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetTurnDataAPI *client = [GetTurnDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getTurnData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            [MMProgressHUD dismiss];
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            //            [MMProgressHUD dismiss];
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            HaviLog(@"缓存的体动数据%@和%@",resposeDic,urlString);
            [self reloadUserViewWithData:resposeDic];
            [self getUserSleepReportData:fromDate toDate:toDate];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                //                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                HaviLog(@"请求的体动数据%@和%@",resposeDic,urlString);
                [self reloadUserViewWithData:resposeDic];
                [self getUserSleepReportData:fromDate toDate:toDate];
            } failure:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
            }];
        }
    }
}

- (void)getUserSleepReportData:(NSString *)fromDate toDate:(NSString *)toDate
{
    if (fromDate) {
        
        NSDate *newDate = [self.dateFormmatterBase dateFromString:fromDate];
        NSString *urlString = @"";
        self.dateComponentsBase.day = -1;
        NSDate *yestoday = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponentsBase toDate:newDate options:0];
        NSString *yestodayString = [NSString stringWithFormat:@"%@",yestoday];
        NSString *newString = [NSString stringWithFormat:@"%@%@%@",[yestodayString substringWithRange:NSMakeRange(0, 4)],[yestodayString substringWithRange:NSMakeRange(5, 2)],[yestodayString substringWithRange:NSMakeRange(8, 2)]];
        urlString = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&UserId=%@&FromDate=%@&EndDate=%@&FromTime=18:00&EndTime=18:00",HardWareUUID,thirdPartyLoginUserId,newString,fromDate];
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        GetTurnSleepDataAPI *client = [GetTurnSleepDataAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [client getTurnSleepData:header withDetailUrl:urlString];
        if ([client getCacheJsonWithDate:fromDate]) {
            NSDictionary *resposeDic = (NSDictionary *)[client cacheJson];
            HaviLog(@"缓存的睡眠数据是%@,and%@",resposeDic,urlString);
            //为了异常报告
            [MMProgressHUD dismiss];
            [self reloadSleepView:resposeDic];
        }else{
            [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
                HaviLog(@"睡眠是%@and %@",resposeDic,urlString);
                //为了异常报告
                [self reloadSleepView:resposeDic];
            } failure:^(YTKBaseRequest *request) {
                [MMProgressHUD dismiss];
                [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
            }];
        }
    }
}

- (void)reloadSleepView:(NSDictionary *)dic
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[dic objectForKey:@"Data"]];
    NSString *selectString = [NSString stringWithFormat:@"%@",selectedDateToUse];
    NSString *subString = [selectString substringToIndex:10];
    NSDictionary *dataDic=nil;
    for (NSDictionary *dic in arr) {
        if ([[dic objectForKey:@"Date"]isEqualToString:subString]) {
            dataDic = dic;
        }
    }
    NSString *sting = [NSString stringWithFormat:@"睡眠时长: %0.2f小时",[[dataDic objectForKey:@"SleepDuration"] floatValue]];
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:sting];
    [attribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [sting length])];
    [attribute addAttribute:NSForegroundColorAttributeName value:selectedThemeIndex==0? DefaultColor:[UIColor whiteColor] range:[sting rangeOfString:@"睡眠时长:"]];
    [attribute addAttribute:NSForegroundColorAttributeName value:selectedThemeIndex==0? DefaultColor:[UIColor whiteColor] range:[sting rangeOfString:@"小时"]];
    _sleepTimeLabel.attributedText = attribute;
    self.timesLabel.text = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"BodyMovementTimes"] intValue]];
}

- (void)reloadUserViewWithData:(NSDictionary *)dataDic
{
    self.turnDic = nil;
    NSArray *arr = [dataDic objectForKey:@"SensorData"];
    for (NSDictionary *dic in arr) {
        self.turnDic = [dic objectForKey:@"Data"];
        
    }
//    for (NSDictionary *dic in self.turnDic) {
//        if ([[dic objectForKey:@"Value"]intValue]==1) {
//            [arrSub addObject:dic];
//        }
//    }
//    self.turnDic = arrSub;
    [self.bottomTableView reloadData];
    
}



#pragma mark 创建view

- (void)createSubView
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 203)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:self.leaveImage];
    [backView addSubview:self.sleepTimeLabel];
    [backView addSubview:self.circleSleepView];
    [self.circleSleepView addSubview:self.timesLabel];
    [self.circleSleepView addSubview:self.circleTitle];
    [self.circleSleepView addSubview:self.circleSubTitle];
    [self.leaveImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView);
        make.height.equalTo(34);
        make.width.equalTo(51);
        make.left.equalTo(backView.left).offset((self.view.frame.size.width-51-150)/2);
        
    }];
    [self.sleepTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leaveImage.centerY);
        make.height.equalTo(30);
        make.width.equalTo(150);
        make.left.equalTo(self.leaveImage.right).offset(20);
    }];
    
    [self.circleSleepView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.centerX);
        make.top.equalTo(self.leaveImage.bottom).offset(25);
        make.width.equalTo(142);
        make.width.equalTo(self.circleSleepView.height);
    }];
    
    [self.timesLabel makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.circleSleepView.center);
        make.height.equalTo(30);
        make.width.equalTo(50);
    }];
    
    [self.circleTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timesLabel.centerX);
        make.bottom.equalTo(self.timesLabel.top).offset(-5);
        make.height.equalTo(30);
        make.width.equalTo(100);
    }];
    
    [self.circleSubTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timesLabel.centerX);
        make.top.equalTo(self.timesLabel.bottom).offset(5);
        make.height.equalTo(20);
        make.width.equalTo(20);
    }];
    
    [self.view addSubview:backView];
}

- (void)createNavigationView
{
    //    isUp = YES;
    //    self.viewHeight = self.view.frame.size.height;
    //    _modalAnimationController = [[ModalAnimation alloc] init];
    [self createClearBgNavWithTitle:@"体动" andTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        else if (nIndex == 0){
            if ([self isThirdAppAllInstalled]) {
                self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
                [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
                [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
                return self.rightButton;
            }
            return nil;
        }
        return nil;
    }];
}

#pragma mark setter

- (UITableView *)bottomTableView
{
    if (_bottomTableView == nil) {
        _bottomTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,202 , self.view.frame.size.width, self.view.frame.size.height-204-64) style:UITableViewStylePlain];
        _bottomTableView.backgroundColor = [UIColor clearColor];
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _bottomTableView;
}

- (UIImageView *)leaveImage
{
    if (_leaveImage==nil) {
        _leaveImage = [[UIImageView alloc]init];
        //                       WithFrame:CGRectMake(100, 0, 51, 34)];
        _leaveImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_body_movement_%d",selectedThemeIndex]];
    }
    return _leaveImage;
}

- (UILabel *)sleepTimeLabel
{
    if (_sleepTimeLabel==nil) {
        _sleepTimeLabel = [[UILabel alloc]init];
        //                           WithFrame:CGRectMake(151, 2, 100, 30)];
        _sleepTimeLabel.text = @"睡眠时长:0小时";
        _sleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _sleepTimeLabel.textColor = [UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f];
        
    }
    return _sleepTimeLabel;
}

- (UIView *)circleSleepView
{
    if (_circleSleepView == nil) {
        _circleSleepView = [[UIView alloc]init];
        _circleSleepView.layer.cornerRadius = 68.5;
        _circleSleepView.layer.masksToBounds = YES;
        _circleSleepView.backgroundColor = selectedThemeIndex==0?[self colorWithHex:0x0e254c alpha:1]:[self colorWithHex:0x5e8abe alpha:1];
    }
    return _circleSleepView;
}

- (UILabel *)timesLabel
{
    if (_timesLabel == nil) {
        _timesLabel = [[UILabel alloc]init];
        _timesLabel.text = @"0";
        _timesLabel.font = [UIFont systemFontOfSize:25];
        _timesLabel.textAlignment = NSTextAlignmentCenter;
        _timesLabel.textColor = [UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f];
    }
    return _timesLabel;
}

- (UILabel *)circleTitle{
    if (_circleTitle==nil) {
        _circleTitle = [[UILabel alloc]init];
        _circleTitle.text = @"您昨晚体动";
        _circleTitle.font = [UIFont systemFontOfSize:15];
        _circleTitle.textAlignment = NSTextAlignmentCenter;
        _circleTitle.textColor = selectedThemeIndex == 0?DefaultColor:[UIColor whiteColor];
        
    }
    return _circleTitle;
}

- (UILabel *)circleSubTitle
{
    if (_circleSubTitle==nil) {
        _circleSubTitle = [[UILabel alloc]init];
        _circleSubTitle.font = [UIFont systemFontOfSize:15];
        _circleSubTitle.textAlignment = NSTextAlignmentCenter;
        _circleSubTitle.text = @"次";
        _circleSubTitle.textColor = selectedThemeIndex == 0?DefaultColor:[UIColor whiteColor];
        
    }
    return _circleSubTitle;
}

#pragma mark tableview 代理函数

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.turnDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.bottomTableView]) {
        
        static NSString *cellTitle = @"cellTitle";
        DataTableViewCell *cell = (DataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellTitle];
        if (cell==nil) {
            cell = [[DataTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTitle];
        }
        NSDictionary *cellDic = [self.turnDic objectAtIndex:indexPath.row];
        NSString *cellString = [cellDic objectForKey:@"At"];
        
        NSString *month = [NSString stringWithFormat:@"%@月%@日",[cellString substringWithRange:NSMakeRange(5, 2)],[cellString substringWithRange:NSMakeRange(8, 2)]];
        NSString *time = [NSString stringWithFormat:@"%@",[cellString substringWithRange:NSMakeRange(11, 8)]];
        if (indexPath.row%2==0) {
            cell.leftTitleName = month;
            cell.leftSubTitleName = time;
            cell.rightTitleName = @"";
            cell.rightSubTitleName = @"";
        }else{
            cell.leftTitleName = @"";
            cell.leftSubTitleName = @"";
            cell.rightTitleName = month;
            cell.rightSubTitleName = time;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
}

#pragma mark button 实现方法

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
//    [self.shareMenuView show];
    [self.shareNewMenuView showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)reloadThemeImage
{
    [super reloadThemeImage];
    _leaveImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_body_movement_%d",selectedThemeIndex]];
    _circleSleepView.backgroundColor = selectedThemeIndex==0?[self colorWithHex:0x0e254c alpha:1]:[self colorWithHex:0x5e8abe alpha:1];
    _circleTitle.textColor = selectedThemeIndex == 0?DefaultColor:[UIColor whiteColor];
    _circleSubTitle.textColor = selectedThemeIndex == 0?DefaultColor:[UIColor whiteColor];
    [self.bottomTableView reloadData];
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
