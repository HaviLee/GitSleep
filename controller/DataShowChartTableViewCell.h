//
//  DataShowTableViewCell.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/30.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataShowChartTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *iconTitleName;
@property (nonatomic,strong) NSString *cellTitleName;
@property (nonatomic,strong) NSString *cellData;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
