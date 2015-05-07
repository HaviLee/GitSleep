//
//  GetSleepReport.h
//  SleepRecoding
//
//  Created by Havi on 15/4/20.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetSleepReport : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetSleepReport*)shareInstance;
- (void)querySleepReport:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
