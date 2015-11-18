//
//  DoubleShowChartTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleShowChartTableViewCell.h"

@interface DoubleShowChartTableViewCell ()
{
    UIImageView *cellImage;
    UILabel *leftCellDataLabel;
    UILabel *rightCellDataLabel;
    UIView *leftView;
    UIView *rightView;
    UILabel *leftCellName;
    UILabel *rightCellName;
}
@end

@implementation DoubleShowChartTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellImage = [[UIImageView alloc]init];
        [self addSubview:cellImage];
        [cellImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(5);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(40);
            make.height.equalTo(40);
        }];
        cellImage.layer.cornerRadius = 10;
        cellImage.image = [UIImage imageNamed:@"image"];
        //
        leftView = [[UIView alloc]init];
        [self addSubview:leftView];
        leftView.layer.cornerRadius = 2.5;
        leftView.layer.masksToBounds = YES;
        leftView.backgroundColor = selectedThemeIndex==0? [UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:DefaultColor;
        [leftView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(10);
            make.width.equalTo(40);
            make.height.equalTo(5);
            make.centerY.equalTo(self.centerY).multipliedBy(0.7);
        }];
        
        //
        rightView = [[UIView alloc]init];
        [self addSubview:rightView];
        rightView.layer.cornerRadius = 2.5;
        rightView.layer.masksToBounds = YES;
        rightView.backgroundColor = selectedThemeIndex==0? [UIColor colorWithRed:0.514f green:0.447f blue:0.820f alpha:1.00f]:DefaultColor;
        [rightView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(10);
            make.width.equalTo(40);
            make.height.equalTo(5);
            make.centerY.equalTo(self.centerY).multipliedBy(1.3);
        }];
        //
        leftCellName = [[UILabel alloc]init];
        [self addSubview:leftCellName];
        leftCellName.text = @"Left";
        rightCellName = [[UILabel alloc]init];
        rightCellName.text = @"Right";
        [self addSubview:rightCellName];
        leftCellName.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];;
        leftCellName.font = [UIFont systemFontOfSize:15];
        rightCellName.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.514f green:0.447f blue:0.820f alpha:1.00f]:[UIColor whiteColor];;
        rightCellName.font = [UIFont systemFontOfSize:15];

        //
        [leftCellName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView.right).offset(5);
            make.centerY.equalTo(leftView.centerY);
            make.height.equalTo(rightCellName);
        }];
        //
        
        [rightCellName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftView.right).offset(5);
            make.centerY.equalTo(rightView.centerY);
        }];
        //
        leftCellDataLabel = [[UILabel alloc]init];
        [self addSubview:leftCellDataLabel];
        rightCellDataLabel = [[UILabel alloc]init];
        [self addSubview:rightCellDataLabel];
        //
        [leftCellDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftCellName.right).offset(10);
            make.centerY.equalTo(leftView.centerY);
            make.height.equalTo(rightCellDataLabel);
        }];
        leftCellDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];;
        leftCellDataLabel.text = @"0次/分";
        leftCellDataLabel.font = [UIFont systemFontOfSize:15];
        //
        
        [rightCellDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(rightCellName.right).offset(10);
            make.centerY.equalTo(rightView.centerY);
        }];
        rightCellDataLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.514f green:0.447f blue:0.820f alpha:1.00f]:[UIColor whiteColor];;
        rightCellDataLabel.text = @"0次/分";
        rightCellDataLabel.font = [UIFont systemFontOfSize:15];
        
    }
    return self;
}

- (void)layoutSubviews
{
//    cellDataLabel.text = self.cellData;
    leftCellName.text = self.leftCellName;
    rightCellName.text = self.rightCellName;
    leftCellDataLabel.text = self.leftCellData;
    rightCellDataLabel.text = self.rightCellData;
    cellImage.image = [UIImage imageNamed:self.iconTitleName];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
