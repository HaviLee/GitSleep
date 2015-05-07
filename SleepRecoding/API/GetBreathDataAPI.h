//
//  GetBreathDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"

@interface GetBreathDataAPI : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetBreathDataAPI*)shareInstance;
- (void)getBreathData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;

//- (id)cacheJson;
@end
