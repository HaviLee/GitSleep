//
//  LoginViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LoginViewController.h"
#import "CKTextField.h"
#import "LabelLine.h"
#import "GetCodeViewController.h"
#import "STAlertView.h"
#import "ZWIntroductionViewController.h"
#import "AppDelegate.h"
//api
#import "GetInavlideCodeApi.h"
#import "RegisterPhoneViewController.h"
//
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "MMPopupView.h"

@interface LoginViewController ()<UITextFieldDelegate,WXApiDelegate>
@property (nonatomic,strong) CKTextField *nameText;
@property (nonatomic,strong) UITextField *passWordText;
@property (nonatomic, strong) ZWIntroductionViewController *introductionView;

@property (nonatomic,strong)  NSString *cellPhone;
@property (assign,nonatomic)  int forgetPassWord;
@property (nonatomic,strong) RegisterPhoneViewController *phoneView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //接受消息，弹出输入电话号码
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showPhoneInputView) name:ShowPhoneInputViewNoti object:nil];
    // Do any additional setup after loading the view.
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
    if (thirdMeddoPhone) {
        self.nameText.text = thirdMeddoPhone;
    }
    if (thirdMeddoPassWord) {
        self.passWordText.text = thirdMeddoPassWord;
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
    registerButton.tag = 10001;
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
    //第三方登录
    UILabel *thirdLoginLabel = [[UILabel alloc]init];
    if ([WXApi isWXAppInstalled]||[WeiboSDK isWeiboAppInstalled]||[TencentOAuth iphoneQQInstalled]) {
        
        [self.view addSubview:thirdLoginLabel];
        thirdLoginLabel.text = @"其他登录方式";
        thirdLoginLabel.font = [UIFont systemFontOfSize:15];
        thirdLoginLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [thirdLoginLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.centerX);
            make.top.equalTo(forgetButton.bottom).offset(0);
            make.height.equalTo(40);
        }];
        UIView *leftLineView = [[UIView alloc]init];
        [self.view addSubview:leftLineView];
        leftLineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [leftLineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(thirdLoginLabel.centerY);
            make.height.equalTo(0.5);
            make.left.equalTo(self.view.left).offset(15);
            make.right.equalTo(thirdLoginLabel.left).offset(-15);
        }];
        
        UIView *rightLineView = [[UIView alloc]init];
        [self.view addSubview:rightLineView];
        rightLineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [rightLineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(thirdLoginLabel.centerY);
            make.height.equalTo(0.5);
            make.left.equalTo(thirdLoginLabel.right).offset(15);
            make.right.equalTo(self.view.right).offset(-15);
        }];
        //
    }
    float centerfriend = self.view.frame.size.width/4;
    if ([WeiboSDK isWeiboAppInstalled]&&[WXApi isWXAppInstalled]&&![TencentOAuth iphoneQQInstalled]) {
        UIButton *weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:weixinButton];
        [weixinButton addTarget:self action:@selector(weixinButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [weixinButton setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [weixinButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(weixinButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(-centerfriend);
        }];
        
        UIButton *sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaButton addTarget:self action:@selector(sinaButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaButton];
        [sinaButton setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
        float centerfriend = self.view.frame.size.width/4;
        [sinaButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(sinaButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(centerfriend);
        }];


    }else if ([WeiboSDK isWeiboAppInstalled]&&[TencentOAuth iphoneQQInstalled]&&![WXApi isWXAppInstalled]){
        UIButton *sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaButton addTarget:self action:@selector(sinaButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaButton];
        [sinaButton setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
        float centerfriend = self.view.frame.size.width/4;
        [sinaButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(sinaButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(centerfriend);
        }];
        
        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:qqButton];
        [qqButton addTarget:self action:@selector(qqButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [qqButton setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        [qqButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(qqButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(-centerfriend);
        }];
    }else if ([WXApi isWXAppInstalled]&&[TencentOAuth iphoneQQInstalled]&&![WeiboSDK isWeiboAppInstalled]){
        UIButton *weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:weixinButton];
        [weixinButton addTarget:self action:@selector(weixinButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [weixinButton setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [weixinButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(weixinButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(centerfriend);
        }];
        
        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:qqButton];
        [qqButton addTarget:self action:@selector(qqButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [qqButton setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        [qqButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(qqButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(-centerfriend);
        }];
    }else if (![WXApi isWXAppInstalled]&&![TencentOAuth iphoneQQInstalled]&&[WeiboSDK isWeiboAppInstalled]){
        UIButton *sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaButton addTarget:self action:@selector(sinaButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaButton];
        [sinaButton setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
        [sinaButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(sinaButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX);
        }];
    }else if ([WXApi isWXAppInstalled]&&![TencentOAuth iphoneQQInstalled]&&![WeiboSDK isWeiboAppInstalled]){
        UIButton *weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:weixinButton];
        [weixinButton addTarget:self action:@selector(weixinButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [weixinButton setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [weixinButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.centerX);
            make.height.equalTo(weixinButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
        }];
    }else if (![WXApi isWXAppInstalled]&&[TencentOAuth iphoneQQInstalled]&&![WeiboSDK isWeiboAppInstalled]){
        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.view addSubview:qqButton];
        [qqButton addTarget:self action:@selector(qqButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [qqButton setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        [qqButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(qqButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX);
        }];
    }else if ([WXApi isWXAppInstalled]&&[WeiboSDK isWeiboAppInstalled]&&[TencentOAuth iphoneQQInstalled]){
        UIButton *weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:weixinButton];
        [weixinButton addTarget:self action:@selector(weixinButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [weixinButton setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        [weixinButton makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.centerX);
            make.height.equalTo(weixinButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
        }];
        
        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.view addSubview:qqButton];
        [qqButton addTarget:self action:@selector(qqButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        float centerfriend = self.view.frame.size.width/4;
        [qqButton setBackgroundImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        [qqButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(qqButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(-centerfriend);
        }];
        
        UIButton *sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sinaButton addTarget:self action:@selector(sinaButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sinaButton];
        [sinaButton setBackgroundImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
        [sinaButton makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(sinaButton.width);
            make.height.equalTo(60);
            make.top.equalTo(thirdLoginLabel.bottom).offset(10);
            make.centerX.equalTo(self.view.centerX).offset(centerfriend);
        }];
        
    }
    
    
//
    //设置引导画面
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"firstInApp":@"YES"}];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"firstInApp"] isEqualToString:@"YES"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [self setIntroduceView];
    }

}

- (void)showPhoneInputView
{
    self.phoneView = [[RegisterPhoneViewController alloc]init];
    [self.view addSubview:self.phoneView.view];
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.delegate = self;
    theAnimation.duration = 0.4;
    theAnimation.repeatCount = 0;
    theAnimation.removedOnCompletion = FALSE;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.autoreverses = NO;
    theAnimation.fromValue = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    theAnimation.toValue = [NSNumber numberWithFloat:0];
    [self.phoneView.view.layer addAnimation:theAnimation forKey:@"animateLayer"];
}

//userbutton taped
- (void)weixinButtonTaped:(UIButton *)sender
{
    isThirdLogin = YES;
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state = @"xxx";
    req.openID = @"0c806938e2413ce73eef92cc3";
    
    [WXApi sendAuthReq:req viewController:self delegate:self];
}

- (void)qqButtonTaped:(UIButton *)sender
{
    isThirdLogin = YES;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_IDOL,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_PIC_T,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_DEL_IDOL,
                            kOPEN_PERMISSION_DEL_T,
                            kOPEN_PERMISSION_GET_FANSLIST,
                            kOPEN_PERMISSION_GET_IDOLLIST,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_GET_REPOST_LIST,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                            kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                            nil];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    [app.tencentOAuth authorize:permissions inSafari:NO];
}

- (void)sinaButtonTaped: (UIButton *)sender
{
    isThirdLogin = YES;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WBRedirectURL;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}


- (void)setIntroduceView
{
    NSArray *coverImageNames = @[@"", @"", @""];
    NSArray *backgroundImageNames = @[@"pic_introduce_1", @"pic_introduce_2", @"pic_introduce_3"];
    self.introductionView = [[ZWIntroductionViewController alloc] initWithCoverImageNames:coverImageNames backgroundImageNames:backgroundImageNames];
    __weak LoginViewController *weakSelf = self;
    [self.view addSubview:self.introductionView.view];
    self.introductionView.didSelectedEnter = ^() {
        [weakSelf.introductionView.view removeFromSuperview];
        weakSelf.introductionView = nil;
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"firstInApp"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    };
}

- (void)login:(UIButton *)sender
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    if ([self.nameText.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入电话号码" duration:1.5 position:@"center"];
        return;
    }
    if ([self.passWordText.text isEqualToString:@""]) {
        [self.view makeToast:@"请输入密码" duration:1.5 position:@"center"];
        return;
    }
    //获取设备状态
    
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
    NSString *url = [NSString stringWithFormat:@"v1/user/UserLogin?UserIDOrigianal=%@&Password=%@",self.nameText.text,self.passWordText.text];
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,url] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            thirdPartyLoginPlatform = MeddoPlatform;
            thirdPartyLoginUserId = [resposeDic objectForKey:@"UserID"];
            NSRange range = [thirdPartyLoginUserId rangeOfString:@"$"];
            thirdPartyLoginNickName = [[resposeDic objectForKey:@"UserID"] substringFromIndex:range.location+range.length];
            thirdPartyLoginOriginalId = [[resposeDic objectForKey:@"UserID"] substringFromIndex:range.location+range.length];
            thirdPartyLoginIcon = @"";
            thirdPartyLoginToken = @"";
            thirdMeddoPhone = self.nameText.text;
            thirdMeddoPassWord = self.passWordText.text;
            [UserManager setGlobalOauth];
            
            self.loginButtonClicked(1);
            [MMProgressHUD dismissAfterDelay:0.3];
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10012) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self.view makeToast:@"密码或者帐号错误,请重试。" duration:2 position:@"center"];
            }];
        }else{
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                NSString *error = [resposeDic objectForKey:@"ErrorMessage"];
                [self.view makeToast:error duration:2 position:@"center"];
            }];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}


- (void)registerButton:(UIButton *)sender
{
    if (self.view.frame.origin.y!=0) {
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }
    self.getCodeButtonClicked(1);
}

- (void)forgetPassWord:(UITapGestureRecognizer *)gesture
{
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
    };
    [[[MMAlertView alloc] initWithInputTitle:@"提示" detail:@"请输入手机号码,我们会将密码以短信的方式发到您的手机上。" placeholder:@"请输入手机号" handler:^(NSString *text) {
        self.cellPhone = text;
        [self getPassWordSelf:text];
    }] showWithBlock:completeBlock];
}
#pragma mark 获取验证码
- (void)getPassWordSelf:(NSString *)cellPhone
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    
    if (cellPhone.length == 0) {
        [self.view makeToast:@"请输入手机号" duration:2 position:@"center"];
        return;
    }
    if (cellPhone.length != 11) {
        [self.view makeToast:@"请输入正确的手机号" duration:2 position:@"center"];
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
    
    NSDictionary *dic = @{
                          @"UserID": [NSString stringWithFormat:@"%@$%@",MeddoPlatform,self.cellPhone], //关键字，必须传递
                          @"Password": [NSString stringWithFormat:@"%d",self.forgetPassWord], //密码
                        };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [WTRequestCenter putWithURL:[NSString stringWithFormat:@"%@v1/user/ModifyUserInfo",BaseUrl] header:header parameters:dic finished:^(NSURLResponse *response, NSData *data) {
         NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"新的密码是%d",self.forgetPassWord);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
                self.passWordText.text = @"";
                [self.view makeToast:@"新的密码已发送到您手机,请查收" duration:3 position:@"center"];
            }];
        }else{
            [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:3];
            self.passWordText.text = @"";
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

#pragma mark textfeild delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.nameText]) {
        [textField setReturnKeyType:UIReturnKeyNext];
        return YES;
    }else if([textField isEqual:self.passWordText]){
        [textField setReturnKeyType:UIReturnKeyDone];
        return YES;
    }
    return YES;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    if ([UserManager IsUserLogged]) {
        
        NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                            [UIImage imageNamed:@"havi1_1"],
                            [UIImage imageNamed:@"havi1_2"],
                            [UIImage imageNamed:@"havi1_3"],
                            [UIImage imageNamed:@"havi1_4"],
                            [UIImage imageNamed:@"havi1_5"]];
        [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:nil status:nil images:images];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.loginButtonClicked(1);
            [MMProgressHUD dismiss];
            //监听网络
            AppDelegate *app = [UIApplication sharedApplication].delegate;
            [app setWifiNotification];
            
        });
    }

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
