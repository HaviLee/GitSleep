//
//  HeartView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BasePicView.h"
#import "ToggleView.h"

@interface HeartView : BasePicView

@property (nonatomic,strong) NSMutableArray *aff;
@property (nonatomic,strong) NSDictionary *infoDic;
@property (nonatomic, strong) ToggleView *timeSwitchButton;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)layoutOutSubViewWithNewData;

@end
