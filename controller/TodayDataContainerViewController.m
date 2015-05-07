//
//  TodayDataContainerViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TodayDataContainerViewController.h"
#import "HeartViewViewController.h"
#import "BreathViewController.h"
#import "LeaveBedViewController.h"
#import "TurnRoundViewController.h"

@interface TodayDataContainerViewController ()

@property (nonatomic,strong) HeartViewViewController *heartView;
@property (nonatomic,strong) BreathViewController *breathView;
@property (nonatomic,strong) LeaveBedViewController *leaveView;
@property (nonatomic,strong) TurnRoundViewController *turnView;
//
@property (nonatomic,assign) int dateType;
@property (strong, nonatomic) UIView *backChangeView;

@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation TodayDataContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor clearColor];

    // Do any additional setup after loading the view.
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }else if (nIndex == 0){
            self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
            [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
            return self.rightButton;
        }
        
        return nil;
    }];
    //
    [self creatSubView];
    //
    // 添加左右手势识别
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRight:)];
    //设置滑动方向，下面以此类推
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.currentView addGestureRecognizer:recognizer];
    [self.view addGestureRecognizer:recognizer];
    UISwipeGestureRecognizer *recognizer1;
    recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromLeft:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.currentView addGestureRecognizer:recognizer1];
    [self.view addGestureRecognizer:recognizer1];
}

- (void)creatSubView
{
    self.backChangeView = [[UIView alloc]init];
    self.backChangeView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    [self.view addSubview:self.backChangeView];
    self.currentView = self.backChangeView;
    self.currentView.userInteractionEnabled = YES;
    self.backChangeView.backgroundColor = [UIColor yellowColor];
}
#pragma mark 手势滑动
//左右滑动
- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)gesture
{
    HaviLog(@"左滑");
    self.dateType ++;
    if (_dateType>4) {
        return;
    }else{
        switch (_dateType) {
            case 1:{
                [self changeViewToHeartView];
                break;
            }
            case 2:{
                [self changeViewToBreathView];
                break;
                
            }
            case 3:{
                [self changeViewToLeaveBedView];
                break;
                
            }
            case 4:{
                [self changeViewToTurnRoundView];
                break;
            }
                
                
            default:
                break;
        }
    }
}
- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)gesture
{
     HaviLog(@"右滑");
    _dateType --;
    if (_dateType<0) {
        return;
    }else{
        switch (_dateType) {
            case 1:{
                [self changeViewToHeartView];
                break;
            }
            case 2:{
                [self changeViewToBreathView];
                break;
                
            }
            case 3:{
                [self changeViewToLeaveBedView];
                break;
                
            }
            case 4:{
                [self changeViewToTurnRoundView];
                break;
            }
                
                
            default:
                break;
        }
    }
}
#pragma mark view title setter method

- (void)setTitle:(NSString *)title
{
    if (title) {
        UIButton *buttonTitle = (UIButton *)[self.view viewWithTag:101];
        [buttonTitle setTitle:title forState:UIControlStateNormal];
        if ([title isEqualToString:@"心率"]) {
            self.dateType = 1;
            [self changeViewToHeartView];
        }else if ([title isEqualToString:@"呼吸"]){
            self.dateType = 2;
            [self changeViewToBreathView];
        }else if ([title isEqualToString:@"离床"]){
            self.dateType = 3;
            [self changeViewToLeaveBedView];
        }else if ([title isEqualToString:@"体动"]){
            self.dateType = 4;
            [self changeViewToTurnRoundView];
        }
    }
}

#pragma mark setter meathod
- (HeartViewViewController *)heartView
{
    if (!_heartView) {
        _heartView = [[HeartViewViewController alloc]init];
    }
    return _heartView;
}

- (BreathViewController *)breathView
{
    if (!_breathView) {
        _breathView = [[BreathViewController alloc]init];
    }
    return _breathView;
}

- (LeaveBedViewController *)leaveView
{
    if (!_leaveView) {
        _leaveView = [[LeaveBedViewController alloc]init];
    }
    return _leaveView;
}

- (TurnRoundViewController *)turnView
{
    if (!_turnView) {
        _turnView = [[TurnRoundViewController alloc]init];
    }
    return _turnView;
}

#pragma mark 切换数据

- (void)changeViewToHeartView
{
    
    self.viewController = self.heartView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [self.viewController viewWillAppear:YES];
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)changeViewToBreathView
{
    
    self.viewController = self.breathView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [self.viewController viewWillAppear:YES];
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)changeViewToLeaveBedView
{
    self.viewController = self.leaveView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [self.viewController viewWillAppear:YES];
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)changeViewToTurnRoundView
{
    self.viewController = self.turnView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [self.viewController viewWillAppear:YES];
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

#pragma mark user action

- (void)backToHomeView:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
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
