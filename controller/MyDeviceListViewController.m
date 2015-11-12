//
//  MyDeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "MyDeviceListViewController.h"
#import "ODRefreshControl.h"
#import "BindDeviceTableViewCell.h"
#import "MessageShowTableViewCell.h"
#import "AddProductNameViewController.h"
#import "UDPAddProductViewController.h"

@interface MyDeviceListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UITableView *myDeviceListView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;


@end

@implementation MyDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.myDeviceListView];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_myDeviceListView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

//刷新
- (void)refresh{
    __weak typeof(self) weakSelf = self;
    
    HaviLog(@"刷新ok");
    [weakSelf.refreshControl endRefreshing];
    
}

#pragma setter meathod

- (UITableView *)myDeviceListView
{
    if (!_myDeviceListView) {
        _myDeviceListView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _myDeviceListView.dataSource = self;
        _myDeviceListView.delegate = self;
        _myDeviceListView.backgroundColor = [UIColor lightGrayColor];
        
        
    }
    return _myDeviceListView;
}

#pragma tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 200;
    }else{
        return 110;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        NSString *cellIndentifier = @"cellIndentifier1";
        BindDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[BindDeviceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.867f blue:0.878f alpha:1.00f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *cellIndentifier = @"cellIndentifier";
        MessageShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[MessageShowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.867f blue:0.878f alpha:1.00f];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        [self showInfoList];
    }else{
        
    }
}

#pragma mark userAction

- (void)showInfoList
{
    HaviLog(@"showDone");
    //控制逻辑添加设备
    UIActionSheet *infoSheet = [[UIActionSheet alloc] initWithTitle:@"选择您的操作"
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"添加设备",@"重命名", @"切换设备", @"重激活设备", @"删除设备", nil];
    
    // Show the sheet
    [infoSheet showInView:self.view];
}

#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %ld", (long)buttonIndex);
    switch (buttonIndex) {
        case 0:{
            AddProductNameViewController *addProductName = [[AddProductNameViewController alloc]init];
            [self.navigationController pushViewController:addProductName animated:YES];
            break;
        }
        case 1:{
            break;
        }
        case 2:{
            break;
        }
        case 3:{
            UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
            NSString *deviceName = @"li";
            NSString *deviceUUID = @"li";
            udp.productName = deviceName;
            udp.productUUID = deviceUUID;
            [self.navigationController pushViewController:udp animated:YES];
            break;
        }
        case 4:{
            break;
        }
            
            
        default:
            break;
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
