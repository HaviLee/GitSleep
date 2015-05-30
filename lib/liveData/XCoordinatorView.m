//
//  XCoordinatorView.m
//  SleepRecoding
//
//  Created by Havi on 15/5/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "XCoordinatorView.h"

@interface XCoordinatorView ()

@property (strong, nonatomic) NSDictionary *textStyleDict;

@end

@implementation XCoordinatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawGrid];
    [self drawXLable];
    [self drawYGrid];
}

- (void)drawYGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat padding = (self.frame.size.width-50)/6;
    CGContextSetLineWidth(context, 2);
    for (int i=0; i<6; i++) {
        CGContextMoveToPoint(context, padding *(i+1), 0);
        CGContextAddLineToPoint(context, padding*(i+1), 2);
        CGContextStrokePath(context);
    }
}

- (void)drawXLable
{
    if (self.xValues) {
        for (int i=0; i<self.xValues.count; i++) {
            NSString *xValuesString = [self.xValues objectAtIndex:i];
            CGFloat padding = (self.frame.size.width-50)/6;
            CGSize size = [xValuesString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
            [xValuesString drawAtPoint:CGPointMake(padding*(i+1)-size.width/2, 2) withAttributes:self.textStyleDict];
        }
    }
}

-(NSDictionary *)textStyleDict
{
    if (!_textStyleDict) {
        UIFont *font = [UIFont systemFontOfSize:13];
        NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init]; // 段落样式
        style.alignment = NSTextAlignmentCenter;
        _textStyleDict = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor],};
    }
    return _textStyleDict;
}


- (void)drawGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat full_width = self.frame.size.width;
    UIColor *gridColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
    
    CGContextMoveToPoint(context, 0, 2);
    CGContextAddLineToPoint(context, full_width, 2);
    
    CGContextStrokePath(context);

}

@end
