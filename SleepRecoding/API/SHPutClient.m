//
//  SHPutClient.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SHPutClient.h"

@implementation SHPutClient
+ (SHPutClient*)shareInstance
{
    static SHPutClient *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[SHPutClient alloc]init];
    });
    return _shClient;
}
//重写父类；

//1，请求方法：
- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPut;
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

- (void)modifyUserInfo:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/ModifyUserInfo";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}
@end
