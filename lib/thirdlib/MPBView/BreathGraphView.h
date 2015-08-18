//
//  BreathGraphView.h
//  SleepRecoding
//
//  Created by Havi on 15/8/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGraphView.h"

@interface BreathGraphView : UIView
+(instancetype)breathGraphView;

@property (nonatomic,strong) MPGraphView *heartView;
/*
 * x坐标的值和y坐标的值
 * coordinate values, chart will draw itself on layer
 * try to value string to xValues' element or yValues' element
 */
@property (strong, nonatomic) NSMutableArray *dataValues;
@property (strong, nonatomic) NSArray *xValues;
@property (strong, nonatomic) NSArray *yValues;
@property (assign, nonatomic) int horizonLine;

@property (assign, nonatomic) int backMinValue;
@property (assign, nonatomic) int backMaxValue;

@property (strong, nonatomic) NSString *alarmMinValue;
@property (strong, nonatomic) NSString *alarmMaxValue;


/** default is 4 (y轴方向的实数个数) */
@property (assign, nonatomic) int yValueCount;
@property (strong, nonatomic) NSString *chartTitle;
@property (strong, nonatomic) UIColor *chartColor;

- (void)reloadGraphXValueArr:(NSArray *)arr;
-(void)drawRect:(CGRect)rect;
@end
