//
//  ReNameDoubleDeviceViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/12/7.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "ReNameDoubleDeviceViewController.h"

@interface ReNameDoubleDeviceViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITextField *nameTextField;
@property (nonatomic,strong) UITextField *txLeftNameView;
@property (nonatomic,strong) UITextField *txRightNameView;
@property (nonatomic,strong) UITableView *tbDeviceNameShowView;

@end

@implementation ReNameDoubleDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initControllerView];
    
}

- (void)initControllerView
{
    self.navigationController.navigationBarHidden = YES;
    self.bgImageView.image = [UIImage imageNamed:@""];
    [self createNavWithTitle:@"重命名设备" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }else if (nIndex == 0){
             self.rightButton.frame = CGRectMake(self.view.frame.size.width-60, 0, 60, 44);
             [self.rightButton setTitle:@"保存" forState:UIControlStateNormal];
             [self.rightButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
             [self.rightButton addTarget:self action:@selector(bindingDeviceWithUUID:) forControlEvents:UIControlEventTouchUpInside];
             return self.rightButton;
         }
         return nil;
     }];
    //
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(self.view.bottom);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.scrollEnabled = NO;
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    [_nameTextField becomeFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_nameTextField becomeFirstResponder];
}


#pragma mark setter meathod

- (UITextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[UITextField alloc]init];
        _nameTextField.frame = CGRectMake(15, 0, self.view.frame.size.width-30, TableViewCellHeight);
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.placeholder = @"设备名称";
        _nameTextField.textColor = [UIColor grayColor];
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.delegate = self;
        
    }
    return _nameTextField;
}

- (UITextField *)txRightNameView
{
    if (!_txRightNameView) {
        _txRightNameView = [[UITextField alloc]init];
        _txRightNameView.frame = CGRectMake(15, 0, self.view.frame.size.width-30, TableViewCellHeight);
        _txRightNameView.borderStyle = UITextBorderStyleNone;
        _txRightNameView.placeholder = @"左侧床垫名称";
        _txRightNameView.textColor = [UIColor grayColor];
        _txRightNameView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txRightNameView.delegate = self;
        
    }
    return _txRightNameView;
}

