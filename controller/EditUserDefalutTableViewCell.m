//
//  EditUserDefalutTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/3/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "EditUserDefalutTableViewCell.h"

@interface EditUserDefalutTableViewCell ()
{
    UILabel *cellTitleLabel;
    UIImageView *cellImage;
}
@end

@implementation EditUserDefalutTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        cellTitleLabel = [[UILabel alloc]init];
        [self addSubview:cellTitleLabel];
        self.userEditView = [[UIView alloc]init];
        [self addSubview:_userEditView];
        cellImage = [[UIImageView alloc]init];
        [self addSubview:cellImage];
        
        [cellImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(5);
            make.height.width.equalTo(25);
            make.centerY.equalTo(self.centerY);
        }];

        [cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(5);
            make.height.equalTo(self);
            make.centerY.equalTo(self.centerY);
        }];
//
        [self.userEditView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellTitleLabel.right);
            make.right.equalTo(self).offset(-5);
            make.height.equalTo(self);
            make.width.equalTo(cellTitleLabel.width);
            make.centerY.equalTo(self.centerY);
        }];
//
    }
    return self;
}

- (void)layoutSubviews
{
    cellTitleLabel.text = self.userCellTitle;
    cellImage.image = [UIImage imageNamed:self.iconTitle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
