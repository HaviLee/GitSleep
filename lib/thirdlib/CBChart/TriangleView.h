//
//  TriangleView.h
//  SleepRecoding
//
//  Created by Havi on 15/8/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TriangleView : UIView

@property (nonatomic) float grade;

@property (nonatomic,strong) CAShapeLayer * chartLine;

@property (nonatomic, strong) UIColor * barColor;

@property (nonatomic,strong) NSString *titleString;

@end
