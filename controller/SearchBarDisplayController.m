//
//  SearchBarDisplayController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "SearchBarDisplayController.h"
#import "XHRealTimeBlur.h"
@class DeviceListViewController;

@interface SearchBarDisplayController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) XHRealTimeBlur *backgroundView;

@end

@implementation SearchBarDisplayController


- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    
    if(!visible) {
        
        [_searchTableView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        [_contentView removeFromSuperview];
        
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
                view.backgroundColor = [UIColor redColor];
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
}

#pragma mark Private Method

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
//    [self.searchBar resignFirstResponder];
//    
//    [self initSearchResultsTableView];
    HaviLog(@"搜索");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    HaviLog(@"取消");
    
    [self.searchBar removeFromSuperview];
    
    [_searchTableView removeFromSuperview];
    [_backgroundView removeFromSuperview];
    [_contentView removeFromSuperview];

    _searchTableView = nil;
    _contentView = nil;
    _backgroundView = nil;
}


@end
