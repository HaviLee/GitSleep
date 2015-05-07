//
//  HaviButton.m
//  NoteWall
//
//  Created by Apple MBP on 14-12-3.
//  Copyright (c) 2014年 Havi_li. All rights reserved.
//

#import "HaviButton.h"

@implementation HaviButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType{
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    [self.imageView setFrame:CGRectMake(0, 0, 15, 15)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 40, 0.0, 0)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              -image.size.width-titleSize.width+15,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
}

@end
