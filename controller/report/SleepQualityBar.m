//
//  SleepQualityBar.m
//  SleepRecoding
//
//  Created by Havi on 15/9/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepQualityBar.h"

@implementation SleepQualityBar
- (id)initWithFrame:(CGRect)frame andGrade:(int)grade
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bounds;
        
        //设置渐变颜色方向
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(0, 1);
        
        //设定颜色组
        self.gradientLayer.colors = [self getColorsWithGrade:grade];
        
        //设定颜色分割点
//        self.gradientLayer.locations = @[@(0.2f) ,@(1.0f)];
        self.gradientLayer.cornerRadius = 3;
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}

- (NSArray *)getColorsWithGrade:(int)grade
{
    
    switch (grade) {
        case 1:
        {
            return @[(__bridge id)[self returnColorWithSleepLevel:1].CGColor];
            break;
        }
        case 2:{
            return @[(__bridge id)[self returnColorWithSleepLevel:2].CGColor,(__bridge id)[self returnColorWithSleepLevel:1].CGColor];
            break;
        }
        case 3:{
            return @[(__bridge id)[self returnColorWithSleepLevel:3].CGColor,(__bridge id)[self returnColorWithSleepLevel:2].CGColor,(__bridge id)[self returnColorWithSleepLevel:1].CGColor];
            break;
        }
        case 4:{
            return @[(__bridge id)[self returnColorWithSleepLevel:4].CGColor,(__bridge id)[self returnColorWithSleepLevel:3].CGColor,(__bridge id)[self returnColorWithSleepLevel:2].CGColor,(__bridge id)[self returnColorWithSleepLevel:1].CGColor];
            break;
        }
        case 5:{
            return @[(__bridge id)[self returnColorWithSleepLevel:5].CGColor,(__bridge id)[self returnColorWithSleepLevel:4].CGColor,(__bridge id)[self returnColorWithSleepLevel:3].CGColor,(__bridge id)[self returnColorWithSleepLevel:2].CGColor,(__bridge id)[self returnColorWithSleepLevel:1].CGColor];
            break;
        }
            
        default:
            return @[(__bridge id)[UIColor colorWithRed:0.000f green:0.855f blue:0.573f alpha:1.00f].CGColor,(__bridge id)[UIColor colorWithRed:0.200f green:0.443f blue:0.545f alpha:1.00f].CGColor];
            break;
    }
}

- (UIColor *)returnColorWithSleepLevel:(int)colorIndex
{
    switch (colorIndex) {
        case 1:{
            return [self colorWithHex:0x3D4E5E alpha:1.0];
            break;
        }
        case 2:{
            return [self colorWithHex:0x8AB8E2 alpha:1.0];
            break;
        }
        case 3:{
            return [self colorWithHex:0xFCAE3C alpha:1.0];
            break;
        }
        case 4:{
            return [self colorWithHex:0x23A7E4 alpha:1.0];
            break;
        }
        case 5:{
            return [self colorWithHex:0x30C704 alpha:1.0];
            break;
        }
            
        default:
            return [UIColor clearColor];
            break;
    }
}

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
