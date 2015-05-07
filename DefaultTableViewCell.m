//
//  DefaultTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DefaultTableViewCell.h"

@interface DefaultTableViewCell ()
{
    UILabel *label;
    UIImageView *leftImage;
    UIImageView *accessoryDefaultView;
}
@end

@implementation DefaultTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftImage = [[UIImageView alloc]init];
        [self addSubview:leftImage];
        label = [[UILabel alloc]init];
        [self addSubview:label];
        
        [leftImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(20);
            make.width.height.equalTo(17);
            make.centerY.equalTo(label.centerY);
        }];
        //
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImage.right).offset(10);
            make.centerY.equalTo(self.centerY);
        }];
        label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        accessoryDefaultView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 18)];
        accessoryDefaultView.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_right_%d",selectedThemeIndex]];
        self.accessoryView = accessoryDefaultView;
        
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
        imageLine.tag = 0101;
        [self addSubview:imageLine];
        [imageLine makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self).offset(0);
            make.bottom.equalTo(self).offset(-1);
            make.height.equalTo(1);
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    label.text = self.cellLabelText;
    leftImage.image = [UIImage imageNamed:self.cellImageName];
    label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    accessoryDefaultView.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_right_%d",selectedThemeIndex]];
    UIImageView *imageline = (UIImageView *)[self viewWithTag:0101];
    imageline.image = [UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
