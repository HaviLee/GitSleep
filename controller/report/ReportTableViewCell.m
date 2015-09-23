//
//  ReportTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ReportTableViewCell.h"

@interface ReportTableViewCell ()
{
    UILabel *titleLabel;
    UILabel *dataLabel;
    UIView *lineViewBottom;
    UIView *lineView;
}
@end

@implementation ReportTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [[UILabel alloc]init];
        [self addSubview:titleLabel];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        titleLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.height.equalTo(self);
        }];
        lineView = [[UIView alloc]init];
        lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.equalTo(60);
            make.width.equalTo(0.5);
        }];
        //
        dataLabel = [[UILabel alloc]init];
        dataLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:dataLabel];
        dataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        dataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [dataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(titleLabel.right).offset(20);
            make.height.equalTo(self);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(titleLabel.width);
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
    titleLabel.text = self.leftDataString;
    dataLabel.text = self.rightDataString;
    titleLabel.font = _cellFont;
    dataLabel.font = _cellFont;
    titleLabel.textColor = _cellColor;
    dataLabel.textColor = _cellDataColor;
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
