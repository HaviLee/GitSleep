//
//  QuaterCalenderView.m
//  SleepRecoding
//
//  Created by Havi on 15/4/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "QuaterCalenderView.h"
#import "AMBlurView.h"

@interface QuaterCalenderView ()
@property (nonatomic,strong) AMBlurView *backView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *leftCalButton;
@property (nonatomic,strong) UIButton *rightCalButton;

@end

@implementation QuaterCalenderView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.backView];
        [self.backView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(134);
            make.height.equalTo(150);
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
    if (touchPoint.y>263 || touchPoint.y<113) {
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
    self.titleLabel.text = self.quaterTitle;
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
    CGFloat padding = (backWidth - 40*4)/5;
    CGFloat height = 40;
    for (UIView *view in self.backView.subviews) {
        if ([view isKindOfClass:[UIButton class]]&&view.tag<4) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0; i<4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //            button.backgroundColor = [UIColor yellowColor];
        [button addTarget:self action:@selector(monthSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        button.tag = i+1;
        if (self.currentQuaterNum == i+1) {
            [button setBackgroundImage:[UIImage imageNamed:@"caleder_bg"] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor colorWithRed:0.404f green:0.639f blue:0.784f alpha:1.00f] forState:UIControlStateNormal];
        button.frame = CGRectMake(padding + i*(40+padding), 20 + 55, height, height);
        [self.backView addSubview:button];
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
    NSString *ymDate = [NSString stringWithFormat:@"%@年第%d季度",self.titleLabel.text,monthNum];
    [self.delegate selectedQuater:ymDate];
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
