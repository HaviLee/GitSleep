//
//  EditCellInfoViewController.h
//  SleepRecoding
//
//  Created by Havi on 15/10/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface EditCellInfoViewController : BaseViewController

@property (nonatomic, copy) void (^saveButtonClicked)(NSUInteger index);

@property (nonatomic,strong) NSString *cellInfoType;

@end
