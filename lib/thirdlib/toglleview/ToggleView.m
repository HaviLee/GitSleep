//
//  ToggleView.m
//  ToggleView
//
//  Created by SOMTD on 12/10/14.
//  Copyright (c) 2012年 somtd.com. All rights reserved.
//

#import "ToggleView.h"
//replace sample image files
NSString *const TOGGLE_BUTTON_IMAGE      = @"toggle_button";
NSString *const TOGGLE_BASE_IMAGE        = @"btn_bg_time";//有用
NSString *const TOGGLE_VIEW_BACKGROUND   = @"background.png";
NSString *const LEFT_BUTTON_IMAGE        = @"left_button_on.png";
NSString *const LEFT_BUTTON_IMAGE_SEL    = @"left_button_off.png";
NSString *const RIGHT_BUTTON_IMAGE       = @"right_button_on.png";
NSString *const RIGHT_BUTTON_IMAGE_SEL   = @"right_button_off.png";

#define LEFT_BUTTON_RECT CGRectMake(0, 0, 72.f, 72.f)
#define RIGHT_BUTTON_RECT CGRectMake(0, 0, 72.f, 72.f)
#define TOGGLE_SLIDE_DULATION 0.15f

@implementation ToggleView 
@synthesize toggleDelegate;
@synthesize viewType;

- (id)initWithFrame:(CGRect)frame
     toggleViewType:(ToggleViewType)aViewType
     toggleBaseType:(ToggleBaseType)aBaseType
   toggleButtonType:(ToggleButtonType)aButtonType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewType = aViewType;
        self.frame = frame;
        
        //set up toggle base image.
        _toggleBase = [[ToggleBase alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_bg_%d",selectedThemeIndex]] baseType:aBaseType];
        _toggleBase.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _toggleBase.userInteractionEnabled = YES;
        
        //set up toggle button image.
        _toggleButton = [[ToggleButton alloc]initWithImage:[UIImage imageNamed:TOGGLE_BUTTON_IMAGE] buttonType:aButtonType];
        _toggleButton.frame = CGRectMake(-0.5, 0, self.frame.size.width/2, 25);
        _toggleButton.userInteractionEnabled = YES;
        
        
        //calculate left/right edge
        _leftEdge = _toggleBase.frame.origin.x + _toggleButton.frame.size.width/2;
        _rightEdge = _toggleBase.frame.origin.x + _toggleBase.frame.size.width - _toggleButton.frame.size.width/2;
        _toggleButton.center = CGPointMake(_leftEdge, self.frame.size.height/2);
        
        [self addSubview:_toggleBase];
        [self addSubview:_toggleButton];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        
        UITapGestureRecognizer* buttonTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonTapGesture:)];
        
        UITapGestureRecognizer* baseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBaseTapGesture:)];
        
        [_toggleButton addGestureRecognizer:panGesture];
        [_toggleButton addGestureRecognizer:buttonTapGesture];
        [_toggleBase addGestureRecognizer:baseTapGesture];
    }
    return self;
}

- (void)onLeftButton:(id)sender
{
    [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
        _toggleButton.center = CGPointMake(_leftEdge, self.frame.size.height/2);
    }];
    if (self.viewType == ToggleViewTypeWithLabel)
    {
        _leftButton.selected = YES;
        _rightButton.selected = NO;
    }
    [_toggleBase selectedLeftToggleBase];
    [_toggleButton selectedLeftToggleButton];
    [self.toggleDelegate selectLeftButton];
}

- (void)onRightButton:(id)sender
{
    [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
        _toggleButton.center = CGPointMake(_rightEdge, self.frame.size.height/2);
    }];
    if (self.viewType == ToggleViewTypeWithLabel)
    {
        _leftButton.selected = NO;
        _rightButton.selected = YES;
    }
    [_toggleBase selectedRightToggleBase];
    [_toggleButton selectedRightToggleButton];
    [self.toggleDelegate selectRightButton];
}

- (void)changeLeftImageWithTime:(int)time
{
    [UIView animateWithDuration:time animations:^{
        _toggleButton.center = CGPointMake(_leftEdge, self.frame.size.height/2);
    }];
    if (self.viewType == ToggleViewTypeWithLabel)
    {
        _leftButton.selected = YES;
        _rightButton.selected = NO;
    }
    [_toggleBase selectedLeftToggleBase];
    [_toggleButton selectedLeftToggleButton];
}
- (void)changeRightImageWithTime:(int)time
{
    [UIView animateWithDuration:time animations:^{
        _toggleButton.center = CGPointMake(_rightEdge, self.frame.size.height/2);
    }];
    if (self.viewType == ToggleViewTypeWithLabel)
    {
        _leftButton.selected = NO;
        _rightButton.selected = YES;
    }
    [_toggleBase selectedRightToggleBase];
    [_toggleButton selectedRightToggleButton];
}

