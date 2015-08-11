//
//  CheckUserIsRegister.h
//  SleepRecoding
//
//  Created by Havi on 15/8/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "YTKRequest.h"

@interface CheckUserIsRegister : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

+ (CheckUserIsRegister*)shareInstance;

- (void)checkUserIsRegister:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;
@end
