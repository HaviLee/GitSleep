//
//  YCoordinatrorView.m
//  SleepRecoding
//
//  Created by Havi on 15/5/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YCoordinatrorView.h"

@interface YCoordinatrorView ()

@property (strong, nonatomic) NSDictionary *textStyleDict;
@property (strong, nonatomic) NSDictionary *textStyleDict1;


@end

@implementation YCoordinatrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawGrid];
    [self drawYLable];
    [self drawYGrid];
}

- (void)drawYGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat padding = (self.frame.size.height)/(self.yValues.count-1);
    CGContextSetLineWidth(context, 2);
    for (int i=0; i<self.yValues.count-1; i++) {
        CGContextMoveToPoint(context, self.frame.size.width-2, padding*(i));
        CGContextAddLineToPoint(context, self.frame.size.width, padding*(i));
        CGContextStrokePath(context);
    }
}

- (void)drawYLable
{
    if (self.yValues) {
        CGFloat padding = (self.frame.size.height)/(self.yValues.count-1);
        for (int i=0; i<self.yValues.count; i++) {
            NSString *xValuesString = [self.yValues objectAtIndex:i];
            CGSize size = [xValuesString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
            if (i==0) {
                if ([xValuesString intValue]>1) {
                    xValuesString = [NSString stringWithFormat:@"(%@)",xValuesString];
                    [xValuesString drawAtPoint:CGPointMake(self.frame.size.width-size.width-6, padding *i-2) withAttributes:self.textStyleDict1];
                }else{
                    [xValuesString drawAtPoint:CGPointMake(self.frame.size.width-size.width-3, padding *i-2) withAttributes:self.textStyleDict];
                }
            }else if(i==self.yValues.count-1){
                [xValuesString drawAtPoint:CGPointMake(self.frame.size.width-size.width-3, padding *i-size.height+2) withAttributes:self.textStyleDict];
            }else{
                [xValuesString drawAtPoint:CGPointMake(self.frame.size.width-size.width-3, padding *i-size.height/2) withAttributes:self.textStyleDict];
            }
           
            
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

-(NSDictionary *)textStyleDict1
{
    if (!_textStyleDict1) {
        UIFont *font = [UIFont systemFontOfSize:11];
        NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init]; // 段落样式
        style.alignment = NSTextAlignmentCenter;
        _textStyleDict1 = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:selectedThemeIndex==0?[UIColor redColor]:[UIColor redColor],};
    }
    return _textStyleDict1;
}


- (void)drawGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *gridColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
    
    CGContextMoveToPoint(context, self.frame.size.width-2, 0);
    CGContextAddLineToPoint(context, self.frame.size.width-2, self.frame.size.height+2);
    
    CGContextStrokePath(context);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