- (void)setTogglePosition:(float)positonValue ended:(BOOL)isEnded
{
    if (!isEnded)
    {
        if (positonValue == 0.f)
        {
            _toggleButton.center = CGPointMake(_leftEdge, _toggleButton.center.y);
        }
        else if (positonValue == 1.f)
        {
            _toggleButton.center = CGPointMake(_rightEdge, _toggleButton.center.y);
        }
        else
        {
            _toggleButton.center = CGPointMake(_baseView.frame.origin.x + (positonValue * _baseView.frame.size.width), _toggleButton.center.y);
        }
        
    }
    else //isEnded == YES;
    {
        if (positonValue == 0.f)
        {
            _toggleButton.center = CGPointMake(_leftEdge, _toggleButton.center.y);
            [_toggleBase selectedLeftToggleBase];
            [_toggleButton selectedLeftToggleButton];
            [self.toggleDelegate selectLeftButton];
            
        }
        else if (positonValue == 1.f)
        {
            _toggleButton.center = CGPointMake(_rightEdge, _toggleButton.center.y);
            [_toggleBase selectedRightToggleBase];
            [_toggleButton selectedRightToggleButton];
            [self.toggleDelegate selectRightButton];
        }
        else if (positonValue > 0.f && positonValue < 0.5f)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_leftEdge, _toggleButton.center.y);
            } completion:^(BOOL finished) {
                [_toggleBase selectedLeftToggleBase];
                [_toggleButton selectedLeftToggleButton];
                [self.toggleDelegate selectLeftButton];
            }];
        }
        else if (positonValue >= 0.5f && positonValue < 1.f)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_rightEdge, _toggleButton.center.y);
            } completion:^(BOOL finished) {
                [_toggleBase selectedRightToggleBase];
                [_toggleButton selectedRightToggleButton];
                [self.toggleDelegate selectRightButton];
            }];
        }
    }
}

- (void)handleButtonTapGesture:(UITapGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"])) {
            URBAlertView *alertView = [URBAlertView dialogWithTitle:@"注意" subtitle:@"请到睡眠设置里面开启睡眠自定义按钮"];
            alertView.blurBackground = NO;
            [alertView addButtonWithTitle:@"确认"];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hide];
                
            }];
            [alertView showWithAnimation:URBAlertAnimationFade];
            return;
        }

        if (_toggleButton.center.x == _rightEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_leftEdge, _toggleButton.center.y);
            }completion:^(BOOL finished) {
                [_toggleBase selectedLeftToggleBase];
                [_toggleButton selectedLeftToggleButton];
                [self.toggleDelegate selectLeftButton];
            }];
        }
        else if (_toggleButton.center.x == _leftEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_rightEdge, _toggleButton.center.y);
            }completion:^(BOOL finished) {
                [_toggleBase selectedRightToggleBase];
                [_toggleButton selectedRightToggleButton];
                [self.toggleDelegate selectRightButton];
            }];
        }
    }
}

- (void)handleBaseTapGesture:(UITapGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"])) {
            URBAlertView *alertView = [URBAlertView dialogWithTitle:@"注意" subtitle:@"请到睡眠设置里面开启睡眠自定义按钮"];
            alertView.blurBackground = NO;
            [alertView addButtonWithTitle:@"确认"];
            [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                [alertView hide];
                
            }];
            [alertView showWithAnimation:URBAlertAnimationFade];
            return;
        }
        if (_toggleButton.center.x == _rightEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_leftEdge, _toggleButton.center.y);
            }completion:^(BOOL finished) {
                [_toggleBase selectedLeftToggleBase];
                [_toggleButton selectedLeftToggleButton];
                [self.toggleDelegate selectLeftButton];
            }];
        }
        else if (_toggleButton.center.x == _leftEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _toggleButton.center = CGPointMake(_rightEdge, _toggleButton.center.y);
            }completion:^(BOOL finished) {
                [_toggleBase selectedRightToggleBase];
                [_toggleButton selectedRightToggleButton];
                [self.toggleDelegate selectRightButton];
            }];
        }
    }
}


- (void)handlePanGesture:(UIPanGestureRecognizer*) sender {
        
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:NO];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:NO];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:YES];
        }
        else if (positionValue >= 1.f)
        {
            [self setTogglePosition:1.f ended:YES];
        }
        else if (positionValue <= 0.f)
        {
            [self setTogglePosition:0.f ended:YES];
        }
    }
}

- (void)setSelectedButton:(ToggleButtonSelected)selectedButton
{
    switch (selectedButton) {
        case ToggleButtonSelectedLeft:
            [self onLeftButton:nil];
            break;
        case ToggleButtonSelectedRight:
            [self onRightButton:nil];
            break;
        default:
            break;
    }
}

@end
