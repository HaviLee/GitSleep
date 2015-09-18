//
//  SleepQualityBar.h
//  SleepRecoding
//
//  Created by Havi on 15/9/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SleepQualityBar : UIView

@property (nonatomic) float grade;

@property (nonatomic,strong) CAShapeLayer * chartLine;

@property (nonatomic, strong) UIColor * barColor;

@property (nonatomic,strong) NSString *titleString;

@property (nonatomic,strong) CAGradientLayer *gradientLayer;

- (id)initWithFrame:(CGRect)frame andGrade:(int)grade;

@end
