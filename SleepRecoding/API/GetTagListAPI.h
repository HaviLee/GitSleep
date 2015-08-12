//
//  GetTagListAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface GetTagListAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (GetTagListAPI*)shareInstance;

- (void)getTagTagWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;
@end
