//
//  TitleViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/9/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TitleViewCell.h"

@interface TitleViewCell ()
{
    UIImageView *cellImage;
    UILabel *cellTitleLabel;
    UILabel *cellDataLabel;
}
@end

@implementation TitleViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (instancetype)init
{
    self = [super init];
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

- (void)setIconTitleName:(NSString *)iconTitleName
{
    cellImage.image = [UIImage imageNamed:iconTitleName];
}

- (void)setCellData:(NSString *)cellData
{
    cellDataLabel.text = cellData;
}

- (void)setCellTitleName:(NSString *)cellTitleName
{
    cellTitleLabel.text = cellTitleName;
}
//- (void)layoutSubviews
//{
//    cellTitleLabel.text = self.cellTitleName;
//    cellDataLabel.text = self.cellData;
//    cellImage.image = [UIImage imageNamed:self.iconTitleName];
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
