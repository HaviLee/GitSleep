//
//  HeartGraphView.h
//  SleepRecoding
//
//  Created by Havi on 15/8/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGraphView.h"

@interface HeartGraphView : UIView

+(instancetype)heartGraphView;

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

@property (strong, nonatomic) NSString *chartTitle;

@property (strong, nonatomic) NSString *alarmMinValue;
@property (strong, nonatomic) NSString *alarmMaxValue;


/** 是否需要虚线网格 */
@property (assign, nonatomic) BOOL isDrawDashLine;
/** 关闭坐标系动画 */
@property (assign, nonatomic) BOOL shutDefaultAnimation;
/** default is 4 (y轴方向的实数个数) */
@property (assign, nonatomic) int yValueCount;
/** 函数线条 或者 柱状图的粗细 */
@property (assign, nonatomic) CGFloat chartWidth;
/** 颜色 */
@property (strong, nonatomic) UIColor *chartColor;

- (void)reloadGraphXValueArr:(NSArray *)arr;
-(void)drawRect:(CGRect)rect;
- (void)drawHorironLineWithColorView;
@end
