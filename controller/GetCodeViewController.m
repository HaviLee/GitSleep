//
//  GetCodeViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/19.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetCodeViewController.h"
#import "RegisterViewController.h"
#import "GetInavlideCodeApi.h"

@interface GetCodeViewController ()<UITextFieldDelegate>
{
    int timeToShow;

}

@property (nonatomic,strong) UITextField *phoneText;
@property (nonatomic,strong) UITextField *codeText;
@property (nonatomic,strong) UIButton *getCodeButton;
@property (nonatomic,assign) int randomCode;

@end

@implementation GetCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.bgImageView.image = [UIImage imageNamed:@"pic_login_bg"];
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        
        return nil;
    }];
    [self creatSubView];
    
}

- (void)creatSubView
{
    self.phoneText = [[UITextField alloc]init];
    [self.view addSubview:self.phoneText];
    self.phoneText.delegate = self;
    self.phoneText.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    self.phoneText.borderStyle = UITextBorderStyleNone;
    self.phoneText.font = DefaultWordFont;
    self.phoneText.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSDictionary *boldFont = @{NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor grayColor],NSFontAttributeName:DefaultWordFont};
    NSAttributedString *attrValue = [[NSAttributedString alloc] initWithString:@"手机号" attributes:boldFont];
    self.phoneText.attributedPlaceholder = attrValue;
    self.phoneText.keyboardType = UIKeyboardTypePhonePad;
    //
    self.codeText = [[UITextField alloc]init];
    [self.view addSubview:self.codeText];
    self.codeText.delegate = self;
    self.codeText.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    self.codeText.borderStyle = UITextBorderStyleNone;
    self.codeText.font = DefaultWordFont;
    NSAttributedString *attrValue1 = [[NSAttributedString alloc] initWithString:@"验证码" attributes:boldFont];
    self.codeText.attributedPlaceholder = attrValue1;
    self.codeText.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeText.keyboardType = UIKeyboardTypePhonePad;
    //
    [self.phoneText makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(self.view.top).offset(84);
        
    }];
    //
    self.phoneText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
    self.codeText.background = [UIImage imageNamed:[NSString stringWithFormat:@"textbox_password_%d",selectedThemeIndex]];
    
    UIImageView *nameImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"phone_%d",selectedThemeIndex]]];
    nameImage.frame = CGRectMake(0, 0,30, 20);
    nameImage.contentMode = UIViewContentModeScaleAspectFit;
    self.phoneText.leftViewMode = UITextFieldViewModeAlways;
    self.phoneText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.phoneText.leftView = nameImage;
    //
    [self.codeText makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(self.phoneText.bottom).offset(10);
        
    }];
    UIImageView *codeImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_password_%d",selectedThemeIndex]]];
    codeImage.frame = CGRectMake(0, 0,30, 20);
    codeImage.contentMode = UIViewContentModeScaleAspectFit;
    self.codeText.leftViewMode = UITextFieldViewModeAlways;
    self.codeText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.codeText.leftView = codeImage;
    //
    self.getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.getCodeButton];
    [self.getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getCodeButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.getCodeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.getCodeButton addTarget:self action:@selector(tapedGetCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.getCodeButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_gain_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    self.getCodeButton.layer.cornerRadius = 0;
    self.getCodeButton.layer.masksToBounds = YES;
    //
    [self.getCodeButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.codeText.centerY);
        make.left.equalTo(self.codeText.right).offset(5);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(ButtonHeight);
        make.width.equalTo(self.codeText.width).multipliedBy(0.5);
    }];
    //
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setBackgroundColor:[UIColor lightGrayColor]];
    nextButton.tag = 1001;
    nextButton.userInteractionEnabled = YES;
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = DefaultWordFont;
    [nextButton addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventTouchUpInside];
    nextButton.layer.cornerRadius = 0;
    nextButton.layer.masksToBounds = YES;
    nextButton.userInteractionEnabled = NO;//测试使用
    [self.view addSubview:nextButton];
    
    //
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_ID_frame"] forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font = DefaultWordFont;
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
    backButton.layer.cornerRadius = 5;
    backButton.layer.masksToBounds = YES;
//    [self.view addSubview:backButton];
    
    //
    [nextButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(ButtonViewWidth);
        make.height.equalTo(ButtonHeight);
        make.top.equalTo(self.codeText.bottom).offset(20);
    }];
}

