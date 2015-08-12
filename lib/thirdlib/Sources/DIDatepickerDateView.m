//
//  Created by Dmitry Ivanenko on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import "DIDatepickerDateView.h"


const CGFloat kDIDatepickerItemWidth = 46.;
const CGFloat kDIDatepickerSelectionLineWidth = 51.;


@interface DIDatepickerDateView ()

@property (strong, nonatomic) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *dateTitleLabel;
@property (nonatomic, strong) UIView *selectionView;

@end


@implementation DIDatepickerDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self setupViews];

    return self;
}

- (void)setupViews
{
    [self addTarget:self action:@selector(dateWasSelected) forControlEvents:UIControlEventTouchUpInside];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeColor:) name:RELOADIMAGE object:nil];
}

//- (void)changeColor:(NSNotification *)noti
//{
//    self.dateTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor blackColor];
//    self.dateLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor blackColor];
//}

- (void)setDate:(NSDate *)date
{
    _date = date;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd"];
    NSString *dayFormattedString = [dateFormatter stringFromDate:date];

    [dateFormatter setDateFormat:@"EEE"];
    NSString *dayInWeekFormattedString = [dateFormatter stringFromDate:date];

    [dateFormatter setDateFormat:@"MMMM"];
//    NSString *monthFormattedString = [[dateFormatter stringFromDate:date] uppercaseString];
    NSMutableAttributedString *dateAttributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",dayFormattedString]];
    NSMutableAttributedString *dateTitleAttributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self getChinaWeekDay:[dayInWeekFormattedString uppercaseString]]]];
    [dateTitleAttributeString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:15],
                                NSForegroundColorAttributeName: selectedThemeIndex==0?[UIColor whiteColor]:[UIColor grayColor]
                                }
                        range:NSMakeRange(0, dateTitleAttributeString.length)];

//    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",  [dayInWeekFormattedString uppercaseString],dayFormattedString]];
//
//
//    [dateString addAttributes:@{
//                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:15],
//                                NSForegroundColorAttributeName: [UIColor blackColor]
//                                }
//                        range:NSMakeRange(dayInWeekFormattedString.length + 1, dayFormattedString.length)];

//    [dateString addAttributes:@{
//                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:8],
//                                NSForegroundColorAttributeName: [UIColor colorWithRed:153./255. green:153./255. blue:153./255. alpha:1.]
//                                }
//                        range:NSMakeRange(dateString.string.length - monthFormattedString.length, monthFormattedString.length)];

//    if ([self isWeekday:date]) {
//        [dateString addAttribute:NSFontAttributeName
//                           value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]
//                           range:NSMakeRange(dayFormattedString.length + 1, dayInWeekFormattedString.length)];
//    }

    self.dateLabel.attributedText = dateAttributeString;
    self.dateLabel.font = [UIFont systemFontOfSize:20];
    self.dateTitleLabel.attributedText = dateTitleAttributeString;
    self.dateTitleLabel.font = [UIFont systemFontOfSize:20];
}
- (NSString *)getChinaWeekDay:(NSString*)enDay
{
    NSRange range = [enDay rangeOfString:@"周"];
    if (range.length>0) {
        NSString *subString = [enDay substringFromIndex:1];
        return subString;
    }else{
        return enDay;
    }
//    if ([enDay containsString:@"周"]) {
//        NSString *subString = [enDay substringFromIndex:1];
//        return subString;
//    }else{
//    }
    
//    if ([enDay isEqualToString:@"WED"]) {
//        return @"三";
//    }else if ([enDay isEqualToString:@"THU"]){
//        return @"四";
//    }else if ([enDay isEqualToString:@"FRI"]){
//        return @"五";
//    }else if ([enDay isEqualToString:@"SAT"]){
//        return @"六";
//    }else if ([enDay isEqualToString:@"SUN"]){
//        return @"日";
//    }else if ([enDay isEqualToString:@"MON"]){
//        return @"一";
//    }else if([enDay isEqualToString:@"TUE"]){
//        return @"二";
//    }else{
//        return nil;
//    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;

    self.selectionView.alpha = (int)_isSelected;
    if (isSelected) {
        self.dateTitleLabel.textColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor whiteColor];
    }else{
        self.dateTitleLabel.textColor = selectedThemeIndex==0?[UIColor whiteColor]:[UIColor whiteColor];
        self.dateLabel.textColor = selectedThemeIndex==0?[UIColor whiteColor]:[UIColor whiteColor];
    }
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2)];
        _dateLabel.numberOfLines = 2;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dateLabel];
        _dateLabel.textColor = selectedThemeIndex==0?[UIColor whiteColor]:[UIColor grayColor];;
    }
//    _dateLabel.backgroundColor = [UIColor redColor];
    return _dateLabel;
}

- (UILabel *)dateTitleLabel{
    if (!_dateTitleLabel) {
        _dateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, self.bounds.size.height/2)];
        _dateTitleLabel.numberOfLines = 2;
        _dateTitleLabel.textAlignment = NSTextAlignmentCenter;
        _dateTitleLabel.textColor = selectedThemeIndex==0?[UIColor whiteColor]:[UIColor grayColor];
        [self addSubview:_dateTitleLabel];
    }
    
    
    return _dateTitleLabel;
}

- (UIView *)selectionView
{
    if (!_selectionView) {
        _selectionView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 51) / 2, self.frame.size.height - 3, 51, 3)];
        _selectionView.alpha = 0;
        _selectionView.backgroundColor = [UIColor colorWithRed:242./255. green:93./255. blue:28./255. alpha:1.];
        [self addSubview:_selectionView];
    }

    return _selectionView;
}

- (void)setItemSelectionColor:(UIColor *)itemSelectionColor
{
    
    self.selectionView.backgroundColor = itemSelectionColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.selectionView.alpha = self.isSelected ? 1 : .5;
    } else {
        self.selectionView.alpha = self.isSelected ? 1 : 0;
    }
    
}


#pragma mark Other methods

- (BOOL)isWeekday:(NSDate *)date
{
    NSInteger day = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date] weekday];

    const NSInteger kSunday = 1;
    const NSInteger kSaturday = 7;

    BOOL isWeekdayResult = day == kSunday || day == kSaturday;

    return isWeekdayResult;
}

- (void)dateWasSelected
{
    self.isSelected = YES;

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
