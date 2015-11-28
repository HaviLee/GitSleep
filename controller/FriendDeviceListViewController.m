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
@interface FriendDeviceListViewController ()<JASwipeCellDelegate>

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
//    return self.resultArr.count;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cellIndentifier%ld",(long)indexPath.row];
    
    FriendMessageTableViewCell *cell = [[FriendMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    //测试
//    [cell addActionButtons:[self leftButtons] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationLeft];
    [cell addActionButtons:[self rightButtons] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationRight];
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
    
//
    cell.delegate = self;
    cell.cellUserDescription = @"哈维床垫";
    cell.cellUserName = @"小白";
    cell.cellUserPhone = @"13122785292";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

//
- (NSArray *)leftButtons
{
    __typeof(self) __weak weakSelf = self;
    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"Delete" color:[UIColor redColor] handler:^(UIButton *actionButton, JASwipeCell*cell) {
        [cell completePinToTopViewAnimation];
        [weakSelf leftMostButtonSwipeCompleted:cell];
        NSLog(@"Left Button: Delete Pressed");
    }];
    
    JAActionButton *button2 = [JAActionButton actionButtonWithTitle:@"Mark as unread" color:kUnreadButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mark As Unread" message:@"Done!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Left Button: Mark as unread Pressed");
    }];
    
    return @[button1, button2];
}

- (NSArray *)rightButtons
{
    __typeof(self) __weak weakSelf = self;
    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"Archive" color:kArchiveButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        [cell completePinToTopViewAnimation];
        [weakSelf rightMostButtonSwipeCompleted:cell];
        NSLog(@"Right Button: Archive Pressed");
    }];
    
    JAActionButton *button2 = [JAActionButton actionButtonWithTitle:@"Flag" color:kFlagButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag" message:@"Flag pressed!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Right Button: Flag Pressed");
    }];
    JAActionButton *button3 = [JAActionButton actionButtonWithTitle:@"More" color:kMoreButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"More Options" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Option 1" otherButtonTitles:@"Option 2",nil];
        [sheet showInView:weakSelf.view];
        NSLog(@"Right Button: More Pressed");
    }];
    
    return @[button1, button2, button3];
}

- (void)leftMostButtonSwipeCompleted:(JASwipeCell *)cell
{
    NSIndexPath *indexPath = [self.myDeviceListView indexPathForCell:cell];
//    [self.tableData removeObjectAtIndex:indexPath.row];
    
    [self.myDeviceListView beginUpdates];
    [self.myDeviceListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.myDeviceListView endUpdates];
}

- (void)rightMostButtonSwipeCompleted:(JASwipeCell *)cell
{
    NSIndexPath *indexPath = [self.myDeviceListView indexPathForCell:cell];
//    [self.tableData removeObjectAtIndex:indexPath.row];
    
    [self.myDeviceListView beginUpdates];
    [self.myDeviceListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.myDeviceListView endUpdates];
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



/*
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

*/
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
