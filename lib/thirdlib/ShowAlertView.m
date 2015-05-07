//
//  ShowAlertView.m
//  Fly_Meet
//
//  Created by Apple MBP on 14-4-11.
//  Copyright (c) 2014年 Apple MBP. All rights reserved.
//

#import "ShowAlertView.h"

@implementation ShowAlertView
+ (void)showAlert:(NSString *)string
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:string delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
@end
