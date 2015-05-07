//
//  ToggleButton.m
//  ToggleView
//
//  Created by SOMTD on 12/10/15.
//  Copyright (c) 2012年 somtd.com. All rights reserved.
//

#import "ToggleButton.h"

//change button image option
NSString *const TOGGLE_BUTTON_IMAGE_L    = @"btn_24h_time";
NSString *const TOGGLE_BUTTON_IMAGE_R    = @"btn_custom_time";


@implementation ToggleButton
@synthesize buttonType;

- (id)initWithImage:(UIImage *)image buttonType:(ToggleButtonType)aButtonType
{
    self = [super initWithImage:image];
    if (self) {
        self.buttonType = aButtonType;
        if (self.buttonType == ToggleButtonTypeChangeImage)
        {
            //default select "L"
            self.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_custom_%d",selectedThemeIndex]];
            return self;
        }
    }
    return self;
}

- (void)selectedLeftToggleButton
{
    if (self.buttonType == ToggleButtonTypeChangeImage)
    {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_24h_%d",selectedThemeIndex]];
    }
}

- (void)selectedRightToggleButton
{
    if (self.buttonType == ToggleButtonTypeChangeImage)
    {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"btn_custom_%d",selectedThemeIndex]];

    }
}
@end
