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
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    FriendMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FriendMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
