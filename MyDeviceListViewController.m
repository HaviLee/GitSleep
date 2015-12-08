//
//  MyDeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/12/2.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "MyDeviceListViewController.h"
#import "ODRefreshControl.h"
#import "MyDeviceListCell.h"
#import "ChangeUUIDAPI.h"
#import "JAActionButton.h"
#import "ReNameDeviceNameViewController.h"
#import "DoubleDUPViewController.h"
#import "UDPAddProductViewController.h"
#import "ReNameDoubleDeviceViewController.h"

@interface MyDeviceListViewController ()<JASwipeCellDelegate>

@property (nonatomic,strong) NSMutableArray *deviceArr;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic, strong) JASwipeCell *selectTableViewCell;
@property (nonatomic, strong) NSString *selectDeviceUUID;


@property (nonatomic, strong) ODRefreshControl *refreshControl;

@end

@implementation MyDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    //
    self.bgImageView.image = [UIImage imageNamed:@""];
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.sideTableView];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view.bottom).offset(0);
        make.right.equalTo(self.view.right).offset(0);
    }];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.sideTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self getUserDeviceList];
}

- (void)refresh{
    
    HaviLog(@"刷新ok");
    [self getUserDeviceList];
    
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
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"请求的设备列表是%@",resposeDic);
        
        [self.refreshControl endRefreshing];
        self.deviceArr = [resposeDic objectForKey:@"DeviceList"];
        if (self.deviceArr.count == 0) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
            }];
            
            [self.view makeToast:@"您还没有绑定设备" duration:2 position:@"center"];
        }
        [self.sideTableView reloadData];
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

#pragma mark tableview 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell%ld",(long)indexPath.row];
    MyDeviceListCell *cell = [[MyDeviceListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    [cell addActionButtons:[self rightButtons] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationRight];
    cell.cellUserDescription = [NSString stringWithFormat:@"%@",[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"]];
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
        cell.selectImageView.hidden = NO;
    }else{
        cell.selectImageView.hidden = YES;
        
    }
    cell.delegate = self;
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"] count]>0) {
        cell.cellIconImageView.image = [UIImage imageNamed:@"icon_double"];
    }else{
        cell.cellIconImageView.image = [UIImage imageNamed:@"icon_solo"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPath = indexPath;
    [tableView reloadData];
    [self changeUUID:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
    thirdHardDeviceUUID = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"];
    thirdHardDeviceName = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"];
    thirdLeftDeviceUUID = @"";
    thirdRightDeviceUUID = @"";
    thirdLeftDeviceName = @"";
    thirdRightDeviceName = @"";
    isMineDevice = @"YES";

    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"] count]>0) {
        NSArray *_arrDeatilListDescription = [[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"];
        NSArray *_sortedDetailDevice = [_arrDeatilListDescription sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 objectForKey:@"UUID"]<[obj1 objectForKey:@"UUID"];
        }];
        thirdLeftDeviceName = [[_sortedDetailDevice objectAtIndex:0]objectForKey:@"Description"];
        thirdLeftDeviceUUID = [[_sortedDetailDevice objectAtIndex:0]objectForKey:@"UUID"];
        thirdRightDeviceName = [[_sortedDetailDevice objectAtIndex:1]objectForKey:@"Description"];
        thirdRightDeviceUUID = [[_sortedDetailDevice objectAtIndex:1]objectForKey:@"UUID"];
        isDoubleDevice = YES;
    }
    [UserManager setGlobalOauth];
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGEDEVICEUUID object:nil];
    /*
     切换uuid
     */
}
//使得tableview顶格
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

#pragma mark 切换uuid
- (void)changeUUID:(NSString *)UUID
{
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
                thirdHardDeviceUUID = UUID;
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

- (NSArray *)rightButtons
{
    __typeof(self) __weak weakSelf = self;
    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"删除" color:[UIColor redColor] handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.sideTableView indexPathForCell:cell];
        [weakSelf deleteFriendDevice:[[weakSelf.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
        NSLog(@"Right Button: Archive Pressed");
    }];
    
    JAActionButton *button2 = [JAActionButton actionButtonWithTitle:@"重命名" color:kFlagButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.sideTableView indexPathForCell:cell];
        [weakSelf renameFriendDevice:indexPath];
        NSLog(@"Right Button: Flag Pressed");
    }];
    JAActionButton *button3 = [JAActionButton actionButtonWithTitle:@"重激活" color:kMoreButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell) {
        weakSelf.selectTableViewCell = cell;
        NSIndexPath *indexPath = [weakSelf.sideTableView indexPathForCell:cell];
        [weakSelf reActiveFriendDevice:indexPath];
        NSLog(@"Right Button: More Pressed");
    }];
    
    return @[button1, button2, button3];
}

