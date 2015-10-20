//
//  EditCellInfoViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "EditCellInfoViewController.h"
#import "SHPutClient.h"

@interface EditCellInfoViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UITableView *cellTableView;
@property (nonatomic,strong) UITextField *cellTextField;
@property (nonatomic,strong) UILabel *cellFooterView;
@property (nonatomic,strong) NSString *cellString;

@end

@implementation EditCellInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    [self createNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]];
            [_backButton setImage:i forState:UIControlStateNormal];
            [_backButton setFrame:CGRectMake(-5, 0, 44, 44)];
            [_backButton addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
            return _backButton;
        }else if (nIndex==0){
            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
            doneButton.frame = CGRectMake(self.view.frame.size.width-65, 0, 60, 44);
            [doneButton setTitle:@"保存" forState:UIControlStateNormal];
            doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [doneButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(saveInfo:) forControlEvents:UIControlEventTouchUpInside];
            return doneButton;
        }
        return nil;
    }];
    [self.view addSubview:self.cellTableView];
}

- (void)backToView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveInfo:(UIButton *)sender
{
    if (self.cellTextField.text.length==0) {
        [self.view makeToast:@"请输入修改信息" duration:2 position:@"center"];
        return;
    }
    
    if ([self.cellString isEqual:@"UserName"]||[self.cellString isEqual:@"EmergencyContact"]) {
        if (![self checkIsValiadForString:self.cellTextField.text]) {
            [self.view makeToast:@"姓名只能由2-8位数字、字母、中文组成" duration:3 position:@"center"];
            return;
        }
    }else{
        if (![self checkIsValiadForNum:self.cellTextField.text]) {
            [self.view makeToast:@"手机号格式有误" duration:3 position:@"center"];
            return;
        }
        
    }
    [self saveUserInfoWithKey:self.cellString andData:self.cellTextField.text];
}

#pragma mark 更新信息
- (void)saveUserInfoWithKey:(NSString *)key andData:(NSString *)data
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          key:data,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789",
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self.navigationController popViewControllerAnimated:YES];
            if (self.saveButtonClicked) {
                self.saveButtonClicked(1);
            }
        }else{
            [self.view makeToast:@"稍后重试" duration:2 position:@"center"];
        }
    } failure:^(YTKBaseRequest *request) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

#pragma mark setter 

- (UITableView *)cellTableView
{
    if (!_cellTableView) {
        _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _cellTableView.delegate = self;
        _cellTableView.dataSource = self;
        _cellTableView.scrollEnabled = NO;
    }
    return _cellTableView;
}

- (UITextField *)cellTextField
{
    if (!_cellTextField) {
        _cellTextField = [[UITextField alloc]init];
        _cellTextField.font = [UIFont systemFontOfSize:15];
        _cellTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _cellTextField.placeholder = @"输入";
        _cellTextField.delegate = self;
        _cellTextField.returnKeyType = UIReturnKeyDone;
    }
    return _cellTextField;
}

- (UILabel *)cellFooterView
{
    if (!_cellFooterView) {
        _cellFooterView = [[UILabel alloc]init];
        _cellFooterView.text = @"I";
        _cellFooterView.frame = CGRectMake(15, 0, self.view.frame.size.width-30, 30);
        _cellFooterView.font = [UIFont systemFontOfSize:11];
        _cellFooterView.alpha = 0.4;
    }
    return _cellFooterView;
}

#pragma mark tableView delegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellInterfier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInterfier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInterfier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:self.cellTextField];
    [self.cellTextField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.left).offset(15);
        make.right.equalTo(cell.right).offset(-10);
        make.centerY.equalTo(cell.centerY);
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [backView addSubview:self.cellFooterView];
    return backView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCellInfoType:(NSString *)cellInfoType
{
    self.cellString = cellInfoType;
    if ([cellInfoType isEqual:@"UserName"]) {
        self.cellFooterView.text = @"2-8个字符，可由中文、英文、数字组成";
        self.cellTextField.placeholder = @"请输入您的姓名";
    }else if ([cellInfoType isEqual:@"EmergencyContact"]){
        self.cellFooterView.text = @"2-8个字符，可由中文、英文、数字组成";
        self.cellTextField.placeholder = @"请输入您的紧急联系人";
    }else if ([cellInfoType isEqual:@"Telephone"]){
        self.cellFooterView.text = @"11位手机号或者家庭座机";
        self.cellTextField.placeholder = @"请输入您的手机或者座机";
        self.cellTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

#pragma mark uitextfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([self.cellString isEqual:@"UserName"]||[self.cellString isEqual:@"EmergencyContact"]) {
        if ([self checkIsValiadForString:textField.text]) {
            [self saveInfo:nil];
            return YES;
        }else{
            [self.view makeToast:@"姓名只能由2-8位数字、字母、中文组成" duration:3 position:@"center"];
        }
    }else{
        if ([self checkIsValiadForNum:textField.text]) {
            [self saveInfo:nil];
            return YES;
        }else{
            [self.view makeToast:@"手机格式有误" duration:3 position:@"center"];
        }
        
    }
    return YES;
}

- (BOOL)checkIsValiadForString:(NSString *)checkString
{
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5]{2,6}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    if ([pred evaluateWithObject:checkString]) {
        
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)checkIsValiadForNum:(NSString *)checkString
{
    NSString *regex = @"1[0-9]{10}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([pred evaluateWithObject:checkString]) {
        
        return YES;
    }else{
        return NO;
    }
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
