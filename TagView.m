//
//  TagView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TagView.h"

@interface TagView ()
{
    UILabel *dayTimeLabel;
}
@end

@implementation TagView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView
{
    self.frame = CGRectMake(0, 0, 80, 40);
    dayTimeLabel = [[UILabel alloc]init];
    dayTimeLabel.frame = CGRectMake(12.5, 5, 55, 30);
    dayTimeLabel.font = [UIFont systemFontOfSize:11];
    dayTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    dayTimeLabel.text = @"08:09AM";
    [self addSubview:dayTimeLabel];
}

- (void)setTagName:(NSString *)tagName
{
    dayTimeLabel.text = tagName;
    self.backgroundColor = [UIColor lightGrayColor];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
