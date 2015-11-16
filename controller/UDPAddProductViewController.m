//
//  UDPAddProductViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UDPAddProductViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "DeviceManagerViewController.h"
#import "Sniffer.h"
#import "UDPController.h"
#import "AppDelegate.h"
#import "DeviceListViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <netdb.h>
#import "HFSmtlkV30.h"

#include <net/if.h>
#import <dlfcn.h>

@interface UDPAddProductViewController ()<UITextFieldDelegate,UIAlertViewDelegate,EventListener,UDPControllerDelegate>
{
    Sniffer *sniffer;
    UDPController *udpController;
    dispatch_queue_t   queue;
    NSInteger   times;
    //double
    NSInteger DoubleTimes;
    NSInteger findTimes;
    BOOL isfinding ;
    HFSmtlkV30 *smtlk;
    int smtlkState;

}
@property (nonatomic,strong) UITextField *textFiledName;
@property (nonatomic,strong) UITextField *textFiledPassWord;
@property (nonatomic, assign) BOOL noReceiveData;
@property (nonatomic,assign) CGFloat keyBoardHeight;


@end

@implementation UDPAddProductViewController

- (void)viewDidLoad {
    self.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
    if ([[self.productUUID substringToIndex:3]isEqualToString:@"845"]) {
        //硬件的初始化
        sniffer = [[Sniffer alloc]init];
        sniffer.delegate = self;
        //udp启动
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        udpController = app.udpController;
        udpController.delegate = self;
        //
        self.noReceiveData = YES;
    }else{
        smtlkState= 0;
        smtlk=[[HFSmtlkV30 alloc] initWithDelegate:self];
    }
    
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
    titleLabel.text = @"激活设备";
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
    if ([[self.productUUID substringToIndex:3]isEqualToString:@"845"]) {
        self.noReceiveData = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.noReceiveData) {
                [self stopUDPAndAgain];
            }
        });
        //这里是调用不同的硬件设备
        NSError *error =[sniffer startSniffer:[self fetchSSIDInfo] password:self.textFiledPassWord.text];
        if (error) {
            [MMProgressHUD dismiss];
            [ShowAlertView showAlert:[NSString stringWithFormat:@"硬件报错%@",error.localizedDescription]];
        }
    }else{
        if (smtlkState== 0)
        {
            smtlkState= 1;
            times= 0;
            findTimes= 0;
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
}
#pragma mark 江波龙硬件设备配置
//激活设备超时提示
- (void)stopUDPAndAgain
{
    [self stopSniffer];
    self.noReceiveData = NO;
    [MMProgressHUD dismissWithError:@"激活超时,请重试" afterDelay:2];
}
//江波龙硬件配置
- (void)getInfo:(NSString*)ip
{
    BOOL isOK = NO;
    
    int  sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock != -1)
    {
        int bOptVal= 1;
        if (setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (const char*)&bOptVal, sizeof(int)))
        {
            NSLog(@"socket option  SO_BROADCAST not support\n");
            
            close(sock);
            return;
        }
        
        struct timeval tv;
        tv.tv_sec = 2;
        tv.tv_usec = 0;
        if(setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv))<0){
            NSLog(@"socket option  SO_RCVTIMEO not support\n");
            close(sock);
            return;
        }
        
        char *findString = "Content-Length:52;{\"cmd\":\"DeviceFind\",\"at\":\"2015-05-18T01:15:43+0800\"}";
        
        char buffer[256] = {0};
        long ret = -1;
        struct sockaddr_in addr;
        unsigned int addr_len =sizeof(struct sockaddr_in);
        /*填写sockaddr_in 结构*/
        bzero ( &addr, sizeof(addr) );
        addr.sin_family=AF_INET;
        addr.sin_port = htons(8000);
        addr.sin_addr.s_addr=inet_addr((char*)[ip UTF8String]) ;
        
        times ++;
        
        ret = sendto(sock, findString, strlen(findString), 0, (struct sockaddr *)&addr, addr_len);
        
        if (ret == -1)
        {
            NSLog(@"errno=%i", errno);
            NSString *recString = [NSString stringWithFormat:@"sendto %ld error: %s", times,  strerror(errno)];
            dispatch_async(dispatch_get_main_queue(), ^(){
                HaviLog(@"发送错误%@",recString);
            });
            
            //错误处理 是否再次发送find
        }
        else
        {
            ret = recvfrom(sock, buffer, sizeof(buffer), 0, (struct sockaddr *)&addr, &addr_len);
            if (ret != -1)
            {
                NSString *recString = [NSString stringWithFormat:@"receive %ld:%s",times, buffer];
                NSLog(@"设备激活成功%@", recString);
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                        [self.view makeToast:@"设备激活成功" duration:2 position:@"center"];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                    [MMProgressHUD dismiss];
                });
                //havi
                self.noReceiveData = NO;
                //成功 不再发送find
                isOK = YES;
            }
            else
            {
                NSString *recString = [NSString stringWithFormat:@"recvfrom (%ld) error: %s", (long)times, strerror(errno)];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [MMProgressHUD dismiss];
                    [self.view makeToast:recString duration:2 position:@"center"];
                });
                
                //错误处理 是否再次发送find
            }
        }
        
        
        close(sock);
        
        // 30次之内
        if ((!isOK) && (times < 30))
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
                [self getInfo:ip];
            });
        }
        if (times>30||times==30) {
            [self stopSniffer];
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self.view makeToast:@"激活失败" duration:2 position:@"center"];
            }];
            
        }
    }
    
    
}
//停止配置设备
-(void)stopSniffer{
    //停止配置设备 如果不停止会一直在配置
    [sniffer stopSniffer];
}

