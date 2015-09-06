//
//  DataTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/9/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *leftTitleName;
@property (nonatomic,strong) NSString *leftSubTitleName;
@property (nonatomic,strong) NSString *rightTitleName;
@property (nonatomic,strong) NSString *rightSubTitleName;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
