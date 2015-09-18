//
//  ReportDataTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/9/15.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportDataTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *leftTitleString;
@property (nonatomic,strong) NSString *rightTitleString;

@property (nonatomic,strong) NSString *leftDataString;
@property (nonatomic,strong) NSString *rightDataString;

@property (nonatomic,strong) UIFont *cellFont;
@property (nonatomic,strong) UIColor *cellColor;
@property (nonatomic,strong) UIColor *bottomColor;
@property (nonatomic,strong) UIColor *cellDataColor;

@end
