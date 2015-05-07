//
//  DataShowTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/30.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DataShowChartTableViewCell.h"

@interface DataShowChartTableViewCell ()
{
    UIImageView *cellImage;
    UILabel *cellTitleLabel;
    UILabel *cellDataLabel;
}
@end

@implementation DataShowChartTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellImage = [[UIImageView alloc]init];
        [self addSubview:cellImage];
        [cellImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(25);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(40);
            make.height.equalTo(40);
        }];
        cellImage.layer.cornerRadius = 10;
        cellImage.image = [UIImage imageNamed:@"image"];
        //
        cellTitleLabel = [[UILabel alloc]init];
        cellTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        [self addSubview:cellTitleLabel];
        [cellTitleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(10);
            make.bottom.equalTo(cellImage.centerY);
        }];
        cellTitleLabel.text = @"心率";
        cellTitleLabel.font = [UIFont systemFontOfSize:17];
        //
        cellDataLabel = [[UILabel alloc]init];
        [self addSubview:cellDataLabel];
        [cellDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(10);
            make.top.equalTo(cellImage.centerY);
        }];
        cellDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        cellDataLabel.text = @"80次/分";
        cellDataLabel.font = [UIFont systemFontOfSize:15];
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    cellTitleLabel.text = self.cellTitleName;
    cellDataLabel.text = self.cellData;
    cellImage.image = [UIImage imageNamed:self.iconTitleName];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
