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

@property (strong, nonatomic) LoginViewController *loginView;
@property (strong, nonatomic) GetCodeViewController *getCodeView;
@property (strong, nonatomic) RegisterViewController *registerView;
@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIViewController *viewController;
@end

@implementation LoginContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSLog(@"the height is %f",self.view.frame.size.height);
    self.containerView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.containerView];
    self.currentView = self.containerView;
    [self changeLoginViewIn:YES];
}

- (LoginViewController*)loginView
{
    if (_loginView==nil) {
        _loginView = [[LoginViewController alloc]init];
        __block typeof(self) weakSelf = self;
        _loginView.getCodeButtonClicked = ^(NSUInteger index) {
            [weakSelf changeGetCodeViewIn:YES];
        };
        _loginView.loginButtonClicked = ^(NSUInteger index) {
            weakSelf.loginSuccessed(1);
        };
    }
    return _loginView;
}

- (GetCodeViewController*)getCodeView
{
    if (_getCodeView == nil) {
        _getCodeView = [[GetCodeViewController alloc]init];
        
    }
    return _getCodeView;
}

- (RegisterViewController *)registerView
{
    if (_registerView == nil) {
        _registerView = [[RegisterViewController alloc]init];
    }
    return _registerView;
}

- (void)changeLoginViewIn:(BOOL)isIn
{
//    __block typeof(self) weakSelf = self;
//    self.loginView.getCodeButtonClicked = ^(NSUInteger index) {
//        [weakSelf changeGetCodeViewIn:YES];
//    };
    UIViewAnimationOptions animation = isIn ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    self.viewController = self.loginView;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.4f options:animation completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
            
        }];
    }
}

- (void)changeGetCodeViewIn:(BOOL)isIn
{
    NSLog(@"getcode");
//    GetCodeViewController *getCodeVC = [[GetCodeViewController alloc]init];
    self.viewController = self.getCodeView;
    __block typeof(self) weakSelf = self;
    self.getCodeView.backToLoginButtonClicked = ^(NSUInteger index) {
        [weakSelf changeLoginViewIn:NO];
    };
    self.getCodeView.registerButtonClicked = ^(NSString *phone) {
        [weakSelf registerViewWith:phone andIn:YES];
    };
    UIViewAnimationOptions animation = isIn ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.5f options:animation completion:^(BOOL finished) {
            self.currentView = self.viewController.view;
        }];
    }
}

- (void)registerViewWith:(NSString *)phone andIn:(BOOL)isIn
{
//    RegisterViewController *registerView = [[RegisterViewController alloc]init];
    self.registerView.cellPhoneNum = phone;
    __block typeof(self) weakSelf = self;
    self.registerView.backToCodeButtonClicked = ^(NSUInteger index) {
        [weakSelf changeGetCodeViewIn:NO];
    };
    self.registerView.registerSuccessed = ^(NSUInteger index) {
        weakSelf.loginSuccessed(1);
    };
    self.viewController = self.registerView;
    UIViewAnimationOptions animation = isIn ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown;
    if (self.currentView != self.viewController.view) {
        self.viewController.view.frame = self.currentView.frame;
        [UIView transitionFromView:self.currentView toView:self.viewController.view duration:0.5f options:animation completion:^(BOOL finished) {
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
