//
//  QHConfiguredObj.m
//  IMFiveApp
//
//  Created by chen on 14-8-30.
//  Copyright (c) 2014年 chen. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "QHConfiguredObj.h"

@implementation QHConfiguredObj

+ (QHConfiguredObj *)defaultConfigure
{
    static QHConfiguredObj *configureObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        configureObj = [[QHConfiguredObj alloc] init];
    });
    
    return configureObj;
}

- (id)init
{
    self = [super init];
    
    _nThemeIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:kTHEME_TAG] integerValue];
    _themefold = [[NSUserDefaults standardUserDefaults] objectForKey:kTHEMEFOLD_TAG];
    
    return self;
}

- (void)setNThemeIndex:(int)nThemeIndex
{
    _nThemeIndex = nThemeIndex;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nThemeIndex] forKey:kTHEME_TAG];
}

- (void)setThemefold:(NSString *)themefold
{
    _themefold = themefold;
    [[NSUserDefaults standardUserDefaults] setObject:_themefold forKey:kTHEMEFOLD_TAG];
}

@end
