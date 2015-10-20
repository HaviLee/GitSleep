//
//  AboutMeViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/31.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "AboutMeViewController.h"


@interface AboutMeViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) NSCalendar *currentCalendar;

@property (assign, nonatomic) BOOL           lunar;

@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    // 使用方法
    self.navigationController.navigationBarHidden = YES;
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createNavWithTitle:@"关于迈动" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }
         return nil;
     }];
//    [self setDateView];
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    image.image = [UIImage imageNamed:@"pic_about"];
    [self.view addSubview:image];
}

- (void)backToHomeView:(UIButton *)sender
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
