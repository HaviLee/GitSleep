//
//  PNLineView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "PNLineView.h"

@implementation PNLineView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bounds;
        
        //设置渐变颜色方向
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(1, 0);
        
        //设定颜色组
        self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.200f green:0.443f blue:0.545f alpha:1.00f].CGColor,(__bridge id)[UIColor colorWithRed:0.000f green:0.855f blue:0.573f alpha:1.00f].CGColor];
        
        //设定颜色分割点
        self.gradientLayer.locations = @[@(0.2f) ,@(1.0f)];
        self.gradientLayer.cornerRadius = 2;
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (void)setColorsArr:(NSArray *)colorsArr
{
    self.gradientLayer.colors = colorsArr;
}

- (void)setFrame:(CGRect)frame
{
    self.gradientLayer.frame = CGRectMake(0, 2.5, 0, 5);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.gradientLayer.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Draw BG
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.329f green:0.557f blue:0.729f alpha:1.0f].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
