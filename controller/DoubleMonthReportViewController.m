//
//  DoubleMonthReportViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/26.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleMonthReportViewController.h"
#import "SLPagingViewController.h"
#import "NewMonthReportViewController.h"

@interface DoubleMonthReportViewController ()

@property (nonatomic, strong) NewMonthReportViewController *leftMonthReport;
@property (nonatomic, strong) NewMonthReportViewController *rightMonthReport;
@property (nonatomic, strong) UIButton *leftMenuButton;
@property (nonatomic, strong) UIButton *rightMenuButton;

@end

@implementation DoubleMonthReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setPageViewController];
}

- (void)setPageViewController
{
    // Do any additional setup after loading the view.
    UILabel *navTitleLabel1 = [UILabel new];
    navTitleLabel1.text = @"梧桐植树";
    navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:17];
    navTitleLabel1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    UILabel *navTitleLabel2 = [UILabel new];
    navTitleLabel2.text = @"哈维之家";
    navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:17];
    navTitleLabel2.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    
    SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1, navTitleLabel2]
                                                                                    navBarBackground:[UIColor clearColor]
                                                                                               views:@[self.leftMonthReport.view, self.rightMonthReport.view]
                                                                                     showPageControl:YES];
    [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
    [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
    [pageViewController updateUserInteractionOnNavigation:NO];
    pageViewController.tintPageControlColor = [UIColor grayColor];
    pageViewController.currentPageControlColor = selectedThemeIndex == 0? DefaultColor: [UIColor whiteColor];
    
    
    // Twitter Like
    pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
        float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
        float width = [UIScreen mainScreen].bounds.size.width;
        CGFloat xOffset = scrollView.contentOffset.x;
        int i = 0;
        for(UILabel *v in subviews){
            CGFloat alpha = 0.0;
            if(v.frame.origin.x < mid)
                alpha = 1 - (xOffset - i*width) / width;
            else if(v.frame.origin.x >mid)
                alpha=(xOffset - i*width) / width + 1;
            else if(v.frame.origin.x == mid-5)
                alpha = 1.0;
            i++;
            v.alpha = alpha;
        }
    };
    
    pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
        // Do something
        NSLog(@"index %ld", (long)currentPageIndex);
    };
    pageViewController.navigationBarView.image = [UIImage imageNamed:@""];
    [pageViewController.navigationBarView addSubview:self.leftMenuButton];
    [pageViewController.navigationBarView addSubview:self.rightMenuButton];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:pageViewController];
    [self addChildViewController:navi];
    navi.navigationBarHidden = YES;
    [self.view addSubview:navi.view];
}

#pragma mark setter

- (UIButton *)leftMenuButton
{
    if (!_leftMenuButton) {
        _leftMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]];
        [_leftMenuButton setImage:i forState:UIControlStateNormal];
        [_leftMenuButton setFrame:CGRectMake(0, 20, 44, 44)];
        [_leftMenuButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftMenuButton;
}

- (UIButton *)rightMenuButton
{
    if (!_rightMenuButton) {
        _rightMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightMenuButton.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]];
        [_rightMenuButton setImage:i forState:UIControlStateNormal];
        [_rightMenuButton setFrame:CGRectMake(self.view.frame.size.width-50, 20, 44, 44)];
        [_rightMenuButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightMenuButton;
}

- (NewMonthReportViewController *)leftMonthReport
{
    if (!_leftMonthReport) {
        _leftMonthReport = [[NewMonthReportViewController alloc]init];
        
    }
    return _leftMonthReport;
}

- (NewMonthReportViewController *)rightMonthReport
{
    if (!_rightMonthReport) {
        _rightMonthReport = [[NewMonthReportViewController alloc]init];
        
    }
    return _rightMonthReport;
}

- (void)backToHome:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
