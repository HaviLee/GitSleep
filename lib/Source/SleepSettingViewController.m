//
//  SleepSettingViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepSettingViewController.h"
#import "LRGlowingButton.h"
#import "RMDateSelectionViewController.h"
#import "SHPutClient.h"
#import "MTStatusBarOverlay.h"
#import "MMPickerView.h"
#import "MMTwoListPickerView.h"


#define SleepAlarmSwitchKey   @"isAlarmSwitch"
#define SleepTimeOutSwitchKey @"isTimeoutSwitch"
#define SleepLeaveBedSwitchKey @"isLeaveBedSwitch"

#define UserDefaultAlarmTime   @"defaultAlarmTime"
#define UserDefaultTimeoutTime   @"defaultTimeoutTime"
#define UserDefaultLeaveTime   @"defaultLeaveTime"

@interface SleepSettingViewController ()<RMDateSelectionViewControllerDelegate>
@property (nonatomic,strong) NSArray *arrTitle;
@property (nonatomic,strong) RMDateSelectionViewController *dateSelectionVC;
@property (nonatomic,strong) RMDateSelectionViewController *pickerSelectionVC;
@property (nonatomic,strong) RMDateSelectionViewController *gerderPicker;

@property (nonatomic,strong) NSMutableArray *hourArr;
@property (nonatomic,strong) NSMutableArray *minteArr;
@property (nonatomic,strong) NSMutableArray *hourArr1;
@property (nonatomic,strong) NSMutableArray *hourArr2;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
//
@property (nonatomic,strong) LRGlowingButton *startTimeLabel;
@property (nonatomic,strong) LRGlowingButton *endTimeLabel;
@property (nonatomic,strong) LRGlowingButton *sleepAlarmLabel;
@property (nonatomic,strong) LRGlowingButton *sleepTimeoutLabel;
@property (nonatomic,strong) LRGlowingButton *leaveBedAlarmLabel;

@property (nonatomic,strong) UIImageView *editImage1;
@property (nonatomic,strong) UIImageView *editImage2;
@property (nonatomic,strong) UIImageView *editImage3;
@property (nonatomic,strong) UIImageView *editImage4;
@property (nonatomic,strong) UIImageView *editImage5;
//记录之前的值
@property (nonatomic,strong) NSString *selectString1;
@property (nonatomic,strong) NSString *selectString2;
@property (nonatomic,strong) NSString *selectString3;
@property (nonatomic,strong) NSArray *arrTimeStep;
@end

@implementation SleepSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self createNavWithTitle:@"睡眠设置" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }
         return nil;
     }];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(self.view.bottom).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    self.arrTitle = @[@"习惯睡觉时间",@"习惯起床时间",@"睡觉提醒",@"久睡超时警告",@"离床时间警告"];
//
    self.hourArr = [[NSMutableArray alloc]init];
    self.minteArr = [[NSMutableArray alloc]init];
    self.hourArr1 = [[NSMutableArray alloc]init];
    self.hourArr2 = [[NSMutableArray alloc]init];
    for (int i=1; i<24; i++) {
        if (i<10) {
            [self.hourArr1 addObject:[NSString stringWithFormat:@"0%d:00",i]];
        }else{
            [self.hourArr1 addObject:[NSString stringWithFormat:@"%d:00",i]];
        }
    }
    _selectString1 = [_hourArr1 objectAtIndex:0];
    for (int i=0; i<24; i++) {
        [self.hourArr2 addObject:[NSString stringWithFormat:@"%d时",i]];
    }
    for (int i = 0; i<12; i++) {
        [self.hourArr addObject:[NSString stringWithFormat:@"%d小时",i]];
    }
    for (int i = 0; i<60; i++) {
        [self.minteArr addObject:[NSString stringWithFormat:@"%d分",i]];
    }
    self.arrTimeStep = @[@"5秒",@"15秒",@"30秒",@"1分钟",@"5分钟",@"10分钟",@"15分钟",];
//  注册默认的设置
    //默认的时间设置
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepSettingSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepAlarmSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepTimeOutSwitchKey:@"NO"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{SleepLeaveBedSwitchKey:@"NO"}];
//    用户默认时间
    
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultAlarmTime:@"20:00"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultTimeoutTime:@"超时0小时15分钟"}];
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{UserDefaultLeaveTime:@"离床5秒警告"}];
//
}


