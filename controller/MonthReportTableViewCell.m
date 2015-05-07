//
//  MonthReportTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/4/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "MonthReportTableViewCell.h"

@interface MonthReportTableViewCell ()
{
    UILabel *titleLabel;
    UILabel *dataLabel;
}
@end

@implementation MonthReportTableViewCell

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
        [titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.height.equalTo(self);
        }];
        //
        dataLabel = [[UILabel alloc]init];
        [self addSubview:dataLabel];
        dataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        dataLabel.textAlignment = NSTextAlignmentRight;
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
    titleLabel.text = self.titleString;
    dataLabel.text = self.dataString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
