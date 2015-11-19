//
//  DoubleChartTableViewCell.m
//  SleepRecoding
//
//  Created by Havi on 15/11/18.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "DoubleChartTableViewCell.h"
#import "MyPieElement.h"
#import "PieLayer.h"

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
        _leftPieChart = [[PieChartView alloc]initWithFrame:CGRectMake(0, 10, 40, 40)];
        [self addSubview:_leftPieChart];
//        [_leftPieChart makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self);
//            make.centerX.equalTo(self.centerX).multipliedBy(0.3333333);
//            make.height.equalTo(_leftPieChart.width);
//            make.top.equalTo(self).offset(20);
//            make.bottom.equalTo(self.bottom).offset(-20);
//            
//        }];
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
        _rightPieChart = [[PieChartView alloc]init];
        [self addSubview:_rightPieChart];
        [_rightPieChart makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self.centerX).multipliedBy(1.6666666);
            make.height.equalTo(_rightPieChart.width);
            make.top.equalTo(self).offset(20);
            make.bottom.equalTo(self).offset(-20);
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
    float pieValue = (float)leftPieGrade;
    MyPieElement* elem = [MyPieElement pieElementWithValue:pieValue color:[UIColor redColor]];
    elem.title = [NSString stringWithFormat:@"%d%@",leftPieGrade,@"%"];
    MyPieElement* elem1 = [MyPieElement pieElementWithValue:(100-pieValue) color:[UIColor whiteColor]];
    elem1.title = [NSString stringWithFormat:@"%d%@",(100-leftPieGrade),@"%"];
    [self.leftPieChart.layer addValues:@[elem] animated:NO];
    [self.leftPieChart.layer addValues:@[elem1] animated:NO];
    
    //mutch easier do this with array outside
    self.leftPieChart.layer.transformTitleBlock = ^(PieElement* elem){
        return [(MyPieElement*)elem title];
    };
    self.leftPieChart.layer.showTitles = ShowTitlesAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
