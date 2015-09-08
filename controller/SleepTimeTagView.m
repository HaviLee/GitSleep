//
//  SleepTimeTagView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SleepTimeTagView.h"
#import "PNLineView.h"
@interface SleepTimeTagView ()
{
    UIImageView *sleepTimeImageView;
    UILabel *sleepNightCategoryLabel;
    UILabel *sleepYearMonthDayLabel;
    UILabel *sleepTimeLongLabel;
    UILabel *sleepNameLabel;
    UILabel *afterNameLabel;
    PNLineView *sleepLineView;

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
    sleepNightCategoryLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    [self addSubview:sleepNightCategoryLabel];
    
    sleepYearMonthDayLabel = [[UILabel alloc]init];
    sleepYearMonthDayLabel.font = [UIFont systemFontOfSize:11];
    sleepYearMonthDayLabel.text = @"15-08-09";
    sleepYearMonthDayLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    [self addSubview:sleepYearMonthDayLabel];
    
    sleepTimeLongLabel = [[UILabel alloc]init];
    sleepTimeLongLabel.font = [UIFont systemFontOfSize:11];
    sleepTimeLongLabel.text = @"10小时35分";
    sleepTimeLongLabel.textColor = selectedThemeIndex==0?[UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f]:[UIColor whiteColor];
    [self addSubview:sleepTimeLongLabel];
    
    sleepNameLabel = [[UILabel alloc]init];
    sleepNameLabel.font = [UIFont systemFontOfSize:11];
    sleepNameLabel.text = @"";
    sleepNameLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self addSubview:sleepNameLabel];
    
    afterNameLabel = [[UILabel alloc]init];
    afterNameLabel.font = [UIFont systemFontOfSize:11];
    afterNameLabel.text = @"";
    afterNameLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self addSubview:afterNameLabel];
    
    sleepTimeImageView = [[UIImageView alloc]init];
    sleepTimeImageView.backgroundColor = [UIColor colorWithRed:0.157f green:0.255f blue:0.357f alpha:0.50f];
    sleepTimeImageView.layer.cornerRadius = 2;
    sleepTimeImageView.layer.masksToBounds = YES;
    [self addSubview:sleepTimeImageView];
    
    sleepLineView  = [[PNLineView alloc]initWithFrame:CGRectMake(0, 0, 0, 5)];
    [sleepTimeImageView addSubview:sleepLineView];
}

- (void)setContraints
{
    [afterNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self.sleepTitleLabel.centerY);
        make.height.equalTo(25);
        make.width.equalTo(0);
    }];
    [self.sleepTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(afterNameLabel.right).offset(-10);
        make.right.equalTo(self).offset(0);
        make.top.equalTo(self).offset(0);
        make.height.equalTo(17);
        make.width.equalTo(0);
        
    }];
    
    [sleepNightCategoryLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sleepTitleLabel.bottom);
        make.left.equalTo(self).offset(20);
        make.height.equalTo(25);
    }];
    
    [sleepYearMonthDayLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sleepNightCategoryLabel.centerY);
        make.height.equalTo(25);
        make.right.equalTo(sleepTimeLongLabel.left).offset(-10);
    }];
    
    [sleepTimeLongLabel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.right).offset(-20);
        make.centerY.equalTo(sleepNightCategoryLabel.centerY);
        make.height.equalTo(25);
    }];
    
    [sleepTimeImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sleepNightCategoryLabel.bottom).offset(2);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.equalTo(5);
    }];
    
    [sleepNameLabel makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(self).offset(20);
        make.top.equalTo(sleepTimeImageView.bottom).offset(2);
        make.height.equalTo(25);
    }];
    
    [self.sleepTagLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sleepNameLabel.right).offset(-10);
        make.right.equalTo(self.right).offset(0);
        make.centerY.equalTo(sleepNameLabel.centerY);
        make.height.equalTo(17);
    }];
}


- (TLTagsControl *)sleepTitleLabel
{
    if (_sleepTitleLabel==nil) {
        _sleepTitleLabel = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 10, 17) andTags:nil withTagsControlMode:TLTagsControlModeList];
        _sleepTitleLabel.tagsBackgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.157f green:0.251f blue:0.357f alpha:1.00f]:[UIColor whiteColor];
        _sleepTitleLabel.tagFont = [UIFont systemFontOfSize:11];
        _sleepTitleLabel.tagsTextColor = [UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f];
        
    }
    return _sleepTitleLabel;
}

- (TLTagsControl *)sleepTagLabel
{
    if (_sleepTagLabel==nil) {
        _sleepTagLabel = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 250, 17) andTags:nil withTagsControlMode:TLTagsControlModeList];
        _sleepTagLabel.tagFont = [UIFont systemFontOfSize:11];
        _sleepTagLabel.tagsBackgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.157f green:0.251f blue:0.357f alpha:1.00f]:[UIColor whiteColor];
        _sleepTagLabel.tagsTextColor = [UIColor colorWithRed:0.000f green:0.851f blue:0.573f alpha:1.00f];
        
    }
    return _sleepTagLabel;
}

//setter

- (void)setSleepNightCategoryString:(NSString *)sleepNightCategoryString
{
    sleepNightCategoryLabel.text = sleepNightCategoryString;
}

- (void)setSleepYearMonthDayString:(NSString *)sleepYearMonthDayString
{
    sleepYearMonthDayLabel.text = sleepYearMonthDayString;
}

- (void)setSleepTimeLongString:(NSString *)sleepTimeLongString
{
    sleepTimeLongLabel.text = sleepTimeLongString;
}

- (void)setSleepNameLabelString:(NSString *)sleepNameLabelString
{
    sleepNameLabel.text = sleepNameLabelString;
}

- (void)setGrade:(CGFloat)grade
{
    CGFloat width = (self.frame.size.width - 40)*grade;
    [UIView animateWithDuration:0.5 animations:^{
        sleepLineView.frame = CGRectMake(0, 2.5, width, 5);
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
