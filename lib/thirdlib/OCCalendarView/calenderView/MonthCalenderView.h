//
//  MonthCalenderView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedMonth <NSObject>

- (void)selectedMonth:(NSString *)monthString;

@end

@interface MonthCalenderView : UIView

@property (nonatomic,strong) NSString *monthTitle;
@property (nonatomic,strong) id<SelectedMonth>delegate;
@property (nonatomic,assign) int currentMonthNum;

@end
