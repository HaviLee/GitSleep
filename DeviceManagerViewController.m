//
//  DevicManagerViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "AddProductViewController.h"
#import "AddProductNameViewController.h"
#import "HaviGetNewClient.h"
#import "GetDeviceListAPI.h"
#import "ChangeUUIDAPI.h"
#import "ReNameDeviceNameViewController.h"
#import "UDPAddProductViewController.h"
//
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "URBAlertView.h"
#import "MMPopupItem.h"

@interface DeviceManagerViewController ()<MGSwipeTableCellDelegate>

@property (nonatomic,strong) NSMutableArray *deviceArr;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@end

@implementation DeviceManagerViewController

- (void)loadView
{
    [super loadView];
    //    [self animationDelete];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self createNavWithTitle:@"设备管理" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }else if (nIndex == 0){
             self.rightButton.frame = CGRectMake(self.view.frame.size.width-35, 8, 25, 25);
             [self.rightButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_add_%d",selectedThemeIndex]] forState:UIControlStateNormal];
             [self.rightButton addTarget:self action:@selector(addDevice:) forControlEvents:UIControlEventTouchUpInside];
             return self.rightButton;
         }
         
         
         return nil;
     }];
    // Do any additional setup after loading the view.
    //
    self.bgImageView.image = [UIImage imageNamed:@""];
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
    
    //    self.deviceArr = [[NSMutableArray alloc]initWithArray:@[@"我的设备",@"梅西的设备",@"哈维的设备",]];
}

#pragma mark 为了左滑动和有滑动的
-(NSArray *) createLeftButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"重命名",@"重激活"};
    UIColor * colors[2] = {[UIColor colorWithRed:0.165f green:0.239f blue:0.588f alpha:1.00f],[UIColor colorWithRed:0.525f green:0.808f blue:0.922f alpha:1.00f]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            HaviLog(@"重命名");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}


-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[1] = {@"  删除  "};
    UIColor * colors[1] = {[UIColor redColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            HaviLog(@"删除");
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

#pragma mark 请求数据
- (void)getUserDeviceList
{
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",thirdPartyLoginUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"请求的设备列表是%@",resposeDic);
        self.deviceArr = [resposeDic objectForKey:@"DeviceList"];
        if (self.deviceArr.count == 0) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self.view makeToast:@"您还没有绑定设备" duration:2 position:@"center"];
            }];
        }
        if (self.deviceArr.count>0) {
            BOOL noActive = YES;
            for (NSDictionary *dic in self.deviceArr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    noActive = NO;
                }
            }
            if (noActive) {
                [MMProgressHUD dismiss];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    [self.view makeToast:@"点击您需要绑定的设备进行绑定" duration:2 position:@"center"];
                }];
            }else{
                [MMProgressHUD dismiss];
            }
        }
        [self.sideTableView reloadData];
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    /*
    GetDeviceListAPI *client = [GetDeviceListAPI shareInstance];
    [client getDeviceList:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"请求的设备列表是%@",resposeDic);
        self.deviceArr = [resposeDic objectForKey:@"DeviceList"];
        if (self.deviceArr.count == 0) {
            [MMProgressHUD dismissWithSuccess:@"您还没有绑定硬件设备" title:nil afterDelay:2];
        }
        if (self.deviceArr.count>0) {
            BOOL noActive = YES;
            for (NSDictionary *dic in self.deviceArr) {
                if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                    noActive = NO;
                }
            }
            if (noActive) {
                [MMProgressHUD dismissWithSuccess:@"点击您需要绑定的设备进行绑定" title:nil afterDelay:2];
            }else{
                [MMProgressHUD dismiss];
            }
        }
        [self.sideTableView reloadData];
    } failure:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
    }];
    */
}

//添加设备
#pragma mark tableview 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * reuseIdentifier = @"programmaticCell";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"]];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPath = indexPath;
    [tableView reloadData];
    [self changeUUID:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
    HardWareUUID = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"];
    /*
     切换uuid
     */
}
//使得tableview顶格
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

#pragma mark 左右滑动的代理
//填充数据
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings;
{
    
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.fillOnTrigger = NO;
        return [self createLeftButtons:2];
    }
    else {
        expansionSettings.fillOnTrigger = YES;
        return [self createRightButtons:1];
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    HaviLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
            direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    NSIndexPath * indexPath = [self.sideTableView indexPathForCell:cell];
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        //delete button
        NSDictionary *dic = [self.deviceArr objectAtIndex:indexPath.row];
        if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
            MMPopupItemHandler block = ^(NSInteger index){
                HaviLog(@"clickd %@ button",@(index));
            };
            NSArray *items =
            @[MMItemMake(@"确定", MMItemTypeNormal, block)];
            
            MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"提示"
                                                                 detail:@"如果确定删除默认关联设备,请先切换其他设备为默认设备" items:items];
            alertView.attachedView = self.view;
            
            [alertView show];

        }else{
            [self deleteDeviceWithUUID:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
        }
    }else if (direction == MGSwipeDirectionLeftToRight && index == 0){
        [self showRenameViewWithDic:[self.deviceArr objectAtIndex:indexPath.row]];
    }else if(direction == MGSwipeDirectionLeftToRight && index == 1){
        UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
        NSString *deviceName = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"];
        NSString *deviceUUID = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"];
        udp.productName = deviceName;
        udp.productUUID = deviceUUID;
        [self.navigationController pushViewController:udp animated:YES];
        
    }
    
    return YES;
}

#pragma mark 切换uuid
- (void)changeUUID:(NSString *)UUID
{
    /*
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"切换设备中..."];
     */
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
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": UUID,
                           };
    ChangeUUIDAPI *client = [ChangeUUIDAPI shareInstance];
    [client changeUUID:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self getUserDeviceList];
                HardWareUUID = UUID;
            }];
            [MMProgressHUD dismiss];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
/*
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [self deleteDeviceWithUUID:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"] with:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]];
 }
 }
 */

- (void)deleteDeviceWithUUID:(NSString *)UUID with:(NSString *)isDefault
{
    
    if (![self isNetworkExist]) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
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
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/DeleteUserDevice",BaseUrl];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": UUID,
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            if ([isDefault isEqualToString:@"False"]) {
                [self getUserDeviceList];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                HardWareUUID = @"";
                [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICEUUID object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEUSERID object:nil];
            }
        }else{
            [MMProgressHUD dismissWithError:[obj objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}
#pragma 删除设备
- (void)deleteDeviceWithUUID:(NSString *)UUID
{
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/DeleteUserDevice",BaseUrl];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": UUID,
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            
            [MMProgressHUD dismiss];
            [self getUserDeviceList];
            //使用logout接口
        }else{
            [MMProgressHUD dismissWithError:[obj objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

- (void)showRenameViewWithDic:(NSDictionary *)deviceInfo
{
    ReNameDeviceNameViewController *name = [[ReNameDeviceNameViewController alloc]init];
    name.deviceInfo = deviceInfo;
    [self.navigationController pushViewController:name animated:YES];
}

- (void)addDevice:(UIButton *)button
{
    HaviLog(@"扫描进行添加");
    AddProductNameViewController *productName = [[AddProductNameViewController alloc]init];
    [self.navigationController pushViewController:productName animated:YES];
    
    //
}
//在界面出现的时候进行刷新数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取数据
    [self getUserDeviceList];
}

//返回
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)reloadThemeImage
{
    [super reloadThemeImage];
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

