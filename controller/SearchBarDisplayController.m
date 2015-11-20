//
//  SearchBarDisplayController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "SearchBarDisplayController.h"
#import "XHRealTimeBlur.h"
#import "SearchUserTableViewCell.h"
#import "UITableView+Common.h"
#import "UIView+Frame.h"
#import "CSSearchModel.h"
#import "TMCacheExtend.h"
#import "SHGetClient.h"
#import "RexpUntil.h"

@class DeviceListViewController;

@interface SearchBarDisplayController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,CustomCellProtocol>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;
//
@property (nonatomic, strong) NSArray *resultArr;
@property (nonatomic, strong) UIScrollView  *searchHistoryView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation SearchBarDisplayController


- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
        
        [_searchTableView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        [_contentView removeFromSuperview];
        _resultArr = [[NSMutableArray alloc]init];
        _searchTableView = nil;
        _contentView = nil;
        _backgroundView = nil;
        
        [super setActive:visible animated:animated];
    }else {
        
        [super setActive:visible animated:animated];
        NSArray *subViews = self.searchContentsController.view.subviews;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
            
            for (UIView *view in subViews) {
                
                if ([view isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
                    
                    NSArray *sub = view.subviews;
                    ((UIView*)sub[2]).hidden = YES;
                }
            }
        } else {
            
            [[subViews lastObject] removeFromSuperview];
        }
        
        if(!_contentView) {
            
            _contentView = ({
                
                UIView *view = [[UIView alloc] init];
                view.frame = CGRectMake(0.0f, 64.0f, kScreen_Width, kScreen_Height - 64.0f);
                view.backgroundColor = [UIColor lightGrayColor];
                view.userInteractionEnabled = YES;
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
                [view addGestureRecognizer:tapGestureRecognizer];
                
                view;
            });
            
            _backgroundView = ({
                
                XHRealTimeBlur *blur = [[XHRealTimeBlur alloc] initWithFrame:_contentView.frame];
                blur.blurStyle = XHBlurStyleBlackGradient;
                blur;
                
            });
            _backgroundView.userInteractionEnabled = NO;
            
            [self initSubViewsInContentView];
        }
        
        [self.parentVC.view addSubview:_backgroundView];
        [self.parentVC.view addSubview:_contentView];
        [self.parentVC.view bringSubviewToFront:_contentView];
        self.searchBar.delegate = self;
    }
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    
    [self.searchBar resignFirstResponder];
    [self.searchBar removeFromSuperview];
    [self.searchTableView removeFromSuperview];
    
    [_backgroundView removeFromSuperview];
    [_contentView removeFromSuperview];
    _searchTableView = nil;
    _contentView = nil;
    _backgroundView = nil;
}

#pragma mark Private Method

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc]init];
        _messageLabel.frame = CGRectMake(0, self.searchTableView.frame.size.height/2-100,self.parentVC.view.frame.size.width , 40);
        _messageLabel.text = @"没有相应的用户！";
        _messageLabel.font = [UIFont systemFontOfSize:17];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor lightGrayColor];
        
    }
    return _messageLabel;
}

- (void)initSubViewsInContentView {
    
//    UILabel *lblHotKey = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 4.0f, kScreen_Width, 39.0f)];
//    [lblHotKey setUserInteractionEnabled:YES];
//    [lblHotKey setText:@"热门话题"];
//    [lblHotKey setFont:[UIFont systemFontOfSize:12.0f]];
//    [lblHotKey setTextColor:[UIColor colorWithHexString:@"0x999999"]];
//    [_contentView addSubview:lblHotKey];
//    
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedMoreHotkey:)];
//    [lblHotKey addGestureRecognizer:tapGestureRecognizer];
//    
//    UIImageView *moreIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10.0f, 20.0f, 20.0f)];
//    moreIconView.image = [UIImage imageNamed:@"me_info_arrow_left"];
//    moreIconView.right = kScreen_Width - 12;
//    moreIconView.centerY = lblHotKey.centerY;
//    [_contentView addSubview:moreIconView];
//    
//    __weak typeof(self) weakSelf = self;
//    
//    _topicHotkeyView = [[TopicHotkeyView alloc] initWithFrame:CGRectMake(0, 44, kScreen_Width, 0)];
//    _topicHotkeyView.block = ^(NSDictionary *dict){
//        [weakSelf.searchBar resignFirstResponder];
//        
//        CSTopicDetailVC *vc = [[CSTopicDetailVC alloc] init];
//        vc.topicID = [dict[@"id"] intValue];
//        [weakSelf.parentVC.navigationController pushViewController:vc animated:YES];
//        
//    };
//    [_contentView addSubview:_topicHotkeyView];
//    [_topicHotkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(@0);
//        make.top.mas_equalTo(@44);
//        make.width.mas_equalTo(kScreen_Width);
//        make.height.mas_equalTo(@0);
//    }];
//    
//    [self initSearchHistoryView];
//    
//    [[Coding_NetAPIManager sharedManager] request_TopicHotkeyWithBlock:^(id data, NSError *error) {
//        if(data && _contentView) {
//            NSArray *array = data;
//            NSMutableArray *hotkeyArray = [[NSMutableArray alloc] initWithCapacity:6];
//            for (int i = 0; i < array.count; i++) {
//                if (i == 6) {
//                    break;
//                }
//                [hotkeyArray addObject:array[i]];
//            }
//            
//            [weakSelf.topicHotkeyView setHotkeys:hotkeyArray];
//            [weakSelf.topicHotkeyView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(@0);
//                make.top.mas_equalTo(@44);
//                make.width.mas_equalTo(kScreen_Width);
//                make.height.mas_equalTo(weakSelf.topicHotkeyView.frame.size.height);
//            }];
//        }
//    }];
}

