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
static NSString* CUR_USERTOKEN = @"CURRENT_USER_TOKEN";
static NSString* CUR_USERICON = @"CURRENT_USER_ICON";
static NSString* CUR_USERPLATFORM= @"CURRENT_USER_PLATFORM";
static NSString* CUR_HardWareUUID = @"CUR_HardWareUUID";
static NSString* CUR_USERNICKNAME = @"CUR_USERNICKNAME";

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
    [global setObject:userinfo forKey:CUR_USERINFO];
}

+(void)resetUserInfo    {
    NSUserDefaults *global = [NSUserDefaults standardUserDefaults];
    if([global objectForKey:CUR_USERINFO]!=nil) {
        [global removeObjectForKey:CUR_USERINFO];
    }
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
        return TRUE;
        
    } else {
        return FALSE;
    }
}

@end
