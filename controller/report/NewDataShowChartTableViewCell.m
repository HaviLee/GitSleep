//
//  NewDataShowChartTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/9/18.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NewDataShowChartTableViewCell.h"

@interface NewDataShowChartTableViewCell ()
{
    UIImageView *cellImage;
    UILabel *cellDataLabel;
}
@end

@implementation NewDataShowChartTableViewCell

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
            make.left.equalTo(self.left).offset(25);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(40);
            make.height.equalTo(40);
        }];
        cellImage.layer.cornerRadius = 10;
        cellImage.image = [UIImage imageNamed:@"image"];
        //
        cellDataLabel = [[UILabel alloc]init];
        [self addSubview:cellDataLabel];
        [cellDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellImage.right).offset(20);
            make.centerY.equalTo(cellImage.centerY);
        }];
        cellDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        cellDataLabel.text = @"0次/分";
        cellDataLabel.font = [UIFont systemFontOfSize:15];
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    cellDataLabel.text = self.cellData;
    cellImage.image = [UIImage imageNamed:self.iconTitleName];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
