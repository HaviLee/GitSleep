//
//  GetBreathLiveDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/5/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetBreathLiveDataAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetBreathLiveDataAPI*)shareInstance;

- (void)getBreathLiveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
