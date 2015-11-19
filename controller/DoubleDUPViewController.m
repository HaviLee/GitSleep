//
//  DoubleDUPViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/19.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleDUPViewController.h"
#import "DeviceListViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "DeviceManagerViewController.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "HFSmtlkV30.h"

#include <net/if.h>
#import <dlfcn.h>

@interface DoubleDUPViewController ()<UITextFieldDelegate>
{
    int smtlkState;
    int showKey;
    HFSmtlkV30 *smtlk;
    NSInteger times;
    NSInteger findTimes;
    BOOL isfinding ;
    NSMutableArray *macArray;
}
@property (nonatomic,strong) UITextField *textFiledName;
@property (nonatomic,strong) UITextField *textFiledPassWord;
@end

@implementation DoubleDUPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    smtlkState= 0;
    showKey= 1;
    smtlk=[[HFSmtlkV30 alloc] initWithDelegate:self];
    macArray=[[NSMutableArray alloc] init];
    self.navigationController.navigationBarHidden = YES;
    smtlkState= 0;
    smtlk=[[HFSmtlkV30 alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor colorWithRed:0.188f green:0.184f blue:0.239f alpha:1.00f];
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(40);
    }];
    titleLabel.text = @"双人激活设备";
    titleLabel.textColor = [UIColor whiteColor];
    //
    self.textFiledName = [[UITextField alloc]init];
    self.textFiledName.borderStyle = UITextBorderStyleNone;
    [self.view addSubview:self.textFiledName];
    self.textFiledPassWord = [[UITextField alloc]init];
    self.textFiledPassWord.borderStyle = UITextBorderStyleNone;
    [self.view addSubview:self.textFiledPassWord];
    self.textFiledName.backgroundColor = [UIColor colorWithRed:0.400f green:0.400f blue:0.400f alpha:1.00f];
    self.textFiledPassWord.backgroundColor = [UIColor colorWithRed:0.400f green:0.400f blue:0.400f alpha:1.00f];
    self.textFiledName.textColor = [UIColor whiteColor];
    self.textFiledPassWord.textColor = [UIColor whiteColor];
    self.textFiledName.delegate = self;
    self.textFiledPassWord.delegate = self;
    self.textFiledName.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFiledPassWord.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFiledName.keyboardType = UIKeyboardTypeAlphabet;
    self.textFiledPassWord.keyboardType = UIKeyboardTypeAlphabet;
    self.textFiledName.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_hollow_%d",selectedThemeIndex]];
    self.textFiledPassWord.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_hollow_%d",selectedThemeIndex]];
    //
    self.textFiledPassWord.placeholder = @"请输入密码";
    self.textFiledPassWord.textColor = [UIColor whiteColor];
    //增加左侧的空格
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)];
    UIView *leftView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 44)];
    self.textFiledName.leftViewMode = UITextFieldViewModeAlways;
    self.textFiledName.leftView = leftView1;
    self.textFiledPassWord.leftView = leftView;
    self.textFiledPassWord.leftViewMode = UITextFieldViewModeAlways;
    [self.textFiledPassWord makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(44);
        make.centerY.equalTo(self.view.centerY).offset(-30);
    }];
    self.textFiledPassWord.secureTextEntry = YES;
    //
    UILabel *passWordLabel = [[UILabel alloc]init];
    [self.view addSubview:passWordLabel];
    passWordLabel.textColor = [UIColor whiteColor];
    passWordLabel.text = @"请输入无线网络密码";
    [passWordLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(44);
        make.bottom.equalTo(self.textFiledPassWord.top).offset(0);
    }];
    
    //
    
    self.textFiledName.text = @"by001";
    [self.textFiledName makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(44);
        make.centerY.equalTo(passWordLabel.centerY).offset(-64);
    }];
    //
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.view addSubview:nameLabel];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = @"请输入需要的无线网络名称";
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(44);
        make.bottom.equalTo(self.textFiledName.top).offset(5);
    }];
    
    //
    UILabel *showLabel = [[UILabel alloc]init];
    [self.view addSubview:showLabel];
    showLabel.textColor = [UIColor whiteColor];
    showLabel.text = @"1.在使用前请确保床垫处于工作状态。\n2.请手动输入需要接入的无线网络名称和密码。";
    showLabel.numberOfLines = 0;
    [showLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.centerY.equalTo(self.view.centerY).offset(40);
    }];
    //
    UIButton *lookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:lookButton];
    [lookButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_save_settings_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    lookButton.layer.cornerRadius = 0;
    lookButton.layer.masksToBounds = YES;
    [lookButton setTitle:@"激活设备" forState:UIControlStateNormal];
    [lookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lookButton addTarget:self action:@selector(searchHardware:) forControlEvents:UIControlEventTouchUpInside];
    [lookButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(showLabel.centerY).offset(84);
    }];
    //
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelButton];
    [cancelButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_hollow_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    cancelButton.layer.cornerRadius = 0;
    cancelButton.layer.masksToBounds = YES;
    [cancelButton setTitle:@"暂时不激活" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(lookButton.centerY).offset(64);
    }];
    //
    
    //获取wifi的SSID
    [self fetchSSIDInfo];

}

