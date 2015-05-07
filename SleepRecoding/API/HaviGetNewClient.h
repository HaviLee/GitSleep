//
//  HaviGetNewClient.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface HaviGetNewClient : YTKRequest
//old
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (HaviGetNewClient*)shareInstance;
- (void)querySensorDataOld:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
