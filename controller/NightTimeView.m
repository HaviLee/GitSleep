//
//  NightTimeView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NightTimeView.h"

@interface NightTimeView ()
{
    UIImageView *nightImage;
    UILabel *nightTimeLabel;
}
@end

@implementation NightTimeView

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
    nightImage = [[UIImageView alloc]init];
    nightImage.frame = CGRectMake(5, 10, 20, 20);
    nightImage.image = [UIImage imageNamed:@"night_icon"];
    [self addSubview:nightImage];
    
    nightTimeLabel = [[UILabel alloc]init];
    nightTimeLabel.frame = CGRectMake(25, 0, 55, 40);
    nightTimeLabel.font = [UIFont systemFontOfSize:11];
    nightTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    nightTimeLabel.text = @"20:09PM";
    [self addSubview:nightTimeLabel];
}

- (void)setNightTime:(NSString *)nightTime
{
    nightTimeLabel.text = nightTime;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
