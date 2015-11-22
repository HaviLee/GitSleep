//
//  FriendMessageTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "FriendMessageTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FriendMessageTableViewCell ()

@property (nonatomic, strong) UIImageView *messageIcon;
@property (nonatomic, strong) UILabel *messageName;
@property (nonatomic, strong) UILabel *messagePhone;
@property (nonatomic, strong) UILabel *messageTime;

@end

@implementation FriendMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageIcon = [[UIImageView alloc]init];
        [self addSubview:_messageIcon];
        _messageIcon.image = [UIImage imageNamed:@"head_portrait_0"];
        _messageIcon.layer.cornerRadius = 22.5;
        _messageIcon.layer.masksToBounds = YES;

        //
        _messageName = [[UILabel alloc]init];
        [self addSubview:_messageName];
        _messageName.text = @"哈维";
        _messageName.font = [UIFont systemFontOfSize:14];
        _messageName.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        //
        _messagePhone = [[UILabel alloc]init];
        [self addSubview:_messagePhone];
        _messagePhone.font = [UIFont systemFontOfSize:14];
        _messagePhone.text = @"13122785292";
        _messagePhone.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        //
        _messageTime = [[UILabel alloc]init];
        _messageTime.numberOfLines = 0;
        [self addSubview:_messageTime];
        _messageTime.text = @"哈维的床垫ddddddddddddd";
        _messageTime.font = [UIFont systemFontOfSize:14];
        _messageTime.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        //
        
        [_messageIcon makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
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
            make.top.equalTo(_messageName.bottom).offset(5);
            make.width.equalTo(100);
        }];
        //
        [_messageTime makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-30);
            make.top.equalTo(_messageName.bottom).offset(5);
            make.bottom.equalTo(self.bottom).offset(-10);
            make.left.equalTo(_messagePhone.right).offset(0);
            make.centerY.equalTo(_messageName.centerY);
            
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

- (void)layoutSubviews
{
    _messageName.text = self.cellUserName;
    _messagePhone.text = self.cellUserPhone;
    _messageTime.text = self.cellUserDescription;
    [self.messageIcon setImageWithURL:[NSURL URLWithString:self.cellUserIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
