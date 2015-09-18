//
//  NewWeekReport.h
//  SleepRecoding
//
//  Created by Havi on 15/9/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportViewDefine.h"

@interface NewWeekReport : UIView
/**
 *  x轴的坐标值
 */
@property (strong, nonatomic) NSArray *xValues;
/**
 *  睡眠质量数据
 */
@property (strong, nonatomic) NSMutableArray *sleepQulityDataValues;
/**
 *  睡眠时长数据
 */
@property (strong, nonatomic) NSMutableArray *sleepTimeDataValues;
/**
 *  刷新界面数据
 */
- (void)reloadChartView;
@end
