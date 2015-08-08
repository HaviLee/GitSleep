//
//  TagShowViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TagShowViewController.h"

@interface TagShowViewController ()

@end

@implementation TagShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavWithTitle:@"睡眠分析" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;

         }
         return nil;
     }];
    self.bgImageView.image = nil;
}

- (void)backToView:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
