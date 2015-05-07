//
//  QuaterCalenderView.h
//  SleepRecoding
//
//  Created by Havi on 15/4/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedQuater <NSObject>

- (void)selectedQuater:(NSString *)monthString;

@end

@interface QuaterCalenderView : UIView

@property (nonatomic,strong) NSString *quaterTitle;
@property (nonatomic,strong) id<SelectedQuater>delegate;
@property (nonatomic,assign) int currentQuaterNum;

@end
