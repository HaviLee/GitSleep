//
//  HeartChartView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartChartView : UIView

+(instancetype)charView;

/*
 * x坐标的值和y坐标的值
 * coordinate values, chart will draw itself on layer
 * try to value string to xValues' element or yValues' element
 */
@property (strong, nonatomic) NSArray *dataValues;
@property (strong, nonatomic) NSArray *xValues;
@property (strong, nonatomic) NSArray *yValues;
@property (strong, nonatomic) NSString *alarmMinValue;
@property (strong, nonatomic) NSString *alarmMaxValue;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;
@property (assign, nonatomic) int horizonLine;
@property (assign, nonatomic) int backMinValue;
@property (assign, nonatomic) int backMaxValue;

@property (strong, nonatomic) NSString *chartTitle;


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

@end
