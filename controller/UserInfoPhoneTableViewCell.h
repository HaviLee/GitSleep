//
//  UserInfoPhoneTableViewCell.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoPhoneTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *userPhone;
@property (nonatomic,strong) NSString *userCall;
@property (nonatomic,strong) NSString *userAddress;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
