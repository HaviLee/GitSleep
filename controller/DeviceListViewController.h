//
//  DeviceListViewController.h
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchBarDisplayController.h"

@interface DeviceListViewController : BaseViewController

//搜索
@property (nonatomic, strong) UISearchBar       *searchBar;
@property (strong, nonatomic) SearchBarDisplayController *searchDisplayVC;

@end