- (void)tapedGetCode:(UIButton *)sender
{
    if (self.phoneText.text.length == 0) {
        [self.view makeToast:@"请输入手机号" duration:2 position:@"center"];
        return;
    }
    if (self.phoneText.text.length != 11) {
        [self.view makeToast:@"请输入正确的手机号" duration:2 position:@"center"];
        return;
    }
    
    NSDictionary *dic = @{
                          @"UserID": [NSString stringWithFormat:@"%@$%@",MeddoPlatform,self.phoneText.text], //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@v1/user/UserInfo?UserID=%@",BaseUrl,[dic objectForKey:@"UserID"] ] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"检测结果是userid 是%@：%@",[dic objectForKey:@"UserID"],resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self.view makeToast:@"该手机号已经注册" duration:2 position:@"center"];
            //发现第三方帐号没有注册过
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10029){
            /*
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
            [MMProgressHUD showWithStatus:@"发送中..."];
             */
            NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                                [UIImage imageNamed:@"havi1_1"],
                                [UIImage imageNamed:@"havi1_2"],
                                [UIImage imageNamed:@"havi1_3"],
                                [UIImage imageNamed:@"havi1_4"],
                                [UIImage imageNamed:@"havi1_5"]];
            [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:nil status:nil images:images];
            self.randomCode = [self getRandomNumber:1000 to:10000];
            NSString *codeMessage = [NSString stringWithFormat:@"【智照护】您的验证码是%d",self.randomCode];
            NSDictionary *dicPara = @{
                                      @"cell" : self.phoneText.text,
                                      @"codeMessage" : codeMessage,
                                      };
            GetInavlideCodeApi *client = [GetInavlideCodeApi shareInstance];
            [client getInvalideCode:dicPara witchBlock:^(NSData *receiveData) {
                NSString *string = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
                NSRange range = [string rangeOfString:@"<error>"];
                if ([[string substringFromIndex:range.location +range.length]intValue]==0) {
                    [MMProgressHUD dismissWithSuccess:@"发送成功" title:nil afterDelay:2];
                    timeToShow = 60;
                    [self showTime];
                }else{
                    [MMProgressHUD dismissWithError:string afterDelay:2];
                }
            }];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
    
    
}

- (void)textFieldChanged:(NSNotification *)noti
{
    HaviLog(@"changed");
    UITextField *textField = (UITextField *)noti.object;
    if ([textField isEqual:self.phoneText]) {
        if (self.phoneText.text.length>11) {
            self.phoneText.text = [self.phoneText.text substringToIndex:11];
            [self shake:self.phoneText];
        }
    }else{
        UIButton *button = (UIButton *)[self.view viewWithTag:1001];
        if (self.codeText.text.length == 4) {
            button.userInteractionEnabled = YES;
            [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_next_t_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        }else if(self.codeText.text.length > 4){
            self.codeText.text = [self.codeText.text substringToIndex:4];
            [self shake:self.codeText];
        }else if (self.codeText.text.length<4){
            button.userInteractionEnabled = NO;
            [button setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

- (void)shake:(UITextField *)textField
{
    textField.layer.transform = CATransform3DMakeTranslation(10.0, 0.0, 0.0);
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        textField.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        textField.layer.transform = CATransform3DIdentity;
    }];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (void)showTime
{
    self.getCodeButton.backgroundColor = [UIColor lightGrayColor];
    self.getCodeButton.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (timeToShow) {
            timeToShow --;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *buttonTitle = [NSString stringWithFormat:@"%ds后重发",timeToShow];
                [self.getCodeButton setTitle:buttonTitle forState:UIControlStateNormal];
                if (timeToShow<1) {
                    self.getCodeButton.userInteractionEnabled = YES;
                    self.getCodeButton.backgroundColor = [UIColor colorWithRed:0.259f green:0.718f blue:0.686f alpha:1.00f];
                    [self.getCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
                }
            });
            sleep(1);
        }
    });
}

- (void)registerUser:(UIButton *)button
{
    if (self.phoneText.text.length == 0) {
        [self.view makeToast:@"请输入手机号" duration:2 position:@"center"];
        return;
    }
    if ([self.codeText.text intValue]!=self.randomCode || [self.codeText.text intValue]<999) {
        [self.view makeToast:@"验证码错误" duration:2 position:@"center"];
        return;
    }
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:self.codeText];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneText];
    self.registerButtonClicked(self.phoneText.text);
//    RegisterViewController *registerController = [[RegisterViewController alloc]init];
//    registerController.cellPhoneNum = self.phoneText.text;
//    [self.navigationController pushViewController:registerController animated:YES];
}

#pragma mark textfeild delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.phoneText]) {
        [textField setReturnKeyType:UIReturnKeyNext];
    }else{
        [textField setReturnKeyType:UIReturnKeyDone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.phoneText]) {
        [self.codeText becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.randomCode) {
        self.randomCode = 0;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.codeText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.phoneText];
}

#pragma mark delegate 隐藏键盘

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HaviLog(@"touched view");
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//    RegisterViewController *registerController = [[RegisterViewController alloc]init];
//    registerController.cellPhoneNum = self.phoneText.text;
//    [self.navigationController pushViewController:registerController animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:self.codeText];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneText];
}

- (void)backToHomeView:(UIButton*)button
{
    self.backToLoginButtonClicked(1);
//    [self.navigationController popViewControllerAnimated:YES];
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
