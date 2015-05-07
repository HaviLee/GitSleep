//
//  WeekCalenderView.h
//  SleepRecoding
//
//  Created by Havi on 15/4/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+NSDateLogic.h"

@protocol SelectedWeek <NSObject>

- (void)selectedWeek:(NSString *)monthString;

@end

@interface WeekCalenderView : UIView
@property (nonatomic,strong) NSString *weekTitle;
@property (nonatomic,strong) id<SelectedWeek>delegate;
@property (nonatomic,assign) int currentWeekNum;
@end
