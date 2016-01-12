//
//  APPSettingViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/3/15.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "APPSettingViewController.h"
#import "UserInfoViewController.h"
#import "ModifyPassWordViewController.h"
#import "PassCodeSettingViewController.h"
#import "SelectThemeViewController.h"
#import "AboutMeViewController.h"
#import "LoginViewController.h"
#import "UserProtocolViewController.h"
#import "AppDelegate.h"
#import "WeiBoLogoutAPI.h"
#import "PersonManagerViewController.h"

@interface APPSettingViewController ()
@property (nonatomic,strong) UIButton *logoutButton;
@end

@implementation APPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self createNavWithTitle:@"设定" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }
         return nil;
     }];
    self.bgImageView.image = [UIImage imageNamed:@""];
    // Do any additional setup after loading the view.
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(64);
        make.bottom.equalTo(self.view.bottom).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    if ([thirdPartyLoginPlatform isEqualToString:MeddoPlatform]) {
        self.sideArray = @[@[@"个人资料",@"登录密码修改",@"皮肤设置",@"App密码设定"],@[@"用户协议",@"关于迈动"],@[@"退出登录"]];
    }else {
        self.sideArray = @[@[@"个人资料",@"皮肤设置",@"App密码设定"],@[@"用户协议",@"关于迈动"],@[@"退出登录"]];
    }
}

#pragma mark setter

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sideArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return [[self.sideArray objectAtIndex:0] count];
            break;
        }
        case 1:{
            return [[self.sideArray objectAtIndex:1] count];
            break;
        }
        case 2:{
            return [[self.sideArray objectAtIndex:2] count];
            break;
        }
            
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defaultCellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
    }
    if (indexPath.section == 2) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = [[self.sideArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [[self.sideArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
            
        case 0:{
            if ([thirdPartyLoginPlatform isEqualToString:MeddoPlatform]) {
                
                switch (indexPath.row) {
                    case 0:
                    {
                        PersonManagerViewController *person = [[PersonManagerViewController alloc]init];
//                        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:person];
                        [self.navigationController pushViewController:person animated:YES];
                        break;
                    }
                    case 1:{
                        ModifyPassWordViewController *passWord = [[ModifyPassWordViewController alloc]init];
                        [self.navigationController pushViewController:passWord animated:YES];
                        break;
                    }
                    case 2:{
                        SelectThemeViewController *selectTheme = [[SelectThemeViewController alloc]init];
                        [self.navigationController pushViewController:selectTheme animated:YES];
                        break;
                    }
                    case 3:{
                        PassCodeSettingViewController *passCode = [[PassCodeSettingViewController alloc]init];
                        [self.navigationController pushViewController:passCode animated:YES];
                        
                        break;
                    }
                        
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        UserInfoViewController *user = [[UserInfoViewController alloc]init];
                        [self.navigationController pushViewController:user animated:YES];
                        break;
                    }
                    case 1:{
                        SelectThemeViewController *selectTheme = [[SelectThemeViewController alloc]init];
                        [self.navigationController pushViewController:selectTheme animated:YES];
                        break;
                    }
                    case 2:{
                        PassCodeSettingViewController *passCode = [[PassCodeSettingViewController alloc]init];
                        [self.navigationController pushViewController:passCode animated:YES];
                        
                        break;
                    }
                        
                    default:
                        break;
                }
            }
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    UserProtocolViewController *protocol = [[UserProtocolViewController alloc]init];
                    protocol.isPush = YES;
                    [self.navigationController pushViewController:protocol animated:YES];
                    break;
                }
                case 1:{
                    AboutMeViewController *about = [[AboutMeViewController alloc]init];
                    [self.navigationController pushViewController:about animated:YES];
                    break;
                }
                    
                    
                default:
                    break;
            }
            break;
        }
        case 2:{
            [self logoutMyId];
        }
            
            
        default:
            break;
    }
}
- (void)logoutMyId
{
    HaviLog(@"登出");
    
    //微博登出
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([thirdPartyLoginPlatform isEqualToString:SinaPlatform]) {
        [WeiBoLogoutAPI weiBoLogoutWithTocken:app.wbtoken parameters:nil finished:^(NSURLResponse *response, NSData *data) {
            NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"微博登出结果%@",obj);
        } failed:^(NSURLResponse *response, NSError *error) {
            
        }];
    }
    [[NSUserDefaults standardUserDefaults]setObject:@"18:00" forKey:UserDefaultStartTime ];
    [[NSUserDefaults standardUserDefaults]setObject:@"06:00" forKey:UserDefaultEndTime ];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc]initWithRootViewController:app.containerView] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    isDoubleDevice = NO;
    [UserManager resetUserInfo];
    thirdHardDeviceUUID = thirdHardDeviceUUID;
    [[NSNotificationCenter defaultCenter]postNotificationName:ThirdUserLogoutNoti object:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

//使得tableview顶格
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}


- (void)backToHomeView:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadThemeImage
{
    [super reloadThemeImage];
    UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
    [self.menuButton setImage:i forState:UIControlStateNormal];
    self.bgImageView.image = [UIImage imageNamed:@""];
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
