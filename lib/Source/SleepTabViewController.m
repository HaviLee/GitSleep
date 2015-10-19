//
//  SleepTabViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/19.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "SleepTabViewController.h"
#import "CenterViewController.h"
#import "SwipableViewController.h"
@interface SleepTabViewController ()

@property (strong, nonatomic) CenterViewController *centerViewController;

@end

@implementation SleepTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    // Do any additional setup after loading the view.
    self.centerViewController = [[CenterViewController alloc] init];
    CenterViewController *center2 = [[CenterViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.centerViewController];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:center2];
    SwipableViewController *tweetsSVC = [[SwipableViewController alloc] initWithTitle:@"动弹"
                                                                         andSubTitles:@[@"", @""]
                                                                       andControllers:@[self.centerViewController,center2]
                                                                          underTabbar:NO];
    self.tabBar.translucent = NO;
    self.viewControllers = @[
                             [self addNavigationItemForViewController:tweetsSVC]

                             ];
}

#pragma mark -

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
    viewController.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:i
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self action:@selector(onClickMenuButton)];
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar-search"]
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self action:@selector(pushSearchViewController)];
    
    
    
    return navigationController;
}

- (void)onClickMenuButton
{
    [self.sideMenuViewController presentLeftMenuViewController];
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
