//
//  GetDeviceListAPI.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetDeviceListAPI.h"

@implementation GetDeviceListAPI
+ (GetDeviceListAPI*)shareInstance
{
    static GetDeviceListAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetDeviceListAPI alloc]init];
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

- (void)getDeviceList:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}

@end
