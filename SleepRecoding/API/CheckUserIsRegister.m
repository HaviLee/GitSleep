//
//  CheckUserIsRegister.m
//  SleepRecoding
//
//  Created by Havi on 15/8/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CheckUserIsRegister.h"

@implementation CheckUserIsRegister
+ (CheckUserIsRegister*)shareInstance
{
    static CheckUserIsRegister *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[CheckUserIsRegister alloc]init];
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

- (void)checkUserIsRegister:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl =@"v1/user/UserInfo";
//    [NSString stringWithFormat:@"v1/user/UserInfo?UserID=%@",[parameter objectForKey:@"UserID"]];
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}
@end