#pragma mark 江波龙硬件回调
//设备配置成功 回调函数 获得设备的 ip 地址
- (void)onDeviceOnline:(NSString*)ip{
    [self stopSniffer];
    sniffer = nil;
    HardWareIP = ip;
    //江波龙
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
        [self getInfo:ip];
    });
}

#pragma mark controller
/*
//广播寻找设备
-(void)findWukoon{
    
    if (HardWareIP) {
        [udpController findWukoonWithIp:HardWareIP];//对设备ip发寻找包
    }else{
        [udpController findWukoonWithBroadcast];//广播发寻找包寻找设备
    }
}
 */


#pragma mark 江波龙接收

-(void)udpReceiveDataString:(NSString *)string{
    //接收到udp包后，将标识位改为no
    self.noReceiveData = NO;
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
}
/*
-(void)findWukoonWithIp:(NSString *)ip{
    [udpController findWukoonWithIp:ip];
}
 */
- (void)cancelButtonDone:(UIButton *)button
{
    //    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
    /*
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[DeviceManagerViewController class]]) {
            
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
     */
}

#pragma 双人床垫设备配置

// do smartLink
- (void)startSmartLink
{
    [smtlk SmtlkV30StartWithKey:self.textFiledPassWord.text];
}

- (void)stopSmartLink
{
    [MMProgressHUD dismiss];
    [smtlk SmtlkV30Stop];
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
//        if ([macArray count]== 0)
//            [self showTimeout];
//        [_butConnect setTitle:@"开始连接" forState:UIControlStateNormal];
        return;
    }
    
    [smtlk SendSmtlkFind];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(SmtlkTimeOut) userInfo:nil repeats:NO];
}

// SmartLink delegate
- (void)SmtlkV30Finished
{
    if (DoubleTimes < 2)
    {
        NSLog(@"smtlk second start");
        DoubleTimes++;
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
//    NSInteger macNum=[macArray count];
//    NSInteger i;
//    for (i= 0; i< macNum; i++)
//    {
//        if ([mac isEqualToString:macArray[i]])
//            return;
//    }
//    [macArray addObject:mac];
    NSString* msg = [@"smart_config " stringByAppendingString:mac];
    NSLog(@"msg %@",msg);
    // 让模块停止发送信息。
    isfinding = NO;
    
    [smtlk SendSmartlinkEnd:msg moduelIp:host];
    [self showLogMac:mac fromhost:host];
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
}
//end
- (void)showLogMac:(NSString *)mac fromhost:(NSString *)host
{
//    _lblLog.text=mac;
//    _lblLogIp.text = host;
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         [_viewLog setAlpha:1.0f];
//                     }
//                     completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.5
//                                               delay:1.0
//                                             options:UIViewAnimationOptionCurveEaseOut
//                                          animations:^{
//                                              [_viewLog setAlpha:0.0f];
//                                          }
//                                          completion:^(BOOL finished) {
//                                          }];
//                     }];
}

//- (void)showTimeout
//{
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         [_viewTimeout setAlpha:1.0f];
//                     }
//                     completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.5
//                                               delay:1.0
//                                             options:UIViewAnimationOptionCurveEaseOut
//                                          animations:^{
//                                              [_viewTimeout setAlpha:0.0f];
//                                          }
//                                          completion:^(BOOL finished) {
//                                          }];
//                     }];
//}
//

#pragma mark 键盘事件
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    self.keyBoardHeight = height;
    CGFloat  bottomLine = self.textFiledPassWord.frame.origin.y + self.textFiledPassWord.frame.size.height;
    CGRect rect = self.view.frame;
    rect.origin.y = -self.keyBoardHeight + (rect.size.height - bottomLine);
    if (rect.origin.y<0) {
        self.view.frame = rect;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
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
