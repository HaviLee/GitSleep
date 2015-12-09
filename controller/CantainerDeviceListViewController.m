//
//  CantainerDeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/12/8.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "CantainerDeviceListViewController.h"
#import "ContainerTableViewCell.h"
@interface CantainerDeviceListViewController ()

@property (nonatomic,strong) NSMutableArray *deviceArr;
@property (nonatomic, strong) NSString *selectDeviceUUID;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@end

@implementation CantainerDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0, 8.0);
    self.view.layer.shadowOpacity = 0.3;
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.cornerRadius = 4.0;
    self.view.layer.masksToBounds = YES;

    // Do any additional setup after loading the view.
    [self setSubView];
    [self getUserDeviceList];
}

- (void)setSubView
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:cancelButton];
    [cancelButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_x_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelView:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.width.height.equalTo(24);
    }];
    //title
    UILabel *titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.text = @"我的设备";
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor= selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cancelButton.centerY);
        make.height.equalTo(40);
        make.centerX.equalTo(self.view.centerX);
    }];
    
    [self.view addSubview:self.sideTableView];
    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    self.sideTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sideTableView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44);
    
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
    ContainerTableViewCell *cell = [[ContainerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.cellUserDescription = [NSString stringWithFormat:@"%@",[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"Description"]];
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"IsActivated"]isEqualToString:@"True"]) {
        cell.selectImageView.hidden = NO;
    }else{
        cell.selectImageView.hidden = YES;
        
    }
    if ([[[self.deviceArr objectAtIndex:indexPath.row] objectForKey:@"DetailDevice"] count]>0) {
        cell.cellIconImageView.image = [UIImage imageNamed:@"icon_double"];
    }else{
        cell.cellIconImageView.image = [UIImage imageNamed:@"icon_solo"];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];

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
            return [[obj1 objectForKey:@"UUID"] compare:[obj2 objectForKey:@"UUID"] options:NSCaseInsensitiveSearch];
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


- (void)cancelView:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    NSString *urlString = [NSString stringWithFormat:@"%@v1/user/ActivateUserDevice",BaseUrl];

    [WTRequestCenter putWithURL:urlString header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"数据是%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self cancelView:nil];
                thirdHardDeviceUUID = UUID;
            }];
            [MMProgressHUD dismiss];
        }else{
            [MMProgressHUD dismissWithError:[resposeDic objectForKey:@"ErrorMessage"] afterDelay:2];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    /*
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
    */
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
