//
//  NameDoubleViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/13.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "NameDoubleViewController.h"
#import "BindingDeviceUUIDAPI.h"
#import "ActiveDeviceAPI.h"
#import "MMPopupItem.h"
#import "UDPAddProductViewController.h"

@interface NameDoubleViewController ()

@end

@implementation NameDoubleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubView];
}

- (void)initSubView
{
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor colorWithRed:0.188f green:0.184f blue:0.239f alpha:1.00f];
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(44);
    }];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = @"命名左右床垫名称";
    titleLabel.textColor = [UIColor whiteColor];
    //
    UILabel *deviceLabel = [[UILabel alloc]init];
    [self.view addSubview:deviceLabel];
    [deviceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(titleLabel.bottom).offset(10);
        make.height.equalTo(44);
    }];
    deviceLabel.font = DefaultWordFont;
    deviceLabel.text = self.doubleDeviceName;
    deviceLabel.textColor = [UIColor whiteColor];
    //
    UIImageView *bgView = [[UIImageView alloc]init];
    bgView.image = [UIImage imageNamed:@"double_bed"];
    [self.view addSubview:bgView];
    bgView.layer.cornerRadius = 10;
    bgView.layer.masksToBounds = YES;
    bgView.userInteractionEnabled = YES;
    bgView.layer.borderColor = [UIColor whiteColor].CGColor;
    bgView.layer.borderWidth = 1;
    [bgView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deviceLabel.bottom).offset(10);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(200);
    }];
    //
    UIView *lineView = [[UIView alloc]init];
    [bgView addSubview:lineView];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bgView.centerX);
        make.width.equalTo(2);
        make.top.equalTo(bgView.top);
        make.bottom.equalTo(bgView.bottom);
    }];
    //
    UITextField *leftText = [[UITextField alloc]init];
    [bgView addSubview:leftText];
    leftText.text = @"Left";
    leftText.layer.borderWidth = 0.5;
    leftText.layer.cornerRadius = 5;
    leftText.layer.masksToBounds = YES;
    leftText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    leftText.textAlignment = NSTextAlignmentLeft;
    leftText.borderStyle = UITextBorderStyleNone;
    leftText.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    leftImage.image = [UIImage imageNamed:@"edit_double_bed"];
    [bgView addSubview:leftImage];
//    leftText.leftView = leftImage;
    
    //
    UITextField *rightText = [[UITextField alloc]init];
    [bgView addSubview:rightText];
    rightText.textAlignment = NSTextAlignmentLeft;
    rightText.layer.borderWidth = 0.5;
    rightText.layer.cornerRadius = 5;
    rightText.layer.masksToBounds = YES;
    rightText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    rightText.text = @"Right";
    rightText.leftViewMode = UITextFieldViewModeAlways;
    rightText.borderStyle = UITextBorderStyleNone;
    UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    rightImage.image = [UIImage imageNamed:@"edit_double_bed"];
    [bgView addSubview:rightImage];
//    rightText.leftView = rightImage;
    //
    [leftText makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgView.centerY);
        make.height.equalTo(25);
        make.left.equalTo(bgView.left).offset(10);
    }];
    [rightText makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgView.centerY);
        make.height.equalTo(25);
        make.left.equalTo(lineView.right).offset(10);
        make.right.equalTo(rightImage.left).offset(-5);
    }];
    //
    [leftImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftText.right).offset(5);
        make.right.equalTo(lineView.left).offset(-10);
        make.height.equalTo(20);
        make.width.equalTo(20);
        make.centerY.equalTo(leftText.centerY);
    }];
    [rightImage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightText.right).offset(5);
        make.right.equalTo(bgView.right).offset(-10);
        make.height.equalTo(20);
        make.width.equalTo(20);
        make.centerY.equalTo(leftText.centerY);
    }];
    
    //
    //
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:nextButton];
    [nextButton setTitle:@"保存" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(addProduct:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_save_settings_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 0;
    nextButton.layer.masksToBounds = YES;
    [nextButton.titleLabel setFont:DefaultWordFont];
    [nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(bgView.bottom).offset(40);
        make.height.equalTo(ButtonHeight);
        make.width.equalTo(bgView.width);
    }];
    //返回
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:backButton];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitle:@"暂时不关联" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backSuperView:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_hollow_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 0;
    backButton.layer.masksToBounds = YES;
    [backButton.titleLabel setFont:DefaultWordFont];
    [backButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(nextButton.bottom).offset(20);
        make.height.equalTo(ButtonHeight);
        make.width.equalTo(bgView.width);
//        make.bottom.equalTo(self.view).offset(-20);
    }];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoardView)];
//    [self.view addGestureRecognizer:tap];
    
}

- (void)addProduct:(UIButton *)sender
{
    [self bindingDeviceWithUUID:nil];
}

-(void)backSuperView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 绑定硬件

- (void)bindingDeviceWithUUID:(NSString *)UUID
{
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": self.barUUIDString,
                           @"Description":self.doubleDeviceName,
                           };
    BindingDeviceUUIDAPI *client = [BindingDeviceUUIDAPI shareInstance];
    [client bindingDeviceUUID:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"绑定设备结果是%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [self activeUUID:self.barUUIDString];
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10008){
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self.view makeToast:@"不存在该硬件,请核对设备ID" duration:2 position:@"center"];
            }];
        }else{
            [MMProgressHUD dismissWithSuccess:[resposeDic objectForKey:@"ErrorMessage"] title:nil afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}
//激活
- (void)activeUUID:(NSString *)UUID
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": UUID,
                           };
    ActiveDeviceAPI *client = [ActiveDeviceAPI shareInstance];
    [client activeDevice:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            HardWareUUID = UUID;
            MMPopupItemHandler block = ^(NSInteger index){
                if (index == 1) {
                    UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
                    udp.productName = @"LI";//测试
                    HardWareUUID = self.barUUIDString;
                    udp.productUUID = self.barUUIDString;
                    [self.navigationController pushViewController:udp animated:YES];
                }else if (index ==0){
                    for (UIViewController *controller in self.navigationController.viewControllers) {
//                        if ([controller isKindOfClass:[DeviceManagerViewController class]]) {
//                            
//                            [self.navigationController popToViewController:controller animated:YES];
//                            //泡个消息，让首界面更新数据
//                            HardWareUUID = self.barUUIDString;
//                            break;
//                        }
                    }
                    
                }
            };
            NSArray *items =
            @[MMItemMake(@"暂不激活", MMItemTypeNormal, block),
              MMItemMake(@"激活", MMItemTypeNormal, block)];
            
            MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                                 detail:@"已成功关联您的设备,是否需要现在激活设备" items:items];
            alertView.attachedView = self.view;
            
            [alertView show];
        }else{
            [self.view makeToast:@"无法设置该设备为您的默认设备" duration:2 position:@"center"];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
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
