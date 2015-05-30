//
//  GetHeartLiveDataAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/5/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetHeartLiveDataAPI.h"

@implementation GetHeartLiveDataAPI

+ (GetHeartLiveDataAPI*)shareInstance
{
    static GetHeartLiveDataAPI *_shClientLive;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClientLive = [[GetHeartLiveDataAPI alloc]init];
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

- (void)getHeartLiveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL
{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
