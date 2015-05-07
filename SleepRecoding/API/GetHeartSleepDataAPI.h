//
//  GetHeartSleepDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/4/30.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"

@interface GetHeartSleepDataAPI : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetHeartSleepDataAPI*)shareInstance;
- (void)getHeartSleepData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