#pragma mark tableView 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndetifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 0:
        {
//            if (indexPath.row==0) {
//                [self configSleepTimeTitleCell:cell];
//            }else{
//                [self configSleepTimeCell:cell];
//            }
            [self configNewStartTime:cell];
            return cell;
            break;
        }
        case 1:{
            [self configNewEndTime:cell];
            return cell;
            break;
        }
        case 2:{
            [self configSleepAlarmCell:cell];
            return cell;
            break;
        }
        case 3:{
            [self configSleepTimeoutCell:cell];
            return cell;
            break;
        }
        case 4:{
            [self configLeaveBedAlarmCell:cell];
            return cell;
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35;
    }
    return 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [self.arrTitle objectAtIndex:section];
    return title;
}
#pragma mark custom cell
- (void)configSleepTimeTitleCell:(UITableViewCell *)cell
{
    UILabel *startLabel = [[UILabel alloc]init];
    [cell addSubview:startLabel];
    startLabel.text = @"开始";
    startLabel.textAlignment = NSTextAlignmentCenter;
    [startLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(40);
    }];
//
    UIImageView *lineImage = [[UIImageView alloc]init];
//    lineImage.image = [UIImage imageNamed:@"line"];
    lineImage.backgroundColor = [UIColor darkGrayColor];
    [cell addSubview:lineImage];
    [lineImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(startLabel.right).offset(20);
        make.centerY.equalTo(cell.centerY);
        make.height.equalTo(1);
        make.width.equalTo(40);
    }];
//
    UILabel *endLabel = [[UILabel alloc]init];
    [cell addSubview:endLabel];
    endLabel.text = @"结束";
    endLabel.textAlignment = NSTextAlignmentCenter;
    [endLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineImage.right).offset(20);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(40);
    }];
//
    UISwitch *sleepSwitch = [[UISwitch alloc]init];
    [cell addSubview:sleepSwitch];
    [sleepSwitch addTarget:self action:@selector(sleepSwitchTaped:) forControlEvents:UIControlEventTouchUpInside];
    [sleepSwitch makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cell.right).offset(-15);
        make.centerY.equalTo(cell.centerY);
    }];
//    设置switch
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [sleepSwitch setOn:NO];
    }else{
        [sleepSwitch setOn:YES animated:YES];
    }
}

//
- (void)configNewStartTime:(UITableViewCell*)cell
{
    [self.startTimeLabel removeFromSuperview];
    self.startTimeLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:_startTimeLabel];
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    [self.startTimeLabel setTitle:startTime forState:UIControlStateNormal];
    [self.startTimeLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startTimeLabel.glowsWhenHighlighted = YES;
    _startTimeLabel.highlightedGlowColor = [UIColor greenColor];
    _startTimeLabel.tag = 1001;
    [self.startTimeLabel addTarget:self action:@selector(showStartTimePicker:) forControlEvents:UIControlEventTouchUpInside];
    [_startTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(60);
    }];
}

- (void)configNewEndTime:(UITableViewCell*)cell
{
    [self.endTimeLabel removeFromSuperview];
    self.endTimeLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:self.endTimeLabel];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    [self.endTimeLabel setTitle:endTime forState:UIControlStateNormal];
    [self.endTimeLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _endTimeLabel.glowsWhenHighlighted = YES;
    _endTimeLabel.tag = 1002;
    _endTimeLabel.highlightedGlowColor = [UIColor greenColor];
    [self.endTimeLabel addTarget:self action:@selector(showEndTimePicker:) forControlEvents:UIControlEventTouchUpInside];
    [_endTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(60);
    }];
}

- (void)configSleepTimeCell:(UITableViewCell *)cell
{
    [self.startTimeLabel removeFromSuperview];
    self.startTimeLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:_startTimeLabel];
    NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
    [self.startTimeLabel setTitle:startTime forState:UIControlStateNormal];
    [self.startTimeLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _startTimeLabel.glowsWhenHighlighted = YES;
    _startTimeLabel.highlightedGlowColor = [UIColor greenColor];
    _startTimeLabel.tag = 1001;
    [self.startTimeLabel addTarget:self action:@selector(showStartTimePicker:) forControlEvents:UIControlEventTouchUpInside];
    [_startTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(60);
    }];
//
    self.editImage1 = [[UIImageView alloc]init];
    _editImage1.image = [UIImage imageNamed:@"edit"];
    [cell addSubview:_editImage1];
    [_editImage1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_startTimeLabel.centerY);
        make.left.equalTo(_startTimeLabel.right).offset(5);
        make.height.width.equalTo(17);
    }];
    
//
    self.endTimeLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:self.endTimeLabel];
    NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
    [self.endTimeLabel setTitle:endTime forState:UIControlStateNormal];
    [self.endTimeLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _endTimeLabel.glowsWhenHighlighted = YES;
    _endTimeLabel.tag = 1002;
    _endTimeLabel.highlightedGlowColor = [UIColor greenColor];
    [self.endTimeLabel addTarget:self action:@selector(showEndTimePicker:) forControlEvents:UIControlEventTouchUpInside];
    [_endTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_startTimeLabel.right).offset(60);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(60);
    }];
    self.editImage2 = [[UIImageView alloc]init];
    _editImage2.image = [UIImage imageNamed:@"edit"];
    [cell addSubview:_editImage2];
    [_editImage2 makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_endTimeLabel.centerY);
        make.left.equalTo(_endTimeLabel.right).offset(5);
        make.height.width.equalTo(17);
    }];
