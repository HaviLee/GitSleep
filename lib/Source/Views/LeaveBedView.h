//
//  LeaveBedView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BasePicView.h"
#import "HaviBarView.h"
#import "ToggleView.h"
@interface LeaveBedView : BasePicView
@property (nonatomic, strong) ToggleView *breathTimeSwitchButton;

@property (nonatomic,strong) HaviBarView *barView;
@property (nonatomic,strong) NSDictionary *infoDic;

@property (nonatomic,strong) NSArray *aff;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)layoutOutSubViewWithNewData;

@end
