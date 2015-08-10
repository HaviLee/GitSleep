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
static NSString* CUR_USERIMEI = @"CURRENT_USER_IMEI";
static NSString* CUR_USERPLATFORM= @"CURRENT_USER_PLATFORM";

static NSString* LOGIN_USERID = @"LOGIN_USERID";
static NSString* LOGIN_ACCESSTOKEN = @"LOGIN_ACCESSTOKEN";

@implementation UserManager

+(void) setGlobalOauth
{
    NSUserDefaults *global = [NSUserDefaults standardUserDefaults];
    if([global objectForKey:CUR_USERINFO]!=nil) {
        [global removeObjectForKey:CUR_USERINFO];
    }
    NSMutableDictionary* userinfo = [NSMutableDictionary dictionary];
    userinfo[CUR_USERID] = thirdPartyLogoutUserId;
    userinfo[CUR_USERTOKEN] = thirdPartyLogoutToken;
    userinfo[CUR_USERIMEI] = thirdPartyLogoutImei;
    userinfo[CUR_USERPLATFORM] = thirdPartyLogoutPlatform;
    
    userinfo[LOGIN_USERID] = userLoginUserId;
    userinfo[LOGIN_ACCESSTOKEN] = userAccessToken;
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

        thirdPartyLogoutUserId = [userinfo objectForKey:CUR_USERID];
        thirdPartyLogoutToken = [userinfo objectForKey:CUR_USERTOKEN];
        thirdPartyLogoutImei = [userinfo objectForKey:CUR_USERIMEI];
        thirdPartyLogoutPlatform = [userinfo objectForKey:CUR_USERPLATFORM];
        
        userAccessToken = [userinfo objectForKey:LOGIN_ACCESSTOKEN];
        userLoginUserId = [userinfo objectForKey:LOGIN_USERID];
        
        return TRUE;
        
    } else {
        return FALSE;
    }
}

@end
