//
//  GetSuggestionList.h
//  SleepRecoding
//
//  Created by Havi on 15/4/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

//#import "YTKRequest.h"
#import "QueryDataCacheAPI.h"

@interface GetSuggestionList : QueryDataCacheAPI
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetSuggestionList*)shareInstance;
- (void)getSuggestionList:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;

@end
