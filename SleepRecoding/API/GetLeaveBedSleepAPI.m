//
//  GetLeaveBedSleepAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/4/30.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetLeaveBedSleepAPI.h"

@implementation GetLeaveBedSleepAPI
+ (GetLeaveBedSleepAPI*)shareInstance
{
    static GetLeaveBedSleepAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetLeaveBedSleepAPI alloc]init];
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

- (void)getLeaveSleepData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