- (UITextField *)txLeftNameView
{
    if (!_txLeftNameView) {
        _txLeftNameView = [[UITextField alloc]init];
        _txLeftNameView.frame = CGRectMake(15, 0, self.view.frame.size.width-30, TableViewCellHeight);
        _txLeftNameView.borderStyle = UITextBorderStyleNone;
        _txLeftNameView.placeholder = @"右侧床垫名称";
        _txLeftNameView.textColor = [UIColor grayColor];
        _txLeftNameView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txLeftNameView.delegate = self;
        
    }
    return _txLeftNameView;
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//使得tableview顶格
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
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
    NSArray *_arrDeatilListDescription = [self.deviceInfo objectForKey:@"DetailDevice"];
    NSArray *_sortedDetailDevice = [_arrDeatilListDescription sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 objectForKey:@"UUID"]<[obj2 objectForKey:@"UUID"];
    }];
    NSLog(@"双人的命名%@",self.deviceInfo);
    if (indexPath.section==0) {
        [cell addSubview:self.nameTextField];
        self.nameTextField.text = [NSString stringWithFormat:@"%@",[self.deviceInfo  objectForKey:@"Description"]];

    }else if (indexPath.section==1){
        [cell addSubview:self.txLeftNameView];
        self.txLeftNameView.text = [NSString stringWithFormat:@"%@",[[_sortedDetailDevice  objectAtIndex:0] objectForKey:@"Description"]];
    }else if (indexPath.section==2){
        self.txRightNameView.text = [NSString stringWithFormat:@"%@",[[_sortedDetailDevice  objectAtIndex:1] objectForKey:@"Description"]];
        [cell addSubview:self.txRightNameView];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
//        view.backgroundColor = [UIColor lightGrayColor];;
        UILabel *lMainNameView = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
        lMainNameView.font = [UIFont systemFontOfSize:12];
        lMainNameView.text = @"设备名称";
        lMainNameView.textColor = [UIColor lightGrayColor];
        [view addSubview:lMainNameView];
        return view;
    }else if (section==1){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
//        view.backgroundColor = [UIColor lightGrayColor];
        UILabel *lMainNameView = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
        lMainNameView.text = @"左侧床垫名称";
        lMainNameView.textColor = [UIColor lightGrayColor];
        lMainNameView.font = [UIFont systemFontOfSize:12];
        [view addSubview:lMainNameView];
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
//        view.backgroundColor = [UIColor lightGrayColor];;
        UILabel *lMainNameView = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
        lMainNameView.textColor = [UIColor lightGrayColor];
        lMainNameView.font = [UIFont systemFontOfSize:12];
        lMainNameView.text = @"右侧床垫名称";
        [view addSubview:lMainNameView];
        return view;
    }
}

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark textfeild delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setReturnKeyType:UIReturnKeyDone];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark 提交
- (void)bindingDeviceWithUUID:(UIButton *)button
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }
    
    if (self.nameTextField.text.length == 0) {
        [self.view makeToast:@"请输入设备名称" duration:2 position:@"center"];
        return;
    }
    if (self.txLeftNameView.text.length == 0) {
        [self.view makeToast:@"请输入左侧床垫名称" duration:2 position:@"center"];
        return;
    }
    if (self.txRightNameView.text.length == 0) {
        [self.view makeToast:@"请输入右侧床垫名称" duration:2 position:@"center"];
        return;
    }
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    //
    
    NSArray *allKeys = [self.deviceInfo allKeys];
    NSArray *_arrDeatilListDescription = [self.deviceInfo objectForKey:@"DetailDevice"];
    NSArray *_sortedDetailDevice = [_arrDeatilListDescription sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 objectForKey:@"UUID"]<[obj2 objectForKey:@"UUID"];
    }];
    if ([allKeys containsObject:@"FriendUserID"]) {
        NSDictionary *para = @{
                               @"FriendUserID": [self.deviceInfo objectForKey:@"FriendUserID"],
                               @"UserID":thirdPartyLoginUserId,
                               @"DeviceList":@[
                                       @{
                                           @"UUID":[self.deviceInfo objectForKey:@"UUID"],
                                           @"Description":self.nameTextField.text,
                                           },
                                       @{
                                           @"UUID":[[_sortedDetailDevice objectAtIndex:0]objectForKey:@"UUID"],
                                           @"Description":self.txLeftNameView.text,
                                           },
                                       @{
                                           @"UUID":[[_sortedDetailDevice objectAtIndex:1]objectForKey:@"UUID"],
                                           @"Description":self.txRightNameView.text,
                                           }
                                       ]
                               };
        NSString *urlString = [NSString stringWithFormat:@"%@v1/user/RenameFriendDevice",BaseUrl];
        [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
            NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            HaviLog(@"数据是%@",obj);
            if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
                thirdHardDeviceName  = self.nameTextField.text;
                thirdLeftDeviceName = self.txLeftNameView.text;
                thirdRightDeviceName = self.txRightNameView.text;
                [UserManager setGlobalOauth];
                [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICNAME object:nil];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    
                    [self backToHomeView:nil];
                }];
                [MMProgressHUD dismiss];
            }else{
                
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    
                }];
                [MMProgressHUD dismiss];
            }
        } failed:^(NSURLResponse *response, NSError *error) {
            [MMProgressHUD dismiss];
            [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        }];
        
    }else{
        NSDictionary *para = @{
                               @"UserID":thirdPartyLoginUserId,
                               @"DeviceList":@[
                                       @{
                                           @"UUID":[self.deviceInfo objectForKey:@"UUID"],
                                           @"Description":self.nameTextField.text,
                                           },
                                       @{
                                           @"UUID":[[_sortedDetailDevice objectAtIndex:0]objectForKey:@"UUID"],
                                           @"Description":self.txLeftNameView.text,
                                           },
                                       @{
                                           @"UUID":[[_sortedDetailDevice objectAtIndex:1]objectForKey:@"UUID"],
                                           @"Description":self.txRightNameView.text,
                                           }
                                       ]
                               };
        NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                            [UIImage imageNamed:@"havi1_1"],
                            [UIImage imageNamed:@"havi1_2"],
                            [UIImage imageNamed:@"havi1_3"],
                            [UIImage imageNamed:@"havi1_4"],
                            [UIImage imageNamed:@"havi1_5"]];
        [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:nil status:nil images:images];
         NSString *urlString = [NSString stringWithFormat:@"%@v1/user/RenameUserDevice",BaseUrl];
        [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
            NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            HaviLog(@"数据是%@",obj);
            if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
                thirdHardDeviceName  = self.nameTextField.text;
                thirdLeftDeviceName = self.txLeftNameView.text;
                thirdRightDeviceName = self.txRightNameView.text;
                [UserManager setGlobalOauth];
                [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICNAME object:nil];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    
                    [self backToHomeView:nil];
                }];
                [MMProgressHUD dismiss];
            }else{
                
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    
                }];
                [MMProgressHUD dismiss];
            }
        } failed:^(NSURLResponse *response, NSError *error) {
            [MMProgressHUD dismiss];
            [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        }];
    }
    
    
    
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
