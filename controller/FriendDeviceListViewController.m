//
//  FriendDeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "FriendDeviceListViewController.h"
#import "ODRefreshControl.h"
#import "FriendMessageTableViewCell.h"
@interface FriendDeviceListViewController ()

@property (nonatomic, strong) UITableView *myDeviceListView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *resultArr;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation FriendDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.myDeviceListView];
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_myDeviceListView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)refreshBegining
{
    [self refresh];

}

- (void)refresh{
    
    HaviLog(@"刷新ok");
    [self getFriendDeviceList];
    
    
}

- (void)getFriendDeviceList
{
//    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
//                        [UIImage imageNamed:@"havi1_1"],
//                        [UIImage imageNamed:@"havi1_2"],
//                        [UIImage imageNamed:@"havi1_3"],
//                        [UIImage imageNamed:@"havi1_4"],
//                        [UIImage imageNamed:@"havi1_5"]];
//    
//    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSString *urlString = [NSString stringWithFormat:@"%@%@",@"v1/user/FriendDeviceList?UserID=",thirdPartyLoginUserId];
    
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        __weak typeof(self) weakSelf = self;
        [weakSelf.refreshControl endRefreshing];
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"朋友的列表%@",resposeDic);
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [MMProgressHUD dismiss];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            self.resultArr = [resposeDic objectForKey:@"UserList"];
            [self.myDeviceListView reloadData];
            [_myDeviceListView setNeedsLayout];
        }else{
            
        }
        if (_resultArr.count==0) {
            [self.myDeviceListView addSubview:self.messageLabel];
        }else{
            [self.messageLabel removeFromSuperview];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    }];

}

#pragma setter meathod

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.frame = CGRectMake(0, self.myDeviceListView.frame.size.height/2-100,self.myDeviceListView.frame.size.width , 40);
        _messageLabel.text = @"没有他人设备！";
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor lightGrayColor];
        
    }
    return _messageLabel;
}


- (UITableView *)myDeviceListView
{
    if (!_myDeviceListView) {
        _myDeviceListView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _myDeviceListView.dataSource = self;
        _myDeviceListView.delegate = self;
        _myDeviceListView.backgroundColor = [UIColor lightGrayColor];
        _myDeviceListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
    }
    return _myDeviceListView;
}

#pragma tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.resultArr.count;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    FriendMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FriendMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    NSString *userName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,[[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserID"]];
    cell.cellUserIcon = url;
    if (userName.length==0) {
        cell.cellUserName = @"匿名用户";
    }else{
        cell.cellUserName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    }
    cell.cellUserDescription = [[[_resultArr objectAtIndex:indexPath.row]objectForKey:@"Description"]substringToIndex:16];
    cell.cellUserPhone = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"CellPhone"];
    //测试
    cell.cellUserDescription = @"哈维床垫";
    cell.cellUserName = @"小白";
    cell.cellUserPhone = @"13122785292";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
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
