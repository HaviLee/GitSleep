//
//  ContainerTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/12/8.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "ContainerTableViewCell.h"

@interface ContainerTableViewCell ()
@property (nonatomic, strong) UILabel *messageTime;

@end

@implementation ContainerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _selectImageView = [[UIImageView alloc]init];
        _selectImageView.image = [UIImage imageNamed:@"choose"];
        [self addSubview:_selectImageView];
        _selectImageView.hidden = YES;
        
        //
        
        [_selectImageView makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(20);
            make.width.equalTo(20);
            make.centerY.equalTo(self.centerY);
            make.right.equalTo(self.right).offset(-50);
        }];
        //
        _cellIconImageView = [[UIImageView alloc]init];
        [self addSubview:_cellIconImageView];
        _cellIconImageView.layer.cornerRadius = 22.5;
        _cellIconImageView.layer.masksToBounds = YES;
        [_cellIconImageView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(45);
            make.width.equalTo(45);
            make.left.equalTo(self.left).offset(10);
        }];
        
        
        //
        _messageTime = [[UILabel alloc]init];
        _messageTime.numberOfLines = 0;
        _messageTime.textColor = selectedThemeIndex==0?DefaultColor:[UIColor lightGrayColor];
        [self addSubview:_messageTime];
        _messageTime.text = @"";
        _messageTime.font = [UIFont systemFontOfSize:14];
        _messageTime.textColor = [UIColor colorWithRed:0.247f green:0.263f blue:0.271f alpha:1.00f];
        [_messageTime makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).offset(-30);
            make.left.equalTo(_cellIconImageView.right).offset(20);
            make.centerY.equalTo(_cellIconImageView.centerY);
            make.height.equalTo(30);
            
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
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

- (void)setCellUserDescription:(NSString *)cellUserDescription
{
    self.messageTime.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    self.messageTime.text = cellUserDescription;
}

@end
