//
//  EndTimeView.m
//  SleepRecoding
//
//  Created by Havi on 15/9/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "EndTimeView.h"

@interface EndTimeView ()
{
    UILabel *endTitleLabel;
    UILabel *endDataLabel;
    UIImageView *imageView;
}
@end

@implementation EndTimeView
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
    endTitleLabel = [[UILabel alloc]init];
    endTitleLabel.frame = CGRectMake(5, 10, 80, 20);
    endTitleLabel.font = [UIFont systemFontOfSize:11];
    endTitleLabel.text = @"起床时间";
    endTitleLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    [self addSubview:endTitleLabel];
    
    endDataLabel = [[UILabel alloc]init];
    endDataLabel.frame = CGRectMake(5, 25, 40, 20);
    endDataLabel.font = [UIFont systemFontOfSize:11];
    endDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    endDataLabel.text = @"08:09AM";
    [self addSubview:endDataLabel];
    
    imageView  = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(45, 25, 10, 10);
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat: @"ic_compile_%d",selectedThemeIndex]];
    [self addSubview:imageView];
    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(endDataLabel.centerY);
        make.left.equalTo(endDataLabel.right).offset(-7);
        make.height.equalTo(10);
        make.width.equalTo(10);
    }];
    
}

- (void)setEndTime:(NSString *)endTime
{
    endDataLabel.text = endTime;
    endTitleLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    endDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    
}

- (void)setEndImageString:(NSString *)endImageString
{
    imageView.image = [UIImage imageNamed:endImageString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
