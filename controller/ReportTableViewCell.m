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
        titleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        titleLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.height.equalTo(self);
        }];
        //
        dataLabel = [[UILabel alloc]init];
        [self addSubview:dataLabel];
        dataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        dataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        dataLabel.textAlignment = NSTextAlignmentLeft;
        [dataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(titleLabel.right).offset(0);
            make.height.equalTo(self);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(titleLabel.width);
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
    dataLabel.textColor = _cellColor;
}

- (void)setCellFont:(UIFont *)cellFont
{
    _cellFont = cellFont;
}

- (void)setCellColor:(UIColor *)cellColor
{
    _cellColor = cellColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
