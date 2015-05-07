//
//  SHClient.h
//  YTKNetworkDemo
//
//  Created by Havi_li on 15/1/13.
//  Copyright (c) 2015年 yuantiku.com. All rights reserved.
//

#import "YTKRequest.h"

@interface SHPostClient : YTKRequest
{
    NSString *_detailUrl;
    NSDictionary *_urlHeaderDic;
    NSDictionary *_urlParaDic;
}

//- (void)继承的子类要做的1，header 2，参数，3，url
+ (SHPostClient*)shareInstance;

- (void)addNewUserWithHeader:(NSDictionary *)header andWithPara:(NSDictionary *)parameter;

@end
