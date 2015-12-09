
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
#import "DeviceListViewController.h"
#import "BindingDeviceUUIDAPI.h"
#import "ActiveDeviceAPI.h"
#import "URBAlertView.h"
#import "MMPopupItem.h"
#import "NameDoubleViewController.h"

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
    self.navigationController.navigationBarHidden = YES;
    self.bgImageView.image = [UIImage imageNamed:@""];
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
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (SIMULATOR==1) {
        [self.view makeToast:@"不能在模拟器中使用" duration:2 position:@"center"];
    }else{
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            MMPopupItemHandler block = ^(NSInteger index){
                HaviLog(@"clickd %@ button",@(index));
            };
            NSArray *items =
            @[MMItemMake(@"确定", MMItemTypeNormal, block)];
            
            MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                                 detail:@"请在设置中打开照相机权限或者手动输入设备序列号" items:items];
            alertView.attachedView = self.view;
            
            [alertView show];
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
#define kKeyboardHeight 216

int prewTag;
float prewMoveY;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFrame = self.barTextfield.frame;
    float textY = textFrame.origin.y + textFrame.size.height;
    float bottomY = self.view.frame.size.height - textY;
    if (bottomY >= kKeyboardHeight){
        prewTag = -1;
        return;
    }
    prewTag = (int)textField.tag;
    float moveY = kKeyboardHeight - bottomY+40;
    prewMoveY = moveY;
    
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    frame.origin.y -=moveY;//view的Y轴上移
    frame.size.height +=moveY; //View的高度增加
    self.view.layer.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.layer.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    //    查看回复头像
    if(prewTag == -1) //当编辑的View不是需要移动的View
    {
        return;
    }
    float moveY ;
    NSTimeInterval animationDuration = 0.80f;
    CGRect frame = self.view.frame;
    if(prewTag == textField.tag) //当结束编辑的View的TAG是上次的就移动
    {   //还原界面
        moveY =  prewMoveY;
        frame.origin.y +=moveY;
        frame.size. height -=moveY;
        self.view.frame = frame;
    }
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.layer.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    
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
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Button29" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
        AudioServicesPlaySystemSound(soundId);
        self.barTextfield.text = stringValue;
        [self.session stopRunning];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.session startRunning];
        });
        [self checkIsDoubleBed:self.barTextfield.text];
        
    }
}

- (BOOL)checkIsDoubleBed:(NSString *)deviceUUID
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorInfo?UUID=%@",deviceUUID];
    
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"当前用户%@设备信息%@",thirdPartyLoginUserId,resposeDic);
        
        if ([[[resposeDic objectForKey:@"SensorInfo"]objectForKey:@"DetailSensorInfo"] count]>1) {
            NameDoubleViewController *doubleBed = [[NameDoubleViewController alloc]init];
            doubleBed.barUUIDString = self.barTextfield.text;
            doubleBed.doubleDeviceName = self.deviceName;
            doubleBed.dicDetailDevice = [resposeDic objectForKey:@"SensorInfo"];
            [self.navigationController pushViewController:doubleBed animated:YES];
        }else{
            [self bindingDeviceWithUUID:self.barTextfield.text];
        }
        //
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
    }];
    return YES;
}

#pragma mark user action
- (void)addProduct:(UIButton *)sender
{
    if (self.barTextfield.text.length == 0) {
        [self.view makeToast:@"请输入或者扫描设备二维码" duration:2 position:@"center"];
        return;
    }
    [self checkIsDoubleBed:self.barTextfield.text];
}
//进行设备关联
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
        }else if ([[resposeDic objectForKey:@"ReturnCode"] intValue]==10033){
            [MMProgressHUD dismiss];
            [self.view makeToast:@"您已经绑定该设备,请换台设备!" duration:2 position:@"center"];
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
            thirdHardDeviceUUID = UUID;
            thirdHardDeviceName = self.deviceName;
            thirdLeftDeviceUUID = @"";
            thirdRightDeviceUUID = @"";
            thirdLeftDeviceName = @"";
            thirdRightDeviceName = @"";
            isMineDevice = @"YES";
            [UserManager setGlobalOauth];
            [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICEUUID object:nil];
            MMPopupItemHandler block = ^(NSInteger index){
                if (index == 1) {
                    UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
                    udp.productName = self.deviceName;
                    thirdHardDeviceUUID = self.barTextfield.text;
                    udp.productUUID = self.barTextfield.text;
                    [self.navigationController pushViewController:udp animated:YES];
                }else if (index ==0){
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[DeviceListViewController class]]) {
                            
                            [self.navigationController popToViewController:controller animated:YES];
                            //泡个消息，让首界面更新数据
                            thirdHardDeviceUUID = self.barTextfield.text;
                            break;
                        }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
