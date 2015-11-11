//
//  SHGetClient.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SHGetClient.h"

@implementation SHGetClient

+ (SHGetClient*)shareInstance
{
    static SHGetClient *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[SHGetClient alloc]init];
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

- (id)requestArgument
{
    return _urlParaDic;
}

- (NSString *)requestUrl {
    return _detailUrl;
}//

- (void)loginUserWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    NSString *url = [NSString stringWithFormat:@"v1/user/UserLogin?UserIDOrigianal=%@&Password=%@",[parameter objectForKey:@"UserIDOrigianal"],[parameter objectForKey:@"Password"]];
    _detailUrl = url;
//    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)queryUserInfoWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/UserInfo";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)queryUserProductHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/UserDeviceList";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)getGloablParameter:(NSDictionary *)parameter
{
    _detailUrl = @"v1/app/GlobalParameter";
    _urlParaDic = parameter;
    _urlHeaderDic = nil;
}

- (void)querySensorInfoWith:(NSDictionary *)header andPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/app/SensorInfo";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)userProductCode:(NSDictionary *)header andPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/RegisterUserDevice";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)querySensorDataToday:(NSDictionary *)header andPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/app/SensorDataToday";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

- (void)queryAlarm:(NSDictionary *)header andPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/app/AlarmInfo";
    _urlParaDic = parameter;
    _urlHeaderDic = header;

}

- (NSInteger)cacheTimeInSeconds {
    return 0 * 60 * 24;
}
@end
