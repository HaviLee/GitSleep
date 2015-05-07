//
//  SHPutClient.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/16.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface SHPutClient : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

//- (void)继承的子类要做的1，header 2，参数，3，url
+ (SHPutClient*)shareInstance;

- (void)modifyUserInfo:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;
@end
