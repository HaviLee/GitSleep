//
//  UserContactTableViewCell.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserContactTableViewCell : UITableViewCell

@property (nonatomic,strong) NSString *userContactName;
@property (nonatomic,strong) NSString *userContactPhone;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
