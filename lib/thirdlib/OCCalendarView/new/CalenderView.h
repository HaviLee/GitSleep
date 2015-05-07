//
//  CalenderView.h
//  SleepRecoding
//
//  Created by Havi on 15/4/13.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedDate <NSObject>

- (void)selectedDate:(NSDate *)selectedDate;

@end

@interface CalenderView : UIView

@property (nonatomic,strong) id<SelectedDate>delegate;

@end
