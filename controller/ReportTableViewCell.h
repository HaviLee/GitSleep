//
//  ReportTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *leftDataString;
@property (nonatomic,strong) NSString *rightDataString;

@property (nonatomic,strong) UIFont *cellFont;
@property (nonatomic,strong) UIColor *cellColor;

@end
