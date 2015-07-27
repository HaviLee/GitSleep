//
//  LoginContainerViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/7/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LoginContainerViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "GetCodeViewController.h"

@interface LoginContainerViewController ()
@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIViewController *viewController;
@end

@implementation LoginContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"the height is %f",self.view.frame.size.height);
    self.containerView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.containerView];
    self.currentView = self.containerView;
    [self loginView];
}

- (void)loginView
{
    LoginViewController *lmvc = [[LoginViewController alloc]init];
    lmvc.getCodeButtonClicked = ^(NSUInteger index) {
        [self getCodeView];
    };
    self.viewController = lmvc;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.4f options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)getCodeView
{
    NSLog(@"getcode");
    GetCodeViewController *getCodeVC = [[GetCodeViewController alloc]init];
    self.viewController = getCodeVC;
    getCodeVC.backToLoginButtonClicked = ^(NSUInteger index) {
        [self loginView];
    };
    getCodeVC.registerButtonClicked = ^(NSString *phone) {
        [self registerViewWith:phone];
    };
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.4f options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
        }];
    }
}

- (void)registerViewWith:(NSString *)phone
{
    RegisterViewController *getCodeVC = [[RegisterViewController alloc]init];
    getCodeVC.cellPhoneNum = phone;
    self.viewController = getCodeVC;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.4f options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
        }];
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
