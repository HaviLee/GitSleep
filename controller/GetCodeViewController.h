//
//  GetCodeViewController.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/19.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface GetCodeViewController : BaseViewController
@property (nonatomic, strong) void (^backToLoginButtonClicked)(NSUInteger index);
@property (nonatomic, strong) void (^registerButtonClicked)(NSString *phone);

@end
