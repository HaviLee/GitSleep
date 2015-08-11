//
//  ModifyPassWordViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/3/15.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ModifyPassWordViewController.h"
#import "SHPutClient.h"

@interface ModifyPassWordViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UITextField *oldTextFieldPass;
@property (nonatomic,strong) UITextField *changeTextFieldPass;
@property (nonatomic,strong) UITextField *confirmTextFieldPass;

@end

@implementation ModifyPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavWithTitle:@"修改密码" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }
         return nil;
     }];
    // Do any additional setup after loading the view.
    self.bgImageView.image = nil;
    [self setSubView];
}

- (void)setSubView
{
    self.oldTextFieldPass = [[UITextField alloc]init];
    _oldTextFieldPass.borderStyle = UITextBorderStyleRoundedRect;
    _oldTextFieldPass.placeholder = @"请输入旧密码";
    _oldTextFieldPass.secureTextEntry = YES;
    _oldTextFieldPass.delegate = self;
    _oldTextFieldPass.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:_oldTextFieldPass];
    
    self.changeTextFieldPass = [[UITextField alloc]init];
    _changeTextFieldPass.borderStyle = UITextBorderStyleRoundedRect;
    _changeTextFieldPass.placeholder = @"请输入新密码";
    _changeTextFieldPass.secureTextEntry = YES;
    _changeTextFieldPass.delegate = self;
    [self.view addSubview:_changeTextFieldPass];
    
    self.confirmTextFieldPass = [[UITextField alloc]init];
    _confirmTextFieldPass.borderStyle = UITextBorderStyleRoundedRect;
    _confirmTextFieldPass.placeholder = @"请确认新密码";
    _confirmTextFieldPass.secureTextEntry = YES;
    _confirmTextFieldPass.delegate = self;
    [self.view addSubview:_confirmTextFieldPass];
    
    
    [_oldTextFieldPass makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.top.equalTo(self.view.top).offset(84);
        make.height.height.equalTo(44);
    }];
    
    
    [_changeTextFieldPass makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.top.equalTo(_oldTextFieldPass.bottom).offset(20);
        make.height.height.equalTo(44);
    }];
//    [_changeTextFieldPass setBackground:[UIImage imageNamed:@"btn_wireframe"]];
    _changeTextFieldPass.layer.borderColor = selectedThemeIndex == 0?DefaultColor.CGColor:[UIColor colorWithRed:0.447f green:0.765f blue:0.910f alpha:1.00f].CGColor;
    _changeTextFieldPass.layer.borderWidth = 1;
    _changeTextFieldPass.layer.cornerRadius = 0;
    
    [_confirmTextFieldPass makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.top.equalTo(_changeTextFieldPass.bottom).offset(10);
        make.height.height.equalTo(44);
    }];
    _confirmTextFieldPass.layer.borderColor = selectedThemeIndex == 0?DefaultColor.CGColor:[UIColor colorWithRed:0.447f green:0.765f blue:0.910f alpha:1.00f].CGColor;
    _confirmTextFieldPass.layer.borderWidth = 1;
    _confirmTextFieldPass.layer.cornerRadius = 0;
//
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"textbox_devicename_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(savePassWord:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.layer.cornerRadius = 0;
    saveButton.layer.masksToBounds = YES;
    [self.view addSubview:saveButton];

    [saveButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.top.equalTo(_confirmTextFieldPass.bottom).offset(20);
        make.height.height.equalTo(44);
    }];
}

- (void)savePassWord:(UIButton *)button
{
    if (self.oldTextFieldPass.text.length == 0) {
        [self.view makeToast:@"请输入旧密码" duration:2 position:@"center"];
        return;
    }
    if (self.changeTextFieldPass.text.length == 0 || self.confirmTextFieldPass.text.length == 0) {
        [self.view makeToast:@"请输入新密码" duration:2 position:@"center"];
        return;
    }
    
    if (![self.changeTextFieldPass.text isEqualToString:self.confirmTextFieldPass.text]) {
        [self.view makeToast:@"新密码输入不一致" duration:2 position:@"center"];
        return;
    }
    [self saveDone];
}

- (void)saveDone
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"提交中..."];
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          @"Password": self.changeTextFieldPass.text,
                          @"OldPassword":self.oldTextFieldPass.text,//密码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            [MMProgressHUD dismiss];
        }else if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==10019){
            [MMProgressHUD dismissWithError:@"旧密码错误" afterDelay:2];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:2];
    }];
}

#pragma mark textfield delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:self.oldTextFieldPass]) {
        [textField setReturnKeyType:UIReturnKeyNext];
        return YES;
    }else if([textField isEqual:self.changeTextFieldPass]){
        [textField setReturnKeyType:UIReturnKeyNext];
        return YES;
    }else{
        [textField setReturnKeyType:UIReturnKeyDone];
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.oldTextFieldPass]) {
        [self.changeTextFieldPass becomeFirstResponder];
        return YES;
    }else if ([textField isEqual:self.changeTextFieldPass]){
        [self.confirmTextFieldPass becomeFirstResponder];
        return YES;
    }else{
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark delegate 隐藏键盘

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HaviLog(@"touched view");
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)backToHomeView:(UIButton*)button
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
