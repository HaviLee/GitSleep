//
//  DatePickerView.m
//  DatePicker
//
//  Created by Havi_li on 15/3/3.
//  Copyright (c) 2015年 Havi_li. All rights reserved.
//

#import "DatePickerView.h"

@interface DatePickerView ()

@property (strong, nonatomic) DIDatepicker *datePicker;
//@property (strong, nonatomic) UIView *dateImage;


@end

@implementation DatePickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 30, self.frame.size.width, (self.frame.size.height-30))];
        _backImageView.image = [UIImage imageNamed:@""];
        _backImageView.userInteractionEnabled = YES;
        [self creatMonthButton];
        [self addSubview:_backImageView];
        [self creatBackView:_backImageView];
        [_backImageView addSubview:self.datePicker];
//        [self creatTapImage];

    }
    return self;
}

- (void)creatBackView:(UIImageView *)backView
{
    CGFloat currentItemXPosition = 10;
    for (int i = 0; i<7; i++) {
        int dateHeight = (self.frame.size.height - 20)*0.65/2;
        UIImageView *viewBack = [[UIImageView alloc]initWithFrame:CGRectMake(currentItemXPosition, (self.frame.size.height - 20)*0.35/2 + (dateHeight - ViewWidth)/2, ViewWidth, ViewWidth)];
        viewBack.layer.cornerRadius = (ViewWidth)/2;
        [backView addSubview:viewBack];
        if (i==3) {
            viewBack.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg_menology_%d",selectedThemeIndex]];
            [backView sendSubviewToBack:viewBack];
//            viewBack.backgroundColor = [UIColor colorWithRed:0.969f green:0.463f blue:0.388f alpha:1.00f];
        }else{
            viewBack.backgroundColor = [UIColor clearColor];
        }
        currentItemXPosition += ViewWidth + 10;
        
    }
}

- (void)creatMonthButton
{
    self.monthLabel = [[UILabel alloc]init];
    [self addSubview:_monthLabel];
    [_monthLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX).offset(0);
        make.top.equalTo(self.top).offset(0);
        make.height.equalTo(30);
    }];
    self.calenderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_calenderButton];
    [_calenderButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@20);
        make.centerY.equalTo(_monthLabel.centerY);
        make.left.equalTo(_monthLabel.right).offset(5);
    }];
    self.backLine = [[UIImageView alloc]init];
    self.backLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self addSubview:self.backLine];
    [_backLine makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.equalTo(self.monthLabel.bottom).offset(0);
        make.left.equalTo(self.monthLabel.left);
        make.right.equalTo(_calenderButton.right).offset(0);
    }];
    
//    UIImageView *imageRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_triangle_right"]];
//    [self addSubview:imageRight];
//    [imageRight makeConstraints:^(MASConstraintMaker *make) {
//        make.height.width.equalTo(@15);
//        make.centerY.equalTo(_monthLabel.centerY);
//        make.left.equalTo(_monthLabel.right).offset(5);
//    }];
}

- (DIDatepicker *)datePicker
{
    if (!_datePicker) {
        
        NSDate *date = [NSDate date];
        //系统时区
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        //和格林尼治时间差
        NSInteger timeOff = [zone secondsFromGMT];
        //视察转化
        NSDate *timeOffDate = [date dateByAddingTimeInterval:timeOff];
        
        
        _datePicker = [[DIDatepicker alloc]initWithFrame:CGRectMake(0, (self.frame.size.height - 20)*0.35/2, self.frame.size.width, (self.frame.size.height - 20)*0.65)];
//        _datePicker.backgroundColor = [UIColor redColor];
        [_datePicker fillCurrentYear:timeOffDate];
        [_datePicker addTarget:self action:@selector(updateDate) forControlEvents:UIControlEventValueChanged];
        NSMutableString *dateString = [NSMutableString stringWithFormat:@"%@",timeOffDate];
        NSString *anew = [dateString substringToIndex:10];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        NSTimeZone *time = [NSTimeZone timeZoneWithName:@"GMT"];
        dateFormatter.timeZone = time;
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *d = [dateFormatter dateFromString:anew];
        NSInteger index = [_datePicker indexOfdateInYear:d];
        self.monthLabel.text = [NSString stringWithFormat:@"%@",d];
        [_datePicker selectDateAtIndex:index];
    }
    return _datePicker;
}

#pragma mark 更新年份
- (void)caculateCurrentYearDate:(NSDate*)currentDate
{
    [self.datePicker fillCurrentYear:currentDate];
}

- (void)updateDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString = [formatter stringFromDate:_datePicker.selectedDate];
    _monthLabel.text = [dateString substringToIndex:8];
    [self.dateDelegate getScrollSelectedDate:_datePicker.selectedDate];
}

- (void)updateCalenderSelectedDate:(NSDate*)selectedDate
{
    NSString *string = [NSString stringWithFormat:@"%@",selectedDate];
    NSTimeZone *time = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = time;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@",[string substringWithRange:NSMakeRange(0, 4)],[string substringWithRange:NSMakeRange(5, 2)],[string substringWithRange:NSMakeRange(8, 2)]];
    NSDate *d = [dateFormatter dateFromString:newDate];
    if ([self.datePicker.dates containsObject:d]) {
        NSInteger index = [_datePicker indexOfdateInYear:d];
        [_datePicker selectDateAtIndex:index];
    }else{
        [self.datePicker fillCurrentYear:d];
    }
    
}

- (void)updateSelectedDate:(NSString *)selectedDate
{
    NSString *anew = [selectedDate substringToIndex:8];
    self.monthLabel.text = anew;
    //[NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    NSTimeZone *time = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = time;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@",[selectedDate substringWithRange:NSMakeRange(0, 4)],[selectedDate substringWithRange:NSMakeRange(5, 2)],[selectedDate substringWithRange:NSMakeRange(8, 2)]];
    NSDate *d = [dateFormatter dateFromString:newDate];
    NSInteger index = [_datePicker indexOfdateInYear:d];
    [_datePicker selectDateAtIndex:index];
    //
}

- (void)creatTapImage
{
    CGFloat currentItemXPosition = 10;
    for (int i = 0; i<7; i++) {
        UIView *viewBack = [[UIView alloc]initWithFrame:CGRectMake(currentItemXPosition, (self.frame.size.height-35)*0.65+35, ViewWidth, (self.frame.size.height-35)*0.35)];
        [self addSubview:viewBack];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(viewBack.frame.size.width/2-10, viewBack.frame.size.height/2-10, 20, 20)];
        [viewBack addSubview:imageView];
        if (i==3) {
            imageView.image = [UIImage imageNamed:@"icon_solid_circle"];
        }else{
            imageView.image = [UIImage imageNamed:@"icon_imaginary"];
        }
        currentItemXPosition += ViewWidth + 10;
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
