//
//  SearchUserTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "SearchUserTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SearchUserTableViewCell ()

@property (nonatomic, strong) UIImageView *messageIcon;
@property (nonatomic, strong) UILabel *messageName;
@property (nonatomic, strong) UILabel *messagePhone;


@end

@implementation SearchUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageIcon = [[UIImageView alloc]init];
        [self addSubview:_messageIcon];
        _messageIcon.layer.cornerRadius = 22.5;
        _messageIcon.layer.masksToBounds = YES;
        _messageIcon.image = [UIImage imageNamed:@"head_portrait_0"];
        //
        _messageName = [[UILabel alloc]init];
        [self addSubview:_messageName];
        _messageName.text = @"哈维";
        _messageName.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        _messageName.font = [UIFont systemFontOfSize:14];
        //
        _messagePhone = [[UILabel alloc]init];
        [self addSubview:_messagePhone];
        _messagePhone.font = [UIFont systemFontOfSize:14];
        _messagePhone.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        _messagePhone.text = @"13122785292";
        //
        _messageSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_messageSendButton];
        [_messageSendButton setTitle:@"申请查看" forState:UIControlStateNormal];
        [_messageSendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.000f green:0.867f blue:0.596f alpha:1.00f]] forState:UIControlStateNormal];
        _messageSendButton.layer.cornerRadius = 5;
        _messageSendButton.layer.masksToBounds = YES;
        [_messageSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_messageSendButton addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];
        [_messageSendButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
        _messageSendButton.titleLabel.font = [UIFont systemFontOfSize:17];
        //
        
        [_messageIcon makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(10);
            make.height.equalTo(45);
            make.width.equalTo(45);
        }];
        //
        [_messageName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_messageIcon.right).offset(5);
            make.top.equalTo(self).offset(10);
            make.height.equalTo(20);
            make.height.equalTo(_messagePhone.height);
            make.width.equalTo(100);
        }];
        //
        [_messagePhone makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_messageIcon.right).offset(5);
            make.top.equalTo(_messageName.bottom).offset(10);
            make.width.equalTo(100);
        }];
        //
        [_messageSendButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(_messagePhone.centerY);
            make.width.equalTo(80);
            make.height.equalTo(30);
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = 0.5;
        [self addSubview:line];
        [line makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(1);
        }];
        
    }
    return self;
}

- (void)buttonTarget:(id)sender
{
    [self.delegate customCell:self didTapButton:self.messageSendButton];
}

- (void)layoutSubviews
{
    _messageName.text = self.cellUserName;
    _messagePhone.text = self.cellUserPhone;
    [self.messageIcon setImageWithURL:[NSURL URLWithString:self.cellUserIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
