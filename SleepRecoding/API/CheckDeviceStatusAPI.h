//
//  CheckDeviceStatusAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface CheckDeviceStatusAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (CheckDeviceStatusAPI*)shareInstance;
- (void)checkStatus:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
