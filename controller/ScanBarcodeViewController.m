
//
//  RootViewController.m
//  NewProject
//
//  Created by 学鸿 张 on 13-11-29.
//  Copyright (c) 2013年 Steven. All rights reserved.
//

#import "ScanBarcodeViewController.h"
#import "AddProductViewController.h"
#import "UDPAddProductViewController.h"
#import "DeviceManagerViewController.h"
#import "BindingDeviceUUIDAPI.h"
#import "ActiveDeviceAPI.h"

@interface ScanBarcodeViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UITextField *barTextfield;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,assign) CGFloat keyBoardHeight;

@end

@implementation ScanBarcodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImageView.image = nil;
    self.view.backgroundColor = [UIColor colorWithRed:0.188f green:0.184f blue:0.239f alpha:1.00f];
    num = 0;
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(44);
    }];
    titleLabel.font = DefaultWordFont;
    titleLabel.text = @"添加设备序列号";
    titleLabel.textColor = [UIColor whiteColor];
    //定义背景
    _imageView = [[UIImageView alloc]init];
    _imageView.image = [UIImage imageNamed:@"pic_scan_mirror"];
    [self.view addSubview:_imageView];
    [_imageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(69);
        if (ISIPHON6) {
            make.width.equalTo(_imageView.height);
        }else{
            make.width.equalTo(self.view.frame.size.width-40);
        }
        make.centerX.equalTo(self.view.centerX);
    }];
    //扫描线
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] init];
    _line.image = [UIImage imageNamed:@"scan_line"];
    [_imageView addSubview:_line];
    [_line makeConstraints:^(MASConstraintMaker *make) {
       make.edges.equalTo(_imageView).insets(UIEdgeInsetsMake(10, 10, 20, 20));
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    //
    UILabel *showTitle = [[UILabel alloc]init];
    [self.view addSubview:showTitle];
    [showTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(_imageView.bottom).offset(10);
        make.height.equalTo(ButtonHeight+20);
    }];
    showTitle.numberOfLines = 0;
    showTitle.textAlignment = NSTextAlignmentCenter;
    showTitle.text = @"请扫描设备二维码\n或者\n输入设备序列号";
    showTitle.textColor = [UIColor whiteColor];
    //
    [self.view addSubview:self.barTextfield];
    [_barTextfield makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(showTitle.bottom).offset(10);
        make.height.equalTo(ButtonHeight);
        make.width.equalTo(self.view.frame.size.width-40);
    }];
    //
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:nextButton];
    [nextButton setTitle:@"关联设备" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(addProduct:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_save_settings_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 0;
    nextButton.layer.masksToBounds = YES;
    [nextButton.titleLabel setFont:DefaultWordFont];
    [nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.top.equalTo(_barTextfield.bottom).offset(20);
        make.height.equalTo(ButtonHeight);
        make.width.equalTo(_barTextfield.width);
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
        make.width.equalTo(_barTextfield.width);
        make.bottom.equalTo(self.view).offset(-20);
    }];

    
}

- (UITextField *)barTextfield
{
    if (!_barTextfield) {
        _barTextfield = [[UITextField alloc]init];
        _barTextfield.borderStyle = UITextBorderStyleNone;
//        _barTextfield.layer.borderColor = [UIColor whiteColor].CGColor;
//        _barTextfield.layer.borderWidth = 1;
        _barTextfield.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_hollow_%d",selectedThemeIndex]];
        _barTextfield.backgroundColor = [UIColor clearColor];
        _barTextfield.layer.cornerRadius = 0;
        _barTextfield.textAlignment = NSTextAlignmentCenter;
        NSDictionary *boldFont = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:DefaultWordFont};
        NSAttributedString *attrValue = [[NSAttributedString alloc] initWithString:@"请输入设备序列号" attributes:boldFont];
        _barTextfield.attributedPlaceholder = attrValue;
        _barTextfield.textColor = [UIColor whiteColor];
        _barTextfield.delegate = self;
    }
    return _barTextfield;
}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;

        _line.frame = CGRectMake(20, num,_imageView.frame.size.width-40, 2);
        if (num == self.imageView.frame.size.height-10) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(20, num, _imageView.frame.size.width-40, 2);
        if (num == 10) {
            upOrdown = NO;
        }
    }

}

