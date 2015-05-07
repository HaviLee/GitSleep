//
//  QueryDataCacheAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/5/5.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface QueryDataCacheAPI : YTKRequest

- (id)cacheJson;
- (id)getCacheJsonWithDate:(NSString *)queryDate;

@end
