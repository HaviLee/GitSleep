//
//  UserInfoTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/5/3.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *iconTitle;
@property (nonatomic,strong) NSString *userCellTitle;
@property (nonatomic,strong) UIView *userEditView;
@property (nonatomic,strong) NSString *cellDataString;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath;
@end
