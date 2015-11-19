//
//  DoubleChartTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"

@interface DoubleChartTableViewCell : UITableViewCell

@property (nonatomic,strong) PieChartView *leftPieChart;
@property (nonatomic,strong) PieChartView *rightPieChart;
@property (nonatomic,strong) NSString *middleDataString;

@property (nonatomic,strong) UIFont *cellFont;
@property (nonatomic,strong) UIColor *cellColor;
@property (nonatomic,strong) UIColor *cellDataColor;

@property (nonatomic,strong) UIColor *bottomColor;

@property (nonatomic,assign) int leftPieGrade;
@property (nonatomic,assign) int rightPieGrade;

@end
