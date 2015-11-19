//
//  PNLineView.h
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PNLineView : UIView

@property (nonatomic) float grade;

@property (nonatomic,strong) CAShapeLayer * chartLine;

@property (nonatomic, strong) UIColor * barColor;

@property (nonatomic, strong) NSArray *colorsArr;

@property (nonatomic,strong) NSString *titleString;

@property (nonatomic,strong) CAGradientLayer *gradientLayer;
@end
