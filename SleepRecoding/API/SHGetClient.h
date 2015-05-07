//
//  SHGetClient.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface SHGetClient : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

//- (void)继承的子类要做的1，header 2，参数，3，url
+ (SHGetClient*)shareInstance;

- (void)loginUserWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;

- (void)queryUserInfoWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;

- (void)queryUserProductHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;

- (void)getGloablParameter:(NSDictionary *)parameter;

- (void)querySensorInfoWith:(NSDictionary *)header andPara:(NSDictionary *)parameter;
//用户关联产品码
- (void)userProductCode:(NSDictionary *)header andPara:(NSDictionary *)parameter;
//读取传感器当日数据
- (void)querySensorDataToday:(NSDictionary *)header andPara:(NSDictionary *)parameter;
//old
- (void)querySensorDataOld:(NSDictionary *)header andPara:(NSDictionary *)parameter;
//警告
- (void)queryAlarm:(NSDictionary *)header andPara:(NSDictionary *)parameter;
//获取图片
- (void)downloadImage:(NSDictionary *)header andImageId:(NSString *)imageId;
@end
