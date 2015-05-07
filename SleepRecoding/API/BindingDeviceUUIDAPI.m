//
//  BindingDeviceUUIDAPI.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/23.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BindingDeviceUUIDAPI.h"

@implementation BindingDeviceUUIDAPI
+ (BindingDeviceUUIDAPI*)shareInstance
{
    static BindingDeviceUUIDAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[BindingDeviceUUIDAPI alloc]init];
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

- (void)bindingDeviceUUID:(NSDictionary *)header andWithPara:(NSDictionary *)parameter
{
    _detailUrl = @"v1/user/RegisterUserDevice";
    _urlParaDic = parameter;
    _urlHeaderDic = header;
}

@end
