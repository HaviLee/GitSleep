//
//  UserInfoPhoneTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserInfoPhoneTableViewCell.h"

@interface UserInfoPhoneTableViewCell ()
{
    UILabel *userPhoneLabel;
    UILabel *userCallLabel;
    UILabel *userAddressLabel;
}
@end

@implementation UserInfoPhoneTableViewCell

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
        UILabel *phone = [[UILabel alloc]init];
        [self addSubview:phone];
        phone.text = @"手机:";
        //        sex.font = DefaultWordFont;
        
        userPhoneLabel = [[UILabel alloc]init];
        [self addSubview:userPhoneLabel];
        userPhoneLabel.text = @"13122785292";
        //        userSexLabel.font = DefaultWordFont;
        
        UILabel *call = [[UILabel alloc]init];
        [self addSubview:call];
        call.text = @"电话:";
        //        brithe.font = DefaultWordFont;
        
        userCallLabel = [[UILabel alloc]init];
        [self addSubview:userCallLabel];
        userCallLabel.text = @"021-1236544";
        //        userBrithdayLabel.font = DefaultWordFont;
        
        UILabel *address = [[UILabel alloc]init];
        [self addSubview:address];
        address.text = @"地址:";
        //        height.font = DefaultWordFont;
        
        userAddressLabel = [[UILabel alloc]init];
        userAddressLabel.numberOfLines = 0;
        [self addSubview:userAddressLabel];
        userAddressLabel.text = @"河南省安阳市汤阴县";
        //        userHeightLabel.font = DefaultWordFont;
        //
        UIImageView *imageLine = [[UIImageView alloc]init];
        imageLine.image = [UIImage imageNamed:@"cellline"];
        imageLine.alpha = 1;
        [self addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left);
            make.right.equalTo(backImage.right);
            make.centerY.equalTo(backImage.centerY).offset(-30);
            make.height.equalTo(0.5);
        }];
        
        UIImageView *imageLine2 = [[UIImageView alloc]init];
        imageLine2.image = [UIImage imageNamed:@"cellline"];
        imageLine2.alpha = 1;
        [self addSubview:imageLine2];
        [imageLine2 makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left);
            make.right.equalTo(backImage.right);
            make.centerY.equalTo(backImage.centerY).offset(30);
            make.height.equalTo(0.5);
        }];
        //
        
        [phone makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(7.5);
            make.width.equalTo(40);
        }];
        
        //
        [userPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(phone.right).offset(5);
            make.right.equalTo(backImage.right).offset(-10);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(7.5);
        }];
        //
        [call makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(40);
        }];
        //
        [userCallLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(call.right).offset(5);
            make.height.equalTo(45);
            make.right.equalTo(backImage.right).offset(-5);
            make.centerY.equalTo(self.centerY);
        }];
        //
        [address makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-7.5);
            make.width.equalTo(40);
        }];
        
        //
        [userAddressLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(address.right).offset(5);
            make.right.equalTo(backImage.right).offset(-10);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-7.5);
        }];
        //
        
    }
    return self;
}

- (void)layoutSubviews
{
    userPhoneLabel.text = self.userPhone;
    userCallLabel.text = self.userCall;
    userAddressLabel.text = self.userAddress;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
