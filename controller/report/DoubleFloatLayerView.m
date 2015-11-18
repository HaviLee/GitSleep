//
//  DoubleFloatLayerView.m
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleFloatLayerView.h"

@interface DoubleFloatLayerView ()
{
    UIImageView *backImage;
    UILabel *leftDataLabel;
    UILabel *rightDataLabel;
}
@end

@implementation DoubleFloatLayerView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        backImage = [[UIImageView alloc]initWithFrame:frame];
        backImage.backgroundColor = [UIColor clearColor];
        backImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"float_view"]];
        [self addSubview:backImage];
        leftDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 1, 20, 10)];
        leftDataLabel.text = @"0";
        leftDataLabel.textAlignment = NSTextAlignmentCenter;
        leftDataLabel.font = [UIFont systemFontOfSize:9];
        leftDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
        [backImage addSubview:leftDataLabel];
        //
        rightDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 11, 20, 10)];
        rightDataLabel.text = @"0";
        rightDataLabel.textAlignment = NSTextAlignmentCenter;
        rightDataLabel.font = [UIFont systemFontOfSize:9];
        rightDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.529f green:0.455f blue:0.839f alpha:1.00f]:[UIColor whiteColor];
        [backImage addSubview:rightDataLabel];
        
    }
    return self;
}

- (void)setLeftDataString:(NSString *)leftDataString
{
    leftDataLabel.text = leftDataString;
}

- (void)setRightDataString:(NSString *)rightDataString
{
    rightDataLabel.text = rightDataString;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
