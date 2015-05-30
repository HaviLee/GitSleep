//
//  GetHeartLiveDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/5/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetHeartLiveDataAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetHeartLiveDataAPI*)shareInstance;

- (void)getHeartLiveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
