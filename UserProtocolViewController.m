//
//  UserProtocolViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/4/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserProtocolViewController.h"

@interface UserProtocolViewController ()

@end

@implementation UserProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createNavWithTitle:@"用户协议" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }
         return nil;
     }];
    
    UIWebView *view = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    view.scrollView.scrollEnabled = YES;
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"protocol" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.view addSubview:view];
    [view loadRequest:request];
}

- (void)backToHomeView:(UIButton *)sender
{
    if (self.isPush) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
   
    
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