-(void)backSuperView:(UIButton *)sender
{
    [timer invalidate];
    [_session stopRunning];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark view 函数
-(void)viewWillAppear:(BOOL)animated
{
//    [self setupCameraWith];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (SIMULATOR==1) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"不能在模拟器使用" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self setupCameraWith];
        if (![timer isValid]) {
            num = 0;
            upOrdown = NO;
            [_imageView addSubview:_line];
            [_line makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_imageView).insets(UIEdgeInsetsMake(10, 10, 20, 20));
            }];
            timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
            
        }
    }
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_session stopRunning];
    [timer invalidate];
    timer = nil;
    [_line removeFromSuperview];
}

- (void)setupCameraWith
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc]init];
    }
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    
    //Start
    [self.session startRunning];
    
}

#pragma mark setter method

- (AVCaptureSession *)session
{
    if (!_session) {
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        //条码类型 AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        // Preview
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        CGRect newRect = _imageView.bounds;
        newRect.size.height -= 25;
        newRect.size.width -= 25;
        newRect.origin.x = 12.5;
        newRect.origin.y = 12.5;
        _preview.frame = newRect;
        [_imageView.layer insertSublayer:self.preview atIndex:0];
    }
    return _session;
}

#pragma mark textdelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.barTextfield setReturnKeyType:UIReturnKeyDone];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.barTextfield resignFirstResponder];
    return YES;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
   
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        self.barTextfield.text = stringValue;
    }
}

#pragma mark user action
- (void)addProduct:(UIButton *)sender
{
//    UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
//    udp.productName = self.deviceName;
//    udp.productUUID = self.barTextfield.text;
//    [self.navigationController pushViewController:udp animated:YES];
    if (self.barTextfield.text.length == 0) {
        [ShowAlertView showAlert:@"请输入或者扫描设备二维码"];
        return;
    }
    [self bindingDeviceWithUUID:self.barTextfield.text];
}
//进行设备关联
#pragma mark 绑定硬件

- (void)bindingDeviceWithUUID:(NSString *)UUID
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"关联设备中..."];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": self.barTextfield.text,
                           @"Description":self.deviceName,
                           };
    BindingDeviceUUIDAPI *client = [BindingDeviceUUIDAPI shareInstance];
    [client bindingDeviceUUID:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"绑定设备结果是%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [self activeUUID:self.barTextfield.text];
        }else if([[resposeDic objectForKey:@"ReturnCode"]intValue]==10008){
            [MMProgressHUD dismissWithSuccess:@"不存在该硬件,请核对设备ID" title:nil afterDelay:2];
        }else{
            [MMProgressHUD dismissWithSuccess:[resposeDic objectForKey:@"ErrorMessage"] title:nil afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithSuccess:[NSString stringWithFormat:@"%@",resposeDic] title:nil afterDelay:2];
    }];
}
//激活
- (void)activeUUID:(NSString *)UUID
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
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
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"已成功关联您的设备,是否需要现在激活设备？" delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"激活", nil];
            [alertView show];
        }else{
            [ShowAlertView showAlert:@"无法设置该设备为您的默认设备"];
        }
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [self.view makeToast:[NSString stringWithFormat:@"%@",resposeDic] duration:2 position:@"center"];
    }];
}


#pragma mark 键盘事件
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    self.keyBoardHeight = height;
    CGFloat  bottomLine = self.barTextfield.frame.origin.y + self.barTextfield.frame.size.height;
    CGRect rect = self.view.frame;
    rect.origin.y = -self.keyBoardHeight + (rect.size.height - bottomLine);
    self.view.frame = rect;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
}

#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"提示"]) {
        if (buttonIndex == 0) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[DeviceManagerViewController class]]) {
                    
                    [self.navigationController popToViewController:controller animated:YES];
                    //泡个消息，让首界面更新数据
                    [[NSNotificationCenter defaultCenter]postNotificationName:POSTDEVICEUUIDCHANGENOTI object:nil];
                    break;
                }
            }

        }else if (buttonIndex == 1){
            UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
            udp.productName = self.deviceName;
            udp.productUUID = self.barTextfield.text;
            [self.navigationController pushViewController:udp animated:YES];

        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
