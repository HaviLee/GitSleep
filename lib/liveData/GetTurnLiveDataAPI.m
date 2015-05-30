//
//  GetTurnLiveDataAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/5/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetTurnLiveDataAPI.h"

@implementation GetTurnLiveDataAPI
+ (GetTurnLiveDataAPI*)shareInstance
{
    static GetTurnLiveDataAPI *_shClientLive;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClientLive = [[GetTurnLiveDataAPI alloc]init];
    });
    return _shClientLive;
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

- (void)getTurnLiveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
