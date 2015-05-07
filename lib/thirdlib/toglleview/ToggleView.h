//
//  ToggleView.h
//  ToggleView
//
//  Created by SOMTD on 12/10/14.
//  Copyright (c) 2012年 somtd.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ToggleButton.h"
#import "ToggleBase.h"
//#import "ToggleSwitchView.h"

@protocol ToggleViewDelegate;

typedef enum{
    ToggleViewTypeWithLabel,
    ToggleViewTypeNoLabel,
}ToggleViewType;

typedef enum{
    ToggleButtonSelectedLeft,
    ToggleButtonSelectedRight,
}ToggleButtonSelected;

@interface ToggleView : UIView <UIGestureRecognizerDelegate>
{
    id<ToggleViewDelegate> _toggleDelegate;
    
    float _leftEdge;
    float _rightEdge;
    
    ToggleButton *_toggleButton;
    ToggleBase *_toggleBase;
    UIView *_baseView;
    UIButton *_leftButton;
    UIButton *_rightButton;
    
}
@property (nonatomic, assign) id<ToggleViewDelegate> toggleDelegate;
@property (nonatomic) ToggleViewType viewType;
@property (nonatomic) ToggleButtonSelected selectedButton;
- (id)initWithFrame:(CGRect)frame
     toggleViewType:(ToggleViewType)viewType
     toggleBaseType:(ToggleBaseType)baseType
   toggleButtonType:(ToggleButtonType)buttonType;
- (void)changeLeftImageWithTime:(int)time;
- (void)changeRightImageWithTime:(int)time;

@end

@protocol ToggleViewDelegate <NSObject>
- (void)selectLeftButton;
- (void)selectRightButton;

@end
