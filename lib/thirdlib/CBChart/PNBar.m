//
//  PNBar.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNBar.h"

@interface PNBar ()
@end

@implementation PNBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_chartLine = [CAShapeLayer layer];
		_chartLine.lineCap = kCALineCapSquare;
		_chartLine.fillColor   = [[UIColor colorWithWhite:0 alpha:0] CGColor];
		_chartLine.lineWidth   = self.frame.size.width;
		_chartLine.strokeEnd   = 0.0;
		self.clipsToBounds = YES;
		[self.layer addSublayer:_chartLine];
		self.layer.cornerRadius = 2.0;
    }
    return self;
}

-(void)setGrade:(float)grade
{
	_grade = grade;
	UIBezierPath *progressline = [UIBezierPath bezierPath];
    
    [progressline moveToPoint:CGPointMake(self.frame.size.width/2.0, self.frame.size.height)];
	[progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - grade) * self.frame.size.height)];
	
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapSquare];
	_chartLine.path = progressline.CGPath;

	if (_barColor) {
		_chartLine.strokeColor = [_barColor CGColor];
	}else{
		_chartLine.strokeColor = [UIColor colorWithRed:0.259f green:0.631f blue:0.737f alpha:0.5f].CGColor;
	}
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    //
    _chartLine.strokeEnd = 1.0;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	//Draw BG
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.329f green:0.557f blue:0.729f alpha:1.0f].CGColor);
	CGContextFillRect(context, rect);
    
}


@end
