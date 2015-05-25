//
//  ReNameDeviceNameViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/4/25.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ReNameDeviceNameViewController.h"
#import "BindingDeviceUUIDAPI.h"

@interface ReNameDeviceNameViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UITextField *nameTextField;

@end

@implementation ReNameDeviceNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = nil;
    [self createNavWithTitle:@"重命名设备" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }else if (nIndex == 0){
             self.rightButton.frame = CGRectMake(self.view.frame.size.width-60, 0, 60, 44);
             [self.rightButton setTitle:@"保存" forState:UIControlStateNormal];
             [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             [self.rightButton addTarget:self action:@selector(bindingDeviceWithUUID:) forControlEvents:UIControlEventTouchUpInside];
             return self.rightButton;
         }
         return nil;
     }];
    
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(64);
        make.height.equalTo(TableViewCellHeight);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.scrollEnabled = NO;
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
}

- (UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc]init];
        _nameTextField.frame = CGRectMake(15, 0, self.view.frame.size.width-30, TableViewCellHeight);
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.placeholder = @"设备名称";
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.delegate = self;
        
    }
    return _nameTextField;
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//使得tableview顶格
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *defaultCellIndentifier = @"cellIndentifier";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
     if (!cell) {
     cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
     }
     cell.accessoryType = UITableViewCellAccessoryNone;
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:self.nameTextField];
    self.nameTextField.text = [NSString stringWithFormat:@"%@",[self.deviceInfo  objectForKey:@"Description"]];
//     cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.deviceInfo  objectForKey:@"Description"]];
     cell.backgroundColor = [UIColor whiteColor];
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark textfeild delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        [textField setReturnKeyType:UIReturnKeyDone];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        [textField resignFirstResponder];
    }
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
#pragma mark 提交
- (void)bindingDeviceWithUUID:(UIButton *)button
{
    
    if (self.nameTextField.text.length == 0) {
        [self.view makeToast:@"请输入设备名称" duration:2 position:@"center"];
        return;
    }
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":GloableUserId,
                           @"UUID": [NSString stringWithFormat:@"%@",[self.deviceInfo  objectForKey:@"UUID"]],
                           @"Description":self.nameTextField.text,
                           };
    [MMProgressHUD showWithStatus:@"修改设备名称中..."];
    BindingDeviceUUIDAPI *client = [BindingDeviceUUIDAPI shareInstance];
    [client bindingDeviceUUID:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"绑定设备结果是%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                
                [self backToHomeView:nil];
            }];
        }else{
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                
            }];
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
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
