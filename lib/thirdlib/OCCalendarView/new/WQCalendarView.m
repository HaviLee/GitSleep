//
//  WQCalendarView.m
//  WQCalendar
//
//  Created by Jason Lee on 14-3-12.
//  Copyright (c) 2014年 Jason Lee. All rights reserved.
//

#import "WQCalendarView.h"

@interface WQCalendarView ()

@end

@implementation WQCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.weeklyHeader = [[UIImageView alloc] init];
        self.weeklyHeader.frame = CGRectMake(0, 0, frame.size.width, 44);
        [self addSubview:self.weeklyHeader];
        self.weeklyHeader.backgroundColor = [UIColor clearColor];
        UIImageView *image = [[UIImageView alloc]init];
        image.frame = CGRectMake(5, 43, frame.size.width-10, 0.5);
        image.backgroundColor = [UIColor colorWithRed:0.404f green:0.639f blue:0.784f alpha:1.00f];
        [self.weeklyHeader addSubview:image];
        //
        NSArray *arr = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
        for (int i=0;i<7; i++) {
            UILabel *titleLabel = [[UILabel alloc]init];
            titleLabel.frame = CGRectMake(i*(frame.size.width/7), 0, frame.size.width/7, 44);
            titleLabel.text = [arr objectAtIndex:i];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.textColor = [UIColor colorWithRed:0.314f green:0.486f blue:0.698f alpha:1.00f];
            [self.weeklyHeader addSubview:titleLabel];
            
        }
        
        
        CGFloat headerHeight = self.weeklyHeader.frame.size.height;
        CGRect gridRect = (CGRect){0, headerHeight, self.bounds.size.width, WQ_CALENDAR_ROW_HEIGHT * 6};
        self.gridView = [[WQCalendarGridView alloc] initWithFrame:gridRect];
        [self addSubview:self.gridView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
