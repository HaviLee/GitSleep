//
//  MonthCalenderView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//
#import "AMBlurView.h"
#import "MonthCalenderView.h"

@interface MonthCalenderView ()
@property (nonatomic,strong) AMBlurView *backView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;

@end

@implementation MonthCalenderView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.backView];
        [self.backView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(113);
            make.height.equalTo(200);
        }];
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
        [_leftCalButton setTintColor:[UIColor grayColor]];
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
}

- (void)addOneYear:(UIButton *)sender
{
    int titleNum = [self.titleLabel.text intValue];
    self.titleLabel.text = [NSString stringWithFormat:@"%d",titleNum+1];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.y>313 || touchPoint.y<113) {
        [self dismissView];
    }
}

- (void)dismissView
{
    [self removeFromSuperview];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

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
    self.titleLabel.text = self.monthTitle;
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
    CGFloat buttonWidth = (backWidth - padding*7)/6;
    CGFloat height = 40;
    for (UIView *view in self.backView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&view.tag<13) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0; i<2; i++) {
        for (int j = 0; j<6; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            button.backgroundColor = [UIColor yellowColor];
            [button addTarget:self action:@selector(monthSelected:) forControlEvents:UIControlEventTouchUpInside];
            int monthNum = i*6 + j+1;
            [button setTitle:[NSString stringWithFormat:@"%d",monthNum] forState:UIControlStateNormal];
            button.tag = monthNum;
            if (self.currentMonthNum == monthNum) {
                [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
            }
            [button setTitleColor:[UIColor colorWithRed:0.404f green:0.639f blue:0.784f alpha:1.00f] forState:UIControlStateNormal];
            button.frame = CGRectMake(padding + j*(buttonWidth+padding), i*(height+20) + 55, buttonWidth, 40);
            [self.backView addSubview:button];
            
        }
    }
    //
}

- (void)setSelectedMonte:(int)monthNum
{
    [self drawSubView];
    UIButton *button = (UIButton *)[self viewWithTag:monthNum];
    [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
}

- (void)monthSelected:(UIButton *)sender
{
    int monthNum = (int)sender.tag;
//    [self drawSubView];
    UIButton *button = (UIButton *)[self viewWithTag:monthNum];
    [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
    NSString *numString;
    if (monthNum<10) {
        numString = [NSString stringWithFormat:@"0%d",monthNum];
    }else{
        numString = [NSString stringWithFormat:@"%d",monthNum];
    }
    NSString *ymDate = [NSString stringWithFormat:@"%@年%@月",self.titleLabel.text,numString];
    [self.delegate selectedMonth:ymDate];
    [self dismissView];
    HaviLog(@"selected");
}

@end
