//
//  UserInfoTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/5/3.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserInfoTableViewCell.h"

@interface UserInfoTableViewCell ()
{
    UILabel *cellTitleLabel;
    UIImageView *cellImage;
    UILabel *cellData;
}
@end

@implementation UserInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellTitleLabel = [[UILabel alloc]init];
        [self addSubview:cellTitleLabel];
        self.userEditView = [[UIView alloc]init];
        [self addSubview:_userEditView];
        cellImage = [[UIImageView alloc]init];
        [self addSubview:cellImage];
        cellData = [[UILabel alloc]init];
        [self addSubview:cellData];
        
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
        if (indexPath.section == 0&&indexPath.row ==3) {
            cellData.textColor = [UIColor lightGrayColor];
            cellTitleLabel.textColor = [UIColor lightGrayColor];
        }
        
        //
        [cellData makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellTitleLabel.right);
            make.right.equalTo(self.right);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(cellTitleLabel.width);
        }];
        cellData.text = @"没事";
    }
    return self;
}

- (void)layoutSubviews
{
    cellTitleLabel.text = self.userCellTitle;
    cellImage.image = [UIImage imageNamed:self.iconTitle];
    cellData.text = self.cellDataString;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
