//
//  GetExceptionAPI.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"


@interface GetExceptionAPI : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetExceptionAPI*)shareInstance;
- (void)getException:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;

@end
