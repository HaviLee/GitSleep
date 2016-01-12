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
BOOL isThirdLogin = NO;
BOOL isSixteenTime = NO;
NSData *user_Register_Data = nil;

BOOL isUserDefaultTime = NO;
BOOL isLeftBodyOnBed = NO;
BOOL isRihtBodyOnBed = NO;
int selectedThemeIndex = 0;
int isTodayHourEqualSixteen = 0;

NSString *sleepBeforeTagTime= @"";

NSString *thirdPartyLoginUserId = @"";
NSString *thirdPartyLoginToken = @"";
NSString *thirdPartyLoginOriginalId = @"";
NSString *thirdPartyLoginIcon = @"";
NSString *thirdPartyLoginPlatform = @"";
NSString *thirdPartyLoginNickName = @"";
NSString *thirdHardDeviceUUID = @"";
NSString *thirdHardDeviceName = @"";
NSString *thirdMeddoPhone = @"";
NSString *thirdMeddoPassWord = @"";
NSString *thirdLeftDeviceUUID = @"";
NSString *thirdRightDeviceUUID = @"";
NSString *thirdLeftDeviceName = @"";
NSString *thirdRightDeviceName = @"";
BOOL isDoubleDevice = NO;
NSString *isMineDevice = @"NO";
NSString *registeredID = @"";




