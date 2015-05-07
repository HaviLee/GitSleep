//
//  GetLeaveDataAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetLeaveDataAPI.h"

@implementation GetLeaveDataAPI
+ (GetLeaveDataAPI*)shareInstance
{
    static GetLeaveDataAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetLeaveDataAPI alloc]init];
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

- (void)getLeaveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
