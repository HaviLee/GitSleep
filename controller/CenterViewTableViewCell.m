//
//  CenterViewTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/8/4.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CenterViewTableViewCell.h"

@interface CenterViewTableViewCell ()
{
    UILabel *cellNameLabel;
    UIImageView *cellImage;
    UILabel *cellDataLabel;
}
@end

@implementation CenterViewTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        cellNameLabel = [[UILabel alloc]init];
        cellNameLabel.text = @"心率";
        cellNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:cellNameLabel];
        [cellNameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.height);
            make.centerY.equalTo(self.centerY);
            make.left.equalTo(self.left).offset(30);
        }];
        
        cellImage = [[UIImageView alloc]init];
        cellImage.image = [UIImage imageNamed:@"heart_5_1"];
//        cellNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:cellImage];
        [cellImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cellNameLabel.right).offset(30);
            make.centerY.equalTo(self.centerY);
            make.height.equalTo(cellImage.width);
            make.height.equalTo(30);
        }];
        
        cellDataLabel = [[UILabel alloc]init];
        cellDataLabel.textColor = [UIColor whiteColor];
        cellDataLabel.text = @"5次/天";
        [self addSubview:cellDataLabel];
        [cellDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.right).offset(-30);
            make.centerY.equalTo(self.centerY);
            make.height.equalTo(self.height);
        }];
        //
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    cellNameLabel.text = self.cellTitle;
    cellImage.image = [UIImage imageNamed:self.cellImageName];
    cellDataLabel.text = self.cellData;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
