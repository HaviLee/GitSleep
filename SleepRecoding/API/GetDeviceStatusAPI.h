//
//  GetDeviceStatusAPI.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetDeviceStatusAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetDeviceStatusAPI*)shareInstance;
- (void)getActiveDeviceUUID:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
