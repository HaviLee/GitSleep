//
//  CirlcleView.h
//  Circle
//
//  Created by Havi on 15/8/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CirlcleView : UIView
-(void)setPercent:(NSInteger)percent animated:(BOOL)animated;
-(void)setPercent:(NSInteger)percent animated:(BOOL)animated withDuration:(int)duration;
@property (nonatomic,strong) CAGradientLayer *gradientLayer2;
@property (nonatomic,strong) CAGradientLayer *gradientLayer1;
@end
