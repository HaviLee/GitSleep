//
//  FloatLayerView.m
//  SleepRecoding
//
//  Created by Havi on 15/9/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "FloatLayerView.h"

@interface FloatLayerView ()
{
    UIImageView *backImage;
    UILabel *dataLabel;
}
@end

@implementation FloatLayerView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        backImage = [[UIImageView alloc]initWithFrame:frame];
        backImage.backgroundColor = [UIColor clearColor];
        backImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"floatView_%d",selectedThemeIndex]];
        [self addSubview:backImage];
        dataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 10)];
        dataLabel.text = @"0";
        dataLabel.textAlignment = NSTextAlignmentCenter;
        dataLabel.font = [UIFont systemFontOfSize:10];
        dataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
        [backImage addSubview:dataLabel];
        
    }
    return self;
}

- (void)setDataString:(NSString *)dataString
{
    dataLabel.text = dataString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
