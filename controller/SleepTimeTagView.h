//
//  SleepTimeTagView.h
//  SleepRecoding
//
//  Created by Havi on 15/8/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLTagsControl.h"
@interface SleepTimeTagView : UIView
@property (nonatomic,strong) TLTagsControl *sleepTitleLabel;
@property (nonatomic,strong) TLTagsControl *sleepTagLabel;
@property (nonatomic,strong) NSString *sleepNightCategoryString;
@property (nonatomic,strong) NSString *sleepYearMonthDayString;
@property (nonatomic,strong) NSString *sleepTimeLongString;
@property (nonatomic,strong) NSString *sleepNameLabelString;

@end