#pragma mark -
#pragma mark UISearchBarDelegate Support

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
//    [CSSearchModel addSearchHistory:searchBar.text];
//    [self initSearchHistoryView];
    [self.searchBar resignFirstResponder];
//
    [self initSearchResultsTableView];
    [_searchTableView layoutSubviews];
    _resultArr = nil;
    HaviLog(@"搜索");
    [self searchUserList:(NSString *)self.searchBar.text];
    
}

//
- (void)searchUserList:(NSString *)searchText
{
    
    if (![RexpUntil checkTelNumber:self.searchBar.text]) {
        [self.searchTableView addSubview:self.messageLabel];
        self.messageLabel.text = @"请输入正确的手机号码!";
        return;
    }else{
        [self.messageLabel removeFromSuperview];
    }
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@",@"v1/user/FindUsers?SelectionCriteria=",self.searchBar.text];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [WTRequestCenter getWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] headers:header parameters:nil option:WTRequestCenterCachePolicyNormal finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [MMProgressHUD dismiss];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            _resultArr = [resposeDic objectForKey:@"UserList"];
            [self.searchTableView reloadData];
            [_searchTableView setNeedsLayout];
        }else{
            
        }
        if (_resultArr.count==0) {
            [self.searchTableView addSubview:self.messageLabel];
            self.messageLabel.text = @"没有对应用户哦！";
        }else{
            [self.messageLabel removeFromSuperview];
        }
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    HaviLog(@"取消");
    [self.searchTableView removeFromSuperview];

    [self.searchBar removeFromSuperview];
    
    [_backgroundView removeFromSuperview];
    [_contentView removeFromSuperview];
    _searchTableView = nil;
    _contentView = nil;
    _backgroundView = nil;
}

- (void)initSearchResultsTableView {
    
    if(!_searchTableView) {
        _searchTableView = ({
            
            UITableView *tableView = [[UITableView alloc] initWithFrame:_contentView.frame style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.delegate = self;
            
            [self.parentVC.parentViewController.view addSubview:tableView];
            
            
            tableView;
        });
    }
    [_searchTableView.superview bringSubviewToFront:_searchTableView];
    //    [self.searchBar.superview bringSubviewToFront:_searchTableView];
    
    //    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.searchTableView];
    //    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    [_searchTableView reloadData];
    
//    [self refresh];
}
#pragma mark custom delegate
- (void)customCell:(SearchUserTableViewCell *)cell didTapButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.searchTableView indexPathForCell:cell];
    HaviLog(@"点击了%ld",(long)indexPath.row);
    NSDictionary *userDic = [_resultArr objectAtIndex:indexPath.row];
    NSString *responseID = [userDic objectForKey:@"UserID"];
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
    };
    [[[MMAlertView alloc] initWithInputTitle:@"提示" detail:@"请输入验证信息，可以提高您的申请成功率" placeholder:@"我是***,希望查看您的设备" handler:^(NSString *text) {
        if (text.length==0) {
            [ShowAlertView showAlert:@"请输入您的验证信息"];
            return ;
        }
        NSString *commentString = text;
        [self sendMyRequest:commentString andUserId:responseID];
        
    }] showWithBlock:completeBlock];
}

#pragma mark UITableViewDelegate & UITableViewDataSource Support

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_resultArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIndentifier = @"cellIndentifier";
    SearchUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[SearchUserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    NSString *userName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,[[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserID"]];
    cell.cellUserIcon = url;
    if (userName.length==0) {
        cell.cellUserName = @"匿名用户";
    }else{
        cell.cellUserName = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"UserName"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellUserPhone = [[_resultArr objectAtIndex:indexPath.row]objectForKey:@"CellPhone"];
    
    cell.delegate = self;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)sendMyRequest:(NSString *)commentRequest andUserId:(NSString *)responseID
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
    NSString *urlString = [NSString stringWithFormat:@"%@",@"v1/user/RequestToAddFriend"];
    NSDictionary *para = @{
                           @"RequestUserId":thirdPartyLoginUserId,
                           @"ResponseUserId":responseID,
                           @"Comment":commentRequest,
                           };
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [WTRequestCenter postWithURL:[NSString stringWithFormat:@"%@%@",BaseUrl,urlString] header:header parameters:para finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *resposeDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [ShowAlertView showAlert:@"成功"];
        }
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [MMProgressHUD dismiss];
        
    } failed:^(NSURLResponse *response, NSError *error) {
        [MMProgressHUD dismiss];

    }];
    
}


@end
