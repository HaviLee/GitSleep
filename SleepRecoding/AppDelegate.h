//
//  AppDelegate.h
//  SleepRecoding
//
//  Created by Havi on 15/2/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDPController.h"
#import "RESideMenu.h"
#import "CenterViewController.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)  UDPController* udpController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RESideMenu *sideMenuController;
@property (strong, nonatomic) CenterViewController *centerViewController;
//
@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;
@property (strong, nonatomic) TencentOAuth *tencentOAuth;

-(void) setWifiNotification;

@end

