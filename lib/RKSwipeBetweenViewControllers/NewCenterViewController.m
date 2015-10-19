//
//  NewCenterViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/19.
//  Copyright © 2015年 Havi. All rights reserved.
//
#import "UIBarButtonItem+Common.h"
#import "NewCenterViewController.h"

@interface NewCenterViewController ()

@end

@implementation NewCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftBarItem =[UIBarButtonItem itemWithIcon:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex] showBadge:NO target:self action:@selector(presentLeftMenuViewController:)];
    [self.parentViewController.navigationItem setLeftBarButtonItem:leftBarItem animated:NO];
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
