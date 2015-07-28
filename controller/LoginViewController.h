//
//  LoginViewController.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (nonatomic, copy) void (^getCodeButtonClicked)(NSUInteger index);
@property (nonatomic, copy) void (^loginButtonClicked)(NSUInteger index);
@end
