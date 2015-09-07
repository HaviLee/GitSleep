//
//  StartTimeView.m
//  SleepRecoding
//
//  Created by Havi on 15/9/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "StartTimeView.h"

@interface StartTimeView ()
{
    UILabel *startTitleLabel;
    UILabel *statrtDataLabel;
}
@end

@implementation StartTimeView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView
{
    self.frame = CGRectMake(0, 0, 80, 60);
    startTitleLabel = [[UILabel alloc]init];
    startTitleLabel.frame = CGRectMake(5, 10, 80, 20);
    startTitleLabel.font = [UIFont systemFontOfSize:11];
    startTitleLabel.text = @"入睡时间";
    startTitleLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    [self addSubview:startTitleLabel];
    
    statrtDataLabel = [[UILabel alloc]init];
    statrtDataLabel.frame = CGRectMake(5, 25, 80, 20);
    statrtDataLabel.font = [UIFont systemFontOfSize:11];
    statrtDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    statrtDataLabel.text = @"08:09AM";
    [self addSubview:statrtDataLabel];
}

- (void)setStartTime:(NSString *)startTime
{
    statrtDataLabel.text = startTime;
    statrtDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
