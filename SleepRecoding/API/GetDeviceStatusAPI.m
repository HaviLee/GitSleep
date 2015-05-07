//
//  GetDeviceStatusAPI.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetDeviceStatusAPI.h"

@implementation GetDeviceStatusAPI
+ (GetDeviceStatusAPI*)shareInstance
{
    static GetDeviceStatusAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetDeviceStatusAPI alloc]init];
    });
    return _shClient;
}
//重写父类；

//1，请求方法：
- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodGet;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    return _urlHeaderDic;
}

- (NSString *)requestUrl {
    return _detailUrl;
}//

- (void)getActiveDeviceUUID:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}

@end
