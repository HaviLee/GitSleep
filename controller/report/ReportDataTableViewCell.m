//
//  ReportDataTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/9/15.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ReportDataTableViewCell.h"

@interface ReportDataTableViewCell ()
{
    UILabel *leftTitleLabel;
    UILabel *rightTitleLabel;
    UILabel *leftDataLabel;
    UILabel *rightDataLabel;
    UIView *lineViewBottom;
    UIView *lineView;
}
@end

@implementation ReportDataTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftTitleLabel = [[UILabel alloc]init];
        [self addSubview:leftTitleLabel];
        leftTitleLabel.textAlignment = NSTextAlignmentCenter;
        leftTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        leftTitleLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [leftTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(self.top).equalTo(10);
        }];
        //
        leftDataLabel = [[UILabel alloc]init];
        [self addSubview:leftDataLabel];
        leftDataLabel.textAlignment = NSTextAlignmentCenter;
        leftDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        leftDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [leftDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(leftTitleLabel.bottom).offset(0);
            make.height.equalTo(leftTitleLabel.height);
            make.bottom.equalTo(self.bottom).offset(-10);
        }];
        //
        rightTitleLabel = [[UILabel alloc]init];
        [self addSubview:rightTitleLabel];
        rightTitleLabel.textAlignment = NSTextAlignmentCenter;
        rightTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        rightTitleLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [rightTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftTitleLabel.right).offset(10);
            make.right.equalTo(self.right).offset(-10);
            make.top.equalTo(self.top).offset(10);
            make.width.equalTo(leftTitleLabel.width);
        }];
        //
        rightDataLabel = [[UILabel alloc]init];
        [self addSubview:rightDataLabel];
        rightDataLabel.backgroundColor = [UIColor clearColor];
        rightDataLabel.textAlignment = NSTextAlignmentCenter;
        rightDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        rightDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [rightDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftDataLabel.right).offset(10);
            make.right.equalTo(self.right).offset(-10);
            make.top.equalTo(rightTitleLabel.bottom).offset(0);
            make.width.equalTo(leftDataLabel.width);
            make.height.equalTo(rightTitleLabel.height);
            make.bottom.equalTo(self.bottom).offset(-10);
        }];
        //
        lineView = [[UIView alloc]init];
        lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.equalTo(self.height);
            make.width.equalTo(0.5);
        }];
        //
        lineViewBottom = [[UIView alloc]init];
        lineViewBottom.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineViewBottom];
        [lineViewBottom makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottom);
            make.height.equalTo(0.5);
            make.width.equalTo(self);
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    leftTitleLabel.text = self.leftTitleString;
    leftDataLabel.text = self.leftDataString;
    leftTitleLabel.font = _cellFont;
    leftDataLabel.font = _cellFont;
    leftTitleLabel.textColor = _cellColor;
    leftDataLabel.textColor = _cellDataColor;
    
    rightTitleLabel.text = self.rightTitleString;
    rightDataLabel.text = self.rightDataString;
    rightTitleLabel.font = _cellFont;
    rightDataLabel.font = _cellFont;
    rightTitleLabel.textColor = _cellColor;
    rightDataLabel.textColor = _cellDataColor;
    lineView.frame = CGRectMake(self.frame.size.width/2, 0, 0.5, 60);
    lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
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

- (void)setBottomColor:(UIColor *)bottomColor
{
    lineViewBottom.backgroundColor = bottomColor;
}

- (void)setCellDataColor:(UIColor *)cellDataColor
{
    _cellDataColor = cellDataColor;
//    rightDataLabel.textColor = cellDataColor;
//    leftDataLabel.textColor = cellDataColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
