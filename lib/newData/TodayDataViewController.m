//
//  TodayDataViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/5/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TodayDataViewController.h"

#import "TodayHeartViewController.h"
#import "TodayBreathViewController.h"
#import "TodayLeaveViewController.h"
#import "TodayTurnViewController.h"
//
#import "HeartViewViewController.h"
#import "BreathViewController.h"
#import "LeaveBedViewController.h"
#import "TurnRoundViewController.h"


@interface TodayDataViewController ()<NKJPagerViewDataSource, NKJPagerViewDelegate>
@property (nonatomic,strong) NSArray *controllerArr;
@end

@implementation TodayDataViewController

- (void)viewDidLoad {
    TodayHeartViewController *heart = [[TodayHeartViewController alloc]init];
    TodayBreathViewController *breath = [[TodayBreathViewController alloc]init];
    TodayLeaveViewController *leave = [[TodayLeaveViewController alloc]init];
    TodayTurnViewController *turn = [[TodayTurnViewController alloc]init];
    self.controllerArr = @[heart,breath,leave,turn];
    self.dataSource = self;
    self.delegate = self;
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        /*
        else if (nIndex == 0){
            self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
            [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
            return self.rightButton;
        }
        */
        return nil;
    }];
}

- (NSUInteger)numberOfTabView
{
    return 4;
}

- (UIView *)viewPager:(NKJPagerViewController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 0)];
    
    CGFloat r = (arc4random_uniform(255) + 1) / 255.0;
    CGFloat g = (arc4random_uniform(255) + 1) / 255.0;
    CGFloat b = (arc4random_uniform(255) + 1) / 255.0;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    label.backgroundColor = color;
    
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = [NSString stringWithFormat:@"Tab #%lu", index * 10];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    
    return label;
}

- (UIViewController *)viewPager:(NKJPagerViewController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{

    return [self.controllerArr objectAtIndex:index];
    /*
    switch (index) {
        case 0:
        {
            TodayHeartViewController *heart = [[TodayHeartViewController alloc]init];
//            HeartViewViewController *heart = [[HeartViewViewController alloc]init];
            return heart;
            break;
        }
        case 1:{
            TodayBreathViewController *breath = [[TodayBreathViewController alloc]init];
//            BreathViewController *breath = [[BreathViewController alloc]init];
            
            return breath;
            break;
        }
        case 2:{
            TodayLeaveViewController *leave = [[TodayLeaveViewController alloc]init];
//            LeaveBedViewController *leave = [[LeaveBedViewController alloc]init];
            return leave;
            break;
        }
        case 3:{
            TodayTurnViewController *turn = [[TodayTurnViewController alloc]init];
//            TurnRoundViewController *turn = [[TurnRoundViewController alloc]init];
            return turn;
            break;
        }
            
        default:
            [ShowAlertView showAlert:@"没有界面了"];
            return nil;
            break;
    }
     */
}

- (NSInteger)widthOfTabView
{
    return 160;
}

#pragma mark - NKJPagerViewDelegate

- (void)viewPager:(NKJPagerViewController *)viewPager didSwitchAtIndex:(NSInteger)index withTabs:(NSArray *)tabs
{
    HaviLog(@"现在在第%ld个view",(long)index)
    switch (index) {
        case 0:{
            [[NSNotificationCenter defaultCenter]postNotificationName:HeartViewNoti object:nil];
            break;
        }
        case 1:{
            [[NSNotificationCenter defaultCenter]postNotificationName:BreathViewNoti object:nil];
            break;
        }
        case 2:{
            [[NSNotificationCenter defaultCenter]postNotificationName:LeaveBedViewNoti object:nil];
            break;
        }
        case 3:{
            [[NSNotificationCenter defaultCenter]postNotificationName:TurnRoundViewNoti object:nil];
            break;
        }
            
            
        default:
            break;
    }
}

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setActiveContentIndex:self.selectedIndex];
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