//    默认设置
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        _endTimeLabel.userInteractionEnabled = NO;
        _startTimeLabel.userInteractionEnabled = NO;
        self.editImage1.alpha = 0;
        self.editImage2.alpha = 0;
    }
}

- (void)configSleepAlarmCell:(UITableViewCell *)cell
{
    [self.sleepAlarmLabel removeFromSuperview];
    self.sleepAlarmLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:_sleepAlarmLabel];
    NSString *alarmTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultAlarmTime];
    [self.sleepAlarmLabel setTitle:alarmTime forState:UIControlStateNormal];
    [self.sleepAlarmLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _sleepAlarmLabel.glowsWhenHighlighted = YES;
    _sleepAlarmLabel.highlightedGlowColor = [UIColor greenColor];
    _sleepAlarmLabel.tag = 1003;
    [self.sleepAlarmLabel addTarget:self action:@selector(showSleepAlart:) forControlEvents:UIControlEventTouchUpInside];
    [_sleepAlarmLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(60);
    }];
    self.editImage3 = [[UIImageView alloc]init];
    _editImage3.image = [UIImage imageNamed:@"edit"];
    [cell addSubview:_editImage3];
    [_editImage3 makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sleepAlarmLabel.centerY);
        make.left.equalTo(_sleepAlarmLabel.right).offset(5);
        make.height.width.equalTo(17);
    }];
//    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepAlarmSwitchKey]isEqualToString:@"NO"]) {
        _sleepAlarmLabel.userInteractionEnabled = NO;
        self.editImage3.alpha = 0;
    }
//
    for (UIView*view in cell.subviews) {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    UISwitch *sleepAlarmSwitch = [[UISwitch alloc]init];
    [cell addSubview:sleepAlarmSwitch];
    [sleepAlarmSwitch addTarget:self action:@selector(sleepAlarmSwitchTaped:) forControlEvents:UIControlEventTouchUpInside];
    [sleepAlarmSwitch makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cell.right).offset(-15);
        make.centerY.equalTo(cell.centerY);
    }];
//
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepAlarmSwitchKey]isEqualToString:@"NO"]) {
        [sleepAlarmSwitch setOn:NO];
    }else{
        [sleepAlarmSwitch setOn:YES animated:YES];
    }
}

- (void)configSleepTimeoutCell:(UITableViewCell *)cell
{
    [self.sleepTimeoutLabel removeFromSuperview];
    self.sleepTimeoutLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:_sleepTimeoutLabel];
    NSString *Timeout = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultTimeoutTime];
    [self.sleepTimeoutLabel setTitle:Timeout forState:UIControlStateNormal];
    [self.sleepTimeoutLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sleepTimeoutLabel addTarget:self action:@selector(showSleepOutList:) forControlEvents:UIControlEventTouchUpInside];
    _sleepTimeoutLabel.glowsWhenHighlighted = YES;
    _sleepTimeoutLabel.highlightedGlowColor = [UIColor greenColor];
    _sleepTimeoutLabel.tag = 1004;
    [_sleepTimeoutLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
//        make.width.equalTo(100);
    }];
    self.editImage4 = [[UIImageView alloc]init];
    _editImage4.image = [UIImage imageNamed:@"edit"];
    [cell addSubview:_editImage4];
    [_editImage4 makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_sleepTimeoutLabel.centerY);
        make.left.equalTo(_sleepTimeoutLabel.right).offset(5);
        make.height.width.equalTo(17);
    }];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepTimeOutSwitchKey]isEqualToString:@"NO"]) {
        _sleepTimeoutLabel.userInteractionEnabled = NO;
        self.editImage4.alpha = 0;
    }
    
    //
    UISwitch *sleepAlarmSwitch = [[UISwitch alloc]init];
    for (UIView*view in cell.subviews) {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    [cell addSubview:sleepAlarmSwitch];
    [sleepAlarmSwitch addTarget:self action:@selector(sleepTimeoutAlarmSwitchTaped:) forControlEvents:UIControlEventTouchUpInside];
    [sleepAlarmSwitch makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cell.right).offset(-15);
        make.centerY.equalTo(cell.centerY);
    }];
//
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepTimeOutSwitchKey]isEqualToString:@"NO"]) {
        [sleepAlarmSwitch setOn:NO];
    }else{
        [sleepAlarmSwitch setOn:YES animated:YES];
    }

}