- (void)leftMostButtonSwipeCompleted:(JASwipeCell *)cell
{
    
}

- (void)rightMostButtonSwipeCompleted:(JASwipeCell *)cell
{
    NSLog(@"左滑到底");
    self.selectTableViewCell = cell;
    NSIndexPath *indexPath = [self.sideTableView indexPathForCell:cell];
    [self deleteFriendDevice:[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"UUID"]];
}
#pragma mark 操作设备

- (void)deleteFriendDevice:(NSString *)deviceUUID
{
    self.selectDeviceUUID = deviceUUID;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"您确认删除该设备？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.tag = 1001;
    [alertView show];
}

#pragma mark - JASwipeCellDelegate methods

- (void)swipingRightForCell:(JASwipeCell *)cell
{
    NSArray *indexPaths = [self.sideTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *visibleCell = (JASwipeCell *)[self.sideTableView cellForRowAtIndexPath:indexPath];
        if (visibleCell != cell) {
            [visibleCell resetContainerView];
        }
        
    }
}

- (void)swipingLeftForCell:(JASwipeCell *)cell
{
    NSArray *indexPaths = [self.sideTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *visibleCell = (JASwipeCell *)[self.sideTableView cellForRowAtIndexPath:indexPath];
        if (visibleCell != cell) {
            [visibleCell resetContainerView];
        }
        
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *indexPaths = [self.sideTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        MyDeviceListCell *cell = (MyDeviceListCell *)[self.sideTableView cellForRowAtIndexPath:indexPath];
        [cell resetContainerView];
    }
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
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/DeleteUserDevice",BaseUrl];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSDictionary *para = @{
                           @"UserID":thirdPartyLoginUserId,
                           @"UUID": deviceUUID,
                           };
    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",obj);
        if ([[obj objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [self getUserDeviceList];
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
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"] count]>0) {
        ReNameDoubleDeviceViewController *name = [[ReNameDoubleDeviceViewController alloc]init];
        name.deviceInfo = [self.deviceArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:name animated:YES];
    }else{
        ReNameDeviceNameViewController *name = [[ReNameDeviceNameViewController alloc]init];
        name.deviceInfo = [self.deviceArr objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:name animated:YES];
    }
}

- (void)reActiveFriendDevice:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.deviceArr objectAtIndex:indexPath.row];
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"] count]>0) {
        DoubleDUPViewController *udp = [[DoubleDUPViewController alloc]init];
        udp.productName = [dic objectForKey:@"Description"];//测试
        thirdHardDeviceUUID = [dic objectForKey:@"UUID"];
        udp.productUUID = [dic objectForKey:@"UUID"];
        [self.navigationController pushViewController:udp animated:YES];
    }else{
        UDPAddProductViewController *udp = [[UDPAddProductViewController alloc]init];
        udp.productName = [dic objectForKey:@"Description"];;
        thirdHardDeviceUUID = [dic objectForKey:@"UUID"];
        udp.productUUID = [dic objectForKey:@"UUID"];
        [self.navigationController pushViewController:udp animated:YES];
    }
}



//在界面出现的时候进行刷新数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取数据
    [self getUserDeviceList];
}
- (void)refreshBegining
{
    [self refresh];
    
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
