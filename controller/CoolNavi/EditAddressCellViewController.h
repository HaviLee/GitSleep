//
//  EditAddressCellViewController.h
//  SleepRecoding
//
//  Created by Havi on 15/10/9.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@interface EditAddressCellViewController : BaseViewController

@property (nonatomic, copy) void (^saveButtonClicked)(NSUInteger index);

@property (nonatomic,strong) NSString *cellInfoType;
@property (nonatomic,strong) NSString *cellInfoString;

@end