- (void)configLeaveBedAlarmCell:(UITableViewCell *)cell
{
    [self.leaveBedAlarmLabel removeFromSuperview];
    self.leaveBedAlarmLabel = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
    [cell addSubview:_leaveBedAlarmLabel];
    NSString *Timeout = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultLeaveTime];
    [self.leaveBedAlarmLabel setTitle:Timeout forState:UIControlStateNormal];
    [self.leaveBedAlarmLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.leaveBedAlarmLabel addTarget:self action:@selector(showLeaveBedPickerList:) forControlEvents:UIControlEventTouchUpInside];
    _leaveBedAlarmLabel.glowsWhenHighlighted = YES;
    _leaveBedAlarmLabel.highlightedGlowColor = [UIColor greenColor];
    _leaveBedAlarmLabel.tag = 1005;
    [_leaveBedAlarmLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(10);
        make.centerY.equalTo(cell.centerY);
//        make.width.equalTo(100);
    }];
    
    self.editImage5 = [[UIImageView alloc]init];
    _editImage5.image = [UIImage imageNamed:@"edit"];
    [cell addSubview:_editImage5];
    [_editImage5 makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_leaveBedAlarmLabel.centerY);
        make.left.equalTo(_leaveBedAlarmLabel.right).offset(5);
        make.height.width.equalTo(17);
    }];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepLeaveBedSwitchKey]isEqualToString:@"NO"]) {
        _leaveBedAlarmLabel.userInteractionEnabled = NO;
        self.editImage5.alpha = 0;
    }
    //
    for (UIView*view in cell.subviews) {
        if ([view isKindOfClass:[UISwitch class]]) {
            [view removeFromSuperview];
        }
    }
    UISwitch *sleepAlarmSwitch = [[UISwitch alloc]init];
    [cell addSubview:sleepAlarmSwitch];
    [sleepAlarmSwitch addTarget:self action:@selector(leaveBedAlarmSwitchTaped:) forControlEvents:UIControlEventTouchUpInside];
    [sleepAlarmSwitch makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cell.right).offset(-15);
        make.centerY.equalTo(cell.centerY);
    }];
//
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepLeaveBedSwitchKey]isEqualToString:@"NO"]) {
        [sleepAlarmSwitch setOn:NO];
    }else{
        [sleepAlarmSwitch setOn:YES animated:YES];
    }
}

#pragma mark datepicker 方法

- (void)showStartTimePicker:(LRGlowingButton*)sender
{
    NSString *senderString = self.startTimeLabel.titleLabel.text;
    NSMutableArray *hour1 = [[NSMutableArray alloc]init];
    NSMutableArray *minute1 = [[NSMutableArray alloc]init];
    for (int i=0; i<60; i++) {
        if (i<10) {
            [minute1 addObject:[NSString stringWithFormat:@"0%d分",i]];
        }else{
            [minute1 addObject:[NSString stringWithFormat:@"%d分",i]];
        }
    }
    for (int i=13; i<24; i++) {
        [hour1 addObject:[NSString stringWithFormat:@"%d点",i]];
    }
    
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[hour1,minute1]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                           self.startTimeLabel.titleLabel.text = senderString;
                                           HaviLog(@"button 的titile是%@",senderString);
                                       }else{
                                           NSString *titleString = [NSString stringWithFormat:@"%@:%@",[selectedString substringWithRange:NSMakeRange(0, 2)],[selectedString substringWithRange:NSMakeRange(3, 2)]];
                                           [_startTimeLabel setTitle:titleString forState:UIControlStateNormal];
                                           isUserDefaultTime = YES;
                                                                               [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultStartTime];
                                                                               [[NSUserDefaults standardUserDefaults]synchronize];
                                           [self sendUserDefaultSleepTime];
                                           _selectString1 = selectedString;
                                       }
                                   }];
    


}
#pragma mark 发送用户习惯睡眠

- (void)sendUserDefaultSleepTime
{
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          @"SleepStartTime":_startTimeLabel.titleLabel.text,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"保存%@",resposeDic);
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [overlay postImmediateFinishMessage:@"睡觉时间修改成功" duration:2 animated:YES];
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
}
- (void)sendUserDefaultEndSleepTime
{
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          @"SleepEndTime":_endTimeLabel.titleLabel.text,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"保存%@",resposeDic);
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [overlay postImmediateFinishMessage:@"起床时间修改成功" duration:2 animated:YES];
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
}


