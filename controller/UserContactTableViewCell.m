//
//  UserContactTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserContactTableViewCell.h"

@interface UserContactTableViewCell ()
{
    UILabel *userContactNameLabel;
    UILabel *userContactPhoneLabel;
}
@end

@implementation UserContactTableViewCell

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
        UILabel *name = [[UILabel alloc]init];
        [self addSubview:name];
        name.text = @"姓名:";
        //        sex.font = DefaultWordFont;
        
        userContactNameLabel = [[UILabel alloc]init];
        [self addSubview:userContactNameLabel];
        userContactNameLabel.text = @"张三";
        //        userSexLabel.font = DefaultWordFont;
        
        UILabel *phone = [[UILabel alloc]init];
        [self addSubview:phone];
        phone.text = @"手机:";
        //        brithe.font = DefaultWordFont;
        
        userContactPhoneLabel = [[UILabel alloc]init];
        [self addSubview:userContactPhoneLabel];
        userContactPhoneLabel.text = @"15036622195";
        
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
        
        [name makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(10);
            make.width.equalTo(40);
        }];
        
        //
        [userContactNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(name.right).offset(5);
            make.right.equalTo(backImage.right).offset(-10);
            make.height.equalTo(45);
            make.top.equalTo(backImage.top).offset(10);
        }];
        //
        [phone makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(backImage.left).offset(10);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-10);
            make.width.equalTo(40);
        }];
        
        //
        [userContactPhoneLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(phone.right).offset(5);
            make.right.equalTo(backImage.right).offset(-10);
            make.height.equalTo(45);
            make.bottom.equalTo(backImage.bottom).offset(-10);
        }];
        //
        
    }
    return self;
}

- (void)layoutSubviews
{
    userContactNameLabel.text = self.userContactName;
    userContactPhoneLabel.text = self.userContactPhone;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
