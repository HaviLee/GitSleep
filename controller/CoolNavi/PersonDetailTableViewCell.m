//
//  PersonDetailTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/10/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "PersonDetailTableViewCell.h"

@interface PersonDetailTableViewCell ()
{
    UILabel *cellTitleLabel;
    UIImageView *cellImage;
    UILabel *cellData;
}
@end

@implementation PersonDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellTitleLabel = [[UILabel alloc]init];
        [self addSubview:cellTitleLabel];
        cellTitleLabel.numberOfLines = 0;
        cellTitleLabel.alpha = 0.6;
        cellTitleLabel.font = [UIFont systemFontOfSize:17];
        //
        cellImage = [[UIImageView alloc]init];
        [self addSubview:cellImage];
        //
        cellData = [[UILabel alloc]init];
        cellData.font = [UIFont systemFontOfSize:17];
        cellData.numberOfLines = 0;
        [self addSubview:cellData];
        
        [cellImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(15);
            make.height.width.equalTo(25);
            make.centerY.equalTo(self.centerY);
        }];
        
        [cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(5);
            make.height.equalTo(self);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(100);
        }];
        //
        [cellData makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellTitleLabel.right).offset(5);
            make.right.equalTo(self.right).offset(-25);
            make.centerY.equalTo(self.centerY);
            make.top.equalTo(self.top).offset(5);
            make.bottom.equalTo(self.bottom).offset(-5);
        }];
        cellData.text = @"";
    }
    return self;
}

//- (void)layoutSubviews
//{
//    cellTitleLabel.text = self.personInfoTitle;
//    cellImage.image = [UIImage imageNamed:self.personInfoIconString];
//    cellData.text = self.personInfoString;
//}

- (void)setPersonInfoIconString:(NSString *)personInfoIconString
{
    cellImage.image = [UIImage imageNamed:personInfoIconString];
}

- (void)setPersonInfoString:(NSString *)personInfoString
{
    cellData.text = personInfoString;
}

- (void)setPersonInfoTitle:(NSString *)personInfoTitle
{
    cellTitleLabel.text = personInfoTitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