- (void)showEndTimePicker:(LRGlowingButton*)sender
{
    NSString *senderString = self.startTimeLabel.titleLabel.text;
    NSMutableArray *hour1 = [[NSMutableArray alloc]init];
    NSMutableArray *minute1 = [[NSMutableArray alloc]init];
    for (int i=0; i<60; i++) {
        if (i<10) {
            [minute1 addObject:[NSString stringWithFormat:@"0%d分",i]];
        }else{
            [minute1 addObject:[NSString stringWithFormat:@"%d分",i]];
        }
    }
    for (int i=0; i<24; i++) {
        if (i<10) {
            [hour1 addObject:[NSString stringWithFormat:@"0%d点",i]];
        }else{
            [hour1 addObject:[NSString stringWithFormat:@"%d点",i]];
        }
    }
    
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[hour1,minute1]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                           self.startTimeLabel.titleLabel.text = senderString;
                                           HaviLog(@"button 的titile是%@",senderString);
                                       }else{
                                           NSString *titleString = [NSString stringWithFormat:@"%@:%@",[selectedString substringWithRange:NSMakeRange(0, 2)],[selectedString substringWithRange:NSMakeRange(3, 2)]];
                                           [_endTimeLabel setTitle:titleString forState:UIControlStateNormal];
                                           isUserDefaultTime = YES;
                                                                               [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultStartTime];
                                                                               [[NSUserDefaults standardUserDefaults]synchronize];
                                           [self sendUserDefaultEndSleepTime];
                                           _selectString1 = selectedString;
                                       }
                                   }];

}

- (void)showSleepAlart:(LRGlowingButton*)sender
{
    NSString *cancel = self.sleepAlarmLabel.titleLabel.text;
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[_hourArr2,_minteArr]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                           self.sleepAlarmLabel.titleLabel.text = cancel;
                                       }else{
                                           NSRange range1 = [selectedString rangeOfString:@"时"];
                                           NSString *sub1 = [selectedString substringToIndex:range1.location];
                                           NSString *sub2 = [selectedString substringFromIndex:(range1.location + range1.length)];
                                           NSRange range2 = [sub2 rangeOfString:@"分"];
                                           NSString *sub3 = [sub2 substringToIndex:range2.location];
                                           if (sub1.length==1) {
                                               sub1 = [NSString stringWithFormat:@"0%@",sub1];
                                           }
                                           if (sub3.length ==1) {
                                               sub3 = [NSString stringWithFormat:@"0%@",sub3];
                                           }
                                           NSString *date = [NSString stringWithFormat:@"%@:%@",sub1,sub3];
                                           [_sleepAlarmLabel setTitle:date forState:UIControlStateNormal];
                                           [[NSUserDefaults standardUserDefaults]setObject:date forKey:UserDefaultAlarmTime];
                                           [[NSUserDefaults standardUserDefaults]synchronize];
                                           //
                                           NSDate *nowdate = [NSDate date];
                                           NSMutableString *dateString = [NSMutableString stringWithFormat:@"%@",nowdate];
                                           [dateString replaceCharactersInRange:NSMakeRange(11, 5) withString:date];
                                           NSString *new = [dateString substringToIndex:19];
                                           NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                                           [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                           NSDate *dateNow = [formatter dateFromString:new];
                                           [self addAlarmToNoteWithNoteModel:dateNow withFormatter:formatter];
                                       }
                                   }];
}

- (void)showSleepOutList:(LRGlowingButton*)sender
{
    NSString *cancel = self.sleepTimeoutLabel.titleLabel.text;
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[_hourArr,_minteArr]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                           self.sleepTimeoutLabel.titleLabel.text = cancel;
                                       }else{
                                           NSString *titleString ;
                                           if (![selectedString isEqualToString:@"(null)"]) {
                                               titleString = [NSString stringWithFormat:@"超时%@",selectedString];
                                           }else{
                                               titleString = [NSString stringWithFormat:@"超时%@",@"0小时0分钟"];
                                           }
                                           [_sleepTimeoutLabel setTitle:titleString forState:UIControlStateNormal];
                                           [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultTimeoutTime];
                                           [[NSUserDefaults standardUserDefaults]synchronize];
                                           //
                                           
                                           if (![selectedString isEqualToString:@"(null)"]) {
                                               titleString = selectedString;
                                           }else{
                                               titleString = @"0小时0分钟";
                                           }
                                           NSRange range1 = [titleString rangeOfString:@"小时"];
                                           NSString *toString = [titleString substringFromIndex:range1.location + range1.length];
                                           NSRange range2 = [toString rangeOfString:@"分"];
                                           NSString *sub1 = [titleString substringToIndex:range1.location];
                                           NSString *sub2 = [toString substringToIndex:range2.location];
                                           int num = [sub1 intValue]*60+[sub2 intValue];
                                           NSString *timeNum = [NSString stringWithFormat:@"%d",num];
                                           [self updateAlartTime:timeNum withAlartType:@"AlarmTimeSleepTooLong"];
                                       }
                                   }];
}

