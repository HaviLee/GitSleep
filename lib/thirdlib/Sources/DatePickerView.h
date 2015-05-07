//
//  DatePickerView.h
//  DatePicker
//
//  Created by Havi_li on 15/3/3.
//  Copyright (c) 2015年 Havi_li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DIDatepicker.h"

@protocol SetScrollDateDelegate <NSObject>

- (void)getScrollSelectedDate:(NSDate *)date;

@end

@interface DatePickerView : UIView

- (instancetype)initWithFrame:(CGRect)frame;
@property (strong, nonatomic) id<SetScrollDateDelegate> dateDelegate;
@property (nonatomic,strong) UIButton *calenderButton;
@property (strong, nonatomic) UILabel *monthLabel;
@property (strong, nonatomic) UIImageView *backImageView;
@property (strong ,nonatomic) UIImageView *backLine;

- (void)updateSelectedDate:(NSString *)selectedDate;
- (void)caculateCurrentYearDate:(NSDate*)currentDate;
- (void)updateCalenderSelectedDate:(NSDate*)selectedDate;
@end
