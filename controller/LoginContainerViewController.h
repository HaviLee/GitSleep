//
//  LoginContainerViewController.h
//  SleepRecoding
//
//  Created by Havi on 15/7/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginContainerViewController : BaseViewController

@property (nonatomic, copy) void (^loginSuccessed)(NSUInteger index);

@end