- (void)showLeaveBedPickerList:(LRGlowingButton*)sender
{
    if (!_gerderPicker) {
        self.gerderPicker = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _gerderPicker.delegate = self;
        _gerderPicker.titleLabel.hidden = YES;
        _gerderPicker.hideNowButton = YES;
        _gerderPicker.pickerDataArray = _arrTimeStep;
    }
    _gerderPicker.title = @"leaveAlert";
    [_gerderPicker show];

    /*
    [MMTwoListPickerView showPickerViewInView:self.view
                                  withStrings:@[_hourArr,_minteArr]
                                  withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                                MMtextColor: [UIColor blackColor],
                                                MMtoolbarColor: [UIColor whiteColor],
                                                MMbuttonColor: [UIColor blueColor],
                                                MMfont: [UIFont systemFontOfSize:35],
                                                MMvalueY: @3,
                                                MMselectedObject:@"li",
                                                MMtextAlignment:@1}
                                   completion:^(NSString *selectedString) {
                                       if ([selectedString isEqualToString:@"cancel"]) {
                                           self.leaveBedAlarmLabel.titleLabel.text = cancel;
                                       }else{
                                           NSString *titleString ;
                                           if (![selectedString isEqualToString:@"(null)"]) {
                                               titleString = [NSString stringWithFormat:@"超时%@",selectedString];
                                           }else{
                                               titleString = [NSString stringWithFormat:@"超时%@",@"0小时0分钟"];
                                           }
                                           [_leaveBedAlarmLabel setTitle:titleString forState:UIControlStateNormal];
                                           [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultLeaveTime];
                                           [[NSUserDefaults standardUserDefaults]synchronize];
                                           NSRange range1 = [titleString rangeOfString:@"小时"];
                                           NSString *toString = [titleString substringFromIndex:range1.location + range1.length];
                                           NSRange range2 = [toString rangeOfString:@"分"];
                                           NSString *sub1 = [titleString substringToIndex:range1.location];
                                           NSString *sub2 = [toString substringToIndex:range2.location];
                                           int num = [sub1 intValue]*60+[sub2 intValue];
                                           NSString *timeNum = [NSString stringWithFormat:@"%d",num];
                                           [self updateAlartTime:timeNum withAlartType:@"AlarmTimeOutOfBed"];
                                       }
                                   }];
     */

}

- (void)showPickerList:(LRGlowingButton*)sender
{
    if (_dateSelectionVC) {
        _dateSelectionVC = nil;
    }
    if (!_pickerSelectionVC) {
        self.pickerSelectionVC = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _pickerSelectionVC.delegate = self;
        _pickerSelectionVC.titleLabel.hidden = YES;
        _pickerSelectionVC.pickerDataArray = @[self.hourArr,self.minteArr];
        _pickerSelectionVC.hideNowButton = YES;
    }
    if (sender.tag == 1004) {
        _pickerSelectionVC.pickerTitle = UserDefaultTimeoutTime;
    }else if (sender.tag == 1005){
        _pickerSelectionVC.pickerTitle = UserDefaultLeaveTime;
    }
    [_pickerSelectionVC show];
}


#pragma mark switch 方法
- (void)sleepSwitchTaped:(UISwitch*)sender
{
    HaviLog(@"睡眠设置开启");
    UISwitch *sleepSwitch = (UISwitch *)sender;
    if (sleepSwitch.on) {
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage1.alpha = 1;
            self.editImage2.alpha = 1;
        }];
        _startTimeLabel.userInteractionEnabled = YES;
        _endTimeLabel.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:SleepSettingSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        isUserDefaultTime = YES;
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage1.alpha = 0;
            self.editImage2.alpha = 0;
        }];
        _startTimeLabel.userInteractionEnabled = NO;
        _endTimeLabel.userInteractionEnabled = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:SleepSettingSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        isUserDefaultTime = NO;
    }
}

- (void)sleepAlarmSwitchTaped:(UISwitch*)sender
{
    HaviLog(@"睡眠警号");
    UISwitch *sleepAlarmSwitch = (UISwitch *)sender;
    if (sleepAlarmSwitch.on) {
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage3.alpha = 1;
        }];
        _sleepAlarmLabel.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:SleepAlarmSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSString *alarmTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultAlarmTime];
        //
        NSDate *nowdate = [NSDate date];
        NSMutableString *dateString = [NSMutableString stringWithFormat:@"%@",nowdate];
        [dateString replaceCharactersInRange:NSMakeRange(11, 5) withString:alarmTime];
        NSString *new = [dateString substringToIndex:19];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter dateFromString:new];
        [self addAlarmToNoteWithNoteModel:date withFormatter:formatter];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage3.alpha = 0;
        }];
        _sleepAlarmLabel.userInteractionEnabled = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:SleepAlarmSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //取消闹钟
        [self cancelAlarm];
    }
}

