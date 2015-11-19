//
//  Example2PieView.h
//  MagicPie
//
//  Created by Alexander on 30.12.13.
//  Copyright (c) 2013 Alexandr Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieLayer;

@interface PieChartView : UIView

@end

@interface PieChartView (ex)
@property(nonatomic,readonly,retain) PieLayer *layer;
@end