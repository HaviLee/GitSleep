//
//  DayTimeView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DayTimeView.h"

@interface DayTimeView ()
{
    UIImageView *dayImage;
    UILabel *dayTimeLabel;
}
@end

@implementation DayTimeView
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
    self.frame = CGRectMake(0, 0, 80, 40);
    dayImage = [[UIImageView alloc]init];
    dayImage.frame = CGRectMake(5, 10, 20, 20);
    dayImage.image = [UIImage imageNamed:@"day_icon"];
    [self addSubview:dayImage];
    
    dayTimeLabel = [[UILabel alloc]init];
    dayTimeLabel.frame = CGRectMake(25, 0, 55, 40);
    dayTimeLabel.font = [UIFont systemFontOfSize:11];
    dayTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    dayTimeLabel.text = @"08:09AM";
    [self addSubview:dayTimeLabel];
}

- (void)setDayTime:(NSString *)dayTime
{
    dayTimeLabel.text = dayTime;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
