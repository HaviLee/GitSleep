//
//  SencondBreathViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SencondBreathViewController.h"
#import "BreathGraphView.h"
#import "DataShowChartTableViewCell.h"
#import "CalenderCantainerViewController.h"
#import "GetBreathDataAPI.h"
#import "GetBreathSleepDataAPI.h"
#import "GetDefatultSleepAPI.h"
#import "GetUserDefaultDataAPI.h"
#import "ModalAnimation.h"
#import "GetExceptionAPI.h"
#import "DiagnoseReportViewController.h"

@interface SencondBreathViewController ()
{
    BOOL isUp;//控制两个tableview切换
    ModalAnimation *_modalAnimationController;
}
@property (nonatomic,assign) CGFloat viewHeight;
@property (nonatomic,strong) UITableView *upTableView;
@property (nonatomic,strong) UITableView *reportTableView;

//表哥
@property (nonatomic,strong) BreathGraphView *breathGraphView;//havi

//数据
@property (nonatomic,strong) NSDictionary *reportData;
@property (nonatomic,strong) NSArray *heartDic;
//记录当前的时间进行请求异常报告
@property (nonatomic,strong) NSString *currentDate;
@property (nonatomic,strong) NSDictionary *currentSleepQulitity;
@property (nonatomic,strong) UIImageView *backImage;
@end

@implementation SencondBreathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
