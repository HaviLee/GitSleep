//
//  GetUserDefaultDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/4/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"

@interface GetUserDefaultDataAPI : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetUserDefaultDataAPI*)shareInstance;
- (void)getUserDefaultData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
