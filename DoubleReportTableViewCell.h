//
//  DoubleReportTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubleReportTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *leftDataString;
@property (nonatomic,strong) NSString *rightDataString;
@property (nonatomic,strong) NSString *middleDataString;

@property (nonatomic,strong) UIFont *cellFont;
@property (nonatomic,strong) UIColor *cellColor;
@property (nonatomic,strong) UIColor *cellDataColor;

@property (nonatomic,strong) UIColor *bottomColor;

@end
