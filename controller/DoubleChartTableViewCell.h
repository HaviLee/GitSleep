//
//  DoubleChartTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDGoalBar.h"

@interface DoubleChartTableViewCell : UITableViewCell

@property (nonatomic,strong) KDGoalBar *leftPieChart;
@property (nonatomic,strong) KDGoalBar *rightPieChart;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic,strong) NSString *middleDataString;

@property (nonatomic,strong) UIFont *cellFont;
@property (nonatomic,strong) UIColor *cellColor;
@property (nonatomic,strong) UIColor *cellDataColor;

@property (nonatomic,strong) UIColor *bottomColor;

@property (nonatomic,assign) int leftPieGrade;
@property (nonatomic,assign) int rightPieGrade;

@end
