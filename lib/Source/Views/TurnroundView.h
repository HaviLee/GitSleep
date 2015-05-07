//
//  TurnroundView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BasePicView.h"
#import "ToggleView.h"

@interface TurnroundView : BasePicView
@property (nonatomic, strong) ToggleView *breathTimeSwitchButton;

@property (nonatomic,strong) NSArray *aff;
@property (nonatomic,strong) NSDictionary *infoDic;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)layoutOutSubViewWithNewData;

- (void)layoutOutDefaultSubViewWithNewData;

@end
