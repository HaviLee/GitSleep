//
//  DataStaticViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/4/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DataStaticViewController.h"
#import "WeekReportViewController.h"
#import "MontheReportViewController.h"
#import "QuarterReportViewController.h"
#import "HaviButton.h"
#import "KxMenu.h"

@interface DataStaticViewController ()

@property (strong, nonatomic) UIView *backChangeView;
@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) NSString *currentTitle;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation DataStaticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    //注意添加的先后顺序
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
    HaviButton *buttonTitle = [[HaviButton alloc]init];
    buttonTitle.frame = CGRectMake((self.view.frame.size.width - 60)/2, 20, 60, 44);
    buttonTitle.tag = 101;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_up_%d",selectedThemeIndex]];
    [buttonTitle setImage:image withTitle:@"月报" forState:UIControlStateNormal];
    [buttonTitle setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonTitle addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonTitle];
    //
    [self creatSubView];
//    [self changeToWeekReportView];
}

- (void)creatSubView
{
    self.backChangeView = [[UIView alloc]init];
    self.backChangeView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    [self.view addSubview:self.backChangeView];
    self.currentView = self.backChangeView;
    self.backChangeView.backgroundColor = [UIColor yellowColor];
}

#pragma mark view title setter method

- (void)setTitle:(NSString *)title
{
    if (title) {
        UIButton *buttonTitle = (UIButton *)[self.view viewWithTag:101];
        [buttonTitle setTitle:title forState:UIControlStateNormal];
        if ([title isEqualToString:@"周报"]) {
            [self changeToWeekReportView];
        }else if ([title isEqualToString:@"月报"]){
            [self changeToMontheReportView];
        }else if ([title isEqualToString:@"季报"]){
            [self changeToQuarterReportView];
        }
    }
}

#pragma mark user action

- (void)showMenu:(UIButton *)sender
{
    UIButton *buttonTitle = (UIButton *)[self.view viewWithTag:101];
    [self rotateTitleArrow:buttonTitle with:M_PI];
    
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"周报"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"月报"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"季报"
                     image:[UIImage imageNamed:@""]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    CGRect popUpPos = sender.frame;
    popUpPos.origin.y -= 10;
    [KxMenu showMenuInView:self.view
                  fromRect:popUpPos
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    [self roateArrow];
    KxMenuItem *item = (KxMenuItem *)sender;
    UIButton *buttonTitle = (UIButton *)[self.view viewWithTag:101];
    [buttonTitle setTitle:item.title forState:UIControlStateNormal];
    if ([item.title isEqualToString:@"周报"] && (self.currentTitle != item.title)) {
        HaviLog(@"周报");
        [self changeToWeekReportView];
        self.currentTitle = item.title;
    }else if ([item.title isEqualToString:@"月报"]&& (self.currentTitle != item.title)){
        HaviLog(@"月报");
        [self changeToMontheReportView];
        self.currentTitle = item.title;
    }else if ([item.title isEqualToString:@"季报"]&& (self.currentTitle != item.title)){
        HaviLog(@"季报");
        [self changeToQuarterReportView];
        self.currentTitle = item.title;
    }
}

#pragma mark report change

- (void)changeToWeekReportView
{
    WeekReportViewController *weekView = [[WeekReportViewController alloc]init];
    self.viewController = weekView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
    
}

- (void)changeToMontheReportView
{
    MontheReportViewController *montheView = [[MontheReportViewController alloc]init];
    self.viewController = montheView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)changeToQuarterReportView
{
    QuarterReportViewController *quarterView = [[QuarterReportViewController alloc]init];
    self.viewController = quarterView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}


//旋转
-(void)rotateTitleArrow:(UIButton*)button with:(double)degree{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        button.imageView.layer.transform = CATransform3DMakeRotation(degree, 0, 0, 1);
    } completion:NULL];
}

- (void)roateArrow
{
    UIButton *buttonTitle = (UIButton *)[self.view viewWithTag:101];
    [self rotateTitleArrow:buttonTitle with:2*M_PI];
}

- (void)backToHomeView:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
}
#pragma mark view method

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.view addSubview:self.backChangeView];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roateArrow) name:KDismissKexMenu object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.backChangeView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KDismissKexMenu object:nil];
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
