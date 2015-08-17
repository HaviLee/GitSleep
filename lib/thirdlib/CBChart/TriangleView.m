//
//  TriangleView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TriangleView.h"

@interface TriangleView ()
{
    CGRect rect1;
}
@end

@implementation TriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rect1 = frame;
//        _chartLine = [CAShapeLayer layer];
//        _chartLine.lineCap = kCALineCapSquare;
//        _chartLine.fillColor   = [[UIColor redColor] CGColor];
//        _chartLine.lineWidth   = self.frame.size.width;
//        _chartLine.strokeEnd   = 0.0;
//        self.clipsToBounds = YES;
//        [self.layer addSublayer:_chartLine];
//        self.layer.cornerRadius = 0.0;
    }
    return self;
}

-(void)setGrade:(float)grade
{
//    _grade = grade;
//    UIBezierPath *progressline = [UIBezierPath bezierPath];
//    
//    [progressline moveToPoint:CGPointMake(self.frame.size.width/2.0, self.frame.size.height)];
//    [progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - grade) * self.frame.size.height)];
//    
//    [progressline setLineWidth:1.0];
//    [progressline setLineCapStyle:kCGLineCapSquare];
//    _chartLine.path = progressline.CGPath;
//    
//    if (_barColor) {
//        _chartLine.strokeColor = [_barColor CGColor];
//    }else{
//        _chartLine.strokeColor = [UIColor colorWithRed:0.259f green:0.631f blue:0.737f alpha:0.5f].CGColor;
//    }
//    
//    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    pathAnimation.duration = 1.0;
//    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
//    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
//    pathAnimation.autoreverses = NO;
//    [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
//    //
//    _chartLine.strokeEnd = 1.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawRectanglecontext:context];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Draw BG
    [super drawRect:rect];
    
    [self drawRectanglecontext:nil];
    
}

- (void)drawRectanglecontext:(CGContextRef)context
{
    //利用path进行绘制三角形
    CGContextRef context1 = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context1);//标记
    CGContextMoveToPoint(context1,rect1.origin.x/2-2, rect1.size.height);//设置起点
    CGContextAddLineToPoint(context1,rect1.origin.x/2, 0);
    CGContextAddLineToPoint(context1,rect1.origin.x/2+2 , rect1.size.height);
//    CGContextMoveToPoint(context,rect.origin.x, rect.size.height);//设置起点
//    CGContextAddLineToPoint(context,rect.size.width/2, 0);
//    CGContextAddLineToPoint(context,rect.origin.y , rect.size.height);
//    CGContextClosePath(context);//路径结束标志，不写默认封闭
    CGContextSetLineWidth(context1, 0.5);
        [[UIColor whiteColor] setFill];
    //设置填充色
//        [[UIColor blueColor] setStroke];
    //设置边框颜色
    CGContextDrawPath(context1,kCGPathStroke);//绘制路径path
}


@end
