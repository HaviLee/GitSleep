//
//  UserManager.m
//  ET
//
//  Created by centling on 13-11-7.
//  Copyright (c) 2013年 Zhaoyu Li. All rights reserved.
//

#import "UserManager.h"

static NSString* CUR_USERINFO = @"CURRENT_USER_INFO";
static NSString* CUR_USERID = @"CURRENT_USER_ID";
static NSString* CUR_OriginalUSERID = @"CUR_OriginalUSERID";
static NSString* CUR_USERTOKEN = @"CURRENT_USER_TOKEN";
static NSString* CUR_USERICON = @"CURRENT_USER_ICON";
static NSString* CUR_USERPLATFORM= @"CURRENT_USER_PLATFORM";
static NSString* CUR_HardWareUUID = @"CUR_HardWareUUID";
static NSString* CUR_HardWareName = @"CUR_HardWareName";
static NSString* CUR_USERNICKNAME = @"CUR_USERNICKNAME";
static NSString* CUR_MeddoPhone = @"CUR_MeddoPhone";
static NSString* CUR_MeddoPassWord = @"CUR_MeddoPassWord";
static NSString* CUR_LeftHardWareUUID = @"CUR_LeftHardWareUUID";
static NSString* CUR_RightHardWareUUID = @"CUR_RightHardWareUUID";
static NSString* CUR_LeftHardWareName = @"CUR_LeftHardWareName";
static NSString* CUR_RightHardWareName = @"CUR_RightHardWareName";
static NSString* CUR_MineDevice = @"CUR_MineDevice";

@implementation UserManager

+(void) setGlobalOauth
{
    NSUserDefaults *global = [NSUserDefaults standardUserDefaults];
    if([global objectForKey:CUR_USERINFO]!=nil) {
        [global removeObjectForKey:CUR_USERINFO];
    }
    NSMutableDictionary* userinfo = [NSMutableDictionary dictionary];
    userinfo[CUR_USERID] = thirdPartyLoginUserId;
    userinfo[CUR_USERTOKEN] = thirdPartyLoginToken;
    userinfo[CUR_USERICON] = thirdPartyLoginIcon;
    userinfo[CUR_USERPLATFORM] = thirdPartyLoginPlatform;
    userinfo[CUR_USERNICKNAME] = thirdPartyLoginNickName;
    userinfo[CUR_HardWareUUID] = thirdHardDeviceUUID;
    userinfo[CUR_HardWareName] = thirdHardDeviceName;
    userinfo[CUR_MeddoPhone] = thirdMeddoPhone;
    userinfo[CUR_OriginalUSERID] = thirdPartyLoginOriginalId;
    userinfo[CUR_MeddoPassWord] = thirdMeddoPassWord;
    userinfo[CUR_LeftHardWareName] = thirdLeftDeviceName;
    userinfo[CUR_LeftHardWareUUID] = thirdLeftDeviceUUID;
    userinfo[CUR_RightHardWareName] = thirdRightDeviceName;
    userinfo[CUR_RightHardWareUUID] = thirdRightDeviceUUID;
    userinfo[CUR_MineDevice] = isMineDevice;
    [global setObject:userinfo forKey:CUR_USERINFO];
}

+(void)resetUserInfo    {
    NSUserDefaults *global = [NSUserDefaults standardUserDefaults];
    if([global objectForKey:CUR_USERINFO]!=nil) {
        [global removeObjectForKey:CUR_USERINFO];
    }
    thirdPartyLoginUserId = @"";
    thirdPartyLoginToken = @"";
    thirdPartyLoginIcon = @"";
    thirdPartyLoginPlatform = @"";
    thirdPartyLoginNickName = @"";
    thirdHardDeviceUUID = @"";
    thirdHardDeviceName = @"";
    thirdMeddoPassWord = @"";
    thirdMeddoPhone = @"";
    thirdPartyLoginOriginalId = @"";
    thirdRightDeviceUUID = @"";
    thirdRightDeviceName = @"";
    thirdLeftDeviceUUID = @"";
    thirdLeftDeviceName = @"";
    isMineDevice = @"NO";
    
}

+(void)resetInitUserInfo {
    
}

+(BOOL)IsUserLogged {
    BOOL ret = FALSE;
    NSMutableDictionary* userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:CUR_USERINFO];
    //用户个人信息存在说名登录成功
    if (userinfo) {
        ret = TRUE;
    }
    return ret;
}

+(BOOL)GetUserObj {
    NSMutableDictionary* userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:CUR_USERINFO];
    if (userinfo) {

        thirdPartyLoginUserId = [userinfo objectForKey:CUR_USERID];
        thirdPartyLoginToken = [userinfo objectForKey:CUR_USERTOKEN];
        thirdPartyLoginIcon = [userinfo objectForKey:CUR_USERICON];
        thirdPartyLoginPlatform = [userinfo objectForKey:CUR_USERPLATFORM];
        thirdPartyLoginNickName = [userinfo objectForKey:CUR_USERNICKNAME];
        thirdHardDeviceUUID = [userinfo objectForKey:CUR_HardWareUUID];
        thirdHardDeviceName = [userinfo objectForKey:CUR_HardWareName];
        thirdMeddoPhone = [userinfo objectForKey:CUR_MeddoPhone];
        thirdMeddoPassWord = [userinfo objectForKey:CUR_MeddoPassWord];
        thirdPartyLoginOriginalId = [userinfo objectForKey:CUR_OriginalUSERID];
        thirdLeftDeviceName = [userinfo objectForKey:CUR_LeftHardWareName];
        thirdLeftDeviceUUID = [userinfo objectForKey:CUR_LeftHardWareUUID];
        thirdRightDeviceName = [userinfo objectForKey:CUR_RightHardWareName];
        thirdRightDeviceUUID = [userinfo objectForKey:CUR_RightHardWareUUID];
        isMineDevice = [userinfo objectForKey:CUR_MineDevice];
        return TRUE;
        
    } else {
        return FALSE;
    }
}

@end
