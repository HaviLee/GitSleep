//
//  GetSleepReport.m
//  SleepRecoding
//
//  Created by Havi on 15/4/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetSleepReport.h"

@implementation GetSleepReport
+ (GetSleepReport*)shareInstance
{
    static GetSleepReport *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetSleepReport alloc]init];
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

- (void)querySleepReport:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
@end
