//
//  DoubleChartTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleChartTableViewCell.h"

@interface DoubleChartTableViewCell ()
{
    UILabel *middleDataLabel;
    UIView *lineViewBottom;
    UIView *lineView;
    UIView *lineView1;
}
@end

@implementation DoubleChartTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _leftPieChart = [[KDGoalBar alloc]initWithFrame:CGRectMake((self.frame.size.width/3-100)/2, 0, 100, 100)];
        [self addSubview:_leftPieChart];
        
        lineView = [[UIView alloc]init];
        lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView];
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).multipliedBy(0.6666666);
            make.height.equalTo(self.height);
            make.width.equalTo(0.5);
        }];
        //
        middleDataLabel = [[UILabel alloc]init];
        [self addSubview:middleDataLabel];
        middleDataLabel.numberOfLines = 0;
        middleDataLabel.textAlignment = NSTextAlignmentCenter;
        middleDataLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        middleDataLabel.font = _cellFont?_cellFont:[UIFont systemFontOfSize:14];
        
        lineView1 = [[UIView alloc]init];
        lineView1.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
        [self addSubview:lineView1];
        //
        [middleDataLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(lineView.right).offset(5);
            make.right.equalTo(lineView1.left).offset(-5);
            make.height.equalTo(self);
        }];
        
        [lineView1 makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX).multipliedBy(1.33333333);
            make.height.equalTo(self.height);
            make.width.equalTo(0.5);
        }];
        //
        _rightPieChart = [[KDGoalBar alloc]initWithFrame:CGRectMake((self.frame.size.width/3-100)/2+self.frame.size.width/3*2, 0, 100, 100)];
        [self addSubview:_rightPieChart];
        [self addSubview:_rightPieChart];
    
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
    
    middleDataLabel.font = _cellFont;
    middleDataLabel.text = self.middleDataString;
    lineView.frame = CGRectMake(self.frame.size.width/3, 0, 0.5, 60);
    lineView.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
    lineView1.frame = CGRectMake(self.frame.size.width/3*2, 0, 0.5, 60);
    lineView1.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.161f green:0.251f blue:0.365f alpha:1.00f]:[UIColor colorWithRed:0.349f green:0.608f blue:0.780f alpha:1.00f];
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

- (void)setLeftPieGrade:(int)leftPieGrade
{
    [self.leftPieChart setPercent:(leftPieGrade) animated:YES];
}

- (void)setRightPieGrade:(int)rightPieGrad;
{
    [self.rightPieChart setPercent:(rightPieGrad) animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