#pragma mark text delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//获取ssid
- (NSString *)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    HaviLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        HaviLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    NSString *wifiName = [info objectForKey:@"SSID"];
    self.textFiledName.text = wifiName;
    HaviLog(@"wifi是%@",wifiName);
    return wifiName;
}

- (void)cancelButtonDone:(UIButton *)button
{
    //    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//搜索硬件UDP
- (void)searchHardware:(UIButton *)button
{
    if ([self.textFiledName.text isEqualToString:@""]||[self.textFiledPassWord.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入网络名或者密码" duration:2 position:@"center"];
        return;
    }
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    if (smtlkState== 0)
    {
        
        smtlkState= 1;
        times= 0;
        findTimes= 0;
        [macArray removeAllObjects];
        // start to do smtlk
        [self startSmartLink];
    }
    else
    {
        // stop smtlk
        [self stopSmartLink];
        smtlkState= 0;
        isfinding = NO;
    }
}

// do smartLink
- (void)startSmartLink
{
    [smtlk SmtlkV30StartWithKey:self.textFiledPassWord.text];
}

- (void)stopSmartLink
{
    [smtlk SmtlkV30Stop];
    [MMProgressHUD dismiss];
}

- (void)SmtlkTimeOut
{
    //findTimes++;
    // NSLog(@"smtlkTimeOut, %ld", findTimes);
    //if (findTimes== 20)
    if (!isfinding)
    {
        [self stopSmartLink];
        smtlkState= 0;
        if ([macArray count]== 0)
            [self.view makeToast:@"激活超时" duration:3 position:@"center"];
        return;
    }
    
    [smtlk SendSmtlkFind];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(SmtlkTimeOut) userInfo:nil repeats:NO];
}

// SmartLink delegate
- (void)SmtlkV30Finished
{
    if (times < 2)
    {
        NSLog(@"smtlk second start");
        times++;
        [self startSmartLink];
        findTimes= 0;
        isfinding = YES;
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(SmtlkTimeOut) userInfo:nil repeats:NO];
    }else{
        isfinding = NO;
        [self stopSmartLink];
    }
}

- (void)SmtlkV30ReceivedRspMAC:(NSString *)mac fromHost:(NSString *)host
{
    NSLog(@"Receive MAC:%@",mac);
    NSLog(@"Receive IP:%@",host);
    NSInteger macNum=[macArray count];
    NSInteger i;
    for (i= 0; i< macNum; i++)
    {
        if ([mac isEqualToString:macArray[i]])
            return;
    }
    [macArray addObject:mac];
    NSString* msg = [@"smart_config " stringByAppendingString:mac];
    NSLog(@"msg %@",msg);
    // 让模块停止发送信息。
    isfinding = NO;
    [smtlk SendSmartlinkEnd:msg moduelIp:host];
    [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
        [self.view makeToast:@"激活成功" duration:2 position:@"center"];
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[DeviceListViewController class]]) {
                
                [self.navigationController popToViewController:controller animated:YES];
                break;
            }
        }
    }];
    [MMProgressHUD dismiss];
    [self.view makeToast:@"激活成功" duration:3 position:@"center"];
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
