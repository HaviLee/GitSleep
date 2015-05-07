//
//  SHClient.m
//  YTKNetworkDemo
//
//  Created by Havi_li on 15/1/13.
//  Copyright (c) 2015年 yuantiku.com. All rights reserved.
//

#import "SHPostClient.h"

@implementation SHPostClient
//
+ (SHPostClient*)shareInstance
{
    static SHPostClient *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[SHPostClient alloc]init];
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

- (void)addNewUserWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/UserRegister";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

@end
