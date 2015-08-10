//
//  WeiXinAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTRequestCenter.h"

typedef void (^WeiXinFinishedBlock)(NSURLResponse *response,NSData *data);
typedef void (^WeiXinFailedBlock)(NSURLResponse *response,NSError *error);

@interface WeiXinAPI : NSObject
+(NSURLRequest*)getWeiXinInfoWith:(NSString*)wxCode
                parameters:(NSDictionary*)parameters
                  finished:(WeiXinFinishedBlock)finished
                    failed:(WeiXinFailedBlock)failed;
@end
