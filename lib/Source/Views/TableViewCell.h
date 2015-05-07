//
//  TableViewCell.h
//  UUChartView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

//类型
typedef enum {
    HaviChartLineStyle,
    HaviChartBarStyle
} HaviChartStyle;

@interface TableViewCell : UITableViewCell

- (void)configUI:(NSIndexPath *)indexPath;
- (void)configCellUI:(HaviChartStyle)ChartStyle withData:(NSArray *)dataArrayIn;

- (instancetype)initWithStyle:(UITableViewCellStyle)style withFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end
