//
//  RegisterViewController.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController
@property (nonatomic, strong) NSString *cellPhoneNum;
@property (nonatomic, strong) void (^backToCodeButtonClicked)(NSUInteger index);
@property (nonatomic, strong) void (^registerSuccessed)(NSUInteger index);
@end
