//
//  MessageShowTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "MessageShowTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface MessageShowTableViewCell ()

@property (nonatomic, strong) UIImageView *messageIcon;
@property (nonatomic, strong) UILabel *messageName;
@property (nonatomic, strong) UILabel *messagePhone;
@property (nonatomic, strong) UILabel *messageTime;

@property (nonatomic, strong) UITextView *messageShowWord;

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
        _messageIcon.layer.cornerRadius = 25;
        _messageIcon.layer.masksToBounds = YES;
        _messageIcon.layer.shouldRasterize = YES;
        _messageIcon.layer.rasterizationScale = 2;
        _messageIcon.image = [UIImage imageNamed:@"head_portrait_0"];
        //
        _messageName = [[UILabel alloc]init];
        [self addSubview:_messageName];
        _messageName.text = @"";
        _messageName.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        _messageName.font = [UIFont systemFontOfSize:14];
        //
        _messagePhone = [[UILabel alloc]init];
        [self addSubview:_messagePhone];
        _messagePhone.font = [UIFont systemFontOfSize:14];
        _messagePhone.text = @"";
        _messagePhone.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        //
        _messageTime = [[UILabel alloc]init];
        [self addSubview:_messageTime];
        _messageTime.text = @"";
        _messageTime.font = [UIFont systemFontOfSize:14];
        _messageTime.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];

        //
        _messageShowWord = [[UITextView alloc]init];
        [self addSubview:_messageShowWord];
        _messageShowWord.text = @"";
//        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:@"你好，我是哈维，我请求查看的你的设备"];
//        [attriString addAttribute:(NSString *)kCTForegroundColorAttributeName
//                            value:(id)[UIColor redColor].CGColor
//                            range:];
//        _messageShowWord.attributedText = attriString;
        _messageShowWord.font = [UIFont systemFontOfSize:14];
        _messageShowWord.layer.cornerRadius = 5;
        _messageShowWord.layer.masksToBounds = YES;
        _messageShowWord.backgroundColor = [UIColor whiteColor];
        _messageShowWord.userInteractionEnabled = NO;
        _messageShowWord.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        //
        _messageAccepteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_messageAccepteButton];
        [_messageAccepteButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.165 green:0.851 blue:0.455 alpha:1.00]] forState:UIControlStateNormal];
        _messageAccepteButton.layer.cornerRadius = 5;
        _messageAccepteButton.layer.masksToBounds = YES;
        [_messageAccepteButton setTitle:@"同意" forState:UIControlStateNormal];
        [_messageAccepteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_messageAccepteButton addTarget:self action:@selector(acceptButtonTarget:) forControlEvents:UIControlEventTouchUpInside];
        [_messageAccepteButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
        _messageAccepteButton.titleLabel.font = [UIFont systemFontOfSize:14];

        //
        _messageRefuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_messageRefuseButton];
        _messageRefuseButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_messageRefuseButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.851 green:0.165 blue:0.216 alpha:1.00]] forState:UIControlStateNormal];
        _messageRefuseButton.layer.cornerRadius = 5;
        _messageRefuseButton.layer.masksToBounds = YES;
        [_messageRefuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_messageRefuseButton addTarget:self action:@selector(refuseButtonTarget:) forControlEvents:UIControlEventTouchUpInside];
        [_messageRefuseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //
        _statusImageView = [[UIImageView alloc]init];
        [self addSubview:_statusImageView];
        
        //设置约束
        [_messageIcon makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self).offset(10);
            make.height.equalTo(50);
            make.width.equalTo(50);
        }];
        //
        [_messageName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_messageIcon.right).offset(5);
            make.top.equalTo(self).offset(10);
            make.height.equalTo(25);
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
//            make.top.equalTo(_messageTime.bottom).offset(0);
            make.centerY.equalTo(_messagePhone.centerY);
            make.height.equalTo(25);
            make.width.equalTo(60);
            make.height.equalTo(_messageRefuseButton.height);
            make.width.equalTo(_messageRefuseButton.width);
            
        }];
        //
        [_messageRefuseButton makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(_messageAccepteButton.centerY);
        }];
        //
        [_messageShowWord makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.top.equalTo(_messageRefuseButton.bottom).offset(10);
            make.bottom.equalTo(self).offset(-10);
        }];
        //
        [_statusImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(0);
            make.right.equalTo(self.right).offset(0);
//            make.bottom.equalTo(_messageRefuseButton.bottom);
            make.height.equalTo(50);
            make.width.equalTo(90);
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
    _messageTime.text = self.cellRequreTime;
    [self.messageIcon setImageWithURL:[NSURL URLWithString:self.cellUserIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
    _messageShowWord.text = self.messageShowString;
}

- (void)acceptButtonTarget:(id)sender
{
    [self.delegate customMessageAcceptCell:self didTapButton:self.messageAccepteButton];
}

- (void)refuseButtonTarget:(id)sender
{
    [self.delegate customMessageRefuseCell:self didTapButton:self.messageRefuseButton];
}

- (void)setCellDataColor:(UIColor *)cellDataColor
{
    _messageName.textColor = cellDataColor;
    _messageTime.textColor = cellDataColor;
    _messagePhone.textColor = cellDataColor;
    _messageShowWord.textColor = cellDataColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
