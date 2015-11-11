//
//  MessageShowTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "MessageShowTableViewCell.h"

@interface MessageShowTableViewCell ()

@property (nonatomic, strong) UIImageView *messageIcon;
@property (nonatomic, strong) UILabel *messageName;
@property (nonatomic, strong) UILabel *messagePhone;
@property (nonatomic, strong) UILabel *messageTime;
@property (nonatomic, strong) UIButton *messageAccepteButton;
@property (nonatomic, strong) UIButton *messageRefuseButton;

@end

@implementation MessageShowTableViewCell

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
        //
        _messageName = [[UILabel alloc]init];
        [self addSubview:_messageName];
        _messageName.text = @"哈维";
        _messageName.font = [UIFont systemFontOfSize:14];
        //
        _messagePhone = [[UILabel alloc]init];
        [self addSubview:_messagePhone];
        _messagePhone.font = [UIFont systemFontOfSize:14];
        _messagePhone.text = @"13122785292";
        //
        _messageTime = [[UILabel alloc]init];
        [self addSubview:_messageTime];
        _messageTime.text = @"2015-11-11";
        _messageTime.font = [UIFont systemFontOfSize:14];
        //
        _messageAccepteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_messageAccepteButton];
        _messageAccepteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _messageAccepteButton.backgroundColor = [UIColor whiteColor];
        _messageAccepteButton.layer.cornerRadius = 5;
        _messageAccepteButton.layer.masksToBounds = YES;
        [_messageAccepteButton setTitle:@"同意" forState:UIControlStateNormal];
        [_messageAccepteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        //
        _messageRefuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_messageRefuseButton];
        _messageRefuseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _messageRefuseButton.backgroundColor = [UIColor whiteColor];
        _messageRefuseButton.layer.cornerRadius = 5;
        _messageRefuseButton.layer.masksToBounds = YES;
        [_messageRefuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_messageRefuseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        //设置约束
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
            make.width.equalTo(150);
        }];
        //
        [_messagePhone makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_messageIcon.right).offset(5);
            make.top.equalTo(_messageName.bottom).offset(5);
            make.width.equalTo(150);
        }];
        //
        [_messageTime makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.height.equalTo(20);
            make.top.equalTo(self).offset(10);
        }];
        //
        [_messageAccepteButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_messageRefuseButton.left).offset(-10);
            make.top.equalTo(_messageTime.bottom).offset(0);
            make.height.equalTo(25);
            make.width.equalTo(50);
            make.height.equalTo(_messageRefuseButton.height);
            make.width.equalTo(_messageRefuseButton.width);
            
        }];
        //
        [_messageRefuseButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(_messageAccepteButton.centerY);
        }];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
