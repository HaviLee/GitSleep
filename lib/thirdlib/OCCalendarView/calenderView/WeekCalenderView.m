//
//  WeekCalenderView.m
//  SleepRecoding
//
//  Created by Havi on 15/4/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "WeekCalenderView.h"
#import "AMBlurView.h"

@interface WeekCalenderView ()
@property (nonatomic,strong) AMBlurView *backView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;
@property (nonatomic,assign) NSInteger weekNums;
@end

@implementation WeekCalenderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.backView];
        CGFloat backWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat padding = 10;
        CGFloat buttonWidth = (backWidth - padding*8)/7;
        [self.backView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(134);
            make.height.equalTo(buttonWidth*8+65);
        }];
        //
        NSDate *today = [NSDate date];
        NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:tzGMT];
        NSInteger interval = [tzGMT secondsFromGMTForDate:today];
        NSDate *localeDate = [today dateByAddingTimeInterval:interval];
        self.weekNums = [localeDate getWeekNumsInOneYear];
    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (AMBlurView *)backView
{
    if (!_backView) {
        _backView = [[AMBlurView alloc]init];
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
    }
    return _backView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor colorWithRed:0.404f green:0.639f blue:0.784f alpha:1.00f];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        NSString *currentDate = [NSString stringWithFormat:@"%@",[NSDate date]];
        _titleLabel.text = [currentDate substringToIndex:4];
    }
    return _titleLabel;
}

- (UIButton *)leftCalButton
{
    if (!_leftCalButton) {
        _leftCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",0]] forState:UIControlStateNormal];
        [_leftCalButton addTarget:self action:@selector(reduceOneYear:) forControlEvents:UIControlEventTouchUpInside];
        _leftCalButton.tag = 102;
    }
    return _leftCalButton;
}

- (UIButton *)rightCalButton
{
    if (!_rightCalButton) {
        _rightCalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightCalButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_right_%d",0]] forState:UIControlStateNormal];
        [_rightCalButton addTarget:self action:@selector(addOneYear:) forControlEvents:UIControlEventTouchUpInside];
        _rightCalButton.tag = 101;
        [_rightCalButton setTintColor:[UIColor grayColor]];
    }
    return _rightCalButton;
}

- (void)reduceOneYear:(UIButton *)sender
{
    int titleNum = [self.titleLabel.text intValue];
    self.titleLabel.text = [NSString stringWithFormat:@"%d",titleNum-1];
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    [compt setYear:titleNum -1];
    [compt setMonth:1];
    [compt setDay:20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:compt];
    self.weekTitle = [NSString stringWithFormat:@"%d",titleNum -1];

    self.weekNums = [date getWeekNumsInOneYear];
    [self drawSubView];
}

- (void)addOneYear:(UIButton *)sender
{
    int titleNum = [self.titleLabel.text intValue];
    self.titleLabel.text = [NSString stringWithFormat:@"%d",titleNum+1];
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    [compt setYear:titleNum +1];
    [compt setMonth:1];
    [compt setDay:20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:compt];
    self.weekNums = [date getWeekNumsInOneYear];
    self.weekTitle = [NSString stringWithFormat:@"%d",titleNum +1];
    [self drawSubView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat backWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat padding = 10;
    CGFloat buttonWidth = (backWidth - padding*8)/7;
    if (touchPoint.y>buttonWidth*8+55 || touchPoint.y<113) {
        [self dismissView];
    }
}



- (void)dismissView
{
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawSubView];
}

- (void)drawSubView
{
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backView.centerX);
        make.height.equalTo(49);
        make.top.equalTo(5);
    }];
    self.titleLabel.text = self.weekTitle;
    //
    [self.backView addSubview:self.leftCalButton];
    [self.leftCalButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel.left).offset(-50);
    }];
    //
    [self.backView addSubview:self.rightCalButton];
    [self.rightCalButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.left.equalTo(self.titleLabel.right).offset(50);
    }];
    //
    CGFloat backWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat padding = 10;
    CGFloat buttonWidth = (backWidth - padding*8)/7;
    for (UIView *view in self.backView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&view.tag<self.weekNums+3) {
            [view removeFromSuperview];
        }
    }
    
    
    
//    NSDate *dateOut = nil;
//    NSTimeInterval count = 0;
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    [calendar setFirstWeekday:1];
//    NSDate *date = [calendar dateFromComponents:compt];
//    BOOL b = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&dateOut interval:&count forDate:date];
//    HaviLog(@"开始时间%@",dateOut);
    
    for (int i = 0; i<8; i++) {
        for (int j = 0; j<7; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            //            button.backgroundColor = [UIColor yellowColor];
            [button addTarget:self action:@selector(weekSelected:) forControlEvents:UIControlEventTouchUpInside];
            int monthNum = i*7 + j+1;
            [button setTitle:[NSString stringWithFormat:@"%d",monthNum] forState:UIControlStateNormal];
            button.tag = monthNum;
            if (self.currentWeekNum == monthNum) {
                [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
            }
            [button setTitleColor:[UIColor colorWithRed:0.404f green:0.639f blue:0.784f alpha:1.00f] forState:UIControlStateNormal];
            button.frame = CGRectMake(padding + j*(buttonWidth+padding), i*(buttonWidth) + 55, buttonWidth, buttonWidth);
            if (monthNum<self.weekNums+1) {
                [self.backView addSubview:button];
            }
            
        }
    }
    //
}

- (void)weekSelected:(UIButton *)sender
{
    int monthNum = (int)sender.tag;
    //    [self drawSubView];
    UIButton *button = (UIButton *)[self viewWithTag:monthNum];
    [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
    NSString *ymDate = [NSString stringWithFormat:@"%@年第%d周",self.titleLabel.text,monthNum];
    [self.delegate selectedWeek:ymDate];
    [self dismissView];
    HaviLog(@"selected");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
