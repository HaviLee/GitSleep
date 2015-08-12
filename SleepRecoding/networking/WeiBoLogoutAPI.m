//
//  WeiBoLogoutAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/8/12.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "WeiBoLogoutAPI.h"

@implementation WeiBoLogoutAPI
+(NSURLRequest*)weiBoLogoutWithTocken:(NSString*)tocken
                      parameters:(NSDictionary*)parameters
                        finished:(WeiBoLogoutFinishedBlock)finished
                          failed:(WeiBonLogoutFailedBlock)failed
{
    NSString *tockenUrl = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/revokeoauth2?access_token=%@",tocken];
    [WTRequestCenter getWithURL:tockenUrl parameters:nil finished:finished failed:failed];
    //    [WTRequestCenter getWithURL:tockenUrl parameters:nil finished:^(NSURLResponse *response, NSData *data) {
    //        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //        HaviLog(@"微博是%@",obj);
    //
    //    } failed:^(NSURLResponse *response, NSError *error) {
    //
    //    }];
    return nil;
    
}
@end
