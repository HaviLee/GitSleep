//
//  LoginViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LoginViewController.h"
#import "CKTextField.h"
#import "RegisterViewController.h"
#import "LabelLine.h"
#import "GetCodeViewController.h"
#import "STAlertView.h"
#import "ZWIntroductionViewController.h"
#import "LeftSideViewController.h"
#import "RightSideViewController.h"
#import "CenterSideViewController.h"
#import "AppDelegate.h"
//api
#import "SHGetClient.h"
#import "GetInavlideCodeApi.h"
#import "SHPutClient.h"
#import "GetDeviceStatusAPI.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) CKTextField *nameText;
@property (nonatomic,strong) UITextField *passWordText;
@property (nonatomic, strong) STAlertView *stAlertView;
@property (nonatomic, strong) ZWIntroductionViewController *introductionView;

@property (nonatomic,strong)  NSString *cellPhone;
@property (assign,nonatomic)  int forgetPassWord;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keybordView = self.view;
    // Do any additional setup after loading the view.
//    logo
//    self.bgImageView.image = [UIImage imageNamed:@"pic_login_bg"];
    int picIndex = [QHConfiguredObj defaultConfigure].nThemeIndex;
    NSString *imageName = [NSString stringWithFormat:@"icon_logo_login_%d",picIndex];
    UIImageView *logoImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
    [self.view addSubview:logoImage];
    self.nameText = [[CKTextField alloc]init];
    [self.nameText setMaxLength:@"5"];
    [self.view addSubview:self.nameText];
    self.passWordText = [[UITextField alloc]init];
    [self.view addSubview:self.passWordText];
    self.nameText.delegate = self;
    self.passWordText.delegate = self;
    [self.nameText setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor grayColor]];
    self.passWordText.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    self.nameText.borderStyle = UITextBorderStyleNone;
    self.passWordText.borderStyle = UITextBorderStyleNone;
    self.nameText.font = DefaultWordFont;
    self.passWordText.font = DefaultWordFont;
    
    NSDictionary *boldFont = @{NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor grayColor],NSFontAttributeName:DefaultWordFont};
    NSAttributedString *attrValue = [[NSAttributedString alloc] initWithString:@"电话号码" attributes:boldFont];
    NSAttributedString *attrValue1 = [[NSAttributedString alloc] initWithString:@"密码" attributes:boldFont];
    self.nameText.attributedPlaceholder = attrValue;
    self.passWordText.attributedPlaceholder = attrValue1;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userName"]) {
        self.nameText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userPassword"]) {
        self.passWordText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"userPassword"];
    }
    if (isLogout) {
        self.nameText.text = @"";
        self.passWordText.text = @"";
        
    }
    self.nameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passWordText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameText.keyboardType = UIKeyboardTypePhonePad;
    self.passWordText.keyboardType = UIKeyboardTypeAlphabet;
    self.passWordText.secureTextEntry = YES;
    //
    self.passWordText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
    self.nameText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
//
    int padding = (self.view.bounds.size.height/2 - 200)/3;
    [logoImage makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.bottom.equalTo(self.nameText.top).offset(-padding);
//        make.top.equalTo(self.view.top).offset(25);
        make.height.width.equalTo(100);
    }];
//
    [self.nameText makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.centerY.equalTo(self.passWordText.centerY).offset(-54);
        
    }];
//    
    [self.passWordText makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.centerY.equalTo(self.view.centerY).offset(-32);
    }];
//
//    添加小图标
    UIImageView *phoneImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"phone_%d",selectedThemeIndex]]];
    phoneImage.frame = CGRectMake(0, 0,30, 20);
    phoneImage.contentMode = UIViewContentModeScaleAspectFit;
    self.nameText.leftViewMode = UITextFieldViewModeAlways;
    self.nameText.leftView = phoneImage;
//
    UIImageView *passImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_password_%d",selectedThemeIndex]]];
    passImage.frame = CGRectMake(0, 0,30, 20);
    passImage.contentMode = UIViewContentModeScaleAspectFit;
    self.passWordText.leftViewMode = UITextFieldViewModeAlways;
    self.passWordText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passWordText.leftView = passImage;
    
