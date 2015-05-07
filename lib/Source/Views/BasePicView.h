//
//  BasePicView.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LabelLine.h"
#define ISChange @"changeButtonTag"
@interface BasePicView : UIView
- (UIColor *) randomColor;
@property (nonatomic, strong) UITableView *chartTableView;
//@property (nonatomic, strong) ToggleView *timeSwitchButton;

//分割线
@property (nonatomic,strong) UIImageView *gifImageUp;
@property (nonatomic,strong) UIImageView *gifImageDown;
//诊断报告
@property (nonatomic,strong) UIImageView *diagnoseImage;
@property (nonatomic,strong) LabelLine *diagonseTitle;
@property (nonatomic,strong) LabelLine *diagnoseResult;
@property (nonatomic,strong) LabelLine *diagnoseExplain;
@property (nonatomic,strong) LabelLine *diagnoseChoice;
@property (nonatomic,strong) UILabel *diagnoseShow;
@property (nonatomic,strong) UILabel *diagnoseSubLabel;

@end
