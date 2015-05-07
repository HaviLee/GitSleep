//
//  ChangeUUIDAPI.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/23.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ChangeUUIDAPI.h"

@implementation ChangeUUIDAPI
+ (ChangeUUIDAPI*)shareInstance
{
    static ChangeUUIDAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[ChangeUUIDAPI alloc]init];
    });
    return _shClient;
}
//重写父类；

//1，请求方法：
- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPost;
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

- (void)changeUUID:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/ActivateUserDevice";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}
@end
