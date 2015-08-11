//
//  ThirdLoginAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/8/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "ThirdRegisterAPI.h"

@implementation ThirdRegisterAPI
+ (ThirdRegisterAPI*)shareInstance
{
    static ThirdRegisterAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[ThirdRegisterAPI alloc]init];
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

- (void)loginThirdUserWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/UserRegister";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}
@end
