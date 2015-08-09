//
//  SleepTimeTagView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepTimeTagView.h"

@interface SleepTimeTagView ()
{
    UIImageView *sleepTimeImageView;
    UILabel *sleepNightCategoryLabel;
    UILabel *sleepYearMonthDayLabel;
    UILabel *sleepTimeLongLabel;
    UILabel *sleepNameLabel;

}
@end

@implementation SleepTimeTagView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubView];
        [self setContraints];
    }
    return self;
}

- (void)initSubView
{
    [self addSubview:self.sleepTitleLabel];
    [self addSubview:self.sleepTagLabel];
    sleepNightCategoryLabel = [[UILabel alloc]init];
    sleepNightCategoryLabel.font = [UIFont systemFontOfSize:11];
    sleepNightCategoryLabel.text = @"最长的夜晚";
    [self addSubview:sleepNightCategoryLabel];
    
    sleepYearMonthDayLabel = [[UILabel alloc]init];
    sleepYearMonthDayLabel.font = [UIFont systemFontOfSize:11];
    sleepYearMonthDayLabel.text = @"15-08-09";
    [self addSubview:sleepYearMonthDayLabel];
    
    sleepTimeLongLabel = [[UILabel alloc]init];
    sleepTimeLongLabel.font = [UIFont systemFontOfSize:11];
    sleepTimeLongLabel.text = @"10小时35分";
    [self addSubview:sleepTimeLongLabel];
    
    sleepNameLabel = [[UILabel alloc]init];
    sleepNameLabel.font = [UIFont systemFontOfSize:11];
    sleepNameLabel.text = @"睡前";
    [self addSubview:sleepNameLabel];
    
    sleepTimeImageView = [[UIImageView alloc]init];
    [self addSubview:sleepTimeImageView];
}

- (void)setContraints
{
    [self.sleepTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.top.equalTo(self).offset(0);
        make.height.equalTo(25);
        
    }];
    
    [sleepNightCategoryLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sleepTitleLabel.bottom);
        make.left.equalTo(self).offset(10);
        make.height.equalTo(25);
    }];
    
    [sleepYearMonthDayLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sleepNightCategoryLabel.centerY);
        make.height.equalTo(25);
        make.right.equalTo(sleepTimeLongLabel.left).offset(-10);
    }];
    
    [sleepTimeLongLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-10);
        make.centerY.equalTo(sleepNightCategoryLabel.centerY);
        make.left.equalTo(sleepYearMonthDayLabel.right);
        make.height.equalTo(25);
    }];
    
    [sleepTimeImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sleepNightCategoryLabel.bottom);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(25);
    }];
    
    [sleepNameLabel makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(self).offset(10);
        make.top.equalTo(sleepTimeImageView.bottom);
        make.height.equalTo(25);
    }];
    
    [self.sleepTagLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sleepNameLabel.right).offset(5);
        make.right.equalTo(self.right).offset(-10);
        make.centerY.equalTo(sleepNameLabel.centerY);
        make.height.equalTo(20);
    }];
}


- (TLTagsControl *)sleepTitleLabel
{
    if (_sleepTitleLabel==nil) {
        _sleepTitleLabel = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 25) andTags:nil withTagsControlMode:TLTagsControlModeList];
        _sleepTitleLabel.tagsBackgroundColor = [UIColor colorWithRed:0.278f green:0.624f blue:0.616f alpha:1.00f];
        _sleepTitleLabel.tagsTextColor = [UIColor lightGrayColor];
        
    }
    return _sleepTitleLabel;
}

- (TLTagsControl *)sleepTagLabel
{
    if (_sleepTagLabel==nil) {
        _sleepTagLabel = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 25) andTags:nil withTagsControlMode:TLTagsControlModeList];
        _sleepTagLabel.tagsBackgroundColor = [UIColor colorWithRed:0.278f green:0.624f blue:0.616f alpha:1.00f];
        _sleepTagLabel.tagsTextColor = [UIColor lightGrayColor];
        
    }
    return _sleepTagLabel;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
