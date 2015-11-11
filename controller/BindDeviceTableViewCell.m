//
//  BindDeviceTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "BindDeviceTableViewCell.h"

@interface BindDeviceTableViewCell ()

@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UILabel *deviceTitleLabel;
@property (nonatomic, strong) UILabel *leftDeviceTitleLabel;
@property (nonatomic, strong) UILabel *rightDeviceTitleLabel;

@end

@implementation BindDeviceTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgImage = [[UIImageView alloc]init];
        [self addSubview:_bgImage];
        _bgImage.backgroundColor = [UIColor colorWithRed:0.929f green:0.929f blue:0.929f alpha:1.00f];
        _bgImage.layer.cornerRadius = 10;
        _bgImage.layer.masksToBounds = YES;
        //
        _deviceTitleLabel = [[UILabel alloc]init];
        _deviceTitleLabel.textAlignment = NSTextAlignmentCenter;
        _deviceTitleLabel.font = [UIFont systemFontOfSize:18];
        _deviceTitleLabel.text = @"哈维的设备";
        [self addSubview:_deviceTitleLabel];
        //
        [_bgImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.bottom.equalTo(self).offset(-5);
            make.top.equalTo(_deviceTitleLabel.bottom).offset(15);
        }];
        [_deviceTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.top.equalTo(self).offset(5);
            make.height.equalTo(30);
        }];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
