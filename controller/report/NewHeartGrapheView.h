//
//  NewHeartGrapheView.h
//  SleepRecoding
//
//  Created by Havi on 15/9/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGraphView.h"

@interface NewHeartGrapheView : UIView

@property (nonatomic,strong) MPGraphView *heartView;
/**
 *  x轴的坐标值
 */
@property (strong, nonatomic) NSArray *xValues;

@property (strong, nonatomic) NSMutableArray *dataValues;


@end
