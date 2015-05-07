//
//  AddProductViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "AddProductViewController.h"
#import "UDPAddProductViewController.h"
#import "ScanBarcodeViewController.h"

@interface AddProductViewController ()

@end

@implementation AddProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.259f green:0.259f blue:0.259f alpha:1.00f];
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(40);
    }];
    titleLabel.text = @"添加设备";
    titleLabel.textColor = [UIColor whiteColor];
//
    UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
    [self.view addSubview:imageLine];
    imageLine.alpha = 0.5;
    [imageLine makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.view).offset(-5);
        make.height.equalTo(1);
        make.centerY.equalTo(self.view.centerY);
    }];
//
    UIButton *buttonUDP = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonUDP];
    [buttonUDP setBackgroundColor:[UIColor colorWithRed:0.102f green:0.780f blue:0.016f alpha:1.00f]];
    buttonUDP.layer.cornerRadius = 5;
    buttonUDP.layer.masksToBounds = YES;
    [buttonUDP setTitle:@"广播获取" forState:UIControlStateNormal];
    [buttonUDP addTarget:self action:@selector(useUDPAdd:) forControlEvents:UIControlEventTouchUpInside];
    [buttonUDP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonUDP makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(imageLine.centerY).offset(-52);
    }];
//
    UIButton *buttonSDK = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonSDK];
    [buttonSDK setBackgroundColor:[UIColor colorWithRed:0.102f green:0.780f blue:0.016f alpha:1.00f]];
    buttonSDK.layer.cornerRadius = 5;
    buttonSDK.layer.masksToBounds = YES;
    [buttonSDK setTitle:@"SDK获取" forState:UIControlStateNormal];
    [buttonSDK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSDK makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(buttonUDP.centerY).offset(-64);
    }];
//
    UILabel *sectionTitleLabel = [[UILabel alloc]init];
    [self.view addSubview:sectionTitleLabel];
    sectionTitleLabel.textColor = [UIColor whiteColor];
    sectionTitleLabel.text = @"我是设备的使用者";
    [sectionTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(buttonSDK.centerY).offset(-54);
    }];
//
    UILabel *sectionTitleLabel1 = [[UILabel alloc]init];
    [self.view addSubview:sectionTitleLabel1];
    sectionTitleLabel1.textColor = [UIColor whiteColor];
    sectionTitleLabel1.text = @"我不是设备的使用者";
    [sectionTitleLabel1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(imageLine.centerY).offset(24);
    }];
//
    UIButton *lookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:lookButton];
    [lookButton setBackgroundColor:[UIColor colorWithRed:0.102f green:0.780f blue:0.016f alpha:1.00f]];
    lookButton.layer.cornerRadius = 5;
    lookButton.layer.masksToBounds = YES;
    [lookButton setTitle:@"我只安静的看看" forState:UIControlStateNormal];
    [lookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lookButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(sectionTitleLabel1.centerY).offset(54);
    }];
//
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelButton];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:0.510f green:0.510f blue:0.510f alpha:1.00f]];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.layer.masksToBounds = YES;
    [cancelButton setTitle:@"暂时不添加" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(44);
        make.centerY.equalTo(lookButton.centerY).offset(64);
    }];
    
}

- (void)useUDPAdd:(UIButton *)button
{
    UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
    [self.navigationController pushViewController:udp animated:YES];
}

- (void)cancelButtonDone:(UIButton *)button
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
