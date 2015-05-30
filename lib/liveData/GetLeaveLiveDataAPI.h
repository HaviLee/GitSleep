//
//  GetLeaveLiveDataAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/5/9.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetLeaveLiveDataAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
}

+ (GetLeaveLiveDataAPI*)shareInstance;

- (void)getLeaveLiveData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL;
@end
