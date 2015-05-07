//
//  CalenderView.m
//  SleepRecoding
//
//  Created by Havi on 15/4/13.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CalenderView.h"
#import "AMBlurView.h"
#import "WQCalendarLogic.h"
#import "WQDraggableCalendarView.h"

@interface CalenderView ()<WQCalendarLogicDelegate>

@property (nonatomic, strong) UILabel *monthLabel;

@property (nonatomic,strong) AMBlurView *backView;
@property (nonatomic, strong) WQDraggableCalendarView *calendarView;
@property (nonatomic, strong) WQCalendarLogic *calendarLogic;

@end

@implementation CalenderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.calendarLogic = [[WQCalendarLogic alloc] init];
        self.calendarLogic.delegate = self;
        [self addSubview:self.backView];
        [self.backView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(64);
            make.height.equalTo(330);
        }];
        //
    }
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    return self;
}

- (AMBlurView *)backView
{
    if (!_backView) {
        _backView = [[AMBlurView alloc]init];
        _backView.layer.cornerRadius = 5;
        _backView.userInteractionEnabled = YES;
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
}

- (void)drawRect:(CGRect)rect
{
    [self showCalendar];
    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    preBtn.frame = (CGRect){25, 0, 60, 44};
    [preBtn addTarget:self action:@selector(goToPreviousMonth:) forControlEvents:UIControlEventTouchUpInside];
    [preBtn setImage:[UIImage imageNamed:@"btn_back_left_calender"] forState:UIControlStateNormal];
//    [preBtn setTitle:@"上一月" forState:UIControlStateNormal];
    preBtn.alpha = 0.7;
    [self.backView addSubview:preBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextBtn.frame = (CGRect){235, 0, 60, 44};
    [nextBtn addTarget:self action:@selector(goToNextMonth:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.alpha = 0.7;
//    [nextBtn setTitle:@"下一月" forState:UIControlStateNormal];
    [nextBtn setImage:[UIImage imageNamed:@"btn_back_calender"] forState:UIControlStateNormal];
    [self.backView addSubview:nextBtn];
    
    CGRect labelRect = (CGRect){110, 0, 100, 44};
    self.monthLabel = [[UILabel alloc] initWithFrame:labelRect];
    self.monthLabel.textAlignment = NSTextAlignmentCenter;
    self.monthLabel.text = [NSString stringWithFormat:@"%lu年%lu月", (unsigned long)self.calendarLogic.selectedCalendarDay.year, (unsigned long)self.calendarLogic.selectedCalendarDay.month];
    self.monthLabel.textColor = [UIColor colorWithRed:0.314f green:0.486f blue:0.698f alpha:1.00f];
    [self.backView addSubview:self.monthLabel];
}

#pragma mark -

- (void)goToNextMonth:(id)sender
{
    [self.calendarLogic goToNextMonthInCalendarView:self.calendarView];
    self.monthLabel.text = [NSString stringWithFormat:@"%lu年%lu月", (unsigned long)self.calendarLogic.selectedCalendarDay.year, (unsigned long)self.calendarLogic.selectedCalendarDay.month];
}

- (void)goToPreviousMonth:(id)sender
{
    [self.calendarLogic goToPreviousMonthInCalendarView:self.calendarView];
    self.monthLabel.text = [NSString stringWithFormat:@"%lu年%lu月", (unsigned long)self.calendarLogic.selectedCalendarDay.year, (unsigned long)self.calendarLogic.selectedCalendarDay.month];
}

- (void)calendarSelectedNewDate:(NSDate *)newDate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedDate:)]) {
        [self.delegate selectedDate:newDate];
    }
}

- (void)showCalendar
{
//    calendarRect.origin.y += 52, calendarRect.size.height -= 52;
    self.calendarView = [[WQDraggableCalendarView alloc] initWithFrame:CGRectMake(0, 44, self.backView.frame.size.width, 330)];
    self.calendarView.draggble = NO;
    [self.backView addSubview:self.calendarView];
    self.calendarView.backgroundColor = [UIColor clearColor];
    [self.calendarLogic reloadCalendarView:self.calendarView];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.y>364 || touchPoint.y<64) {
        [self dismissView];
    }
}


- (void)dismissView
{
    [self removeFromSuperview];
//    self.backView = nil;
//    self.calendarLogic = nil;
//    self.calendarView = nil;
}

#pragma mark 

@end
