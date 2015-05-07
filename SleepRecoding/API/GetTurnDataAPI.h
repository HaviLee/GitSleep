//
//  GetTurnDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"

@interface GetTurnDataAPI : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetTurnDataAPI*)shareInstance;
- (void)getTurnData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
