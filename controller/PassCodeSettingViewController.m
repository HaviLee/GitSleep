//
//  PassCodeSettingViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "PassCodeSettingViewController.h"
#import "PAPasscodeViewController.h"

@interface PassCodeSettingViewController ()<PAPasscodeViewControllerDelegate>

@property (nonatomic,strong) UISwitch *codeSwitch;
@property (nonatomic,strong) UILabel *openLabel;
@property (nonatomic,strong) UILabel *settingLabel;

@end

@implementation PassCodeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavWithTitle:@"密码锁设定" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;
         }
         return nil;
     }];
    self.bgImageView.image = [UIImage imageNamed:@""];
    [self setSubView];
}

- (void)setSubView
{
    
    //
    self.view.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(self.view.bottom).offset(-200);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
}

- (UILabel *)openLabel
{
    if (!_openLabel) {
        _openLabel = [[UILabel alloc]init];
    }
    return _openLabel;
}

- (UILabel *)settingLabel
{
    if (!_settingLabel) {
        _settingLabel = [[UILabel alloc]init];
    }
    return _settingLabel;
}

- (UISwitch *)codeSwitch
{
    if (!_codeSwitch) {
        _codeSwitch = [[UISwitch alloc]init];
    }
    return _codeSwitch;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defaultCellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        [cell addSubview:self.openLabel];
        [_openLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.centerY);
            make.left.equalTo(cell.left).offset(20);
            make.height.equalTo(cell.height);
        }];
        [cell addSubview:self.codeSwitch];
        [_codeSwitch makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.centerY);
            make.right.equalTo(cell.right).offset(-20);
            
        }];
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
            [_codeSwitch setOn:YES];
            _openLabel.text = @"锁屏密码已开启";
        }else{
            [_codeSwitch setOn:NO];
            _openLabel.text = @"锁屏密码已关闭";
        }
        [_codeSwitch addTarget:self action:@selector(changeInvalidCodeStatus:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else if (indexPath.row == 1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell addSubview:self.settingLabel];
        [_settingLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell.centerY);
            make.left.equalTo(cell.left).offset(20);
            make.height.equalTo(cell.height);
        }];
        
        _settingLabel.text = @"更改锁屏密码";
        if (_codeSwitch.on) {
            _settingLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }else{
            _settingLabel.textColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)changeInvalidCodeStatus:(UISwitch *)sender
{
    if (sender.on) {
        PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionSet];
        passcodeViewController.delegate = self;
        [self presentViewController:passcodeViewController animated:YES completion:nil];
    }else{
        PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionEnter];
        NSString *passWord = [[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey];
        passcodeViewController.passcode = passWord;
        passcodeViewController.delegate = self;
        [self presentViewController:passcodeViewController animated:YES completion:nil];
    }
    [self.sideTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1 && _codeSwitch.on) {
        PAPasscodeViewController *passcodeViewController = [[PAPasscodeViewController alloc] initForAction:PasscodeActionChange];
        NSString *passWord = [[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey];
        passcodeViewController.passcode = passWord;
        passcodeViewController.delegate = self;
        [self presentViewController:passcodeViewController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
#pragma mark 锁屏密码设定
- (void)PAPasscodeViewControllerDidCancel:(PAPasscodeViewController *)controller {
    if (controller.action == PasscodeActionSet) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_codeSwitch setOn:NO];
            [self.sideTableView reloadData];
        }];
    }else if (controller.action == PasscodeActionEnter){
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else if (controller.action == PasscodeActionChange){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//设定
- (void)PAPasscodeViewControllerDidSetPasscode:(PAPasscodeViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^() {
        HaviLog(@"密码是%@",controller.passcode);
        [[NSUserDefaults standardUserDefaults]setObject:controller.passcode forKey:AppPassWordKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        _openLabel.text = @"锁屏密码已开启";
        //想Centerview发送消息开始检测后台弹出app 密码界面
        [[NSNotificationCenter defaultCenter]postNotificationName:AppPassWorkSetOkNoti object:nil];
    }];
}
//验证
- (void)PAPasscodeViewControllerDidEnterPasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^() {
        HaviLog(@"密码是%@",controller.passcode);
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:AppPassWordKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
//        //想Centerview发送消息开始检测后台弹出app 密码界面
        [_codeSwitch setOn:NO];
        [self.sideTableView reloadData];
        _openLabel.text = @"锁屏密码已关闭";
        [[NSNotificationCenter defaultCenter]postNotificationName:AppPassWordCancelNoti object:nil];
    }];
}

//修改
- (void)PAPasscodeViewControllerDidChangePasscode:(PAPasscodeViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^() {
        HaviLog(@"密码是%@",controller.passcode);
        [[NSUserDefaults standardUserDefaults]setObject:controller.passcode forKey:AppPassWordKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //        //想Centerview发送消息开始检测后台弹出app 密码界面
        //        [[NSNotificationCenter defaultCenter]postNotificationName:AppPassWorkSetOkNoti object:nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.sideTableView reloadData];
}

//返回
- (void)backToHomeView:(UIButton *)sender
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
