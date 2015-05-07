//
//  AppDelegate.h
//  SleepRecoding
//
//  Created by Havi on 15/2/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDPController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)  UDPController* udpController;
@property (strong, nonatomic) UIWindow *window;


@end

