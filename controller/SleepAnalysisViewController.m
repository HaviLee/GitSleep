//
//  SleepAnalysisViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/7.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepAnalysisViewController.h"

@interface SleepAnalysisViewController ()

@end

@implementation SleepAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavWithTitle:@"睡眠分析" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }
         return nil;
     }];
    self.bgImageView.image = nil;
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
