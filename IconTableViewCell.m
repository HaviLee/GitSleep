//
//  IconTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "IconTableViewCell.h"

@interface IconTableViewCell ()
@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *iconNameLabel;
@end

@implementation IconTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iconImageView = [[UIImageView alloc]init];
        [self addSubview:_iconImageView];
        [_iconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
            make.width.equalTo(_iconImageView.height);
        }];
        _iconImageView.layer.cornerRadius = 30;
        _iconImageView.layer.masksToBounds = YES;
        self.iconNameLabel = [[UILabel alloc]init];
        [self addSubview:_iconNameLabel];
        [_iconNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconImageView.right).offset(10);
            make.centerY.equalTo(_iconImageView.centerY);
            make.right.equalTo(self.right).offset(-20);
        }];
        UIImageView *accessoryDefaultView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 18)];
        accessoryDefaultView.image = [UIImage imageNamed:@"arrow"];
        self.accessoryView = accessoryDefaultView;
        
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
        [self addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self).offset(0);
            make.bottom.equalTo(self).offset(-1);
            make.height.equalTo(1);
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _iconNameLabel.text = self.iconName;
    _iconImageView.image = self.iconImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
