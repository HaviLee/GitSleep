//
//  Gloable.m
//  FeiMi_Express
//
//  Created by Apple MBP on 14-7-10.
//  Copyright (c) 2014年 Havi_li. All rights reserved.
//

#import "Gloable.h"

//用户ID
NSString *GloableUserId = @"";
//硬件ip
NSString *HardWareIP = @"";
//硬件UUID
NSString *HardWareUUID = @"";
//为了使得在进入当日心率时时间一致。
NSString *dayTimeToUse = @"";
NSDate *selectedDateToUse = nil;
BOOL DeviceStatus = NO;

BOOL isLogout = NO;

BOOL isUserDefaultTime = NO;

int selectedThemeIndex = 0;

NSString *userLoginUserId = nil;
NSString *userAccessToken = nil;

NSString *thirdPartyLogoutUserId = nil;
NSString *thirdPartyLogoutToken = nil;
NSString *thirdPartyLogoutImei = nil;
NSString *thirdPartyLogoutPlatform = nil;