//    添加button
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [loginButton setBackgroundColor:[UIColor colorWithRed:0.259f green:0.718f blue:0.686f alpha:1.00f]];
    [loginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_login_bg_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [loginButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = DefaultWordFont;
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.layer.cornerRadius = 0;
    loginButton.layer.masksToBounds = YES;
    [self.view addSubview:loginButton];
    
//txtbox_no_add_0@2x
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"txtbox_no_add_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [registerButton setTitle:@"还没有帐号" forState:UIControlStateNormal];
    registerButton.titleLabel.font = DefaultWordFont;
    [registerButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButton:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.layer.cornerRadius = 0;
    registerButton.layer.masksToBounds = YES;
    [self.view addSubview:registerButton];
    
//
    [loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.centerY.equalTo(self.view.centerY).offset(32);
    }];
    
    [registerButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.centerY.equalTo(loginButton.centerY).offset(54);
    }];
//
    LabelLine *forgetButton = [[LabelLine alloc]init];
    forgetButton.text = @"忘记密码?";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgetPassWord:)];
    forgetButton.userInteractionEnabled = YES;
    [forgetButton addGestureRecognizer:tap];
    forgetButton.backgroundColor = [UIColor clearColor];
    forgetButton.font = DefaultWordFont;
    forgetButton.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.view addSubview:forgetButton];
    [forgetButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(registerButton.bottom).offset(10);
        make.right.equalTo(self.view.right).offset(-20);
    }];
//
    //设置引导画面
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"firstInApp":@"YES"}];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"firstInApp"] isEqualToString:@"YES"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self setIntroduceView];
    }

}

- (void)setIntroduceView
{
    NSArray *coverImageNames = @[@"", @"", @""];
    NSArray *backgroundImageNames = @[@"pic_breathe_0", @"icon_heart_rate1_0", @"pic_sleep_0"];
    self.introductionView = [[ZWIntroductionViewController alloc] initWithCoverImageNames:coverImageNames backgroundImageNames:backgroundImageNames];
    __weak LoginViewController *weakSelf = self;
    [self.view addSubview:self.introductionView.view];
    self.introductionView.didSelectedEnter = ^() {
        [weakSelf.introductionView.view removeFromSuperview];
        weakSelf.introductionView = nil;
        HaviLog(@"引导ok");
        // enter main view , write your code ...
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"firstInApp"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    };
}

- (void)login:(UIButton *)sender
{
    if ([self.nameText.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入电话号码" duration:1.5 position:@"center"];
        return;
    }
    if ([self.passWordText.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入密码" duration:1.5 position:@"center"];
        return;
    }
    //获取设备状态
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"登录中..."];
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"CellPhone": self.nameText.text, //手机号码
                          @"Email": @"", //邮箱地址，可留空，扩展注册用
                          @"Password": self.passWordText.text //传递明文，服务器端做加密存储
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client loginUserWithHeader:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            NSString *userId = [resposeDic objectForKey:@"UserID"];
            GloableUserId = userId;
            [[NSUserDefaults standardUserDefaults]setObject:self.nameText.text forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSUserDefaults standardUserDefaults]setObject:self.passWordText.text forKey:@"userPassword"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            //
            if (!isLogout) {
                [MMProgressHUD dismissAfterDelay:0.3];
                [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                    [self loginView];
                }];
            }else{
                [MMProgressHUD dismissAfterDelay:0.3];
                [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEUSERID object:nil];
                    }];
                }];
            }
            
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10012) {
            
            [MMProgressHUD dismissWithError:@"密码或者帐号错误,请重试。" afterDelay:2];
        }else{
            [MMProgressHUD dismissWithError:@"登录失败,请稍后重试。" afterDelay:2];
        }
       
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:3];
    }];
    
}

#pragma mark 登录

- (void)loginView
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[CenterSideViewController alloc] init]];
    LeftSideViewController *leftMenuViewController = [[LeftSideViewController alloc] init];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:leftMenuViewController
                                                                   rightMenuViewController:nil];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:[NSDate date]]];
    NSString *sub = [nowDateString substringWithRange:NSMakeRange(11, 2)];
    if ([sub intValue]>7 && [sub intValue]<18) {
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_day"];
    }else{
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"pic_bg_night"];
    }
    sideMenuViewController.menuPreferredStatusBarStyle = 0; // UIStatusBarStyleLightContent
