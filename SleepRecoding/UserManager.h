//
//  UserManager.h
//  ET
//
//  Created by centling on 13-11-7.
//  Copyright (c) 2013年 Zhaoyu Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
+(void) setGlobalOauth;
+(void)resetUserInfo;
+(BOOL)IsUserLogged;
+(BOOL)GetUserObj;

@end
