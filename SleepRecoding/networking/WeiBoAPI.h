//
//  WeiBoAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^WeiBoFinishedBlock)(NSURLResponse *response,NSData *data);
typedef void (^WeiBonFailedBlock)(NSURLResponse *response,NSError *error);
@interface WeiBoAPI : NSObject
+(NSURLRequest*)getWeiBoInfoWith:(NSString*)wxCode
                       parameters:(NSDictionary*)parameters
                         finished:(WeiBoFinishedBlock)finished
                           failed:(WeiBonFailedBlock)failed;
@end
