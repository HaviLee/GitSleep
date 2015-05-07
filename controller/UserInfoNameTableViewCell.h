//
//  UserInfoNameTableViewCell.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoNameTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *userSex;
@property (nonatomic,strong) NSString *userBrithday;
@property (nonatomic,strong) NSString *userHeight;
@property (nonatomic,strong) NSString *userWeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