- (void)sleepTimeoutAlarmSwitchTaped:(UISwitch *)sender
{
    HaviLog(@"久睡超时");
    NSString *alartType = @"IsTimeoutAlarmSleepTooLong";
    UISwitch *sleepTimeoutSwitch = (UISwitch *)sender;
    if (sleepTimeoutSwitch.on) {
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage4.alpha = 1;
        }];
        _sleepTimeoutLabel.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:SleepTimeOutSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setSleepTimeOutTo:sleepTimeoutSwitch.on withAlartType:alartType];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage4.alpha = 0;
        }];
        _sleepTimeoutLabel.userInteractionEnabled = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:SleepTimeOutSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setSleepTimeOutTo:sleepTimeoutSwitch.on withAlartType:alartType];
    }
}

- (void)leaveBedAlarmSwitchTaped:(UISwitch *)sender
{
    HaviLog(@"离床");
    NSString *alartType = @"IsTimeoutAlarmOutOfBed";
    UISwitch *leaveBedSwitch = (UISwitch *)sender;
    if (leaveBedSwitch.on) {
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage5.alpha = 1;
        }];
        _leaveBedAlarmLabel.userInteractionEnabled = YES;
        [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:SleepLeaveBedSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setSleepTimeOutTo:leaveBedSwitch.on withAlartType:alartType];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            self.editImage5.alpha = 0;
        }];
        _leaveBedAlarmLabel.userInteractionEnabled = NO;
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:SleepLeaveBedSwitchKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setSleepTimeOutTo:leaveBedSwitch.on withAlartType:alartType];
    }
}


//返回
- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark datePicker delegate
#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSString *)aDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",aDate];
    if ([vc.pickerTitle isEqualToString:UserDefaultStartTime]) {
        [_startTimeLabel setTitle:aDate forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:aDate forKey:UserDefaultStartTime];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else if ([vc.pickerTitle isEqualToString:UserDefaultEndTime]){
        [_endTimeLabel setTitle:aDate forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:aDate forKey:UserDefaultEndTime];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }else if ([vc.pickerTitle isEqualToString:UserDefaultAlarmTime]){
        NSRange range1 = [dateString rangeOfString:@"时"];
        NSString *sub1 = [dateString substringToIndex:range1.location];
        NSString *sub2 = [dateString substringFromIndex:(range1.location + range1.length)];
        NSRange range2 = [sub2 rangeOfString:@"分"];
        NSString *sub3 = [sub2 substringToIndex:range2.location];
        if (sub1.length==1) {
            sub1 = [NSString stringWithFormat:@"0%@",sub1];
        }
        if (sub3.length ==1) {
            sub3 = [NSString stringWithFormat:@"0%@",sub3];
        }
        NSString *date = [NSString stringWithFormat:@"%@:%@",sub1,sub3];
        [_sleepAlarmLabel setTitle:date forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:date forKey:UserDefaultAlarmTime];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //
        NSDate *nowdate = [NSDate date];
        NSMutableString *dateString = [NSMutableString stringWithFormat:@"%@",nowdate];
        [dateString replaceCharactersInRange:NSMakeRange(11, 5) withString:date];
        NSString *new = [dateString substringToIndex:19];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateNow = [formatter dateFromString:new];
        [self addAlarmToNoteWithNoteModel:dateNow withFormatter:formatter];
    }else if ([vc.pickerTitle isEqualToString:UserDefaultTimeoutTime]){
        NSString *titleString ;
        if (![dateString isEqualToString:@"(null)"]) {
            titleString = [NSString stringWithFormat:@"超时%@",dateString];
        }else{
            titleString = [NSString stringWithFormat:@"超时%@",@"0小时0分钟"];
        }
        [_sleepTimeoutLabel setTitle:titleString forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultTimeoutTime];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //
        
        if (![dateString isEqualToString:@"(null)"]) {
            titleString = dateString;
        }else{
            titleString = @"0小时0分钟";
        }
        NSRange range1 = [titleString rangeOfString:@"小时"];
        NSString *toString = [titleString substringFromIndex:range1.location + range1.length];
        NSRange range2 = [toString rangeOfString:@"分"];
        NSString *sub1 = [titleString substringToIndex:range1.location];
        NSString *sub2 = [toString substringToIndex:range2.location];
        int num = [sub1 intValue]*60+[sub2 intValue];
        NSString *timeNum = [NSString stringWithFormat:@"%d",num];
        [self updateAlartTime:timeNum withAlartType:@"AlarmTimeSleepTooLong"];
    }else if ([vc.pickerTitle isEqualToString:UserDefaultLeaveTime]){
        NSString *titleString ;
        if (![dateString isEqualToString:@"(null)"]) {
            titleString = [NSString stringWithFormat:@"超时%@",dateString];
        }else{
            titleString = [NSString stringWithFormat:@"超时%@",@"0小时0分钟"];
        }
        [_leaveBedAlarmLabel setTitle:titleString forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultLeaveTime];
        [[NSUserDefaults standardUserDefaults]synchronize];
        NSRange range1 = [titleString rangeOfString:@"小时"];
        NSString *toString = [titleString substringFromIndex:range1.location + range1.length];
        NSRange range2 = [toString rangeOfString:@"分"];
        NSString *sub1 = [titleString substringToIndex:range1.location];
        NSString *sub2 = [toString substringToIndex:range2.location];
        int num = [sub1 intValue]*60+[sub2 intValue];
        NSString *timeNum = [NSString stringWithFormat:@"%d",num];
        [self updateAlartTime:timeNum withAlartType:@"AlarmTimeOutOfBed"];
    }else if ([vc.title isEqualToString:@"leaveAlert"]){
        if (aDate.length>0) {
            HaviLog(@"Successfully selected date: %@", aDate);
            NSString *titleString = [NSString stringWithFormat:@"离床%@警告",aDate];
            [_leaveBedAlarmLabel setTitle:titleString forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults]setObject:titleString forKey:UserDefaultLeaveTime];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSRange rangeMinute = [aDate rangeOfString:@"分钟"];
            int num=0;
            if (rangeMinute.length>0) {
                num = [[aDate substringToIndex:rangeMinute.location] intValue];
                num = num*60;
            }else{
                NSRange rangeMinute1 = [aDate rangeOfString:@"秒"];
                num = [[aDate substringToIndex:rangeMinute1.location] intValue];
            }
            [self updateAlartTime:[NSString stringWithFormat:@"%d",num] withAlartType:@"AlarmTimeOutOfBed"];
            [[NSNotificationCenter defaultCenter]postNotificationName:ShowLeaveBedAfterTime object:nil userInfo:@{@"time":[NSString stringWithFormat:@"%d",num]}];
        }
    }
    
}
#pragma mark 设置设备的闹钟提醒

