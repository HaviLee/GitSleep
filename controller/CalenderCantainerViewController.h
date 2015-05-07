//
//  CalenderCantainerViewController.h
//  SleepRecoding
//
//  Created by Havi on 15/5/1.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"

@protocol SelectCalenderDate <NSObject>

- (void)selectedCalenderDate:(NSDate*)date;

@end

@interface CalenderCantainerViewController : BaseViewController
@property (nonatomic,strong) id<SelectCalenderDate> calenderDelegate;
@end
