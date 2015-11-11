//
//  DeviceListViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DeviceListViewController.h"
#import "MyDeviceListViewController.h"
#import "FriendDeviceListViewController.h"

@interface DeviceListViewController ()

@property UISegmentedControl *segmentTitle;
@property MyDeviceListViewController *myDeviceList;
@property FriendDeviceListViewController *friendDeviceList;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigationBar];
    [self setNaviTitleView];
}

- (void)initNavigationBar
{
    [self createNavWithTitle:@"" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             return self.menuButton;
         }else if (nIndex == 0){
             self.rightButton.frame = CGRectMake(self.view.frame.size.width-35, 12, 20, 20);
             [self.rightButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"search"]] forState:UIControlStateNormal];
             [self.rightButton addTarget:self action:@selector(searchDevice:) forControlEvents:UIControlEventTouchUpInside];
             return self.rightButton;
         }
         
         return nil;
     }];
}

//设置导航栏中的titleView
- (void)setNaviTitleView
{
    self.segmentTitle = [[UISegmentedControl alloc] initWithItems:@[@"我的设备", @"他人设备"]];
    self.segmentTitle.selectedSegmentIndex = 0;
//    self.segmentTitle.tintColor = [UIColor whiteColor];
    self.segmentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segmentTitle.frame = CGRectMake(70, 30, self.view.frame.size.width-140, 25);
    [self.segmentTitle addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentTitle];
    _myDeviceList = [[MyDeviceListViewController alloc]init];
    _myDeviceList.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    _myDeviceList.view.tag = 1001;
    _friendDeviceList = [[FriendDeviceListViewController alloc]init];
    _friendDeviceList.view.tag = 1002;
    [self addChildViewController:_myDeviceList];
    [self addChildViewController:_friendDeviceList];
    [self.view addSubview:_myDeviceList.view];
}

//选择控件的事件
- (void)switchView
{
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == 1001 || subview.tag == 1002) {
            [subview removeFromSuperview];
        }
    }
    
    switch (_segmentTitle.selectedSegmentIndex) {
        case 0: {
            [self.view addSubview:_myDeviceList.view];
            _myDeviceList.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
//            _myDeviceList.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 1: {
            [self.view addSubview:_friendDeviceList.view];
            _friendDeviceList.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
//            _friendDeviceList.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            break;
        }
        default:
            break;
    }
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
