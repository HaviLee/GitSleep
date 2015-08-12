//
//  UploadTagAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface UploadTagAPI : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (UploadTagAPI*)shareInstance;

- (void)uploadTagWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;
@end