//    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = sideMenuViewController;
    /*
    XHDrawerController *drawerController = [[XHDrawerController alloc] init];
    drawerController.springAnimationOn = YES;
    
    LeftSideViewController *leftSideController = [[LeftSideViewController alloc]init];
    RightSideViewController *rightSideController = [[RightSideViewController alloc]init];
    CenterSideViewController *centerSideController = [[CenterSideViewController alloc]init];
    
    drawerController.leftViewController = leftSideController;
    drawerController.rightViewController = rightSideController;
    drawerController.centerViewController = [[UINavigationController alloc] initWithRootViewController:centerSideController];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MenuBackground"]];
    [backgroundImageView setContentMode:UIViewContentModeCenter];
    drawerController.backgroundView = backgroundImageView;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = drawerController;
     */
}

- (void)registerButton:(UIButton *)sender
{
    HaviLog(@"register");
    GetCodeViewController *code = [[GetCodeViewController alloc]init];
    [self.navigationController pushViewController:code animated:YES];
    
//  
}

- (void)forgetPassWord:(UITapGestureRecognizer *)gesture
{
    HaviLog(@"忘记密码");
    self.stAlertView = [[STAlertView alloc] initWithTitle:@"提示"
                                                  message:@"请输入手机号码,我们会将密码以短信的方式发到您的手机上。"
                                            textFieldHint:@"请输入手机号"
                                           textFieldValue:nil
                                        cancelButtonTitle:@"取消"
                                         otherButtonTitle:@"确定"
                        
                                        cancelButtonBlock:^{
                                            
                                        } otherButtonBlock:^(NSString * result){
                                            self.cellPhone = result;
                                            [self getPassWordSelf:result];
                                        }];
    
    //You can make any customization to the native UIAlertView
    self.stAlertView.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[self.stAlertView.alertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypePhonePad];
    
    [self.stAlertView show];
}
#pragma mark 获取验证码
- (void)getPassWordSelf:(NSString *)cellPhone
{
    if (cellPhone.length == 0) {
        [self.view makeToast:@"请输入手机号" duration:2 position:@"center"];
        return;
    }
    if (cellPhone.length != 11) {
        [self.view makeToast:@"请输入正确的手机号" duration:2 position:@"center"];
        return;
    }
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"发送中..."];
    self.forgetPassWord = [self getRandomNumber:100000 to:1000000];
    NSString *codeMessage = [NSString stringWithFormat:@"您的密码已经重置，新密码是%d,请及时修改您的密码。",self.forgetPassWord];
    NSDictionary *dicPara = @{
                              @"cell" : cellPhone,
                              @"codeMessage" : codeMessage,
                              };
    GetInavlideCodeApi *client = [GetInavlideCodeApi shareInstance];
    [client getInvalideCode:dicPara witchBlock:^(NSData *receiveData) {
        NSString *string = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSRange range = [string rangeOfString:@"<error>"];
        if ([[string substringFromIndex:range.location +range.length]intValue]==0) {
            [self modifyPassWord];
        }else{
            [MMProgressHUD dismissWithError:string afterDelay:2];
        }
    }];

}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (void)modifyPassWord
{
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": self.cellPhone, //关键字，必须传递
                          @"Password": [NSString stringWithFormat:@"%d",self.forgetPassWord], //密码
                        };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismissWithSuccess:@"新的密码已发送到您手机,请查收" title:@"注意" afterDelay:3];
            [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                self.passWordText.text = @"";
            }];
        }else{
            [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:3];
            self.passWordText.text = @"";
        }
    }failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:3];
    }];
}

#pragma mark textfeild delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.nameText]) {
        int height = self.view.bounds.size.height/2 + 108;
        self.keybordheight = height;
        [textField setReturnKeyType:UIReturnKeyNext];
        return YES;
    }else{
        int height = self.view.bounds.size.height/2 + 108;
        self.keybordheight = height;
        [textField setReturnKeyType:UIReturnKeyDone];
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameText]) {
        [self.passWordText becomeFirstResponder];
        if (textField.text.length >4) {
            CKTextField *text = (CKTextField *)textField;
            [text shake];
        }
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    HaviLog(@"进行");
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
