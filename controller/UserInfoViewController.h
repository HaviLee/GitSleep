//
//  UserInfoViewController.h
//  SleepRecoding
//
//  Created by Havi_li on 15/2/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"
#import "GBPathImageView.h"

@interface UserInfoViewController : BaseViewController

@property (nonatomic,strong) UILabel *userTitleLabel;
@property (nonatomic,strong) UIImageView *iconImageButton;
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIButton *backButton;

- (void)animationToOriginalPostion;
- (void)animationToNewPositionAnimation;

@end
