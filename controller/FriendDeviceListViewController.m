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
#import "ReNameDeviceNameViewController.h"

@interface FriendDeviceListViewController ()<JASwipeCellDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *myDeviceListView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *resultArr;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSString *selectDeviceUUID;
@property (nonatomic, strong) JASwipeCell *selectTableViewCell;

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
    //测试数据
    
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
            self.resultArr = [resposeDic objectForKey:@"DeviceList"];
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

#pragma mark setter meathod

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.frame = CGRectMake(0, self.myDeviceListView.frame.size.height/2-100,self.myDeviceListView.frame.size.width , 40);
        _messageLabel.text = @"没有他人设备！";
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor grayColor];
        
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
    return self.resultArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cellIndentifier%ld",(long)indexPath.row];
    
    FriendMessageTableViewCell *cell = [[FriendMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    [cell addActionButtons:[self rightButtons] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationRight];
    NSString *userName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"FriendUserName"];
    NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,[[_resultArr objectAtIndex:indexPath.row]objectForKey:@"FriendUserID"]];
    cell.cellUserIcon = url;
    if (userName.length==0) {
        cell.cellUserName = @"匿名用户";
    }else{
        cell.cellUserName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"FriendUserName"];
    }
    cell.delegate = self;
    cell.cellUserDescription = [[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"Description"];
    cell.cellUserPhone = [[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"CellPhone"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    if ([[[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
        cell.selectImageView.hidden = NO;
    }else{
        cell.selectImageView.hidden = YES;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reActiveFriendDevice:indexPath];
}

//
- (NSArray *)rightButtons
{
    __typeof(self) __weak weakSelf = self;
    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"删除" color:[UIColor redColor] handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.myDeviceListView indexPathForCell:cell];
        [weakSelf deleteFriendDevice:[[weakSelf.resultArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
        NSLog(@"Right Button: Archive Pressed");
    }];
    
    JAActionButton *button2 = [JAActionButton actionButtonWithTitle:@"重命名" color:kFlagButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.myDeviceListView indexPathForCell:cell];
        [weakSelf renameFriendDevice:indexPath];
        NSLog(@"Right Button: Flag Pressed");
    }];
    JAActionButton *button3 = [JAActionButton actionButtonWithTitle:@"重激活" color:kMoreButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.myDeviceListView indexPathForCell:cell];
        [weakSelf reActiveFriendDevice:indexPath];
        NSLog(@"Right Button: More Pressed");
    }];
    
    return @[button1, button2];
}

- (void)rightMostButtonSwipeCompleted:(JASwipeCell *)cell
{
    NSLog(@"左滑到底");
    self.selectTableViewCell = cell;
    NSIndexPath *indexPath = [self.myDeviceListView indexPathForCell:cell];
    [self deleteFriendDevice:[[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"FriendUserID"]];
}
#pragma mark 操作设备

- (void)deleteFriendDevice:(NSString *)deviceUUID
{
    self.selectDeviceUUID = deviceUUID;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"注意" message:@"删除该设备将同时删除和该设备关联的用户下的所有设备" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.tag = 1001;
    [alertView show];
}

#pragma mark - JASwipeCellDelegate methods

- (void)swipingRightForCell:(JASwipeCell *)cell
{
    NSArray *indexPaths = [self.myDeviceListView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *visibleCell = (JASwipeCell *)[self.myDeviceListView cellForRowAtIndexPath:indexPath];
        if (visibleCell != cell) {
            [visibleCell resetContainerView];
        }
        
    }
}

- (void)swipingLeftForCell:(JASwipeCell *)cell
{
    NSArray *indexPaths = [self.myDeviceListView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *visibleCell = (JASwipeCell *)[self.myDeviceListView cellForRowAtIndexPath:indexPath];
        if (visibleCell != cell) {
            [visibleCell resetContainerView];
        }
        
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *indexPaths = [self.myDeviceListView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        FriendMessageTableViewCell *cell = (FriendMessageTableViewCell *)[self.myDeviceListView cellForRowAtIndexPath:indexPath];
        [cell resetContainerView];
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

#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1001) {
        switch (buttonIndex) {
            case 0:{
                [self.selectTableViewCell resetContainerView];
                break;
            }
            case 1:{
                [self deleteFriendSureUUID:self.selectDeviceUUID];
                break;
                }
                
            default:
                break;
        }
        
    }else if (alertView.tag == 1002){
    }
}

#pragma mark 操作设备
- (void)deleteFriendSureUUID:(NSString *)deviceUUID
{
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/RemoveFriend",BaseUrl];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"RequestUserId":thirdPartyLoginUserId,
                           @"ResponseUserId": deviceUUID,
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [self getFriendDeviceList];
        }else{
            [MMProgressHUD dismissWithError:[obj objectForKey:@"ErrorMessage"] afterDelay:2];
            [self.selectTableViewCell resetContainerView];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

#pragma mark rename device

- (void)renameFriendDevice:(NSIndexPath *)indexPath
{
    [self.selectTableViewCell resetContainerView];
    ReNameDeviceNameViewController *name = [[ReNameDeviceNameViewController alloc]init];
    name.deviceInfo = [self.resultArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:name animated:YES];
}

- (void)reActiveFriendDevice:(NSIndexPath *)indexPath
{
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/ActivateFriendDevice",BaseUrl];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"FriendUserID": [[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"FriendUserID"],
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": [[self.resultArr objectAtIndex:indexPath.row] objectForKey:@"UUID"],
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [self getFriendDeviceList];
        }else{
            [MMProgressHUD dismissWithError:[obj objectForKey:@"ErrorMessage"] afterDelay:2];
            [self.selectTableViewCell resetContainerView];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
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