- (void)addAlarmToNoteWithNoteModel:(NSDate *)date withFormatter:(NSDateFormatter *)fametter
{
    //先取消本地的
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
    //
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    
    if (notification!=nil) {
        notification.fireDate= date;//10秒后通知
        notification.repeatInterval= kCFCalendarUnitDay;//循环次数，kCFCalendarUnitWeekday一周一次
        notification.timeZone=[NSTimeZone defaultTimeZone];
        //        notification.applicationIconBadgeNumber=0; //应用的红色数字
        notification.soundName = @"user3.wav";
        NSString *noteAlert = [NSString stringWithFormat:@"您有一个起床闹钟"] ;//提示信息 弹出提示框
        notification.alertBody= noteAlert;//提示信息 弹出提示框
        notification.alertAction = @"打开";  //提示框按钮
        //notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消
        NSDictionary *infoDic = @{@"key": date, @"alertString": noteAlert};
        notification.userInfo = infoDic;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)cancelAlarm
{
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
}

#pragma mark modify usersetting

- (void)setSleepTimeOutTo:(BOOL)isOn withAlartType:(NSString *)alartType
{
    NSString *isSleepOn = isOn ? @"true":@"false";
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          alartType:isSleepOn,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            if (isOn) {
                if ([alartType isEqualToString:@"IsTimeoutAlarmSleepTooLong"]) {
                    [JDStatusBarNotification showWithStatus:@"久睡超时警告开启" dismissAfter:2 styleName:JDStatusBarStyleDark];
                }else{
                    [JDStatusBarNotification showWithStatus:@"久睡离床警告开启" dismissAfter:2 styleName:JDStatusBarStyleDark];
                    /*
                    [[NSNotificationCenter defaultCenter]postNotificationName:ShowLeaveBedAlertNoti object:nil];
                     */
                }
            }else{
                if ([alartType isEqualToString:@"IsTimeoutAlarmSleepTooLong"]) {
                    [JDStatusBarNotification showWithStatus:@"久睡超时警告关闭" dismissAfter:2 styleName:JDStatusBarStyleDark];
                }else{
                    [JDStatusBarNotification showWithStatus:@"久睡离床警告关闭" dismissAfter:2 styleName:JDStatusBarStyleDark];
                    /*
                    [[NSNotificationCenter defaultCenter]postNotificationName:ShowLeaveBedAlertNoti object:nil];
                     */
                }
            }
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];

}

- (void)updateAlartTime:(NSString *)aString withAlartType:(NSString *)alartType
{
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          alartType:aString,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"保存%@",resposeDic);
        
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            if ([alartType isEqualToString:@"AlarmTimeSleepTooLong"]) {
                [JDStatusBarNotification showWithStatus:@"久睡超时修改成功" dismissAfter:2 styleName:JDStatusBarStyleDark];
            }else{
                [JDStatusBarNotification showWithStatus:@"久睡离床修改成功" dismissAfter:2 styleName:JDStatusBarStyleDark];
            }
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    HaviLog(@"Date selection was canceled");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hourArr = nil;
    self.minteArr = nil;
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
