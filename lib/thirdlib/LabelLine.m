//
//  LabelLine.m
//  Fly_Meet
//
//  Created by Apple MBP on 14-4-11.
//  Copyright (c) 2014年 Apple MBP. All rights reserved.
//

#import "LabelLine.h"

@implementation LabelLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize fontSize =[self.text sizeWithFont:self.font
                                    forWidth:self.frame.size.width
                               lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGContextSetStrokeColorWithColor(ctx, self.textColor.CGColor);  // set as the text's color
    CGContextSetLineWidth(ctx, 1.0f);
    
    CGPoint l,r;
        l = CGPointMake(0, self.frame.size.height/2.0 +fontSize.height/2.0);
        r = CGPointMake(fontSize.width, self.frame.size.height/2.0 + fontSize.height/2.0);
        
    // Add Move Command to point the draw cursor to the starting point
    CGContextMoveToPoint(ctx, l.x, l.y);
    
    // Add Command to draw a Line
    CGContextAddLineToPoint(ctx, r.x, r.y);
    
    
    // Actually draw the line.
    CGContextStrokePath(ctx);
    
    // should be nothing, but who knows...
    [super drawRect:rect];
    
}


@end
