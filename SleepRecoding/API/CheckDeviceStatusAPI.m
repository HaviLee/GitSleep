//
//  CheckDeviceStatusAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CheckDeviceStatusAPI.h"

@implementation CheckDeviceStatusAPI
+ (CheckDeviceStatusAPI*)shareInstance
{
    static CheckDeviceStatusAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[CheckDeviceStatusAPI alloc]init];
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

- (void)checkStatus:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
