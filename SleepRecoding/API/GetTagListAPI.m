//
//  GetTagListAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetTagListAPI.h"

@implementation GetTagListAPI
+ (GetTagListAPI*)shareInstance
{
    static GetTagListAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetTagListAPI alloc]init];
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

- (void)getTagTagWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    NSRange range = [[parameter objectForKey:@"url"] rangeOfString:@"?"];
    _detailUrl = [NSString stringWithFormat:@"v1/user/UserTags?%@",[[parameter objectForKey:@"url"] substringFromIndex:range.length+range.location]];
    _urlParaDic = parameter;
    HaviLog(@"请求url%@",_detailUrl);
    _urlHeaderDic = header;
}
@end
