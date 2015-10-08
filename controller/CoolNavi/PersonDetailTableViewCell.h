//
//  PersonDetailTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/10/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonDetailTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *personInfoTitle;
@property (nonatomic,strong) NSString *personInfoIconString;
@property (nonatomic,strong) NSString *personInfoString;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath;
@end
