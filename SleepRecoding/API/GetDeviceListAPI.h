//
//  GetDeviceListAPI.h
//  SleepRecoding
//
//  Created by Havi_li on 15/4/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetDeviceListAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetDeviceListAPI*)shareInstance;
- (void)getDeviceList:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;

@end
