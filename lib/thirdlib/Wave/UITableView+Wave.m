//
//  UITableView+Wave.m
//  TableViewWaveDemo
//
//  Created by jason on 14-4-23.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import "UITableView+Wave.h"

@implementation UITableView (Wave)


- (void)reloadDataAnimateWithWave:(WaveAnimation)animation;
{
    [self setContentOffset:self.contentOffset animated:NO];
    [UIView animateWithDuration:.5 animations:^{
        [self setHidden:YES];
        [self reloadData];
    } completion:^(BOOL finished) {
        //Do something after that...
        [self setHidden:NO];
        [self visibleRowsBeginAnimation:animation];
    }];
}


- (void)visibleRowsBeginAnimation:(WaveAnimation)animation
{
    NSArray *array = [self indexPathsForVisibleRows];
    for (int i=0 ; i < [array count]; i++) {
        NSIndexPath *path = [array objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:path];
        cell.hidden = YES;
        NSArray *array = @[path,[NSNumber numberWithInt:animation]];
        [self performSelector:@selector(animationStart:) withObject:array afterDelay:.1*(i+1)];
        
    }
}


- (void)animationStart:(NSArray *)array
{
    NSIndexPath *path = [array objectAtIndex:0];
    float i = [((NSNumber*)[array objectAtIndex:1]) floatValue] ;
    UITableViewCell *cell = [self cellForRowAtIndexPath:path];
    CGPoint originPoint = cell.center;
    cell.center = CGPointMake(cell.frame.size.width*i, originPoint.y);
    [UIView animateWithDuration:0.35
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
                         cell.center = CGPointMake(originPoint.x-i*kBOUNCE_DISTANCE, originPoint.y);
                         cell.hidden = NO;
                     }
                     completion:^(BOOL f) {
						 [UIView animateWithDuration:0.1 delay:0
											 options:UIViewAnimationOptionCurveEaseIn
										  animations:^{
                                              cell.center = CGPointMake(originPoint.x+i*kBOUNCE_DISTANCE, originPoint.y);
                                          }
										  completion:^(BOOL f) {
											  [UIView animateWithDuration:0.2 delay:0
                                                                  options:UIViewAnimationOptionCurveEaseIn
                                                               animations:^{
                                                                   cell.center= originPoint;
                                                               }
                                                               completion:NULL];
										  }];
                     }];
    
    
}

@end
