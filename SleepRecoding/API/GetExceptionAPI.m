//
//  GetExceptionAPI.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetExceptionAPI.h"

@implementation GetExceptionAPI
+ (GetExceptionAPI*)shareInstance
{
    static GetExceptionAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetExceptionAPI alloc]init];
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

- (void)getException:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
