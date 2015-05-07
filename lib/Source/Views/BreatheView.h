//
//  BreatheView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BasePicView.h"
#import "ToggleView.h"

@interface BreatheView : BasePicView

@property (nonatomic, strong) ToggleView *breathTimeSwitchButton;
@property (nonatomic,strong) NSDictionary *infoDic;
@property (nonatomic,strong) NSArray *aff;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)layoutOutSubViewWithNewData;

@end
