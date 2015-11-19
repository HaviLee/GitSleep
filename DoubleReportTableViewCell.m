//
//  DoubleReportTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleReportTableViewCell.h"

@interface DoubleReportTableViewCell ()
{
    UILabel *leftDataLabel;
    UILabel *rightDataLabel;
    UILabel *middleDataLabel;
    UIView *lineViewBottom;
    UIView *lineView;
    UIView *lineView1;
}
@end

@implementation DoubleReportTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftDataLabel = [[UILabel alloc]init];
        [self addSubview:leftDataLabel];
        leftDataLabel.textAlignment = NSTextAlignmentCenter;
        leftDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        leftDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [leftDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(0);
            make.height.equalTo(self);
        }];
        lineView = [[UIView alloc]init];
        lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).multipliedBy(0.6666666);
            make.height.equalTo(60);
            make.width.equalTo(0.5);
        }];
        //
        middleDataLabel = [[UILabel alloc]init];
        [self addSubview:middleDataLabel];
        middleDataLabel.textAlignment = NSTextAlignmentCenter;
        middleDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        middleDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [middleDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(leftDataLabel.right);
            make.height.equalTo(self);
        }];
        lineView1 = [[UIView alloc]init];
        lineView1.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView1];
        [lineView1 makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).multipliedBy(1.33333333);
            make.height.equalTo(60);
            make.width.equalTo(0.5);
        }];
        //
        rightDataLabel = [[UILabel alloc]init];
        rightDataLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:rightDataLabel];
        rightDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        rightDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [rightDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(middleDataLabel.right).offset(0);
            make.height.equalTo(self);
            make.right.equalTo(self).offset(0);
            make.width.equalTo(middleDataLabel.width);
            make.width.equalTo(leftDataLabel.width);
        }];
        lineViewBottom = [[UIView alloc]init];
        lineViewBottom.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineViewBottom];
        [lineViewBottom makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottom).offset(-0.5);
            make.height.equalTo(0.5);
            make.width.equalTo(self.width);
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    leftDataLabel.text = self.leftDataString;
    rightDataLabel.text = self.rightDataString;
    middleDataLabel.text = self.middleDataString;
    middleDataLabel.font = _cellFont;
    leftDataLabel.font = _cellFont;
    leftDataLabel.font = _cellFont;
    leftDataLabel.textColor = _cellColor;
    rightDataLabel.textColor = _cellDataColor;
    lineView.frame = CGRectMake(self.frame.size.width/3, 0, 0.5, 60);
    lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    lineView1.frame = CGRectMake(self.frame.size.width/3*2, 0, 0.5, 60);
    lineView1.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    lineViewBottom.frame = CGRectMake(0, 59, self.frame.size.width, 0.5);
}

- (void)setCellFont:(UIFont *)cellFont
{
    _cellFont = cellFont;
}

- (void)setCellColor:(UIColor *)cellColor
{
    _cellColor = cellColor;
}

- (void)setCellDataColor:(UIColor *)cellDataColor
{
    _cellDataColor = cellDataColor;
}

- (void)setBottomColor:(UIColor *)bottomColor
{
    lineViewBottom.backgroundColor = bottomColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
