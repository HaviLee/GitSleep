//
//  WeiBoLogoutAPI.h
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^WeiBoLogoutFinishedBlock)(NSURLResponse *response,NSData *data);
typedef void (^WeiBonLogoutFailedBlock)(NSURLResponse *response,NSError *error);
@interface WeiBoLogoutAPI : NSObject
+(NSURLRequest*)weiBoLogoutWithTocken:(NSString*)tocken
                      parameters:(NSDictionary*)parameters
                        finished:(WeiBoLogoutFinishedBlock)finished
                          failed:(WeiBonLogoutFailedBlock)failed;
@end
