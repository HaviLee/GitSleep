//
//  HaviGetNewClient.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "HaviGetNewClient.h"

@implementation HaviGetNewClient

+ (HaviGetNewClient*)shareInstance
{
    static HaviGetNewClient *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[HaviGetNewClient alloc]init];
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

- (void)querySensorDataOld:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}

@end
