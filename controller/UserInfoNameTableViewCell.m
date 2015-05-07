//
//  UserInfoNameTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserInfoNameTableViewCell.h"

@interface UserInfoNameTableViewCell ()
{
    UILabel *userSexLabel;
    UILabel *userBrithdayLabel;
    UILabel *userHeightLabel;
    UILabel *userWeightLabel;
}
@end

@implementation UserInfoNameTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *backImage = [[UIImageView alloc]init];
        backImage.image = [UIImage imageNamed:@"wireframe"];
        [self addSubview:backImage];
        [backImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(10);
            make.right.equalTo(self.right).offset(-10);
            make.top.equalTo(self.top).offset(2);
            make.bottom.equalTo(self.bottom).offset(-2);
        }];
//        
        UILabel *sex = [[UILabel alloc]init];
        [self addSubview:sex];
        sex.text = @"性别:";
//        sex.font = DefaultWordFont;
        
        userSexLabel = [[UILabel alloc]init];
        [self addSubview:userSexLabel];
        userSexLabel.text = @"男";
//        userSexLabel.font = DefaultWordFont;
        
        UILabel *brithe = [[UILabel alloc]init];
        [self addSubview:brithe];
        brithe.text = @"生日:";
//        brithe.font = DefaultWordFont;
        
        userBrithdayLabel = [[UILabel alloc]init];
        [self addSubview:userBrithdayLabel];
        userBrithdayLabel.text = @"1989-09-10";
//        userBrithdayLabel.font = DefaultWordFont;
        
        UILabel *height = [[UILabel alloc]init];
        [self addSubview:height];
        height.text = @"身高:";
//        height.font = DefaultWordFont;
        
        userHeightLabel = [[UILabel alloc]init];
        [self addSubview:userHeightLabel];
        userHeightLabel.text = @"172CM";
//        userHeightLabel.font = DefaultWordFont;
        
        UILabel *weight = [[UILabel alloc]init];
        [self addSubview:weight];
        weight.text = @"体重:";
//        weight.font = DefaultWordFont;
        
        userWeightLabel = [[UILabel alloc]init];
        [self addSubview:userWeightLabel];
        userWeightLabel.text = @"60KG";
//        userWeightLabel.font = DefaultWordFont;
//
        UIImageView *imageLine = [[UIImageView alloc]init];
        imageLine.image = [UIImage imageNamed:@"cellline"];
        imageLine.alpha = 1;
        [self addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left);
            make.right.equalTo(backImage.right);
            make.centerY.equalTo(backImage.centerY);
            make.height.equalTo(0.5);
        }];
//
        
        [sex makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(10);
            make.width.equalTo(40);
        }];
        
//
        [userSexLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sex.right).offset(5);
            make.right.equalTo(brithe.left).offset(-5);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(10);
        }];
//
        [brithe makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(userSexLabel.right).offset(5);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(10);
            make.width.equalTo(40);
        }];
//
        [userBrithdayLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(brithe.right).offset(5);
            make.height.equalTo(45);
            make.right.equalTo(backImage.right).offset(-5);
            make.top.equalTo(backImage.top).offset(10);
            make.width.equalTo(userSexLabel.width);
        }];
//
        [height makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-10);
            make.width.equalTo(40);
        }];
        
//
        [userHeightLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sex.right).offset(5);
            make.right.equalTo(brithe.left).offset(-5);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-10);
        }];
//
        [weight makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(userSexLabel.right).offset(5);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-10);
            make.width.equalTo(40);
        }];
//
        [userWeightLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(brithe.right).offset(5);
            make.height.equalTo(45);
            make.right.equalTo(backImage.right).offset(-5);
            make.bottom.equalTo(backImage.bottom).offset(-10);
            make.width.equalTo(userSexLabel.width);
        }];
        
    }
    return self;
}

- (void)layoutSubviews
{
    userSexLabel.text = self.userSex;
    userBrithdayLabel.text = self.userBrithday;
    userHeightLabel.text = self.userHeight;
    userWeightLabel.text = self.userWeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
