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
        [self.topContentView addSubview:_messageIcon];
        _messageIcon.frame = CGRectMake(0, 10, 20, 20);
        _messageIcon.image = [UIImage imageNamed:@"head_portrait_0"];
        _messageIcon.layer.cornerRadius = 22.5;
        _messageIcon.layer.masksToBounds = YES;
        
        //
        _messageName = [[UILabel alloc]init];
        [self.topContentView addSubview:_messageName];
        _messageName.text = @"";
        _messageName.font = [UIFont systemFontOfSize:14];
        _messageName.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        
        //
        _messagePhone = [[UILabel alloc]init];
        [self.topContentView addSubview:_messagePhone];
        _messagePhone.font = [UIFont systemFontOfSize:14];
        _messagePhone.text = @"";
        _messagePhone.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        
        //
        _messageTime = [[UILabel alloc]init];
        _messageTime.numberOfLines = 0;
        [self.topContentView addSubview:_messageTime];
        _messageTime.text = @"";
        _messageTime.font = [UIFont systemFontOfSize:14];
        _messageTime.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        _selectImageView = [[UIImageView alloc]init];
        _selectImageView.image = [UIImage imageNamed:@"choose"];
        [self.topContentView addSubview:_selectImageView];
        _selectImageView.hidden = YES;
        
        //
        
        [_selectImageView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(20);
            make.width.equalTo(20);
            make.centerY.equalTo(self.topContentView.centerY);
            make.right.equalTo(self.topContentView.right).offset(-10);
        }];
        
        [_messageIcon makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topContentView).offset(10);
            make.top.equalTo(self.topContentView).offset(10);
            make.height.equalTo(45);
            make.width.equalTo(45);
        }];
        //
        [_messageName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_messageIcon.right).offset(5);
            make.top.equalTo(self.topContentView).offset(10);
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
            make.right.equalTo(self.topContentView.right).offset(-30);
            make.left.equalTo(_messagePhone.right).offset(10);
            make.centerY.equalTo(_messageName.centerY);
            make.height.equalTo(30);
            
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = 0.5;
        [self.topContentView addSubview:line];
        [line makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.topContentView);
            make.left.equalTo(self.topContentView);
            make.right.equalTo(self.topContentView);
            make.height.equalTo(1);
        }];
        
    }
    return self;
}

- (void)setCellUserIcon:(NSString *)cellUserIcon
{
    [self.messageIcon setImageWithURL:[NSURL URLWithString:cellUserIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
}

- (void)setCellUserName:(NSString *)cellUserName
{
    self.messageName.text = cellUserName;
}

- (void)setCellUserPhone:(NSString *)cellUserPhone
{
    self.messagePhone.text = cellUserPhone;
}

- (void)setCellUserDescription:(NSString *)cellUserDescription
{
    self.messageTime.text = cellUserDescription;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
