//
//  GetUserDefaultDataAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/4/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetUserDefaultDataAPI.h"

@implementation GetUserDefaultDataAPI
+ (GetUserDefaultDataAPI*)shareInstance
{
    static GetUserDefaultDataAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetUserDefaultDataAPI alloc]init];
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

- (void)getUserDefaultData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
