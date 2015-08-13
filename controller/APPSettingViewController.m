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

@interface APPSettingViewController ()
@property (nonatomic,strong) UIButton *logoutButton;
@end

@implementation APPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavWithTitle:@"设定" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }
         return nil;
     }];
    self.bgImageView.image = nil;
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
    self.sideArray = @[@[@"个人资料",@"登录密码修改",@"皮肤设置",@"App密码设定"],@[@"用户协议",@"关于迈动"],@[@"退出登录"]];
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
//        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
//        [cell addSubview:imageLine];
//        imageLine.alpha = 0.3;
//        [imageLine makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(cell.left).offset(5);
//            make.right.equalTo(cell).offset(-5);
//            make.bottom.equalTo(cell).offset(-1);
//            make.height.equalTo(1);
//        }];
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setImage:[UIImage imageNamed:@"btn_back_right"] forState:UIControlStateNormal];
//        button.frame = CGRectMake(0, 0, 20, 20);
//        cell.accessoryView = button;
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
            switch (indexPath.row) {
                case 0:
                {
                    UserInfoViewController *user = [[UserInfoViewController alloc]init];
                    [self.navigationController pushViewController:user animated:YES];
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
    [WeiBoLogoutAPI weiBoLogoutWithTocken:app.wbtoken parameters:nil finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"微博登出结果%@",obj);
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:app.centerViewController] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    [UserManager resetUserInfo];
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

- (void)reloadImage
{
    [super reloadImage];
    UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
    [self.menuButton setImage:i forState:UIControlStateNormal];
    self.bgImageView.image = nil;
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
