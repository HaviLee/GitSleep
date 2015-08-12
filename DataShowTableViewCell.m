//
//  DataShowTableViewCell.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "DataShowTableViewCell.h"
@class LeftSideViewController;
@interface DataShowTableViewCell ()
{
    UILabel *cellLabel;
    UIImageView *leftImage;
    UIButton *buttonType1;
    UIButton *buttonType2;
    UIButton *buttonType3;
    UIButton *buttonType4;
    NSArray *buttonArray;
}
@end

@implementation DataShowTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        leftImage = [[UIImageView alloc]init];
        [self addSubview:leftImage];
        cellLabel = [[UILabel alloc]init];
        [self addSubview:cellLabel];
        [leftImage makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left).offset(20);
            make.width.height.equalTo(17);
            make.centerY.equalTo(cellLabel.centerY);
        }];
        //
        cellLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        [cellLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImage.right).offset(10);
            make.top.equalTo(self.top).offset(10);
            make.height.equalTo(30);
        }];
// button1
        buttonType1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:buttonType1];
        [buttonType1 makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(cellLabel.bottom).offset(10);
            make.width.height.equalTo(45);
        }];
        [buttonType1 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"week_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        buttonType1.tag = 101;
        //
        /*
        UILabel *label1 = [[UILabel alloc]init];
        [self addSubview:label1];
        [label1 makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(buttonType1.centerX);
            make.top.equalTo(buttonType1.bottom).offset(5);
        }];
        label1.text = @"周";
        label1.textColor = [UIColor whiteColor];
         */
// button2
        buttonType2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:buttonType2];
        [buttonType2 makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buttonType1.right).offset(15);
            make.width.height.equalTo(45);
            make.centerY.equalTo(buttonType1.centerY);
        }];
        [buttonType2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonType2 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"month_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        buttonType2.tag = 102;
        /*
        UILabel *label2 = [[UILabel alloc]init];
        [self addSubview:label2];
        [label2 makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(buttonType2.centerX);
            make.top.equalTo(buttonType2.bottom).offset(5);
        }];
        label2.text = @"月";
        label2.textColor = [UIColor whiteColor];
         */
//button3
        buttonType3 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:buttonType3];
        [buttonType3 makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(buttonType2.right).offset(15);
            make.width.height.equalTo(45);
            make.centerY.equalTo(buttonType2.centerY);
        }];
        [buttonType3 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"quarter_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        buttonType3.tag = 103;
        /*
        UILabel *label3 = [[UILabel alloc]init];
        [self addSubview:label3];
        [label3 makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(buttonType3.centerX);
            make.top.equalTo(buttonType3.bottom).offset(5);
        }];
        label3.text = @"季度";
        label3.textColor = [UIColor whiteColor];
        */
        
        buttonType4 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:buttonType4];
        [buttonType4 makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-40);
            make.top.equalTo(buttonType2.bottom).offset(10);
            make.height.equalTo(30);
        }];
        [buttonType4 setTitle:@"睡眠分析" forState:UIControlStateNormal];
        [buttonType4 setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"sleep_analysis_textbox_%d",selectedThemeIndex]] forState:UIControlStateNormal];
        buttonType4.titleLabel.font = [UIFont systemFontOfSize:15];
        buttonType4.tag = 104;
        [buttonType4 setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonArray = @[buttonType1,buttonType2,buttonType3,buttonType4];
        
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
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
    cellLabel.text = self.cellName;
    leftImage.image = [UIImage imageNamed:self.cellImageName];
    for (int i = 0; i<buttonArray.count; i++) {
        UIButton *button = [buttonArray objectAtIndex:i];
        [button addTarget:self.target action:self.buttonTaped forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
