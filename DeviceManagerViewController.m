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
#import "CenterSideViewController.h"
#import "ReNameDeviceNameViewController.h"
//
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface DeviceManagerViewController ()<MGSwipeTableCellDelegate>

@property (nonatomic,strong) NSMutableArray *deviceArr;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic,strong)  NSString *oldUUID;

@end

@implementation DeviceManagerViewController

- (void)loadView
{
    [super loadView];
//    [self animationDelete];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.oldUUID = HardWareUUID;
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
    self.bgImageView.image = nil;
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
    NSString* titles[1] = {@"重命名"};
    UIColor * colors[1] = {[UIColor blueColor]};
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
    NSString *urlString = [NSString stringWithFormat:@"v1/user/UserDeviceList?UserID=%@",GloableUserId];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [KVNProgress showWithStatus:@"请求中..."];
    GetDeviceListAPI *client = [GetDeviceListAPI shareInstance];
    [client getDeviceList:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"请求的设备列表是%@",resposeDic);
        [KVNProgress dismissWithCompletion:^{
            self.deviceArr = [resposeDic objectForKey:@"DeviceList"];
            if (self.deviceArr.count == 0) {
                [self.view makeToast:@"您还没有绑定硬件设备" duration:2 position:@"center"];
            }
            if (self.deviceArr.count>0) {
                BOOL noActive = YES;
                for (NSDictionary *dic in self.deviceArr) {
                    if ([[dic objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
                        noActive = NO;
                    }
                }
                if (noActive) {
                    [ShowAlertView showAlert:@"点击您想要绑定的默认设备名称进行绑定"];
                }
            }
            [self.sideTableView reloadData];
        }];
    } failure:^(YTKBaseRequest *request) {
        
    }];
    
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
    /*
    static NSString *defaultCellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"]];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
     */
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
        return [self createLeftButtons:1];
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
        [self deleteDeviceWithUUID:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"] with:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]];
    }else if (direction == MGSwipeDirectionLeftToRight && index == 0){
        [self showRenameViewWithDic:[self.deviceArr objectAtIndex:indexPath.row]];
    }
    
    return YES;
}

#pragma mark 切换uuid
- (void)changeUUID:(NSString *)UUID
{
    
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":GloableUserId,
                           @"UUID": UUID,
                           };
    ChangeUUIDAPI *client = [ChangeUUIDAPI shareInstance];
    [client changeUUID:header andWithPara:para];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [KVNProgress showSuccessWithStatus:@"切换设备成功" completion:^{
                [self getUserDeviceList];
                
                //更新主界面设备状态
                //使用logout接口，主要是更新设备
//
            }];
        }else{
            [KVNProgress showSuccessWithStatus:@"切换设备失败,稍后重试" completion:^{
            }];
        }
    } failure:^(YTKBaseRequest *request) {
        
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
#pragma 删除设备
- (void)deleteDeviceWithUUID:(NSString *)UUID with:(NSString *)isDefault
{
    NSString *urlString = [NSString stringWithFormat:@"http://webservice.meddo99.com:9000/v1/user/DeleteUserDevice"];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":GloableUserId,
                           @"UUID": UUID,
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            [KVNProgress showSuccessWithStatus:@"删除设备成功" completion:^{
                if ([isDefault isEqualToString:@"False"]) {
                    [self getUserDeviceList];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    HardWareUUID = @"";
                    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICEUUID object:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEUSERID object:nil];
                }
            }];
            //更新主界面设备状态
            //使用logout接口
        }else{
            [KVNProgress showSuccessWithStatus:@"删除设备失败,稍后重试" completion:^{
            }];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        
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
- (void)backToHomeView:(UIButton *)sender
{
    if (![self.oldUUID isEqualToString:HardWareUUID]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEUSERID object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadImage
{
    [super reloadImage];
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
