//
//  MyDeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "MessageListViewController.h"
#import "ODRefreshControl.h"
#import "BindDeviceTableViewCell.h"
#import "MessageShowTableViewCell.h"
#import "AddProductNameViewController.h"
#import "UDPAddProductViewController.h"
#import "ReNameDeviceNameViewController.h"

@interface MessageListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CustomMessageProtocol>

@property (nonatomic, strong) UITableView *myDeviceListView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *resultArr;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavWithTitle:@"我的消息" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }
         return nil;
     }];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.myDeviceListView];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_myDeviceListView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self getMessageList];
}

- (void)getMessageList
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",@"v1/user/BeingRequestedUsers?UserId=",thirdPartyLoginUserId];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        [self.refreshControl endRefreshing];
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [MMProgressHUD dismiss];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            _resultArr = [resposeDic objectForKey:@"UserList"];
            [self.myDeviceListView reloadData];
            [_myDeviceListView setNeedsLayout];
        }else{
            
        }
        if (_resultArr.count==0) {
            [self.myDeviceListView addSubview:self.messageLabel];
            self.messageLabel.text = @"没有对应用户哦！";
        }else{
            [self.messageLabel removeFromSuperview];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
    }];
}

//刷新
- (void)refresh{
    
    HaviLog(@"刷新ok");
    [self getMessageList];
    
}

#pragma setter meathod

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.frame = CGRectMake(0, self.view.frame.size.height/2-100,self.view.frame.size.width , 40);
        _messageLabel.text = @"没有申请消息！";
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor lightGrayColor];
        
    }
    return _messageLabel;
}


- (UITableView *)myDeviceListView
{
    if (!_myDeviceListView) {
        _myDeviceListView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _myDeviceListView.dataSource = self;
        _myDeviceListView.delegate = self;
        _myDeviceListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myDeviceListView.backgroundColor = [UIColor lightGrayColor];
        
        
    }
    return _myDeviceListView;
}

#pragma tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    MessageShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[MessageShowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    NSString *userName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,[[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserID"]];
    cell.cellUserIcon = url;
    if (userName.length==0) {
        cell.cellUserName = @"匿名用户";
    }else{
        cell.cellUserName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellUserPhone = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"CellPhone"];
    cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.867f blue:0.878f alpha:1.00f];
    return cell;
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
    }else{
        
    }
}

#pragma mark custom cell action
- (void)customMessageAcceptCell:(MessageShowTableViewCell *)cell didTapButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.myDeviceListView indexPathForCell:cell];
    HaviLog(@"点击了%ld",(long)indexPath.row);
    NSDictionary *userDic = [_resultArr objectAtIndex:indexPath.row];
    NSString *responseID = [userDic objectForKey:@"UserID"];
    [self acceptMessage:responseID];
}

- (void)acceptMessage:(NSString *)userID
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSString *urlString = [NSString stringWithFormat:@"%@",@"v1/user/GrantToAddFriend"];
    NSDictionary *para = @{
                           @"RequestUserId":userID,
                           @"ResponseUserId":thirdPartyLoginUserId,
                           @"StatusCode" : @"1",
                           };
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [WTRequestCenter putWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        [self.refreshControl endRefreshing];
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self getMessageList];
            [self.view makeToast:@"您已同意该用户的申请" duration:2 position:@"center"];
        }else{
            
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)customMessageRefuseCell:(MessageShowTableViewCell *)cell didTapButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.myDeviceListView indexPathForCell:cell];
    HaviLog(@"点击了%ld",(long)indexPath.row);
    NSDictionary *userDic = [_resultArr objectAtIndex:indexPath.row];
    NSString *responseID = [userDic objectForKey:@"UserID"];
    [self refuseMessage:responseID];
}

- (void)refuseMessage:(NSString *)userID
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSString *urlString = [NSString stringWithFormat:@"%@",@"v1/user/GrantToAddFriend"];
    NSDictionary *para = @{
                           @"RequestUserId":userID,
                           @"ResponseUserId":thirdPartyLoginUserId,
                           @"StatusCode" : @"-1",
                           };
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [WTRequestCenter putWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        [self.refreshControl endRefreshing];
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self getMessageList];
            [self.view makeToast:@"您已拒绝该用户的申请" duration:2 position:@"center"];
        }else{
            
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}


#pragma mark userAction


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
